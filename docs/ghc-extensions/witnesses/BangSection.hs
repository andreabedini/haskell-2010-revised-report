-- Extensions: BangPatterns
-- Class: D
-- By the report ! is an ordinary operator symbol, so (!1) is a right section.
-- The program prints [2,4]. GHC reads a ! with nothing between it and the
-- next token as a strictness annotation, even in an expression, with or
-- without the extension.
module Main where

(!) :: [a] -> Int -> a
xs ! n = xs !! n

main :: IO ()
main = print (map (!1) [[1, 2], [3, 4 :: Int]])
