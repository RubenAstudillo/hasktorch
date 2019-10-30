{-# LANGUAGE DataKinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE GADTs #-}

module Main where

import           Prelude                 hiding ( tanh )
import           Control.Exception.Safe         ( try
                                                , SomeException(..)
                                                )
import           Control.Monad                  ( foldM
                                                , when
                                                )
import           Data.Proxy
import           Foreign.ForeignPtr
import           GHC.Generics
import           GHC.TypeLits
import           GHC.TypeLits.Extra
import           System.Environment
import           System.IO.Unsafe
import           System.Random

import qualified ATen.Cast                     as ATen
import qualified ATen.Class                    as ATen
import qualified ATen.Type                     as ATen
import qualified ATen.Managed.Type.Tensor      as ATen
import qualified ATen.Managed.Type.Context     as ATen
import           Torch.Typed
import           Torch.Typed.Native     hiding ( linear )
import           Torch.Typed.Factories
import           Torch.Typed.NN
import qualified Torch.Autograd                as A
import qualified Torch.NN                      as A
import qualified Torch.DType                   as D
import qualified Torch.Tensor                  as D
import qualified Torch.Functions               as D
import qualified Torch.TensorFactories         as D
import qualified Image                         as I
import qualified Monitoring
import           Common

--------------------------------------------------------------------------------
-- MLP for MNIST
--------------------------------------------------------------------------------

data MLPSpec (dtype :: D.DType)
             (inputFeatures :: Nat) (outputFeatures :: Nat)
             (hiddenFeatures0 :: Nat) (hiddenFeatures1 :: Nat)
 where
  MLPSpec
    :: forall dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1
     . { mlpDropoutProbSpec :: Double }
    -> MLPSpec dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1
 deriving (Show, Eq)

data MLP (dtype :: D.DType)
         (inputFeatures :: Nat) (outputFeatures :: Nat)
         (hiddenFeatures0 :: Nat) (hiddenFeatures1 :: Nat)
 where
  MLP
    :: forall dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1
     . { mlpLayer0 :: Linear dtype inputFeatures hiddenFeatures0
       , mlpLayer1 :: Linear dtype hiddenFeatures0 hiddenFeatures1
       , mlpLayer2 :: Linear dtype hiddenFeatures1 outputFeatures
       , mlpDropout :: Dropout
       }
    -> MLP dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1
 deriving (Show, Generic)

mlp
  :: MLP dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1
  -> Bool
  -> Tensor dtype '[batchSize, inputFeatures]
  -> IO (Tensor dtype '[batchSize, outputFeatures])
mlp MLP {..} train input =
  return
    .   linear mlpLayer2
    =<< Torch.Typed.NN.dropout mlpDropout train
    .   tanh
    .   linear mlpLayer1
    =<< Torch.Typed.NN.dropout mlpDropout train
    .   tanh
    .   linear mlpLayer0
    =<< pure input

instance A.Parameterized (MLP dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1)

instance ( KnownDType dtype
         , KnownNat inputFeatures
         , KnownNat outputFeatures
         , KnownNat hiddenFeatures0
         , KnownNat hiddenFeatures1
         )
  => A.Randomizable (MLPSpec dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1)
                    (MLP     dtype inputFeatures outputFeatures hiddenFeatures0 hiddenFeatures1)
 where
  sample MLPSpec {..} =
    MLP
      <$> A.sample LinearSpec
      <*> A.sample LinearSpec
      <*> A.sample LinearSpec
      <*> A.sample (DropoutSpec mlpDropoutProbSpec)

type BatchSize = 512
type TestBatchSize = 8192
type HiddenFeatures0 = 512
type HiddenFeatures1 = 256

main = do
  backend' <- try (getEnv "BACKEND") :: IO (Either SomeException String)
  let backend = case backend' of
        Right "CUDA" -> "CUDA"
        _            -> "CPU"
      (numIters, printEvery) = (1000000, 250)
      dropoutProb            = 0.5
  (trainingData, testData) <- I.initMnist
  ATen.manual_seed_L 123
  init                     <- A.sample
    (MLPSpec @D.Float @I.DataDim @I.ClassDim @HiddenFeatures0 @HiddenFeatures1
      dropoutProb
    )
  init' <- A.replaceParameters init <$> traverse
    (A.makeIndependent . toBackend backend . A.toDependent)
    (A.flattenParameters init)
  (trained, _, _) <-
    foldLoop (init', randomIndexes (I.length trainingData), []) numIters
      $ \(state, idxs, metrics) i -> do
          let (indexes, nextIndexes) =
                (take (natValI @I.DataDim) idxs, drop (natValI @I.DataDim) idxs)
          (trainingLoss, _) <- computeLossAndErrorRate @BatchSize backend
                                                                  state
                                                                  True
                                                                  indexes
                                                                  trainingData
          let flat_parameters = A.flattenParameters state
          let gradients       = A.grad (toDynamic trainingLoss) flat_parameters

          metrics' <-
            if (i `mod` printEvery == 0) then do
              (testLoss, testError) <-
                 withTestSize (I.length testData) $ \(Proxy :: Proxy testSize) ->
                   computeLossAndErrorRate @(Min TestBatchSize testSize)
                     backend
                     state
                     False
                     (randomIndexes (I.length testData))
                     testData
              let metric = (i, Monitoring.Metric trainingLoss testLoss testError)
                  metrics' = metric:metrics
              Monitoring.printLosses metric
              Monitoring.plotLosses "loss.html" metrics'
              return metrics'
            else
              return metrics

          new_flat_parameters <- mapM A.makeIndependent
            $ A.sgd 1e-01 flat_parameters gradients
          return (A.replaceParameters state new_flat_parameters,
                  nextIndexes,
                  metrics')
  print trained
 where
  computeLossAndErrorRate
    :: forall n
     . (KnownNat n)
    => String
    -> MLP 'D.Float I.DataDim I.ClassDim HiddenFeatures0 HiddenFeatures1
    -> Bool
    -> [Int]
    -> I.MnistData
    -> IO (Tensor 'D.Float '[], Tensor 'D.Float '[])
  computeLossAndErrorRate backend state train indexes data' = do
    let input  = toBackend backend $ I.getImages @n data' indexes
        target = toBackend backend $ I.getLabels @n data' indexes
    result <- mlp state train input
    return (crossEntropyLoss backend result target, errorRate result target)
