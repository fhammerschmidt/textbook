# How to Create the Textbook Environment

- Install
  [Miniconda3 for Python 3.9](https://docs.conda.io/en/latest/miniconda.html).
- Run `conda update -n base -c defaults conda` to upgrade that base install to
  latest versions.
- Proceed with one of the next two options.

Automatic option (recommended for quality of life):

- Install [conda-auto-env](https://github.com/introkun/conda-auto-env). All you
  have to do is clone the repo and source the script.
- Now any time you `cd` into the root of the textbook repo you'll have the right
  environment active. You lose the environment by cd'ing below it though.

Manual option:

- Run `conda env create -f environment.yml` to create the `textbook`
  environment.
- Run `conda activate textbook` to activate the environment **every time** you
  want to work on the textbook.

# How to Build the Textbook

- Run `make build` or just `make` to build the HTML version.
- Run `make view` (currently supported on Mac only) to conveniently open the
  generated HTML in your browser.
- Run `make deploy` to deploy the textbook to GitHub Pages. Before doing that,
  you need to have a git remote set up. You can do so with
  `git remote add public git@github.com:cs3110/textbook.git`. The name of the
  remote, `public` in that example command, can be configured at the top of
  `Makefile` if you want to use a different name.