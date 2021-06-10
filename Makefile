.PHONY: help notebooks stage deploy

BLUE=\033[0;34m
NOCOLOR=\033[0m
BOOK=src

default: build

help:
	@echo "Please use 'make <target>' where <target> is one of:"
	@echo "  build         to build locally."
	@echo "  view          to view in browser (Mac only)."
	@echo "  deploy        to deploy the book to the course website."
	@echo "  clean         to remove all generated files."

clean:
	jupyter-book clean ${BOOK}

build:
	jupyter-book build ${BOOK}
	
view: build
	open ${BOOK}/_build/html/index.html

deploy:
	@echo "${BLUE}REMINDER: always 'make build' or 'make serve' before deploying.${NOCOLOR}"
	@echo ""
	@echo "${BLUE}Deploying book to course website.${NOCOLOR}"
	@echo "${BLUE}=================================${NOCOLOR}"
	./deploy.sh
	@echo ""
	@echo "${BLUE}    Done."
