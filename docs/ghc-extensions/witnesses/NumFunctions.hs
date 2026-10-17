-- Shared by the literal witnesses: a Haskell 2010 Num instance for
-- functions, under which a literal applied to an argument is well typed.
module NumFunctions where

instance Show (a -> b) where
  show _ = "<function>"

instance Eq (a -> b) where
  _ == _ = False

instance Num b => Num (a -> b) where
  f + g = \x -> f x + g x
  f - g = \x -> f x - g x
  f * g = \x -> f x * g x
  negate f = negate . f
  abs f = abs . f
  signum f = signum . f
  fromInteger n = const (fromInteger n)
