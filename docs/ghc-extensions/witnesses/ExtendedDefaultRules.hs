-- Extensions: ExtendedDefaultRules
-- Class: R
-- The extension puts () at the front of the default list, so with this
-- Num instance the documented rule would default the literal to ().
-- GHC 9.12.2 instead rejects the program as ambiguous.
module Main where

instance Num () where
  _ + _ = ()
  _ * _ = ()
  abs _ = ()
  signum _ = ()
  fromInteger _ = ()
  negate _ = ()

main :: IO ()
main = print (1 + 1)
