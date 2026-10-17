-- Extensions: TransformListComp
-- Class: R
-- using, by and group are ordinary identifiers in Haskell 2010.
module Main where

main :: IO ()
main = print ( [using | using <- [1, 2 :: Int]]
             , [by | by <- [3 :: Int]]
             , [group | group <- [4 :: Int]] )
