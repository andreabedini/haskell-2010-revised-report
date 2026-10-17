-- Extensions: Strict
-- Class: M
-- The extension makes let bindings strict, so the unused binding of
-- undefined is evaluated.
module Main where

main :: IO ()
main = print (let x = undefined :: Int in (1 :: Int))
