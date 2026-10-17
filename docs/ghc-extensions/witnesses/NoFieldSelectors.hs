-- Extensions: NoFieldSelectors
-- Class: R
module Main where

data R = R { fld :: Int }

main :: IO ()
main = print (fld (R 1))
