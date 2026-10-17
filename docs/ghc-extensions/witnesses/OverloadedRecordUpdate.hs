-- Extensions: OverloadedRecordUpdate
-- Class: R
module Main where

data R = R { fld :: Int } deriving Show

main :: IO ()
main = print ((R 1) { fld = 2 })
