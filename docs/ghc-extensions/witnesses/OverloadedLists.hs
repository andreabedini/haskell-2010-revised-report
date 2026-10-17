-- Extensions: OverloadedLists
-- Class: R
-- The list literal's type becomes ambiguous.
module Main where

main :: IO ()
main = print (length [1, 2, 3 :: Int])
