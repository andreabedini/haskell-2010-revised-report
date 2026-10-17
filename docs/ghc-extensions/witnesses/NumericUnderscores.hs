-- Extensions: NumericUnderscores
-- Class: D
-- By the report 1_000 lexes as the literal 1 applied to the variable
-- _000, so the program prints 1.  GHC rejects 1_000 when the extension is
-- off, and reads it as 1000 when it is on.
module Main where
import NumFunctions ()

_000 :: Integer
_000 = 0

main :: IO ()
main = print (1_000 :: Integer)
