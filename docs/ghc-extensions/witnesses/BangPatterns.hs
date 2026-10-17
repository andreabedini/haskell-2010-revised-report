-- Extensions: BangPatterns
-- Class: D
-- By the report this defines the operator !, but GHC reads a prefix !
-- as a bang pattern even when BangPatterns is off.
module Main where

(!) :: Int -> Int -> Int
a !b = a + b

main :: IO ()
main = print (1 ! 2)
