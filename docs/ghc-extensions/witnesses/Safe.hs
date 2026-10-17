-- Extensions: Safe
-- Class: R
-- Safe Haskell rejects imports of unsafe modules.
module Main where
import System.IO.Unsafe (unsafePerformIO)

main :: IO ()
main = print (unsafePerformIO (return (1 :: Int)))
