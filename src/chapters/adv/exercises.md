# Exercises

##### Exercise: propositions as types [&#10029;&#10029;]

For each of the following propositions, write its corresponding type
in OCaml.

- `true -> p`
- `p /\ (q /\ r)`
- `(p \/ q) \/ r`
- `false -> p`

##### Exercise: programs as proofs [&#10029;&#10029;&#10029;]

For each of the following propositions, determine its corresponding type in
OCaml, then write an OCaml `let` definition to give a program of that type.
Your program proves that the type is *inhabited*, which means there is a value
of that type.  It also proves the proposition holds.

- `p /\ q -> q /\ p`
- `p \/ q -> q \/ p`

##### Exercise: evaluation as simplification [&#10029;&#10029;&#10029;]

Consider the following OCaml program:
```
let f x = snd ((fun x -> x,x) (fst x))
```

- What is the type of that program?
- What is the proposition corresponding to that type?
- How would `f (1,2)` evaluate in the small-step semantics?
- What simplified implementation of `f` does that evaluation suggest?
  (or perhaps there are several, though one is probably the simplest?)
- Does your simplified `f` still have the same type as the original?
  (It should.)

Your simplified `f` and the original `f` are both proofs of
the same proposition, but evaluation has helped you to produce
a simpler proof.
