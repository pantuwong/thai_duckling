-- Copyright (c) 2016-present, Facebook, Inc.
-- All rights reserved.
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree. An additional grant
-- of patent rights can be found in the PATENTS file in the same directory.


{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoRebindableSyntax #-}

module Duckling.Numeral.EN.Rules
  ( rules
  ) where

import Control.Applicative ((<|>))
import Data.HashMap.Strict (HashMap)
import Data.Maybe
import Data.String
import Data.Text (Text)
import Prelude
import qualified Data.HashMap.Strict as HashMap
import qualified Data.Text as Text

import Duckling.Dimensions.Types
import Duckling.Numeral.Helpers
import Duckling.Numeral.Types (NumeralData (..))
import Duckling.Regex.Types
import Duckling.Types
import qualified Duckling.Numeral.Types as TNumeral

ruleDozen :: Rule
ruleDozen = Rule
  { name = "a dozen of"
  , pattern =
    [ regex "\d*( )?โหล" --is this correct?
    ]
  , prod = \_ -> integer 12 >>= withMultipliable >>= notOkForAnyTime
  }

zeroNineteenMap :: HashMap Text Integer
zeroNineteenMap = HashMap.fromList
  [ ( "ศูนย์"   , 0 )
  , ( "หนึ่ง"      , 1 )
  , ( "สอง"      , 2 )
  , ( "สาม"    , 3 )
  , ( "สี่"     , 4 )
  , ( "ห้า"     , 5 )
  , ( "หก"      , 6 )
  , ( "เจ็ด"    , 7 )
  , ( "แปด"    , 8 )
  , ( "เก้า"     , 9 )
  , ( "สิบ"      , 10 )
  , ( "สิบเอ็ด"   , 11 )
  , ( "สิบสอง"   , 12 )
  , ( "สิบสาม" , 13 )
  , ( "สิบสี่" , 14 )
  , ( "สิบห้า"  , 15 )
  , ( "สิบหก"  , 16 )
  , ( "สิบเจ็ด", 17 )
  , ( "สิบแปด" , 18 )
  , ( "สิบเก้า" , 19 )
  ]

informalMap :: HashMap Text Integer
informalMap = HashMap.fromList
  [ ( "หนึ่งเดียว", 1 )
  , ( "คู่"   , 2 )
  , ( "คู่ของ", 2 )
  , ( "นิดหน่อย", 3 )
  ]

ruleToNineteen :: Rule
ruleToNineteen = Rule
  { name = "integer (0..19)" 
    , pattern =
    [ regex "(ศูนย์|หนึ่ง|สอง|สาม|สี่|ห้า|หก|เจ็ด|แปด|เก้า|สิบ|สิบเอ็ด|สิบสอง|สิบสาม|สิบสี่|สิบห้า|สิบหก|สิบเจ็ด|สิบแปด|สิบเก้า)"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (match:_)):_) ->
        let x = Text match in
        (HashMap.lookup x zeroNineteenMap >>= integer) <|>
        (HashMap.lookup x informalMap >>= integer >>= notOkForAnyTime)
      _ -> Nothing
  }

tensMap :: HashMap Text Integer
tensMap = HashMap.fromList
  [ ( "ยี่สิบ"  , 20 )
  , ( "สามสิบ"  , 30 )
  , ( "สี่สิบ"   , 40 )
  , ( "ห้าสิบ"  , 50 )
  , ( "หกสิบ"   , 60 )
  , ( "เจ็ดสิบ"   , 70 )
  , ( "แปดสิบ" , 80 )
  , ( "เก้าสิบ"  , 90 )
  ]

ruleTens :: Rule
ruleTens = Rule
  { name = "integer (20..90)"
  , pattern =
    [ regex "(ยี่สิบ|สามสิบ|สี่สิบ|ห้าสิบ|หกสิบ|เจ็ดสิบ|แปดสิบ|เก้าสิบ)"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (match:_)):_) ->
        HashMap.lookup (Text match) tensMap >>= integer
      _ -> Nothing
  }

rulePowersOfTen :: Rule
rulePowersOfTen = Rule
  { name = "powers of tens"
  , pattern = [regex "(ร้อย|พัน|หมื่น|แสน|ล้าน|)?"]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (match : _)) : _) ->
        case Text match of
          "ร้อย" -> double 1e2 >>= withGrain 2 >>= withMultipliable
          "พัน" -> double 1e3 >>= withGrain 3 >>= withMultipliable
          "หมื่น" -> double 1e4 >>= withGrain 7 >>= withMultipliable
          "แสน" -> double 1e5 >>= withGrain 5 >>= withMultipliable
          "ล้าน" -> double 1e6 >>= withGrain 6 >>= withMultipliable
          _ -> Nothing
      _ -> Nothing
  }

ruleCompositeTens :: Rule
ruleCompositeTens = Rule
  { name = "integer 21..99"
  , pattern =
    [ oneOf [20,30..90]
    , regex "[\\s\\-]+"
    , numberBetween 1 10
    ]
  , prod = \tokens -> case tokens of
      (Token Numeral NumeralData{TNumeral.value = tens}:
       _:
       Token Numeral NumeralData{TNumeral.value = units}:
       _) -> double $ tens + units
      _ -> Nothing
  }

ruleSkipHundreds1 :: Rule
ruleSkipHundreds1 = Rule
  { name = "one eleven"
  , pattern =
    [ regex "(one|two|three|four|five|six|seven|eight|nine)"
    , regex "(ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|fou?rty|fifty|sixty|seventy|eighty|ninety)"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (m1:_)):
       Token RegexMatch (GroupMatch (m2:_)):
       _) -> do
       let x1 = Text.toLower m1
       let x2 = Text.toLower m2
       hundreds <- HashMap.lookup x1 zeroNineteenMap
       rest <- HashMap.lookup x2 zeroNineteenMap <|> HashMap.lookup x2 tensMap
       integer (hundreds * 100 + rest)
      _ -> Nothing
  }

ruleSkipHundreds2 :: Rule
ruleSkipHundreds2 = Rule
  { name = "one twenty two"
  , pattern =
    [ regex "(one|two|three|four|five|six|seven|eight|nine)"
    , regex "(twenty|thirty|fou?rty|fifty|sixty|seventy|eighty|ninety)"
    , regex "(one|two|three|four|five|six|seven|eight|nine)"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (m1:_)):
       Token RegexMatch (GroupMatch (m2:_)):
       Token RegexMatch (GroupMatch (m3:_)):
       _) -> do
       let x1 = Text.toLower m1
       let x2 = Text.toLower m2
       let x3 = Text.toLower m3
       hundreds <- HashMap.lookup x1 zeroNineteenMap
       tens <- HashMap.lookup x2 tensMap
       rest <- HashMap.lookup x3 zeroNineteenMap
       integer (hundreds * 100 + tens + rest)
      _ -> Nothing
  }

ruleDotSpelledOut :: Rule
ruleDotSpelledOut = Rule
  { name = "one point 2"
  , pattern =
    [ dimension Numeral
    , regex "point|dot"
    , Predicate $ not . hasGrain
    ]
  , prod = \tokens -> case tokens of
      (Token Numeral nd1:_:Token Numeral nd2:_) ->
        double $ TNumeral.value nd1 + decimalsToDouble (TNumeral.value nd2)
      _ -> Nothing
  }

ruleLeadingDotSpelledOut :: Rule
ruleLeadingDotSpelledOut = Rule
  { name = "point 77"
  , pattern =
    [ regex "point|dot"
    , Predicate $ not . hasGrain
    ]
  , prod = \tokens -> case tokens of
      (_:Token Numeral nd:_) -> double . decimalsToDouble $ TNumeral.value nd
      _ -> Nothing
  }

ruleDecimals :: Rule
ruleDecimals = Rule
  { name = "decimal number"
  , pattern =
    [ regex "(\\d*\\.\\d+)"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (match:_)):_) -> parseDecimal True match
      _ -> Nothing
  }

ruleCommas :: Rule
ruleCommas = Rule
  { name = "comma-separated numbers"
  , pattern =
    [ regex "(\\d+(,\\d\\d\\d)+(\\.\\d+)?)"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (match:_)):_) ->
        parseDouble (Text.replace "," Text.empty match) >>= double
      _ -> Nothing
  }

ruleSuffixes :: Rule
ruleSuffixes = Rule
  { name = "suffixes (K,M,G))"
  , pattern =
    [ dimension Numeral
    , regex "(k|m|g)(?=[\\W$€¢£]|$)"
    ]
  , prod = \tokens -> case tokens of
      (Token Numeral nd : Token RegexMatch (GroupMatch (match : _)):_) -> do
        x <- case Text.toLower match of
          "k" -> Just 1e3
          "m" -> Just 1e6
          "g" -> Just 1e9
          _ -> Nothing
        double $ TNumeral.value nd * x
      _ -> Nothing
  }

ruleNegative :: Rule
ruleNegative = Rule
  { name = "negative numbers"
  , pattern =
    [ regex "(-|minus|negative)(?!\\s*-)"
    , Predicate isPositive
    ]
  , prod = \tokens -> case tokens of
      (_:Token Numeral nd:_) -> double (TNumeral.value nd * (-1))
      _ -> Nothing
  }

ruleSum :: Rule
ruleSum = Rule
  { name = "intersect 2 numbers"
  , pattern =
    [ Predicate $ and . sequence [hasGrain, isPositive]
    , Predicate $ and . sequence [not . isMultipliable, isPositive]
    ]
  , prod = \tokens -> case tokens of
      (Token Numeral NumeralData{TNumeral.value = val1, TNumeral.grain = Just g}:
       Token Numeral NumeralData{TNumeral.value = val2}:
       _) | (10 ** fromIntegral g) > val2 -> double $ val1 + val2
      _ -> Nothing
  }

ruleSumAnd :: Rule
ruleSumAnd = Rule
  { name = "intersect 2 numbers (with and)"
  , pattern =
    [ Predicate $ and . sequence [hasGrain, isPositive]
    , regex "and"
    , Predicate $ and . sequence [not . isMultipliable, isPositive]
    ]
  , prod = \tokens -> case tokens of
      (Token Numeral NumeralData{TNumeral.value = val1, TNumeral.grain = Just g}:
       _:
       Token Numeral NumeralData{TNumeral.value = val2}:
       _) | (10 ** fromIntegral g) > val2 -> double $ val1 + val2
      _ -> Nothing
  }

ruleMultiply :: Rule
ruleMultiply = Rule
  { name = "compose by multiplication"
  , pattern =
    [ dimension Numeral
    , Predicate isMultipliable
    ]
  , prod = \tokens -> case tokens of
      (token1:token2:_) -> multiply token1 token2
      _ -> Nothing
  }

rules :: [Rule]
rules =
  [ ruleToNineteen
  , ruleTens
  , rulePowersOfTen
  , ruleCompositeTens
  , ruleSkipHundreds1
  , ruleSkipHundreds2
  , ruleDotSpelledOut
  , ruleLeadingDotSpelledOut
  , ruleDecimals
  , ruleCommas
  , ruleSuffixes
  , ruleNegative
  , ruleSum
  , ruleSumAnd
  , ruleMultiply
  , ruleDozen
  ]
