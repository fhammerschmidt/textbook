# Function Application

Here we cover a somewhat simplified syntax of function application
compared to what OCaml actually allows.

**Syntax.** 
```
e0 e1 e2 ... en
```
The first expression `e0` is the function, and it is applied to
arguments `e1` through `en`.  Note that parentheses are not required
around the arguments to indicate function application, as they are in 
languages in the C family, including Java.

**Static semantics.**

* If `e0 : t1 -> ... -> tn -> u` and `e1:t1` and ... and `en:tn`
  then `e0 e1 ... en : u`.
  
**Dynamic semantics.**

To evaluate `e0 e1 ... en`:

1. Evaluate `e0` to a function.  Also evaluate the argument expressions `e1` through `en` 
   to values `v1` through `vn`.

   For `e0`, the result might be an anonymous function `fun x1 ... xn ->
   e` or a name `f`. In the latter case, we need to find the definition of `f`,
   which we can assume to be of the form `let rec f x1 ... xn =
   e`.  Either way, we now know the argument names `x1` through `xn` and the
   body `e`.

2. Substitute each value `vi` for the corresponding argument name `xi` in the
   body `e` of the function. That substitution results in a new expression `e'`.
   
3. Evaluate `e'` to a value `v`, which is the result of evaluating `e0 e1 ... en`.

If you compare these evaluation rules to the rules for `let` expressions,
you will notice they both involve substitution.  This is not an accident.
In fact, anywhere `let x = e1 in e2` appears in a program, we could replace
it with `(fun x -> e2) e1`.  They are syntactically different but semantically
equivalent.  In essence, `let` expressions are just syntactic
sugar for anonymous function application. 

## Pipeline

There is a built-in infix operator in OCaml for function application called the
*pipeline* operator, written `|>`. Imagine that as depicting a triangle pointing
to the right. The metaphor is that values are sent through the pipeline from
left to right. For example, suppose we have the increment function `inc` from
above as well as a function `square` that squares its input. Here are two
equivalent ways of writing the same computation:
```
square (inc 5)
5 |> inc |> square
(* both yield 36 *)
```
The latter uses the pipeline operator to send `5` through the `inc` function,
then send the result of that through the `square` function. This is a nice,
idiomatic way of expressing the computation in OCaml. The former way is arguably
not as elegant: it involves writing extra parentheses and requires the reader's
eyes to jump around, rather than move linearly from left to right. The latter
way scales up nicely when the number of functions being applied grows, where as
the former way requires more and more parentheses:
```
5 |> inc |> square |> inc |> inc |> square  
square (inc (inc (square (inc 5))))
(* both yield 1444 *)
```
It might feel weird at first, but try using the pipeline operator
in your own code the next time you find yourself writing a big
chain of function applications.

Since `e1 |> e2` is just another way of writing `e2 e1`, we don't need
to state the semantics for `|>`:  it's just the same as function application.
These two programs are another example of expressions 
that are syntactically different but semantically equivalent.
