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

# Functional Data Structures

A *functional data structure* is one that does not make use of any imperative
features. That is, no operations of the data structure have any side effects.
It's possible to build functional data structures both in functional languages
and in imperative languages.

Functional data structures have the property of being *persistent*: updating the
data structure with one of its operations does not change the existing version
of the data structure but instead produces a new version. Both exist and both
can still be accessed. A good language implementation will ensure that any parts
of the data structure that are not changed by an operation will be *shared*
between the old version and the new version. Any parts that do change will be
*copied* so that the old version may persist. The opposite of a persistent data
structure is an *ephemeral* data structure: changes are destructive, so that
only one version exists at any time. Both persistent and ephemeral data
structures can be built in both functional and imperative languages.

## Lists

The built-in singly-linked `list` data structure in OCaml is functional. We know
that, because we've seen how to implement it with algebraic data types. It's
also persistent, which we can demonstrate:

```{code-cell} ocaml
let lst = [1; 2];;
let lst' = List.tl lst;;
lst';;
```

Taking the tail of `lst` does not change the list. Both `lst` and `lst'`
coexist without affecting one another.

## Stacks

We implemented stacks earlier in this chapter. Here's a terse variant of one of
those implementations, in which add a `to_list` operation to make it easier to
view the contents of the stack in examples:

```{code-cell} ocaml
:tags: ["hide-output"]
module type Stack = sig
  type 'a t
  exception Empty
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a -> 'a t -> 'a t
  val peek : 'a t -> 'a
  val pop : 'a t -> 'a t
  val size : 'a t -> int
  val to_list : 'a t -> 'a list
end

module ListStack : Stack = struct
  type 'a t = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push = List.cons
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
  let size = List.length
  let to_list = Fun.id
end
```

That implementation is functional, as can be seen above, and also persistent:

```{code-cell} ocaml
open ListStack;;
let s = empty |> push 1 |> push 2;;
let s' = pop s;;
to_list s;;
to_list s';;
```

The value `s` is unchanged by the `pop` operation on `s'`. Both versions of the
stack coexist.

The `Stack` module type gives us a strong hint that the data structure is
persistent in the types it provides for `push` and `pop`:

```ocaml
val push : 'a -> 'a t -> 'a t
val pop : 'a t -> 'a t
```

Both of those take a stack as an argument and return a new stack as a result. An
ephemeral data structure usually would not bother to return a stack. In Java,
for example, similar methods might have a `void` return type; the equivalent in
OCaml would be returning `unit`.

## Options vs Exceptions

All of our stack implementations so far have raised an exception whenever `peek`
or `pop` is applied to the empty stack. Another possibility would be to use an
`option` for the return value. If the input stack is empty, then `peek` and
`pop` return `None`; otherwise, they return `Some`.

```{code-cell} ocaml
:tags: ["hide-output"]
module type Stack = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a -> 'a t -> 'a t
  val peek : 'a t -> 'a option
  val pop : 'a t -> 'a t option
  val size : 'a t -> int
  val to_list : 'a t -> 'a list
end

module ListStack : Stack = struct
  type 'a t = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push = List.cons
  let peek = function [] -> None | x :: _ -> Some x
  let pop = function [] -> None | _ :: s -> Some s
  let size = List.length
  let to_list = Fun.id
end
```

But that makes it harder to pipeline:

```{code-cell} ocaml
:tags: ["raises-exception"]
ListStack.(empty |> push 1 |> pop |> peek)
```

The types break down for the pipeline right after the `pop`, because that
now returns an `'a t option`, but `peek` expects an input that is merely
an `'a t`.

It is possible to define some additional operators to help restore the ability
to pipeline. In fact, these functions are already defined in the `Option` module
in the standard library, though not as infix operators:

```{code-cell} ocaml
(* Option.map aka fmap *)
let ( >>| ) opt f =
  match opt with
  | None -> None
  | Some x -> Some (f x)

(* Option.bind *)
let ( >>= ) opt f =
  match opt with
  | None -> None
  | Some x -> f x
```

We can use those as needed for pipelining:

```{code-cell} ocaml
ListStack.(empty |> push 1 |> pop >>| push 2 >>= pop >>| push 3 >>| to_list)
```

But it's not so pleasant to figure out which of the three operators to use
where.

There is therefore a tradeoff in the interface design:

* Using options ensures that surprising exceptions regarding empty stacks never
  occur at run-time. The program is therefore more robust. But the convenient
  pipeline operator is lost.

* Using exceptions means that programmers don't have to write as much code. If
  they are sure that an exception can't occur, they can omit the code for
  handling it. The program is less robust, but writing it is more convenient.

There is thus a tradeoff between writing more code early (with options) or doing
more debugging later (with exceptions). The OCaml standard library has recently
begun providing both versions of the interface in a data structure, so that the
client can make the choice of how they want to use it.  For example, we could
provide both `peek` and `peek_opt`, and the same for `pop`, for clients of
our stack module:

```{code-cell} ocaml
:tags: ["hide-output"]
module type Stack = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a -> 'a t -> 'a t
  val peek : 'a t -> 'a
  val peek_opt : 'a t -> 'a option
  val pop : 'a t -> 'a t
  val pop_opt : 'a t -> 'a t option
  val size : 'a t -> int
  val to_list : 'a t -> 'a list
end

module ListStack : Stack = struct
  type 'a t = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push = List.cons
  let peek = function [] -> raise Empty | x :: _ -> x
  let peek_opt = function [] -> None | x :: _ -> Some x
  let pop = function [] -> raise Empty | _ :: s -> s
  let pop_opt = function [] -> None | _ :: s -> Some s
  let size = List.length
  let to_list = Fun.id
end
```

One nice thing about this implementation is that it is efficient. All the
operations except for `size` are constant time. We saw earlier in the chapter
that `size` could be made constant time as well, at the cost of some extra space
&mdash; though just a constant factor more &mdash; by caching the size of the
stack at each node in the list.

## Queues

Queues and stacks are fairly similar interfaces.  We'll stick with exceptions
instead of options for now.

```{code-cell} ocaml
:tags: ["hide-output"]
module type Queue = sig
  (** An ['a t] is a queue whose elements have type ['a]. *)
  type 'a t

  (** Raised if [front] or [dequeue] is applied to the empty queue. *)
  exception Empty

  (** [empty] is the empty queue. *)
  val empty : 'a t

  (** [is_empty q] is whether [q] is empty. *)
  val is_empty : 'a t -> bool

  (** [enqueue x q] is the queue [q] with [x] added to the end. *)
  val enqueue : 'a -> 'a t -> 'a t

  (** [front q] is the element at the front of the queue. Raises [Empty]
      if [q] is empty. *)
  val front : 'a t -> 'a

  (** [dequeue q] is the queue containing all the elements of [q] except the
      front of [q]. Raises [Empty] is [q] is empty. *)
  val dequeue : 'a t -> 'a t

  (** [size q] is the number of elements in [q]. *)
  val size : 'a t -> int

  (** [to_list q] is a list containing the elements of [q] in order from
      front to back. *)
  val to_list : 'a t -> 'a list
end
```

```{important}
Similarly to `peek` and `pop`, note how `front` and `dequeue` divide the
responsibility of getting the first element vs. getting all the rest of the
elements.
```

It's easy to implement queues with lists, just as it was for implementing
stacks:

```{code-cell} ocaml
module ListQueue : Queue = struct
  (** The list [x1; x2; ...; xn] represents the queue with [x1] at its front,
      followed by [x2], ..., followed by [xn]. *)
  type 'a t = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let enqueue x q = q @ [x]
  let front = function [] -> raise Empty | x :: _ -> x
  let dequeue = function [] -> raise Empty | _ :: q -> q
  let size = List.length
  let to_list = Fun.id
end
```

But despite being as easy, this implementation is not as efficient as our
list-based stacks. Dequeueing is a constant-time operation with this
representation, but enqueueing is a linear-time operation. That's because
`dequeue` does a single pattern match, whereas `enqueue` must traverse the
entire list to append the new element at the end.

There's a very clever way to do better on efficiency. We can use two lists to
represent a single queue. This representation was invented by Robert Melville as
part of his PhD dissertation at Cornell (*Asymptotic Complexity of Iterative
Computations*, Jan 1981), which was advised by Prof. David Gries. Chris Okasaki
(*Purely Functional Data Structures*, Cambridge University Press, 1988) calls
these *batched queues*. Sometimes you will see this same implementation referred
to as "implementing a queue with two stacks". That's because stacks and lists
are so similar (as we've already seen) that you could rewrite `pop` as
`List.tl`, and so forth.

The core idea has a Part A and a Part B. Part A is: we use the two lists to
split the queue into two pieces, the *inbox* and *outbox*. When new elements are
enqueued, we put them in the inbox. Eventually (we'll soon come to how) elements
are transferred from the inbox to the outbox. When a dequeue is requested, that
element is removed from the outbox; or when the front element is requested, we
check the outbox for it. For example, if the inbox currently had `[3; 4; 5]` and
the outbox had `[1; 2]`, then the front element would be `1`, which is the head
of the outbox. Dequeuing would remove that element and leave the inbox with just
`[2]`, which is the tail of the outbox. Likewise, enqueuing `6` would make the
inbox become `[3; 4; 5; 6]`.

The efficiency of `front` and `dequeue` is very good so far. We just have to
take the head or tail of the outbox, respectively, assuming it is non-empty.
Those are constant-time operations. But the efficiency of `enqueue` is still
bad. It's linear time, because we have to append the new element to the end of
the list. It's too bad we have to use the append operator, which is inherently
linear time. It would be much better if we could use cons, which is constant
time.

So here's Part B of the core idea: let's keep the inbox in reverse order.  For
example, if we enqueued `3` then `4` then `5`, the inbox would actually
be `[5; 4; 3]`, not `[3; 4; 5]`.  Then if `6` were enqueued next, we could
cons it onto the beginning of the inbox, which becomes `[6; 5; 4; 3]`.  The
queue represented by inbox `i` and outbox `o` is therefore `o @ List.rev i`.
So `enqueue` can now always be a constant-time operation.

But what about `dequeue` (and `front`)? They're constant time too, **as long as
the outbox is not empty.** If it's empty, we have a problem. We need to transfer
whatever is in the inbox to the outbox at that point.  For example, if the
outbox is empty, and the inbox is `[6; 5; 4; 3]`, then we need to switch them
around, making the outbox be `[3; 4; 5; 6]` and the inbox be empty.  That's
actually easy:  we just have to reverse the list.

Unfortunately, we just re-introduced a linear-time operation. But with one
crucial difference: we don't have to do that linear-time reverse on every
`dequeue`, whereas with `ListQueue` above we had to do the linear-time append on
every `enqueue`. Instead, we only have to do the reverse on those rare occasions
when the outbox becomes empty.

So even though in the worst case `dequeue` (and `front`) will be linear time,
most of the time they will not be. In fact, later in this book when we study
*amortized analysis* we will show that in the long run they can be understood as
constant-time operations. For now, here's a piece of intuition to support that
claim: every individual element enters the outbox once (with a cons), moves to
the inbox once (with a pattern match then cons), and leaves the inbox once (with
a pattern match). Each of those is constant time. So each element only ever
experiences constant-time operations from its own perspective.

For now, let's move on to implementing these ideas. In the implementation, we'll
add one more idea: the outbox always has to have an element in it, unless the
queue is empty. In other words, if the outbox is empty, we're guaranteed the
inbox is too. That requirement isn't necessary for batched queues, but it does
keep the code simpler by reducing the number of times we have to check whether a
list is empty. The tiny tradeoff is that if the queue is empty, `enqueue` now
has to directly put an element into the outbox. No matter, that's still a
constant-time operation.

```{code-cell} ocaml
module BatchedQueue : Queue = struct
  (** [{o; i]} represents the queue [o @ List.rev i]. For example,
      [{o = [1; 2]; i = [5; 4; 3]}] represents the queue [1, 2, 3, 4, 5],
      where [1] is the front element. To avoid ambiguity about emptiness,
      whenever only one of the lists is empty, it must be [i]. For example,
      [{o = [1]; i = []}] is a legal representation, but [{o = []; i = [1]}]
      is not. This implies that if [o] is empty, [i] must also be empty. *)
  type 'a t = {o : 'a list; i : 'a list}

  exception Empty

  let empty = {o = []; i = []}

  let is_empty = function
    | {o = []} -> true
    | _ -> false

  let enqueue x = function
    | {o = []} -> {o = [x]; i = []}
    | {o; i} -> {o; i = x :: i}

  let front = function
    | {o = []} -> raise Empty
    | {o = h :: _} -> h

  let dequeue = function
    | {o = []} -> raise Empty
    | {o = [_]; i} -> {o = List.rev i; i = []}
    | {o = _ :: t; i} -> {o = t; i}

  let size {o; i} = List.(length o + length i)

  let to_list {o; i} = o @ List.rev i
end
```

The efficiency of batched queues comes at a price in readability. If we compare
`ListQueue` and `BatchedQueue`, it's hopefully clear that `ListQueue` is a
simple and correct implementation of a queue data structure. It's probably far
less clear that `BatchedQueue` is a correct implementation. Just look at how
many paragraphs of writing it took to explain it above!

## Dictionaries

A *dictionary* maps *keys* to *values*.  This data structure typically
supports at least a lookup operation that allows you to find the value
with a corresponding key, an insert operation that lets you create a new
dictionary with an extra key included.  And there needs to be a way of
creating an empty dictionary.

We might represent this in a `Dictionary` module type as follows:

```
module type Dictionary = sig
  type ('k, 'v) t

  (* The empty dictionary *)
  val empty  : ('k, 'v) t

  (* [insert k v d] produces a new dictionary [d'] with the same mappings
   * as [d] and also a mapping from [k] to [v], even if [k] was already
   * mapped in [d]. *)
  val insert : 'k -> 'v -> ('k,'v) t -> ('k,'v) t

  (* [lookup k d] returns the value associated with [k] in [d].
   * raises:  [Not_found] if [k] is not mapped to any value in [d]. *)
  val lookup  : 'k -> ('k,'v) t -> 'v
end
```

Note how the type `Dictionary.t` is parameterized on two types, `'k` and `'v`,
which are written in parentheses and separated by commas.  Although `('k,'v)`
might look like a pair of values, it is not: it is a syntax for writing
multiple type variables.

We have seen already in this class that an association list can be used
as a simple implementation of a dictionary.  For example, here is an
association list that maps some well-known names to an approximation of
their numeric value:

```
[("pi", 3.14); ("e", 2.718); ("phi", 1.618)]
```

Let's try implementing the `Dictionary` module type with a module
called `AssocListDict`.

```
module AssocListDict = struct
  type ('k, 'v) t = ('k * 'v) list

  let empty = []

  let insert k v d = (k,v)::d

  let lookup k d = List.assoc k d
end
```

If we put that code in a file named `dict.ml`, launch utop, and type:
```
# #use "dict.ml";;
# open AssocListDict;;
# let d = insert 1 "one" empty;;
```
The response we get is:
```
val d : (int * string) list = [(1, "one")]
```

But if we change the first line of the implementation of
`AssocListDict` in `dict.ml` to the following:
```
module AssocListDict : Dictionary = struct
```
And if we restart utop and repeat the three phrases above (use,open,let),
we get a different response:
```
val d : (int, string) t = <abstr>
```

That's because by indicating that the module has type `Dictionary`, the
type `AssocListDict.t` has become abstract.  Clients of the module
are no longer permitted to know that it is implemented with a list.
That provides encapsulation, so that if we later wanted to change
the representation, we could safely do so.

## Sets

Here is a signature for sets:
```
module type Set = sig
  type 'a t

  (* [empty] is the empty set *)
  val empty : 'a t

  (* [mem x s] holds iff [x] is an element of [s] *)
  val mem   : 'a -> 'a t -> bool

  (* [add x s] is the set [s] unioned with the set containing exactly [x] *)
  val add   : 'a -> 'a t -> 'a t

  (* [elts s] is a list containing the elements of [s].  No guarantee
   * is made about the ordering of that list. *)
  val elts  : 'a t -> 'a list
end
```
There are many other operations a set data structure might be expected to
support, but these will suffice for now.

Here's an implementation of that interface using a list to represent the
set. This implementation ensures that the list never contains any
duplicate elements, since sets themselves do not:
```
module ListSetNoDups : Set = struct
  type 'a t   = 'a list
  let empty   = []
  let mem     = List.mem
  let add x s = if mem x s then s else x::s
  let elts s  = s
end
```
Note how `add` ensures that the representation never contains any duplicates,
so the implementation of `elts` is quite easy.  Of course, that makes the
implementation of `add` linear time, which is not ideal.  But if we want
high-performance sets, lists are not the right representation anyway;
there are much better data structures for sets, which you might
see in an upper-level algorithms course.

Here's a second implementation, which permits duplicates in the list:
```
module ListSetDups : Set = struct
  type 'a t   = 'a list
  let empty   = []
  let mem     = List.mem
  let add x s = x::s
  let elts s  = List.sort_uniq Stdlib.compare s
end
```
In that implementation, the `add` operation is now constant time, and
the `elts` operation is linearithmic time.

##  Arithmetic

Here is a module type that represents values that support the usual operations from
arithmetic, or more precisely, a *[field][]*:

[field]: https://en.wikipedia.org/wiki/Field_(mathematics)

```
module type Arith = sig
  type t
  val zero  : t
  val one   : t
  val (+)   : t -> t -> t
  val ( * ) : t -> t -> t
  val (~-)  : t -> t
end
```
There are a couple syntactic curiosities here.  We have to write `( * )` instead
of `(*)` because the latter would be parsed as beginning a comment.  And
we write the `~` in `(~-)` to indicate a *unary* negation operator.

Here is a module that implements that module type:
```
module Ints : Arith = struct
  type t    = int
  let zero  = 0
  let one   = 1
  let (+)   = Stdlib.(+)
  let ( * ) = Stdlib.( * )
  let (~-)  = Stdlib.(~-)
end
```

Outside of the module `Ints`, the expression `Ints.(one + one)` is perfectly fine,
but `Ints.(1 + 1)` is not, because `t` is abstract:  outside the module no one
is permitted to know that `t = int`.  In fact, the toplevel can't even give us
good output about what the sum of one and one is!
```
# Ints.(one + one);;
- : Ints.t = <abstr>
```

The reason why is that the type `Ints.t` is abstract: the module type doesn't
tell use that `Ints.t` is `int`.  This is actually a good thing in many cases:
code outside of `Ints` can't rely on the internal implementation details of
`Ints`, and so we are free to change it.
Since the `Arith` interface only has functions that return `t`, so once you
have a value of type `t`, all you can do is create other values of type `t`.

When designing an interface with an abstract type, you will almost certainly
want at least one function that returns something other than that type.
For example, it's often useful to provide a `to_string` function.  We could
add that to the `Arith` module type:
```
module type Arith = sig
  (* everything else as before, and... *)
  val to_string : t -> string
end
```
And now we would need to implement it as part of `Ints`:
```
module Ints : Arith = struct
  (* everything else as before, and... *)
  let to_string = string_of_int
end
```
Now we can write:
```
# Ints.(to_string (one + one));;
- : string = "2"
```
