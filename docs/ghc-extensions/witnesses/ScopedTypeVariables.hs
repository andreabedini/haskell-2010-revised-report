-- Extensions: ScopedTypeVariables
-- Class: R
-- In Haskell 2010 the a in the signature of h is fresh; the extension
-- scopes the class variable over the default method, so h cannot be used
-- at Char.
module Main where

class C a where
  m :: a -> Char
  m _ = let h :: a -> a
            h y = y
        in h 'x'

instance C Bool

main :: IO ()
main = print (m True)
