-- Extensions: NoMonomorphismRestriction
-- Class: M
-- Under the restriction len is monomorphic, and the use at (/) makes it a
-- Double everywhere; without it, the second use defaults to Integer.
module Main where
import Data.List (genericLength)

len = genericLength "abc"

main :: IO ()
main = print (len / 2, len)
