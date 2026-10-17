-- Extensions: OverloadedRecordDot
-- Class: R
-- In Haskell 2010 inc.dbl is the composition inc . dbl.
module Main where

inc, dbl :: Int -> Int
inc = (+ 1)
dbl = (* 2)

main :: IO ()
main = print ((inc.dbl) 3)
