-- Extensions: MultilineStrings
-- Class: R
-- In Haskell 2010 """x" is the empty string followed by the string "x".
module Main where

g :: String -> String -> String
g a b = a ++ b

main :: IO ()
main = putStrLn (g """x")
