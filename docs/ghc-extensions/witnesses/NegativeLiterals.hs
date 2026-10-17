-- Extensions: NegativeLiterals
-- Class: M
-- Haskell 2010 reads -1 as negate (fromInteger 1); the extension reads it
-- as fromInteger (-1).  The two differ for this Num instance.
module Main where

newtype N = N Integer deriving (Eq, Show)

instance Num N where
  N a + N b = N (a + b)
  N a * N b = N (a * b)
  abs (N a) = N (abs a)
  signum (N a) = N (signum a)
  fromInteger = N
  negate (N a) = N (1000 + a)

main :: IO ()
main = print (-1 :: N)
