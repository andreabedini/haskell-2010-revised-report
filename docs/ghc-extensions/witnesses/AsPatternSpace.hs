-- Extensions: TypeApplications
-- Class: D
-- By the report @ is a reserved operator that forms an as-pattern, and white
-- space may surround it as it may surround any lexeme. The program prints 3.
-- GHC reads an @ surrounded by white space as an infix operator, with or
-- without the extension.
module Main where

g :: Maybe Int -> Int
g x @ (Just y) = y
g _ = 0

main :: IO ()
main = print (g (Just 3))
