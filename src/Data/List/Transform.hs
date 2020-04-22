{-| Module      : Data.List.Transform
    Description : Transform lists to other lists.
    Copyright   : (c) Preetham Gujjula, 2020
    License     : GPL-3
    Maintainer  : preetham.gujjula@gmail.com
    Stability   : experimental

    Transform lists to other lists.
-}
module Data.List.Transform
  ( takeEvery
  , group
  , groupBy
  , groupAdjacent
  , groupAdjacentBy
  , rotate
  ) where

import Control.Monad (guard)
import Data.List     (sort, sortBy, uncons)
import Data.Maybe    (fromMaybe)

-- TODO: Consider moving to Data.List.Filter
{-| @takeEvery n xs@ is a list of every nth element of xs

    __Precondition:__ @n@ must be positive.

    >>> takeEvery 3 [1..10]
    [3, 6, 9]
    >>> (takeEvery 1 [1..10]) == [1..10]
    True
-}
takeEvery :: Int -> [a] -> [a]
takeEvery n xs =
  case drop (n - 1) xs of
    []     -> []
    (y:ys) -> y : takeEvery n ys

{-| @group xs@ groups elements of xs that are equal. The groups are returned in
    a sorted order, so a group of a smaller element appears before a group of a
    larger one.

    >>> group [1, 3, 2, 3, 2, 3]
    [[1], [2, 2], [3, 3, 3]]
    >>> group []
    []
-}
group :: (Ord a) => [a] -> [[a]]
group = groupAdjacent . sort

{-| Like @group@, but with a custom comparison test. -}
groupBy :: (a -> a -> Ordering) -> [a] -> [[a]]
groupBy cmp = groupAdjacentBy eq . sortBy cmp
  where eq a b = cmp a b == EQ

{-| @groupAdjacent xs@ groups adjacent elements of xs that are equal. It works
    with infinite lists as well.

    >>> groupAdj [1, 3, 3, 3, 2, 2]
    [[1], [3, 3, 3], [2, 2]]
    >>> take 4 $ groupAdj $ concatMap (\x -> take x $ repeat x) [1..]
    [[1], [2, 2], [3, 3, 3], [4, 4, 4, 4]]
    >>> groupAdj []
    []
-}
groupAdjacent :: (Eq a) => [a] -> [[a]]
groupAdjacent = groupAdjacentBy (==)

{-| Like @groupAdjacent@, but with a custom equality test. -}
groupAdjacentBy :: (a -> a -> Bool) -> [a] -> [[a]]
groupAdjacentBy eq = foldr f []
  where
    f x yss = (x:zs):zss
      where
        (zs, zss) = fromMaybe ([], yss) $ do
          (ys, yss') <- uncons yss
          guard (x `eq` head ys)
          return (ys, yss')

-- TODO: Simplify this implementation
{-| Rotate a list by an offset. Positive offset is left rotation, negative is
    right. Zero- and left-rotation work with infinite lists. Also works if the
    offset is greater than the length of the list.

    >>> rotate 2 [1..6]
    [5, 6, 1, 2, 3, 4]
    >>> rotate (-2) [1..6]
    [3, 4, 5, 6, 1, 2]
    >>> rotate 0 [1..6]
    [1, 2, 3, 4, 5, 6]
    >>> take 6 $ rotate (-2) [1..]
    [3, 4, 5, 6, 7, 8]
    >>> rotate 5 [1, 2, 3]
    [2, 3, 1]
-}
rotate :: Int -> [a] -> [a]
rotate n xs
  | null xs   = []
  | n >= 0    = let d = case lengthTo n xs of
                          Nothing -> n
                          Just l  -> n `rem` l
                    (ys, zs) = splitAt d xs
                 in zs ++ ys
  | otherwise = let (ys, zs) = splitAt (n `mod` length xs) xs
                 in zs ++ ys

lengthTo :: Int -> [a] -> Maybe Int
lengthTo n xs =
  if (not . null) $ drop n xs
  then Nothing
  else Just (length xs)
