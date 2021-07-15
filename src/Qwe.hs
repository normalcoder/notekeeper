{-# LANGUAGE TemplateHaskell #-}

module Qwe (checkth) where

import Development.GitRev

checkth = do
  print "12345678"
  print $(gitHash)
  print "456"
