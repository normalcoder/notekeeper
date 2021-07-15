{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module Qwe (checkth) where

import Development.GitRev
import qualified Language.C.Inline as C

C.include "<math.h>"
C.include "<stdio.h>"

getCos = do
  [C.exp| double{ cos(1) } |]
  

checkth = do
  x <- getCos
  print $ "x: " ++ show x
  print "12345678"
  print $(gitHash)
  print "456"
  y <- [C.block| int {
      // Read and sum 5 integers
      int i, sum = 0, tmp;
      for (i = 0; i < 5; i++) {
        //scanf("%d", &tmp);
        //sum += tmp;
        sum += i*i;
      }
      return sum;
    } |]
  print $ "y: " ++ show y
