-- Extensions: UnboxedTuples UnboxedSums
-- Class: R
-- In Haskell 2010 (#) is the operator # in prefix form.
module Main where

(#) :: Int -> Int -> Int
a # b = a + b

main :: IO ()
main = print ((#) 1 2)
