#!/bin/bash

# Create ocaml env, build javascript
opam init --bare
opam switch create . --deps-only --locked --yes
eval $(opam env)

dune build bin/main.bc.js

# Put the static files where vercel would like them to be
VERCEL_OUTPUT=.vercel/output/static/
mkdir -p $VERCEL_OUTPUT
cp public/index.html $VERCEL_OUTPUT
cp _build/default/bin/main.bc.js $VERCEL_OUTPUT

