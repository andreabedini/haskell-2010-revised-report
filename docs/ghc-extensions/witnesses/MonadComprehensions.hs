-- Extensions: MonadComprehensions
-- Class: R
-- The comprehension's monad becomes ambiguous.
module Main where

main :: IO ()
main = print [x | x <- return (1 :: Int)]
