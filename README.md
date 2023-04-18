# `macaroni`

Macro spaghetti code.

[I wrote a blog post about this](https://ianthehenry.com/posts/generalized-macros/) which explains the idea much more clearly than this readme does. Think of this like an early, primordial version of that post.

(A macaron is a little syntax sugar sandwich. And macaroni is, of course, the plural of macaron.)

This is an experimental alternative to `defmacro`. This proof-of-concept is implemented in [Janet](https://janet-lang.org), but the technique could work in any language with a similar macro system.

A macaron is a generalization of a regular macro, with three differences:

- A macro can only appear at the beginning of a form. A macaron can appear anywhere inside a form.
- Macarons have two argument lists: the nodes "to the left" and the nodes "to the right" of the macaron.
- Macarons are first-class values, and macarons can return other macarons. This allows macarons to not only rewrite themselves, but also the forms in which they appear.

For example, a macaron called `foo` would receive the following arguments if it appeared in the following positions:

```janet
(foo x y) # [] ['x 'y]
(x foo y) # ['x] ['y]
(x y foo) # ['x 'y] []
```

This is a generalization of a regular macro, since a macaron that checks that there are no nodes to the left of it is exactly a traditional `defmacro` macro.

# operator sections

For a simple example of something you can do with a macaron that you cannot do with a regular macro, consider [operator sections](http://wiki.haskell.org/Section_of_an_infix_operator). In this example, `+`, `-`, and `>` have been redefined as macarons:

```
repl:1:> (1 + 2)
3
repl:2:> (def plus-one (+ 1))
<function 0x6000026A8080>
repl:3:> (plus-one 10)
11
repl:4:> (map (+ 1) [1 2 3])
(2 3 4)
repl:5:> (map (1 -) [0.2 0.5 0.6])
(0.8 0.5 0.4)
repl:5:> (all (> 0) [1 2 3])
true
```

We can define such a "partially-applicable" macaron like this:

```janet
(defmacaron + [& left] [& right]
  (case [(length left) (length right)]
    [0 0] (error "nothing to add")
    [1 0] (with-syms [$] ~(fn [,$] (,+ ,(first left) ,$)))
    [0 1] (with-syms [$] ~(fn [,$] (,+ ,$ ,(first right))))
    [1 1] ~(,+ ,(first left) ,(first right))
    (error "too many arguments")))
```

Now you might be thinking: why? We can just write `|(+ $ 1)` and get exactly the same effect. Which is very true: operator sections aren't a compelling addition to Janet's syntax.

# infix application

Here's a weirder one. Consider the following Janet code:

```janet
(x | f)
```

That will parse into the following abstract syntax tree:

```janet
(x (short-fn f))
```

But let's say we want to make `|` behave as in [Bauble's postfix function application](https://bauble.studio), where `(x | f)` becomes `(f x)`.

We can do this by defining a macaron called `short-fn` that rewrites that expression.

Of course, we could also define a *macro* called `short-fn` -- it is a macro in the standard library, after all. But a macro would only be able to replace the form `(short-fn f)` with a new form. A macaron can actually replace the *parent form* that the `short-fn` appears in.

It does this by returning not an abstract syntax tree, but a first-class macaron. That macaron will be expanded -- just like any other macaron -- in the position it appears in its parent's form. So it's a two-step process:

```janet
(x (short-fn f))
(x <macaron>)
(f x)
```

Where did the `f` go? It was smuggled into the parent in the closure of the anonymous macaron's environment. Here, let's look at a slightly simpler example first:

```janet
(defmacaron short-fn [] [form]
  (macaron [& before] [& after]
    [;before 'pipe form ;after]))
```

That will go through the following expansions:

```janet
(x (short-fn f))
(x <macaron>)
(x pipe f)
```

We could then define a macaron called `pipe`, if we wanted to, to do the actual rearranging. But in reality, we can just return another first-class macaron directly:

```janet
(def pipe (macaron [& before] [& after]
  (def subject (case (length before)
    0 (error "nothing to pipe!")
    1 (first before)
    before))

  (match after
    [f & args] [f subject ;args]
    [] (error "nothing to pipe!"))))

(defmacaron short-fn [] [form]
  (macaron [& before] [& after]
    [;before pipe form ;after]))
```

I find this syntax very useful, and I'm very pleased by how easy it is to implement as a macaron. From the tests, some examples of what this macaron does:

```janet
(test-macaron (x | f)
  (f x))

(test-macaron (x 1 | f)
  (f (x 1)))

(test-macaron (x 1 | f 2 3 | g 4)
  (g (f (x 1) 2 3) 4))
```

This is a lot like the threading macro `->`, but it's easier for me to read and write.

# `def`

The original motivating use-case for macaroni was `def`.

Janet has `def` of course, so this sounds ridiculous. But you don't *need* `def` as a language primitive. You can implement `def` in terms of `let` pretty easily, like this:

```janet
(defmacaron def [] [name value]
  (macaron [& lefts] [& rights]
    ~(,;lefts (let [,name ,value] ,;rights))))

(test-macaron (do (def x 1) (+ x 1))
  (do
    (let
      [x 1]
      (+ x 1))))
```

Once again, the expansion goes like this:

```janet
(do (def x 1) (+ x 1))
(do <macaron> (+ x 1))
(do (let [x 1] (+ x 1)))
```

(And, of course, you can implement `let` in terms of `lambda`. And you can also implement `do` in terms of lambda, and have an incredibly small set of special forms. But... now is not the time for that. In Janet, `do` and `def` are special-forms, and `let` is actually implemented in terms of them. Which is perfectly pragmatic, but wouldn't you rather have a bizarre lambda calculus core surrounded by macro spaghetti?)

# `defer`

Another thing you can do with this is a `defer` "statement" that does not increase indentation:

```janet
(do
  (def f (file/open "file"))
  (defer (file/close f))
  (do-something)
  (do-something-else))
```

By rewriting that to a `finally`:

```janet
(defmacaron defer [] [expr]
  (macaron [& lefts] [& rights]
    ~(,;lefts (finally (do ,;rights) ,expr))))

(test-macaron
  (do
    (def f (file/open "foo.txt"))
    (defer (file/close f))
    (do-something)
    (do-something-else))
  (do
    (def f (file/open "foo.txt"))
    (finally
      (do
        (do-something)
        (do-something-else)) 
      (file/close f))))
```

(Janet doesn't actually have a `finally` macro in the standard library, but that's easy to define as a regular macro.)

The Gleam language [special-cases this kind of construct](https://gleam.run/book/tour/use.html) in a general way, which is neat. But with macarons, there is no need for any kind of special-case.

# Infix operators

There is [a simple example in the tests](test/infix.janet) of implementing left- and right-associative infix operators, as well as operators with two levels of precedence.

I *think* it's possible to implement arbitrary precedence infix operators with this technique, but I haven't attempted it yet.
