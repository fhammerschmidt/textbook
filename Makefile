# REMOTE is the name of the git remote that hosts
# https://github.com/cs3110/textbook. The gh-pages branch there is
# automatically served by https://cs3110.github.io/textbook.
REMOTE=public

BOOK=src
HTML=${BOOK}/_build/html
LATEX=${BOOK}/_build/latex
PDF_NAME=ocaml_programming.pdf

default: html

clean:
	jupyter-book clean ${BOOK}

html:
	jupyter-book build -W ${BOOK}

view:
	open ${HTML}/index.html

pdf:
	jupyter-book build src --builder pdflatex

view-pdf:
	open ${LATEX}/book.pdf

deploy: html pdf
	cp ${LATEX}/book.pdf ${HTML}/${PDF_NAME} \
	  && ghp-import -n -p -f ${HTML} -r ${REMOTE} -m "Update textbook"