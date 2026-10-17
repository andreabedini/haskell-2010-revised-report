-- Extensions: PostfixOperators
-- Class: M
-- Haskell 2010 translates the section (1 `op`) to \y -> 1 `op` y, a
-- value in weak head normal form; the extension translates it to op 1.
module Main where

op :: Int -> Int -> Int
op = undefined

main :: IO ()
main = putStrLn (((1 `op`) :: Int -> Int) `seq` "lambda")
