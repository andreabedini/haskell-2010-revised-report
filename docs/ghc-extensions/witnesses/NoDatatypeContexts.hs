-- Extensions: NoDatatypeContexts GHC2021 GHC2024
-- Class: R
module Main where

data Eq a => S a = S a

main :: IO ()
main = case S 'x' of S c -> print c
