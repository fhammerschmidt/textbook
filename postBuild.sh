#!/bin/bash

set -ex

opam switch create 4.11.1 ocaml-base-compiler.4.11.1
opam install jupyter
ocaml-jupyter-opam-genspec
jupyter kernelspec install --user --name ocaml-jupyter "$(opam var share)/jupyter"
