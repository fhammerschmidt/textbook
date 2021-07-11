# Original source: https://github.com/edmcman/ocaml-jupyter-binder-environment
# Modified by Michael Clarkson starting 7/11/21
# The Python and OCaml packages installed below are not a minimal set for
# the textbook. Archimedes and all its dependencies are not needed. But I've
# preserved them for now in case some data science examples ever would be
# added to the textbook.

FROM ocaml/opam:ubuntu-20.10-ocaml-4.12

# Install Apt packages
RUN sudo -E apt-get update -y
RUN sudo -E apt-get upgrade -y
RUN sudo -E apt-get -y install pkg-config m4 zlib1g-dev python3-pip libcairo2-dev libgmp-dev libzmq3-dev

# Install Jupyter
RUN sudo -E pip3 install notebook nbgitpuller jupytext

# Install the OCaml Jupyter kernel and packages
RUN opam update -y
RUN opam install -y jupyter cairo2 graphics archimedes jupyter-archimedes
RUN eval $(opam env) && ocaml-jupyter-opam-genspec
RUN sudo jupyter kernelspec install --name ocaml-jupyter "$(sudo -E -u opam opam var share)/jupyter"
RUN echo '#use "topfind";;' > /home/opam/.ocamlinit

COPY --chown=opam . /home/opam