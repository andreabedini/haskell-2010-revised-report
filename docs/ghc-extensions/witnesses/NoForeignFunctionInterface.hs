-- Extensions: NoForeignFunctionInterface
-- Class: R
module Main where

foreign import ccall "math.h sin" c_sin :: Double -> Double

main :: IO ()
main = print (c_sin 0)
