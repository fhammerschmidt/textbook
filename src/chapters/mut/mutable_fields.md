---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Mutable Fields

The fields of a record can be declared as mutable, meaning their contents can be
updated without constructing a new record. For example, here is a record type
for two-dimensional colored points whose color field `c` is mutable:

```{code-cell} ocaml
type point = {x : int; y : int; mutable c : string}
```

Note that `mutable` is a property of the field, rather than the type of the
field. In particular, we write `mutable field : type`, not
`field : mutable type`.

The operator to update a mutable field is `<-` which is meant to look like
a left arrow.

```{code-cell} ocaml
let p = {x = 0; y = 0; c = "red"}
```

```{code-cell} ocaml
p.c <- "white"
```

```{code-cell} ocaml
p
```

Non-mutable fields cannot be updated that way:

```{code-cell} ocaml
:tags: ["raises-exception"]
p.x <- 3;;
```

* **Syntax:** `e1.f <- e2`

* **Dynamic semantics:** To evaluate `e1.f <- e2`, evaluate `e2` to a value
  `v2`, and `e1` to a value `v1`, which must have a field named `f`. Update
  `v1.f` to `v2`. Return `()`.

* **Static semantics:** `e1.f <- e2 : unit` if `e1 : t1` and
  `t1 = {...; mutable f : t2; ...}`, and `e2 : t2`.

## Refs Are Mutable Fields

It turns out that refs are actually implemented as mutable fields. In
[`Stdlib`][stdlib] we find the following declaration:

```ocaml
type 'a ref = { mutable contents : 'a }
```

And that's why when the toplevel outputs a ref it looks like a record: it *is* a
record with a single mutable field named `contents`!

```{code-cell} ocaml
let r = ref 42
```

The other syntax we've seen for records is in fact equivalent to simple OCaml
functions:

```{code-cell} ocaml
let ref x = {contents = x}
```

```{code-cell} ocaml
let ( ! ) r = r.contents
```

```{code-cell} ocaml
let ( := ) r x = r.contents <- x
```

The reason we say "equivalent" is that those functions are actually implemented
not in OCaml itself but in the OCaml run-time, which is implemented mostly in C.
Nonetheless the functions do behave the same as the OCaml source given above.

[stdlib]: https://ocaml.org/api/Stdlib.html

# Example: Mutable Singly-Linked Lists

TODO add week6 mlist code; compare to refs.

# Example: Mutable Stacks

As an example of a mutable data structure, let's look at stacks.  We're
already familiar with functional stacks:
```
exception Empty

module type Stack = sig
  (* ['a t] is the type of stacks whose elements have type ['a]. *)
  type 'a t

  (* [empty] is the empty stack *)
  val empty : 'a t

  (* [push x s] is the stack whose top is [x] and the rest is [s]. *)
  val push : 'a -> 'a t -> 'a t

  (* [peek s] is the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val peek : 'a t -> 'a

  (* [pop s] is all but the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val pop : 'a t -> 'a t
end
```

An interface for a *mutable* or *non-persistent* stack would look a
little different:
```
module type MutableStack = sig
  (* ['a t] is the type of mutable stacks whose elements have type ['a].
   * The stack is mutable not in the sense that its elements can
   * be changed, but in the sense that it is not persistent:
   * the operations [push] and [pop] destructively modify the stack. *)
  type 'a t

  (* [empty ()] is the empty stack *)
  val empty : unit -> 'a t

  (* [push x s] modifies [s] to make [x] its top element.
   * The rest of the elements are unchanged. *)
  val push : 'a -> 'a t -> unit

  (* [peek s] is the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val peek : 'a t -> 'a

  (* [pop s] removes the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val pop : 'a t -> unit
end
```
Notice especially how the type of `empty` changes:  instead of being a
value, it is now a function.  This is typical of functions that create
mutable data structures. Also notice how the types of `push` and `pop`
change: instead of returning an `'a t`, they return `unit`.  This again
is typical of functions that modify mutable data structures. In all
these cases, the use of `unit` makes the functions more like their
equivalents in an imperative language.  The constructor for an empty
stack in Java, for example, might not take any arguments (which is
equivalent to taking unit).  And the push and pop functions for a Java
stack might return `void`, which is equivalent to returning `unit`.

Now let's implement the mutable stack with a mutable linked list.
We'll have to code that up ourselves, since OCaml linked lists
are persistent.
```
module MutableRecordStack = struct
  (* An ['a node] is a node of a mutable linked list.  It has
   * a field [value] that contains the node's value, and
   * a mutable field [next] that is [Null] if the node has
   * no successor, or [Some n] if the successor is [n]. *)
  type 'a node = {value : 'a; mutable next : 'a node option}

 (* AF: An ['a t] is a stack represented by a mutable linked list.
  * The mutable field [top] is the first node of the list,
  * which is the top of the stack. The empty stack is represented
  * by {top = None}.  The node {top = Some n} represents the
  * stack whose top is [n], and whose remaining elements are
  * the successors of [n]. *)
  type 'a t = {mutable top : 'a node option}

  let empty () =
    {top = None}

  (* To push [x] onto [s], we allocate a new node with [Some {...}].
   * Its successor is the old top of the stack, [s.top].
   * The top of the stack is mutated to be the new node. *)
  let push x s =
    s.top <- Some {value = x; next = s.top}

  let peek s =
    match s.top with
    | None -> raise Empty
    | Some {value} -> value

  (* To pop [s], we mutate the top of the stack to become its successor. *)
  let pop s =
    match s.top with
    | None -> raise Empty
    | Some {next} -> s.top <- next
end
```

Here is some example usage of the mutable stack:
```
# let s = empty ();;
val s : '_a t = {top = None}

# push 1 s;;
- : unit = ()

# s;;
- : int t = {top = Some {value = 1; next = None}}

# push 2 s;;
- : unit = ()

# s;;
- : int t = {top = Some {value = 2; next = Some {value = 1; next = None}}}

# pop s;;
- : unit = ()

# s;;
- : int t = {top = Some {value = 1; next = None}}
```
