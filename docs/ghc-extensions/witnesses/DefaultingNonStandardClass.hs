-- Extensions: NamedDefaults ExtendedDefaultRules
-- Class: A
-- Deviates: 9.12
-- By the report the type of 3 is ambiguous: its type variable is constrained
-- by C, which is not defined in the Prelude or a standard library, so it
-- cannot be defaulted and the program is a static error. GHC 9.12 relaxed
-- defaulting for all code while implementing NamedDefaults, and accepts the
-- program, printing Integer. GHC 9.10 and 9.14 reject it.
module Main where

class C a where
  c :: a -> String

instance C Integer where
  c _ = "Integer"

instance C Double where
  c _ = "Double"

main :: IO ()
main = putStrLn (c 3)
