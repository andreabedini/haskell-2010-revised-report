-- Extensions: NamedWildCards
-- Class: R
-- In Haskell 2010 _a is an ordinary type variable; the extension makes it
-- a wildcard, which is an error without PartialTypeSignatures.
module Main where

f :: _a -> _a
f x = x

main :: IO ()
main = print (f (1 :: Int))
