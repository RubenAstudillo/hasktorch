{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}

module Torch.GraduallyTyped.NN.Dropout where

import Data.Kind (Type)
import GHC.Generics (Generic)
import Torch.GraduallyTyped.NN.Class (HasForward (..), HasInitialize (..))
import Torch.GraduallyTyped.Random (Generator)
import Torch.GraduallyTyped.Scalar (Scalar)
import Torch.GraduallyTyped.Tensor.Type (Tensor)

-- | Given a random generator, randomly zeroes some of the elements of
-- the input tensor with probability 'p' using samples from a Bernoulli distribution.
-- Each channel will be zeroed out independently on every 'forward' call.
data Dropout (p :: Type) where
  Dropout ::
    forall p.
    -- | probability of an element to be zeroed
    p ->
    Dropout p
  deriving (Generic)

instance (Scalar p) => HasInitialize (Dropout p) where
  type InitializeF (Dropout p) = p -> Dropout p
  initialize p = Dropout p

instance
  (Scalar p) =>
  HasForward
    (Dropout p)
    (Tensor requiresGradient layout device dataType shape)
  where
  type
    ForwardOutput
      (Dropout p)
      (Tensor requiresGradient layout device dataType shape) =
      Generator device -> (Tensor requiresGradient layout device dataType shape, Generator device)
  forward = undefined