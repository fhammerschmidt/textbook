# More List Syntax

Here are a couple additional pieces of syntax related to lists and
pattern matching.

**Immediate matches:**

When you have a function that immediately pattern-matches against
its final argument, there's a nice piece of syntactic sugar
you can use to avoid writing extra code.  Here's an example:
instead of 
```
let rec sum lst =
  match lst with
  | [] -> 0
  | h::t -> h + sum t
```
you can write
```
let rec sum = function
  | [] -> 0
  | h::t -> h + sum t
```
The word `function` is a keyword.  Notice that we're able to leave
out the line containing `match` as well as the name of the argument,
which was never used anywhere else but that line.  In such cases, though,
it's especially important in the specification comment for the function
to document what that argument is supposed to be, since the code
no longer gives it a descriptive name.

**OCamldoc:**

OCamldoc is a documentation generator similar to Javadoc.  It extracts
comments from source code and produces HTML (as well as other output
formats).  The [standard library web documentation][std-web] for the List
module is generated by OCamldoc from the [standard library source code][std-src] for
that module, for example.  We won't stress OCamldoc in this course, but we do
bring it up here for a reason:  there is a syntactic convention in it that
can be confusing with respect to lists.  

In an OCamldoc comment, source code is surrounded by square brackets.  That code
will be rendered in typewriter face and syntax-highlighted in the output HTML.
The square brackets in this case do not indicate a list.

For example, here is the comment for `List.hd` in the source code:
```
(** Return the first element of the given list. Raise
   [Failure "hd"] if the list is empty. *)
```
The `[Failure "hd"]` does not mean a list containing the exception `Failure "hd"`.
Rather it means to typeset the expression `Failure "hd"` as source code, as you can
see [here][std-web].

This can get especially confusing when you want to talk about lists as part of the
documentation.  For example, here is a way we could rewrite that comment:
```
(** returns:  the first element of [lst].  
  * raises:  [Failure "hd"] if [lst = []].
  *)
```
In `[lst = []]`, the outer square brackets indicate source code as part of a comment,
whereas the inner square brackets indicate the empty list.

[std-web]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html
[std-src]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/list.mli

**List comprehensions:**

Some languages, including Python and Haskell, have a syntax called
*comprehension* that allows lists to be written somewhat like set
comprehensions from mathematics.  The earliest example of comprehensions
seems to be the functional language NPL, which was designed in 1977. 
OCaml doesn't have built-in syntactic support for comprehensions, though
that doesn't make the language any less expressive:  everything you can
do with comprehensions can be done with more primitive language
features.  Moreover, we won't be using comprehensions in this course, so
it's safe for you to ignore the rest of this subsection.

*The following instructions are currently not working as of Fall 2019;
the `ppx_monadic` package (and its dependencies) haven't yet been updated
to work with OCaml 4.08.x.  We'll leave this here for future reference,
hoping that support is restored someday.*

It is possible to get support for them with the `ppx_monadic` package.
Install it with this command:
```
opam install -y ppx_monadic
```
Then in utop you can write comprehensions in a Haskell-like notation:
```
# #require "ppx_monadic";;
# [%comp x+y || x <-- [1;2;3]; y <-- [1;2;3]; x<y];;
- : int list = [3; 4; 5]  
```
