-- Extensions: RebindableSyntax
-- Class: M
-- Do notation uses Prelude's (>>) in Haskell 2010 and whatever (>>) is in
-- scope under the extension.
module Main where
import Prelude

main :: IO ()
main = do
    putStrLn "first"
    putStrLn "second"
  where
    _ >> b = b
