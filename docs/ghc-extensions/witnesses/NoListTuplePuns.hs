-- Extensions: NoListTuplePuns
-- Class: R
module Main where

f :: [Int] -> (Int, Int)
f xs = (length xs, sum xs)

main :: IO ()
main = print (f [1, 2])
