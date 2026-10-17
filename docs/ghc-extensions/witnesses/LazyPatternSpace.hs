-- Extensions: TypeOperators
-- Class: D
-- By the report ~ is a reserved operator that marks an irrefutable pattern,
-- and white space may follow it as it may follow any lexeme. The program
-- prints 1, because the pattern is never matched. GHC reads a ~ followed by
-- white space as an infix operator, with or without the extension.
module Main where

f :: (Int, Int) -> Int
f ~ (a, _) = 1

main :: IO ()
main = print (f undefined)
