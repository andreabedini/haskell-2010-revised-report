-- Extensions: ApplicativeDo
-- Class: M
-- The extension desugars independent statements with (<*>) in place of
-- (>>=).  The two agree only when (<*>) = ap, which this instance violates.
module Main where

newtype W a = W ([String], a)

instance Functor W where
  fmap f (W (l, a)) = W (l, f a)

instance Applicative W where
  pure a = W ([], a)
  W (l1, f) <*> W (l2, a) = W (l1 ++ l2 ++ ["<*>"], f a)

instance Monad W where
  return = pure
  W (l, a) >>= k = let W (l', b) = k a in W (l ++ l', b)

tell :: String -> W ()
tell s = W ([s], ())

main :: IO ()
main = let W (l, _) = do { x <- tell "a"; y <- tell "b"; return (x, y) }
       in print l
