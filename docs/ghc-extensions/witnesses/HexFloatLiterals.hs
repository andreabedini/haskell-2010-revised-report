-- Extensions: HexFloatLiterals
-- Class: M
-- Without the extension 0x1p4 lexes as the literal 0x1 applied to the
-- variable p4, so the program prints 1.0; with it, the literal is 16.0.
module Main where
import NumFunctions ()

p4 :: Integer
p4 = 0

main :: IO ()
main = print (0x1p4 :: Double)
