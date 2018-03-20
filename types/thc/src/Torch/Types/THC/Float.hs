{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
module Torch.Types.THC.Float
  ( CTensor
  , CState
  , CStorage
  , CReal
  , CAccReal
  , HsAccReal
  , HsReal
  , hs2cReal
  , hs2cAccReal
  , c2hsReal
  , c2hsAccReal
  , Tensor(..)
  , DynTensor(..)
  , Storage(..)
  , asStorage
  , asDyn
  , asStatic
  ) where

import Foreign.C.Types
import Foreign (ForeignPtr)
import GHC.TypeLits (Nat)
import Torch.Types.THC

type CTensor = CTHCudaFloatTensor
type CState = ()
type CStorage = CTHCFloatStorage
type CReal = CFloat
type CAccReal = CDouble
type HsReal = Float
type HsAccReal = Double

hs2cReal :: HsReal -> CReal
hs2cReal = realToFrac

hs2cAccReal :: HsAccReal -> CAccReal
hs2cAccReal = realToFrac

c2hsReal :: CReal -> HsReal
c2hsReal = realToFrac

c2hsAccReal :: CAccReal -> HsAccReal
c2hsAccReal = realToFrac

newtype Storage = Storage { storage :: ForeignPtr CStorage }
  deriving (Eq, Show)

newtype DynTensor = DynTensor { tensor :: ForeignPtr CTensor }
  deriving (Show, Eq)

newtype Tensor (ds :: [Nat]) = Tensor { dynamic :: DynTensor }
  deriving (Show, Eq)

asStorage = Storage
asDyn = DynTensor
asStatic = Tensor

