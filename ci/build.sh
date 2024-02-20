#!/usr/bin/env bash

# Create ocaml env, install dependencies
opam init --bare
opam switch create . --deps-only --locked --yes

# Build the JavaScript
opam exec -- dune build bin/main.bc.js

# Put the static files where vercel would like them to be
VERCEL_OUTPUT=.vercel/output
mkdir -p "$VERCEL_OUTPUT/static/"
cp public/index.html "$VERCEL_OUTPUT/static/"
cp _build/default/bin/main.bc.js "$VERCEL_OUTPUT/static/"

cat <<EOF > "$VERCEL_OUTPUT/config.json"
{
  "version": 3
}
EOF
