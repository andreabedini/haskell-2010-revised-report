-- Extensions: MagicHash
-- Class: R
-- In Haskell 2010 x#y is the operator # applied to x and y.
module Main where

(#) :: Int -> Int -> Int
a # b = a + b

main :: IO ()
main = print (x#y)
  where x = 1
        y = 2
