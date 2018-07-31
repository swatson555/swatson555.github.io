---
img: philip.png
title: Programming with Haskell
abstract: Many absurdities have been written about the Haskell programming language. Talk of how Haskell is pure and, it's usage of monadic logic make Haskell confusing for the uninformed. This article aims to clarify the hyperbole that exists around the Haskell programming language by providing the reader with the insight necessary to understand such hyperbole. A basic understanding of functional programming is assumed.
---
# The Basics of Haskell

Haskell allows one to write very elegant programs. Let's begin by looking at a program that calculates the factorial of it's input.

```haskell
fac n =
  if n == 0 then 1 else n * fac (n-1)
```
```haskell
{-
 Calculate the hypotenuse of a and b.
 -}

hyp a b =
  let
    a' = a ** 2
    b' = b ** 2
  in
    sqrt (a' + b')
```
```haskell
{-
 Find the sqrt of x.
 -}

sqrt' x =
  -- The sqrt of x must be between 0 and x
  -- so, that will be our initial guess.
  guess 0 x
  where
    -- This is the tolerance.
    -- The program will find the sqrt +/- epsilon.
    epsilon = 0.001

    guess low high =
      let
        rt = (high + low) / 2 -- Take the midpoint as the potential square root.
        x' = rt ** 2          -- Squaring the guess should be the original value x.
      in
        if abs (x' - x) >= epsilon
        then
          if x' < x
          then guess rt high
          else guess low rt
        else
          rt
```
```haskell
{-
 Find the sqrt of x.
 -}

sqrt' epsilon x =
  guess 0 x
  where
    guess low high =
      let
        rt = (high + low) / 2
        x' = rt ** 2
      in
        if abs (x' - x) >= epsilon
        then
          if x' < x
          then guess rt high
          else guess low rt
        else
          rt


{-
 Find the sqrt of x +/- 0.1. Very fast but imprecise.
 -}

fastSqrt =
  sqrt' 0.1


{-
 Find the sqrt of x +/- 0.1. Slower but very precise.
 -}

slowSqrt =
  sqrt' 0.0000000000001
```


# The Problem of Lazy Evaluation

tbd


# Programming with Monads

tbd


# Programming with Lazy Evaluation

tbd
