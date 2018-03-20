{-# LANGUAGE ForeignFunctionInterface #-}
module Torch.FFI.THC.Byte.TensorMathReduce where

import Foreign
import Foreign.C.Types
import Torch.Types.THC
import Data.Word
import Data.Int

-- | c_sum :  state self src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h THCByteTensor_sum"
  c_sum :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ()

-- | c_prod :  state self src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h THCByteTensor_prod"
  c_prod :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ()

-- | c_sumall :  state self -> accreal
foreign import ccall "THCTensorMathReduce.h THCByteTensor_sumall"
  c_sumall :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CLong

-- | c_prodall :  state self -> accreal
foreign import ccall "THCTensorMathReduce.h THCByteTensor_prodall"
  c_prodall :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CLong

-- | c_min :  state values indices src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h THCByteTensor_min"
  c_min :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaLongTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ()

-- | c_max :  state values indices src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h THCByteTensor_max"
  c_max :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaLongTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ()

-- | c_minall :  state self -> real
foreign import ccall "THCTensorMathReduce.h THCByteTensor_minall"
  c_minall :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CUChar

-- | c_maxall :  state self -> real
foreign import ccall "THCTensorMathReduce.h THCByteTensor_maxall"
  c_maxall :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CUChar

-- | c_medianall :  state self -> real
foreign import ccall "THCTensorMathReduce.h THCByteTensor_medianall"
  c_medianall :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CUChar

-- | c_median :  state values indices src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h THCByteTensor_median"
  c_median :: Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaLongTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ()

-- | p_sum : Pointer to function : state self src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_sum"
  p_sum :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ())

-- | p_prod : Pointer to function : state self src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_prod"
  p_prod :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ())

-- | p_sumall : Pointer to function : state self -> accreal
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_sumall"
  p_sumall :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CLong)

-- | p_prodall : Pointer to function : state self -> accreal
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_prodall"
  p_prodall :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CLong)

-- | p_min : Pointer to function : state values indices src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_min"
  p_min :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaLongTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ())

-- | p_max : Pointer to function : state values indices src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_max"
  p_max :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaLongTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ())

-- | p_minall : Pointer to function : state self -> real
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_minall"
  p_minall :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CUChar)

-- | p_maxall : Pointer to function : state self -> real
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_maxall"
  p_maxall :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CUChar)

-- | p_medianall : Pointer to function : state self -> real
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_medianall"
  p_medianall :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> IO CUChar)

-- | p_median : Pointer to function : state values indices src dim keepdim -> void
foreign import ccall "THCTensorMathReduce.h &THCByteTensor_median"
  p_median :: FunPtr (Ptr C'THCState -> Ptr C'THCudaByteTensor -> Ptr C'THCudaLongTensor -> Ptr C'THCudaByteTensor -> CInt -> CInt -> IO ())