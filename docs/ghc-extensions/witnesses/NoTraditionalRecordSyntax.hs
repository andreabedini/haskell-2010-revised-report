-- Extensions: NoTraditionalRecordSyntax
-- Class: R
module Main where

data R = R { fld :: Int }

main :: IO ()
main = print (fld R { fld = 1 })
