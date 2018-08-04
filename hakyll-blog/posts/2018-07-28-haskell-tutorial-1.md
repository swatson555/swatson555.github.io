---
img: philip.png
title: Programming in Haskell
abstract: Haskell can be a daunting programming language for those outside of a certain knowledge circle. Talk of how Haskell is pure and, it's usage of monads frustrate what is a wonderfully elegant programming language. This article aims to clarify the hyperbole that manifests around the Haskell programming language by providing the reader with the insight necessary to understand such hyperbole. A basic understanding of functional programming is assumed.
---
# The Basics of Haskell

Haskell allows one to write very elegant programs. Let's begin by looking at a program that calculates the factorial of it's input.

```haskell
fac n =
 if n == 0 then 1 else n * fac (n-1)
```

Here we have a function of 1 argument. The function's definition is a single `if then else` statement. I don't want to dwell on this example for too long. It should be clear what's going on in this example by inspection. The important thing to note is how functions and if-statements are defined.

Let's look at a slightly more involved example that calculates the hypotenuse of it's 2 inputs. In this function we'll see an example of multi-line comments, a function of more than 1 argument and, the let-in clause.

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

The body of this function is also quite different from our first example. Here we're using a let-in clause. We're saying let `a'` be a^2^ and, let `b'` be b^2^. Once we've defined `a'` and `b'` we can use them in an expression. Here the expression is `sqrt (a' + b')`.

These small examples should feel straight forward. The next example will be far more involved. We'll be using a bisection search to find the square root of some number x. This example will use a function defined locally within another function, single-line comments show up, the let-in and if-statements make a return and, a new concept called a where clause will be introduced.

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

First take a look at these comments. At the top we have a multi-line comment just as before but, now we have single-line comments denoted by `--`. Hopefully, the syntax highlighting makes these comments clear to distinguish.

Look at the body of the `sqrt'` function. It's just a single statement. Our function's body is just a single function call in the form `guess 0 x`. `guess` is a function defined within a where clause. In fact, we define 2 things in the where clause. We defined `guess` and, a variable called `epsilon`. You may be thinking that a where clause and a let-in clause are very similar. Indeed, they can be thought of as doing the same thing in a different way.

I'll leave the analysis of the `guess` function as an exercise to the reader. Syntactically speaking `guess` contains no new language constructs however, that doesn't mean understanding the program is trivial. Much has been written about this method. In fact, the bisection search of square roots have been known since Babylonian times!

So far we've seen quite a bit about Haskell. We've seen ways to define functions, if-statements, the let-in clause and, the where clause. One big topic I'm not going over is algebraic data types and pattern matching. Make no mistake. These are extremely important topics but, for the sake of brevity I won't go over those here.


# The Problem of Haskell

In general there are 2 ways of evaluating programs. The most common evaluation strategy is called [applicative order evaluation](https://en.wikipedia.org/wiki/Evaluation_strategy#Applicative_order). The other evaluation strategy is called [normal order evaluation](https://en.wikipedia.org/wiki/Evaluation_strategy#Normal_order). Haskell uses normal order evaluation.

Unfortunately normal order evaluation has a very nasty problem. That problem is side effects. A pure function is strictly a mapping from it's domain to it's range. If we want to write to stdout we don't really care about it's mapping. We want a function that has the side effect of writing to stdout. That causes a problem for a programming language like Haskell. Let's look at a small example using applicative order evaluation first to get a better idea of everything.

```haskell
numWithPrint num =
 print num
 num

doubleNum num =
 num + num

doubleNum (numWithPrint 6)
```

This is our setup. `numWithPrint` takes in a number, prints it to stdout, and returns the same number. So, `numWithPrint 6 = 6`, `numWithPrint 1 = 1`, etc. `doubleNum` just doubles it's input. E.g. `doubleNum 4 = 8`. This is not valid Haskell code. We'll find out why that is soon enough but, for now let's use applicative order evaluation to evaluate `doubleNum (numWithPrint 6)`.

```bash
1> doubleNum (numWithPrint 6)

# We evaluate the arguments of `doubleNum` first

2> doubleNum (print 6; 6)

# We can't reduce `doubleNum`'s arguments anymore

3> doubleNum 6
4> 6 + 6
5> 12

---
stdout:
6
```

Do you see what's happening here? We evaluate the function's arguments first and, substitute the result into the function's body. `doubleNum (numWithPrint 6)` got reduced to `doubleNum 6` but, we have a side effect. The side effect was printing to stdout. Let's look at what happens if we used normal order evaluation.

```bash
1> doubleNum (numWithPrint 6)

# We substitute the arguments of `doubleNum` first

2> (numWithPrint 6) + (numWithPrint 6)

# We can't substitute anymore

3> (print 6; 6) + (print 6; 6)
4> 6 + 6
5> 12

---
stdout:
6
6
```

Oh my! This isn't good. We've printed '6' twice! Unlike applicative order we don't evaluate the function's arguments first. Instead we substitute the arguments into the function's body. This is the problem of Haskell.

Haskell's solution to this problem is to use monads. Actually I want to make this very clear. **Monads solve the problem of normal order evaluation.** If you're reading this paper surely at some point you'll read that monads allow for pure functional programming. **Not all functions in Haskell are pure functions.** You may read that monads represent a type that passes along a world concept or, that they're a type that represents the abstract idea of a computation. This is true at a conceptual level. You may read that monads aren't necessary. **For handling side effects in Haskell they are necessary.** Let's look at why they're necessary with a small example of how to use them.

```haskell
numWithPrint num = do
 print num
 return num

doubleNum ioNum = do
 num <- ioNum
 return (num + num)

doubleNum (numWithPrint 6)
```

The first thing that one needs to understand is the do-return macro. Look at `numWithPrint` after the `=` there's a `do`. This begins the do-return macro. The last line of this function is a `return`. What are we returning? A monad! No longer is `numWithPrint 6 = 6` a true statement. Rather `numWithPrint 6 = IO 6` is what we have here.

This is quite good because `doubleNum` only accepts a number wrapped in a monad. Unfortunately, we can't just add 2 monads. It doesn't work that way. We need to unwrap our monad and add them. That's what `num <- ioNum` does. It takes the monad `ioNum` and, binds it's value to `num`. Now `num` is just a regular number. We can double it and, return it back out as a monad.

This is valid haskell code. It isn't as nice looking as before but, it'll get the job done. Let's look at this using normal order evaluation. There is one caveat about this analysis. You may have noticed I called do-return a macro. It's useful to see what do-return expands to however, I won't be expanding the do-return macro here.

```bash
1> doubleNum (numWithPrint 6)
2> doubleNum (print 6; return 6)

# Binding acts like a wall. We can't substitute
# anything at this point without evaluating `num`

3> num <- (print 6; return 6);
   return (num + num);

# 6 will be bound to `num`

4> num <- IO 6
   return (num + num);
5> return (6 + 6)
6> IO 12

---
stdout:
6
```

Monads save the day. We can have our normal order evaluation and use it too.

# Further Reading
* [Learn Haskell in 10 minutes](https://wiki.haskell.org/Learn_Haskell_in_10_minutes)
* [A Gentle Introduction to Haskell 98](https://www.haskell.org/tutorial/)
* [Imperative functional programming](https://www.microsoft.com/en-us/research/publication/imperative-functional-programming/?from=http%3A%2F%2Fresearch.microsoft.com%2Fen-us%2Fum%2Fpeople%2Fsimonpj%2Fpapers%2Fimperative.ps.z)
* [Tackling the awkward squad: monadic input/output, concurrency, exceptions, and foreign-language calls in Haskell](https://www.microsoft.com/en-us/research/publication/tackling-awkward-squad-monadic-inputoutput-concurrency-exceptions-foreign-language-calls-haskell/)
* [Type classes: an exploration of the design space](https://www.microsoft.com/en-us/research/publication/type-classes-an-exploration-of-the-design-space/?from=http%3A%2F%2Fresearch.microsoft.com%2F%7Esimonpj%2Fpapers%2Ftype-class-design-space%2F)