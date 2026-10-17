-- Extensions: AlternativeLayoutRule
-- Class: R
-- The implicit block opened by let is closed by the parse-error(t) rule
-- of Haskell 2010, which the alternative layout rule does not implement.
module Main where

f :: Int -> Int
f x | let y = x * 2 = y
    | otherwise = 0

main :: IO ()
main = print (f 1)
