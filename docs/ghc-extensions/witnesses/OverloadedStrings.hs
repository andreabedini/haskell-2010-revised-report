-- Extensions: OverloadedStrings
-- Class: R
-- The string literal's type becomes ambiguous.
module Main where

main :: IO ()
main = print (length "abc")
