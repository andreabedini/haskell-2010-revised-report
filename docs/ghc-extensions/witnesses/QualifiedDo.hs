-- Extensions: QualifiedDo
-- Class: D
-- By the report M.do lexes as the constructor M composed with a do block,
-- so the program prints M 3.  GHC rejects M.do when the extension is off.
module Main where

data T = M Int deriving Show

main :: IO ()
main = print ((M.do id) 3)
