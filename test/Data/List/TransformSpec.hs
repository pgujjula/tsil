module Data.List.TransformSpec (spec) where

import Test.Hspec            (Spec, describe, it, shouldBe)
import Test.Hspec.QuickCheck (modifyMaxSuccess)

import Data.Function         (on)
import Data.List.Transform   (group, groupAdjacent, groupAdjacentBy, groupBy,
                              rotate, takeEvery)
import Data.Ord              (Down (Down), comparing)

numTests :: Int
numTests = 1000

maxListLength :: Int
maxListLength = 1000

spec :: Spec
spec = modifyMaxSuccess (const numTests) $ do
       describe "takeEvery" takeEverySpec
       describe "groupAdjacent" groupAdjacentSpec
       describe "group" groupSpec
       describe "groupBy" groupBySpec
       describe "groupAdjacentBy" groupAdjacentBySpec
       describe "rotateSpec" rotateSpec

takeEverySpec :: Spec
takeEverySpec = do
  it "n = 1, empty list" $
    takeEvery 1 ([] :: [Int]) `shouldBe` []
  it "n = 1, finite list" $ do
    let xs = [1..10] :: [Int]
    takeEvery 1 xs `shouldBe` xs
  it "n = 1, prefix of infinite list" $ do
    let xs = [1..] :: [Int]
    take 10 (takeEvery 1 xs) `shouldBe` take 10 xs

  it "n = 3, empty list" $
    takeEvery 3 ([] :: [Int]) `shouldBe` []
  it "n = 3, finite list" $
    takeEvery 3 [1..10] `shouldBe` ([3, 6, 9] :: [Int])
  it "n = 3, prefix of infinite list" $ do
    let xs = [1..] :: [Int]
    take 10 (takeEvery 3 xs) `shouldBe` take 10 (map (*3) xs)

groupAdjacentSpec :: Spec
groupAdjacentSpec = do
  it "empty list" $
    groupAdjacent ([] :: [Int]) `shouldBe` []
  it "finite list" $
    groupAdjacent ([1, 3, 3, 3, 2, 2] :: [Int]) `shouldBe` [[1], [3, 3, 3], [2, 2]]
  it "infinite list" $ do
    -- output == [[1], [2, 2], [3, 3, 3]..]
    let output = map (\x -> replicate x x) [1..] :: [[Int]]
    let input = concat output
    let n = floor $ sqrt (fromIntegral maxListLength :: Double)
    take n (groupAdjacent input) `shouldBe` take n output

-- TODO: We can add randomized tests once we add predicates to Data.List.Predicate
-- (allEqual, sorted)
groupSpec :: Spec
groupSpec = do
  it "empty list" $
    group ([] :: [Int]) `shouldBe` []
  it "finite list" $
    group ([1, 3, 2, 3, 2, 3] :: [Int]) `shouldBe` [[1], [2, 2], [3, 3, 3]]

groupBySpec :: Spec
groupBySpec =
  let cmp = comparing Down
   in do
      it "empty list" $
        groupBy cmp ([] :: [Int]) `shouldBe` []
      it "finite list" $
        groupBy cmp ([1, 3, 2, 3, 2, 3] :: [Int]) `shouldBe` [[3, 3, 3], [2, 2], [1]]

groupAdjacentBySpec :: Spec
groupAdjacentBySpec =
  let eq = (==) `on` head
   in do
      it "empty list" $
        groupAdjacentBy eq ([] :: [String]) `shouldBe` []
      it "finite list" $ do
        let input = ["apple", "at", "atom", "banana", "bot", "cat", "curry", "clip"]
        let output = [["apple", "at", "atom"], ["banana", "bot"], ["cat", "curry", "clip"]]
        groupAdjacentBy eq input `shouldBe` output

-- TODO: Can we turn off annotation warnings for this file?
rotateSpec :: Spec
rotateSpec = do
  it "empty list, 0 offset" $
    rotate 0 [] `shouldBe` ([] :: [Int])
  it "empty list, positive offset" $
    rotate 3 [] `shouldBe` ([] :: [Int])
  it "empty list, negative offset" $
    rotate (-2) [] `shouldBe` ([] :: [Int])

  let xs = [1..6] :: [Int]
  let naturals = [1..] :: [Int]
  it "finite list, 0 offset" $
    rotate 0 xs `shouldBe` xs
  it "finite list, positive offset" $
    rotate 2 xs `shouldBe` [3, 4, 5, 6, 1, 2]
  it "finite list, negative offset" $
    rotate (-2) xs `shouldBe` [5, 6, 1, 2, 3, 4]

  it "finite list, positive offset equals length" $
    rotate 6 xs `shouldBe` xs
  it "finite list, negative offset equals negative length" $
    rotate (-6) xs `shouldBe` xs

  it "finite list, positive offset greater than length" $
    rotate 10 xs `shouldBe` [5, 6, 1, 2, 3, 4]
  it "finite list, negative offset greater than length" $
    rotate (-10) xs `shouldBe` [3, 4, 5, 6, 1, 2]

  it "infinite list, 0 offset" $
    take 10 (rotate 0 naturals) `shouldBe` [1..10]
  it "ininite list, positive offset" $
    take 10 (rotate 10 naturals) `shouldBe` [11..20]

  let bigOffset = 3 * (10 :: Int)^(8 :: Int) -- TODO: disable warnings, this is ugly
  it "finite list, huge positive offset" $
    rotate bigOffset xs `shouldBe` rotate (bigOffset `mod` length xs) xs
  it "finite list, huge negative offset" $
    rotate (-bigOffset) xs `shouldBe` rotate ((-bigOffset) `mod` length xs) xs
