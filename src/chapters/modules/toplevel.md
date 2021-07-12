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

# Modules and the Toplevel

{{ video_embed | replace("%%VID%%", "4yo-04VVzIw")}}

There are several pragmatics involving modules and the toplevel that are
important to master to use the two together effectively.

## Loading Compiled Modules

Compiling an OCaml file produces a module having the same name as the file, but
with the first letter capitalized. These compiled modules can be loaded into the
toplevel using `#load`.

For example, suppose you create a file called `mods.ml`, and put the following
code in it:

```ocaml
let b = "bigred"
let inc x = x + 1
module M = struct
  let y = 42
end
```

Note that there is no `module Mods = struct ... end` around that. The code is at
the topmost level of the file, as it were.

Then suppose you type `ocamlbuild mods.byte` to compile it. Inside the `_build`
directory you will now find the files that `ocamlbuild` produced. One of them is
`mods.cmo`: this is a <u>c</u>ompiled <u>m</u>odule <u>o</u>bject file, aka
bytecode.

You can make this bytecode available for use in the toplevel with the following
directives. Recall that the `#` character is required in front of a directive.
It is not part of the prompt.

```ocaml
# #directory "_build";;
# #load "mods.cmo";;
```

The first directive tells utop to add the `_build` directory to the path in
which it looks for compiled (and source) files. The second directive loads the
bytecode found in `mods.cmo`, thus making a module named `Mods` available to be
used.  It exactly as if you had entered this code:

```{code-cell} ocaml
module Mods = struct
  let b = "bigred"
  let inc x = x + 1
  module M = struct
    let y = 42
  end
end
```

Both of these expressions will therefore evaluate successfully:

```{code-cell} ocaml
Mods.b;;
Mods.M.y;;
```

But this will fail:
```{code-cell} ocaml
:tags: ["raises-exception"]
inc
```

It fails because `inc` is in the namespace of `Mods`.
```{code-cell} ocaml
Mods.inc
```

Of course, if you open the module, you can directly name `inc`:

```{code-cell} ocaml
open Mods;;
inc;;
```

## Initializing the Toplevel

If you are doing a lot of testing of a particular module, it can be annoying to
have to type those directives (`#directory` and `#load`) every time you start
utop. You really want to initialize the toplevel with some code as it launches,
so that you don't have to keep typing that code.

The solution is to create a file in the working directory and call that file
`.ocamlinit`. Note that the `.` at the front of that filename is required and
makes it a [hidden file][hidden] that won't appear in directory listings unless
explicitly requested (e.g., with `ls -a`). Everything in `.ocamlinit` will be
processed by utop when it loads.

[hidden]: https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory

For example, suppose you create a file named `.ocamlinit` in the same directory
as `mods.ml`, and in that file put the following code:

```ocaml
#directory "_build";;
#load "mods.cmo";;
open Mods
```

Now restart utop. All the names defined in `Mods` will already be in scope. For
example, these will both succeed:

```{code-cell} ocaml
inc;;
M.y;;
```

## Requiring Libraries

Suppose you were to add the following lines to the end of `mods.ml`:

```ocaml
open OUnit2
let test = "testb" >:: (fun _ -> assert_equal "bigred" b)
```

If you try to recompile the module with `ocamlbuild mods.byte`, it will fail.
The problem is that you need to tell the build system to include the third-party
library OUnit. Recompiling with `ocamlbuild -pkg ounit2 mods.byte` will, as
usual, succeed.

But if you restart utop, there will be an error message:

```text
File ".ocamlinit", line 1:
Error: Reference to undefined global `OUnit2'
```

The problem is that the OUnit library hasn't been loaded into utop yet. It can
be with the following directive:

```ocaml
#require "ounit2";;
```

Now you can successfully load your own module without getting an error.

```ocaml
#load "mods.cmo";;
```

Moreover, if you add that `#require` directive to `.ocamlinit` anywhere before
the `#load` directive, the "undefined global" error will go away.

## Dependencies

When compiling a file, the build system automatically figures out which other
files it depends on and recompiles those as necessary. The toplevel, however, is
not as sophisticated: you have to make sure to load all the dependencies of a
file.

Suppose you have a file named `mods2.ml` in the same directory as `mods.ml`
from above, and `mods2.ml` contains this code:

```ocaml
open Mods
let x = inc 0
```

If you run `ocamlbuild -pkg ounit2 mods2.byte`, the compilation will succeed.
You don't have to name `mods.byte` on the command line, even though `mods2.ml`
depends on the module `Mod`. The build system is smart that way.

Also suppose that `.ocamlinit` contains exactly the following:

```ocaml
#directory "_build";;
#require "ounit2";;
```

If you restart utop and try to load `mods2.cmo`, you will get an error:

```text
# #load "mods2.cmo";;
Error: Reference to undefined global `Mods'
```

The problem is that the toplevel does not automatically load the modules that
`Mods2` depends upon. There are two ways to solve this problem.
First, you can manually load the dependencies, like this:

```ocaml
# #load "mods.cmo";;
# #load "mods2.cmo";;
```

Second, you could instead tell the toplevel to load `Mods2` and recursively
to load everything it depends on:

```ocaml
# #load_rec "mods2.cmo";;
```

And that is probably the better solution.

## Load vs Use

There is a big difference between `#load`-ing a compiled module file and
`#use`-ing an uncompiled source file. The former loads bytecode and makes it
available for use. For example, loading `mods.cmo` caused the `Mod` module to be
available, and we could access its members with expressions like `Mod.b`. The
latter (`#use`) is *textual inclusion*: it's like typing the contents of the
file directly into the toplevel. So using `mods.ml` does **not** cause a `Mod`
module to be available, and the definitions in the file can be accessed
directly, e.g., `b`.

For example, in the following interaction, we can directly refer to `b` but
cannot use the qualified name `Mods.b`:

```text
# #use "mods.ml"

# b;;
val b : string = "bigred"

# Mods.b;;
Error: Unbound module Mods
```

Whereas in this interaction the situation is reversed:

```text
# #directory "_build";;
# #load "mods.cmo";;

# Mods.b;;
- : string = "bigred"

# b;;
Error: Unbound value b
```

So when you're using the toplevel to experiment with your code, it's often
better to work with `#load` rather than `#use`. The `#load` directive accurately
reflects how your modules interact with each other and with the outside world.
