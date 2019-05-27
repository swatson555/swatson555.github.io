---
img: goldberg.gif
title: What Is A Monad?
abstract: Monads are often a point of frustration for learners of Haskell. The question of what a monad is leads to the question of why a monad is. The question of why a monad is leads to the question of what a monad is. It's been said that the IO monad is special. This is wrong. It's time that these myths be debunked. This article seeks to answer the question of what a monad is.
---
# What A Monad Is
A monad is an interface of 2 functions where 3 laws are satisfied. These 2 functions are:

* unit
* bind

These 3 laws are:

* Left identity
* Right identity
* Associativity

In Haskell, we might choose to represent the interface as the following.

```haskell
class Monad m where
  return ::   a               -> m a --This is unit
  (>>=)  :: m a -> (a -> m b) -> m b --This is bind
```

Here I'm referring to `unit` as `return` and to `bind` as `>>=`. These names are the typical way to refer to these concepts in Haskell programming.

It's important to understand that these types alone are not what make something a monad. A monad is more truly defined by it's laws. What the laws mean in this context follows.

```haskell
return a  >>= f      == f a                     --Left identity
m         >>= return == m                       --Right identity
(m >>= f) >>= g      == m >>= (\x -> f x >>= g) --Associativity
```

Actually, it's hard to see that these laws are even being satisfied so, let's look at this in a slightly different way.

```haskell
(>=>) :: Monad m => (a -> m b) -> (b -> m c) -> a -> m c
(m >=> n) x =
  m x >>= n

-- therefore, if this is a monad the following will be true.

return    >=> g      == g               --Left identity
f         >=> return == f               --Right identity
(f >=> g) >=> h      == f >=> (g >=> h) --Associativity
```

Ah, now we can see these properties far more clearly. The `>=>` is called a Kleisli composition operator.

If you've made it to this point you may be thinking "Why? What's the point of this?" The answer to that question is explored in [Why We Need Monads](https://steven741.github.io/posts/2018-07-28-haskell-tutorial-1.html) but, to make this article complete I'll say it here. It turns out monads are useful for managing side-effects in programs that are evaluated using normal order.

Well. This is exceptionally complicated. This is truly confusing. How can one make sense of this? Unfortunately, the only way is practice. You won't fully understand monads by reading this article. [There's no royal path to geometry](https://www.quora.com/Euclid-wrote-There-is-no-royal-road-to-geometry-What-does-this-mean-to-you) and, there's no royal path to monads.

With this being the case it would be useful to know what monads aren't. Monads aren't a design pattern. Monads aren't a typeclass. Monads aren't incomprehendable. What makes something a monad, principally, are the 3 monad laws. The type of unit and bind necessarily come from the monad laws. However, it's important to realize that the type alone isn't enough for something to be a monad. Indeed, one can implement the monad interface and, not have something that satisfies the monad laws. For this reason it's also not a design pattern.

What monads are like is a more structured form of currying. It's a form of composition. What that means is quite involved. However, let's not worry about this. You already know what a monad is in some sense. It's that interface and laws. More importantly it's those laws. Understanding those laws are really essential to understanding monads.

# The IO Monad
It would be useful to see a monad in action. It's been said that the IO monad is special. It's been said that it's a monad that's internal to the compiler and, can't be implemented by a typical program. Not only is this untrue but, the IO monad is in fact the simplest monad which exists. To that end, let's implement the IO monad.

```haskell
data IO a = IO a deriving Show

class Monad m where
  unit ::   a               -> m a
  bind :: m a -> (a -> m b) -> m b

instance Monad IO where
  unit a        = IO a
  bind (IO a) f = f a
```

That's it. That's all the IO monad is. It's literally just it's construction and no more. With this we can use functions with side effects. Let's take a look at that.

```haskell
foreign import ccall unsafe "getchar" get' :: Int
foreign import ccall unsafe "putchar" put' :: Int -> Int

get :: IO Int
get = unit get'

put :: Int -> IO Int
put c = unit (put' c)
```

Here we're calling out to some C code and, wrapping the results of the call in our monad. That's all we have to do. Let's use this. Let's get a character from stdin and write it back to stdout.

```haskell
do
  c <- get
  put c

-- or

bind get (\c -> put c)

-- or

bind get put
```

Here I have 3 ways of doing the same thing. The top-most example is the most sugared. The bottom-most example has no sugar. The unsugared example is the most useful to us since this is what will actually be evaluated. We evaluate from left to right. So, evaluate `get`. Then evaluate `put` with the value of `get`. That's not so bad. Let's look at a more complicated example. 

```haskell
do
  a <- unit 97
  c <- get
  put a
  put c

-- or

bind (unit 97)
     (\a -> bind get
                 (\c -> bind (put a)
		             (\_ -> put c)))
```

Now this is interesting. The top example looks just like an imperatively defined program but, our desugared version is clearly just one expression. Evaluating this expression will be hard so let's walk through it in pieces.

```haskell
bind (unit 97)
     (\a -> bind get
                 (\c -> bind (put a)
		             (\_ -> put c)))

-- \a is now 97


bind get
     (\c -> bind (put a)
                 (\_ -> put c))

-- \c is now the result of `get`


bind (put a)
     (\_ -> put c)

-- \_ is now the result of `put a`


\_ -> put c

-- The expression is the result of `put c`
```

That's it. That's really what the IO monad is. Now, it's significant to note that Haskell's evaluation is memoized. That has consequences for functions with side-effects. But, this isn't much of a problem. You could imagine a version of `foreign import ccall` that doesn't memoize it's results. Indeed, Haskell's IO monad doesn't memoize it's results.

So, what's a monad? It's complicated. It's defined by abstract properties but, it can be useful for achiving certain results as was shown here.

# Further Reading
* [Monad laws](https://wiki.haskell.org/Monad_laws)
* [Haskell Programming: from first principles](http://haskellbook.com/)
* [Imperative functional programming](https://www.microsoft.com/en-us/research/publication/imperative-functional-programming/?from=http%3A%2F%2Fresearch.microsoft.com%2Fen-us%2Fum%2Fpeople%2Fsimonpj%2Fpapers%2Fimperative.ps.z)
* [Type classes: an exploration of the design space](https://www.microsoft.com/en-us/research/publication/type-classes-an-exploration-of-the-design-space/?from=http%3A%2F%2Fresearch.microsoft.com%2F%7Esimonpj%2Fpapers%2Ftype-class-design-space%2F)