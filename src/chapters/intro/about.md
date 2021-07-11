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

# About This Book

**Reporting Errors.** If you find an error, please report it! Or if you have a
suggestion about how to rewrite some part of the book, let us know. Just go to
the page of the book for which you'd like to make a suggestion, click on the
Github icon (it looks like a cat) near the top right of the page, and click
"open issue" or "suggest edit". The latter is a little heavier weight, because
it requires you to fork the textbook repository with Github. But for minor edits
that will be appreciated and lead to much quicker uptake of suggestions.

**Videos.** You will find about 200 YouTube videos embedded throughout this
book. The videos usually provide an introduction to material, upon which the
textbook then expands. These videos were produced during pandemic when the
Cornell course that uses this textbook, CS 3110, had to be asynchronous. The
student response to them was overwhelmingly positive, so they are now being made
public as part of the textbook. But just so you know, they were not produced by
a professional A/V team&mdash;just a guy in his basement who was learning as he
went.

The videos mostly use the versions of OCaml and its ecosystem that were current
in Fall 2020. Current versions you are using are likely to look different from
the videos, but don't be alarmed: the underlying ideas are the same. The most
visible difference is likely to be the VS Code plugin for OCaml. In Fall 2020
the badly-aging "OCaml and Reason IDE" plugin was still being used. It has since
been superseded by the "OCaml Platform" plugin.

The order that the textbook covers topics sometimes differs from the order that
the videos cover the topics, simply because the videos originate from lectures.
The videos are placed in the textbook nearest to the topic they cover, but that
does mean sometimes the videos are not in chronological order.

**Collaborative Annotations.** At the right margin of each page, you will find
an annotation feature provided by [hypothes.is][hypothesis]. You can use this to
highlight and make private notes as you study the text. You can form study
groups to share your annotations, or share them publicly. Check out these
[tips for how to annotate effectively][tips].

[hypothesis]: https://web.hypothes.is/
[tips]: https://web.hypothes.is/annotation-tips-for-students/

**Downloadable Pages.** Each page of this book is downloadable in a variety of
formats. The download icon is at the top right of each page. You'll always find
the original source code of the page, which is usually [Markdown][md]&mdash;or
more precisely [MyST Markdown][myst], which is an extension of Markdown for
technical writing. Each page is also individually available as PDF, which simply
prints from your browser. For the entire book as a PDF, see the paragraph about
that below.

Pages with OCaml code cells embedded in them, such as the one below, can also be
downloaded as [Jupyter notebooks][jupyter].

```{code-cell} ocaml
print_endline "Hello world!"
```

Jupyter notebooks are documents (usually ending in the `.ipynb` extension) that
can be opened in your web browser and used to write narrative content as well as
code. They became popular in data science communities (especially Python, R, and
Julia) as a way of sharing analyses. Now many languages can run in Jupyter
notebooks, including OCaml.

To use Jupyter notebooks locally on your own machine, you'll need to install
Jupyter. The easiest way of doing that is typically to install
[Anaconda][anaconda]. Then you'll need to install
[OCaml Jupyter][ocaml-jupyter], which requires that you already have OCaml
installed.

To be clear, there's no need to install Jupyter or to use notebooks. But it's a
nice way to interact with the code if you're wondering what would happen if you
were to tweak some of the example code provided in the textbook. Instead of
having to copy and paste all the code from a page into an OCaml file, you can
just fire up the notebook and start tweaking the code.

[md]: https://en.wikipedia.org/wiki/Markdown
[myst]: https://myst-parser.readthedocs.io/en/latest/
[jupyter]: https://jupyter.org/
[anaconda]: https://www.anaconda.com/
[ocaml-jupyter]: https://github.com/akabe/ocaml-jupyter

**Exercises and Solutions.** At the end of each chapter except the first, you
will find a section of exercises. The exercises are annotated with a difficulty
rating:

* One star [&starf;]: easy exercises that should take only a minute or two.

* Two stars [&starf;&starf;]: straightforward exercises that should take a few
  minutes.

* Three stars [&starf;&starf;&starf;]: exercises that might require anywhere
  from five to twenty minutes or so.

* Four [&starf;&starf;&starf;&starf;] or more stars: challenging or
  time-consuming exercises provided for students who want to dig deeper into the
  material.

It's possible we've misjudged the difficulty of a problem from time to time. Let
us know if you think an annotation is off.

Please do not post your solutions to the exercises anywhere, especially not in
public repositories where they could be found by search engines. {{ solutions }}

**Binder.** TODO

**PDF.** An experimental <a href="ocaml_programming.pdf">full PDF version of
this book</a> is available. It does not contain the embedded videos,
annotations, or other features that the HTML version has. It might also have
typesetting errors. At this time, no tablet (ePub, etc.) version is available,
but most tablets will let you import PDFs.