# camlpdf example

I needed to extract text from a well-structured PDF. It turned out to be much less explored topic than I expected. There are many libraries in multiple languages but they are all surpisingly difficult to use for the task. After a closer inspection I decided to use camlpdf since I'm most comfortable with OCaml and the libraries in other langauges I considered (Javascript, Python) didn't seem simple either.

Camlpdf is the most up to date PDF library for OCaml. After a couple of hours of hacking I was able to parse text in PDF and extract UTF-8 text out of it. It's trickier than expected since you need to access font information to decode non ascii characters.

# Running the example

1. Install nix
2. Run `nix develop -c $SHELL`
3. run `dune exec ./src/parser.exe`
