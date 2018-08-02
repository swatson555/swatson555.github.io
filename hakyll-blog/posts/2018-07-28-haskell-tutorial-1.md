---
img: philip.png
title: Programming with Haskell
abstract: Haskell can be a daunting programming language for those outside of a certain knowledge circle. Talk of how Haskell is pure and, it's usage of monadic logic frustrate what is a wonderfully elegant programming language. This article aims to clarify the hyperbole that manifests around the Haskell programming language by providing the reader with the insight necessary to understand such hyperbole. A basic understanding of functional programming is assumed.
---
# The Basics of Haskell

Haskell allows one to write very elegant programs. Let's begin by looking at a program that calculates the factorial of it's input.

```haskell
fac n =
  if n == 0 then 1 else n * fac (n-1)
```

Here we have a function of 1 argument. The function's definition is a single `if then else` statement. I don't want to dwell on this example for too long. It should be clear what's going on in this example by inspection. The important thing to note is how functions and if statements are defined.

Let's look at a slightly more involved example that calculates the hypotenuse of it's 2 inputs. In this function we'll see an example of multi-line comments, a function of more than 1 argument, and the let-in clause.

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

Notice at the very top of this program that we have `{- -}`. These are how one would write multi-line comments. Later we'll see an example of single-line comments.

The last function had a single argument. This function has 2 arguments. Note the syntax for that. The syntax takes the form `f arg1 arg2 arg3 ...` where the trailing ellipsis could be additional arguments.

The body of this function is also quite different from our first example. Here we're using a let-in clause. We're saying let `a'` be a^2^ and, let `b'` be b^2^. Once we've defined `a'` and `b'` we can use them in an expresion. Here the expresion is `sqrt (a' + b')`.

These small examples should feel straight forward. The next example will be far more involved. We'll be using a bisectional search to find the square root of some number x. This example will use a function defined locally within another function, single-line comments show up, the let-in and if statements make a return, and a new concept called a where clause will be introduced.

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

tbd

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

tbd

# The Problem of Lazy Evaluation

tbd


# Programming with Monads

tbd


# Programming with Lazy Evaluation

tbd
