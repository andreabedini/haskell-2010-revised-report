-- Extensions: PatternSynonyms
-- Class: R
-- pattern is an ordinary identifier in Haskell 2010.
module Main where

pattern :: Int
pattern = 1

main :: IO ()
main = print pattern
