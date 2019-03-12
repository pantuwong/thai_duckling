-- Copyright (c) 2016-present, Facebook, Inc.
-- All rights reserved.
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree. An additional grant
-- of patent rights can be found in the PATENTS file in the same directory.


{-# LANGUAGE OverloadedStrings #-}

module Duckling.Numeral.EN.Corpus
  ( corpus ) where

import Prelude
import Data.String

import Duckling.Numeral.Types
import Duckling.Testing.Types

corpus :: Corpus
corpus = (testContext, testOptions, allExamples)

allExamples :: [Example]
allExamples = concat
  [ examples (NumeralValue 0)
             [ "0"
             , "๐"
             , "ศูนย์"
             ]
  , examples (NumeralValue 1)
             [ "1"
             , "๑"
             , "หนึ่ง"
             ]
  , examples (NumeralValue 2)
             [ "2"
             , "๒"
             , "สอง"
             ]
  , examples (NumeralValue 3)
             [ "3"
             , "๓"
             , "สาม"
             ]
  , examples (NumeralValue 10)
             [ "10"
             , "๑๐"
             , "สิบ"
             ]
  , examples (NumeralValue 11)
             [ "11"
             , "๑๑"
             , "สิบเอ็ด"
             , "สิบหนึ่ง"
             ]
  , examples (NumeralValue 12)
             [ "12"
             , "๑๒"
             , "สิบสอง"
             , "โหล"
             ]
 , examples (NumeralValue 13)
             [ "13"
             , "๑๓"
             , "สิบสาม"
             ]
  , examples (NumeralValue 14)
             [ "14"
             , "๑๔"
             , "สิบสี่"
             ]
  , examples (NumeralValue 16)
             [ "16"
             , "๑๖"
             , "สิบหก"
             ]
  , examples (NumeralValue 17)
             [ "17"
             , "๑๗"
             , "สิบเจ็ด"
             ]
  , examples (NumeralValue 18)
             [ "18"
             , "๑๘"
             , "สิบแปด"
             ]
, examples (NumeralValue 20)
             [ "20"
             , "๒๐"
             , "ยี่สิบ"
             ]
  , examples (NumeralValue 21)
             [ "21"
             , "๒๑"
             , "ยี่สิบเอ็ด"
             ]
  , examples (NumeralValue 24)
             [ "24"
             , "๒๔"
             , "สองโหล"
             , "2 โหล"
             , "๒ โหล"
             ]

  , examples (NumeralValue 1.1)
             [ "1.1"
             , "1.10"
             , "๑.๑"
             , "หนึ่งจุดหนึ่ง"
             ]
  , examples (NumeralValue 1.2)
             [ "1.2"
             , "1.20"
             , "๑.๒"
             , "หนึ่งจุดสอง"
             ]
  , examples (NumeralValue 0.77)
             [ ".77"
             , "0.77"
             . "๐.๗๗"
             , "ศูนย์จุดเจ็ดเจ็ด"
             ]
  , examples (NumeralValue 100000)
             [ "100,000"
             , "100,000.0"
             , "100000"
             , "๑๐๐,๐๐๐"
             , "๑๐๐๐๐๐"
             , "หนึ่งแสน"
             ]
  , examples (NumeralValue 0.2)
             [ "๐.๒"
             , "0.2"
             , "ศูนย์จุดสอง"
             ]
  , examples (NumeralValue 5000)
             [ "5 พัน"
             , "ห้าพัน"
             , "๕๐๐๐"
             , "๕ พัน"
             ]
  , examples (NumeralValue (-504))
             [ "-504"
             , "-๕๐๔"
             , "ลบห้าร้อยสี่"
             ]
  , examples (NumeralValue (3e6 ))
              [
                "3000000"
              , "3,000,000"
              , "๓,๐๐๐,๐๐๐"
              , "สามล้าน"
              ]           
  , examples (NumeralValue (-1.2e6))
             [ "-1,200,000"
             , "-1200000"
             , "-๑๒๐๐๐๐๐"
             , "-๑,๒๐๐,๐๐๐"
             , "ลบหนึ่งล้านสองแสน"
             ]
  , examples (NumeralValue 122)
             [ "หนึ่งสองสอง"
             , "หนึ่งร้อยยี่สิบสอง"
             ]
  , examples (NumeralValue 2e5)
             [ "สองแสน"
             ]
  , examples (NumeralValue 21011)
             [ "สองหมื่นหนึ่งพันสิบเอ็ด"
             ]
  , examples (NumeralValue 721021)
             [ "เจ็ดแสนสองหมื่นหนึ่งพันยี่สิบเอ็ด"
             ]
  , examples (NumeralValue 31256721)
             [ "สามสิบเอ็ดล้านสองแสนห้าหมื่นหกพันเจ็ดร้อยยี่สิบเอ็ด"
             ]
  , examples (NumeralValue 2400)
             [ "สองร้อยโหล"
             , "200 โหล"
             , "๒๐๐ โหล"
             ]
  , examples (NumeralValue 2200000)
             [ "สองจุดสองล้าน"
             ]
  , examples (NumeralValue 3000000000)
             [ "สามพันล้าน"
             ]
  ]
