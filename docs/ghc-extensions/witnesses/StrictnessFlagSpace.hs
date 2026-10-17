-- Extensions: BangPatterns StrictData
-- Class: D
-- By the report ! in a constructor declaration is a strictness flag, and
-- white space may follow it as it may follow any lexeme. GHC reads a ! that
-- is followed by white space as an infix operator, with or without either
-- extension.
module Main where

data T = MkT ! Int

data U = MkU { field :: ! Int }

main :: IO ()
main = print (case MkT 1 of MkT n -> n + field (MkU 2))
