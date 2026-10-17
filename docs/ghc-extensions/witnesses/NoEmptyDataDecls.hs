-- Extensions: NoEmptyDataDecls Haskell98
-- Class: R
module Main where

data V

main :: IO ()
main = print (1 :: Int)
