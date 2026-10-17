-- Extensions: BinaryLiterals
-- Class: M
-- Without the extension 0b101 lexes as the literal 0 applied to the
-- variable b101, so the program prints 0; with it, the literal is 5.
module Main where
import NumFunctions ()

b101 :: Integer
b101 = 0

main :: IO ()
main = print (0b101 :: Integer)
