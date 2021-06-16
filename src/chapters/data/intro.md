# Data

In this chapter, we'll examine some of OCaml's built-in data types, including
lists, variants, records, tuples, and options. Many of those are likely to feel
familiar from other programming languages. In particular,

- **lists** and **tuples**, might feel similar to Python; and

- **records** and **variants**, might feel similar to `struct` and `enum` types
  from C or Java.

Because of that familiarity, we call these *standard* data types. We'll learn
about *pattern matching*, which is a feature that's less likely to be familiar.

Almost immediately after we learn about lists, we'll pause our study of standard
data types to learn about unit testing in OCaml with OUnit, a unit testing
framework similar to those you might have used in other languages. OUnit relies
on lists, which is why we couldn't cover it before now.

Later in the chapter, we will see how we can define our own *algebraic data
types*. We'll also discover how several of OCaml's built-in data types are
actually definable with algebraic data types. We'll use algebraic data types to
define our own custom types for trees and maps.