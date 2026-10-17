-- Extensions: ExtendedLiterals
-- Class: R
-- In Haskell 2010 1#Int8 is the operator # applied to 1 and Int8.
module Main where

data T = Int8 deriving Show

(#) :: Int -> T -> (Int, T)
n # t = (n, t)

main :: IO ()
main = print (1#Int8)
