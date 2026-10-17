-- Extensions: StrictData
-- Class: M
-- The extension makes constructor fields strict, so building P undefined
-- diverges.
module Main where

data P = P Int

main :: IO ()
main = case P undefined of P _ -> print (1 :: Int)
