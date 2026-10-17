-- Extensions: ImplicitParams
-- Class: R
-- In Haskell 2010 1 ?x is the operator ? applied to 1 and x.
module Main where

(?) :: Int -> Int -> Int
a ? b = a + b

main :: IO ()
main = print (1 ?x)
  where x = 2
