-- Extensions: LexicalNegation
-- Class: M
-- Haskell 2010 reads (- 1) as the number negate 1, here used at a function
-- type; the extension reads it as the section \x -> x - 1.
module Main where
import NumFunctions ()

main :: IO ()
main = print ((- 1) (5 :: Integer) :: Integer)
