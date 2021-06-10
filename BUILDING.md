# How to Create the Textbook Environment

- Install [Miniconda3 for Python 3.9](https://docs.conda.io/en/latest/miniconda.html).
- Run `conda update -n base -c defaults conda` to upgrade that base install to
  latest versions.
- Proceed with one of the next two options.
  
Automatic option (recommended for quality of life):

- Install [conda-auto-env](https://github.com/introkun/conda-auto-env). All you have
  to do is clone the repo and source the script.
- Now any time you `cd` into the textbook you'll have the right environment active.

Manual option:
  
- Run `conda env create -f environment.yml` to create the `textbook` environment.
- Run `conda activate textbook` to activate the environment **every time** you want
  to work on the textbook.

# How to Build the Textbook

- Run `make build` or just `make` to build the HTML version.
- Run `make view` (currently supported on Mac only) to conveniently open the generated
  HTML in your browser.

# Old instructions (Deprecated, Preserved for future incorporation)

To edit the textbook:

* Find the section you want to edit in `SUMMARY.md`.  That will tell you
  which Markdown file to edit.

To build the textbook and push changes to the world:

* Run `make build` to build locally.
* Run `make serve`.  This runs a local dev server that hosts the edited textbook.  
  Check that everything looks right.
* Run `make deploy` to push it to the world.  Check the public website to make
  sure everything looks right.

To make the ebook version:

- Install [Calibre](https://calibre-ebook.com/).
- Make the command line tool available on your path with, e.g.,
  `ln -s /Applications/calibre.app/Contents/MacOS/ebook-convert ~/bin`.
- Install `ebook-convert` with `sudo npm install -g ebook-convert` and `gitbook update`.
- Generate the ebooks with `make ebook`.