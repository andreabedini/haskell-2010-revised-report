-- Extensions: TemplateHaskellQuotes TemplateHaskell
-- Class: R
-- In Haskell 2010 [e|e<-xs] is a list comprehension.
module Main where

main :: IO ()
main = print [e|e<-[1, 2 :: Int]]
