-- Extensions: NumDecimals
-- Class: M
-- Haskell 2010 types 1e3 as Fractional, so it defaults to Double; the
-- extension types it as Num, so it defaults to Integer.
module Main where

main :: IO ()
main = print 1e3
