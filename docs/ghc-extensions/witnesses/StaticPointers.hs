-- Extensions: StaticPointers
-- Class: R
-- static is an ordinary identifier in Haskell 2010.
module Main where

static :: Int
static = 1

main :: IO ()
main = print (static + 1)
