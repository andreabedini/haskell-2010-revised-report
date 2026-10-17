-- Extensions: UnicodeSyntax
-- Class: R
-- In Haskell 2010 → is an ordinary operator symbol.
module Main where

(→) :: Int -> Int -> Int
a → b = a + b

main :: IO ()
main = print (1 → 2)
