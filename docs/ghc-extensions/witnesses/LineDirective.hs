-- Extensions: CPP
-- Class: D
-- With explicit braces a line may start with # in column 1.  GHC treats
-- such a line as a line directive even when CPP is off.
module Main (main) where {

(#) :: Int -> Int -> Int;
a # b = a + b;

main :: IO ();
main = print (1
# 2)
}
