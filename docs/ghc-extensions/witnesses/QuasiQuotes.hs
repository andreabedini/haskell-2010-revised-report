-- Extensions: QuasiQuotes
-- Class: R
-- In Haskell 2010 [x|x<-xs] is a list comprehension.
module Main where

main :: IO ()
main = print [x|x<-[1, 2 :: Int]]
