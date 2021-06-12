BOOK=src
HTML=${BOOK}/_build/html
REMOTE=public

default: build

clean:
	jupyter-book clean ${BOOK}

build:
	jupyter-book build ${BOOK}

view: build
	open ${HTML}/index.html

deploy: build
	ghp-import -n -p -f ${HTML} -r ${REMOTE} -m "Update textbook"
