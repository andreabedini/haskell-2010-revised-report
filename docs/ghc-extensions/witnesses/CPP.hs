-- Extensions: CPP
-- Class: R
-- The C preprocessor joins a line ending in a backslash to the next one,
-- so the operator \\ followed by a line break becomes a lambda.
module Main where
import Data.List ((\\))

main :: IO ()
main = print ([1, 2, 3 :: Int] \\
  [2])
