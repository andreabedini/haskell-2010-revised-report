-- Extensions: NoDoAndIfThenElse
-- Class: R
module Main where

main :: IO ()
main = do
  if True
  then putStrLn "yes"
  else putStrLn "no"
