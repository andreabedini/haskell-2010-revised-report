-- Extensions: MonoLocalBinds GADTs TypeFamilies TypeFamilyDependencies LinearTypes
-- Class: R
-- g mentions the lambda-bound x, so MonoLocalBinds does not generalise it,
-- and it cannot be used at both Char and Bool.
module Main where

f :: Int -> ((Int, Char), (Int, Bool))
f x = let g y = (x, y) in (g 'a', g True)

main :: IO ()
main = print (f 1)
