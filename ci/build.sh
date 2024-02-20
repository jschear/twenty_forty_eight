#!/bin/bash

# Create ocaml env, build javascript
opam init --bare
opam switch create . --deps-only --locked --yes
eval $(opam env)

dune build bin/main.bc.js

# Put the static files where vercel would like them to be
VERCEL_OUTPUT=.vercel/output
mkdir -p "$VERCEL_OUTPUT/static/"
cp public/index.html "$VERCEL_OUTPUT/static/"
cp _build/default/bin/main.bc.js "$VERCEL_OUTPUT/static/"

cat <<EOF > "$VERCEL_OUTPUT/"
{
  "version": 3
}
EOF
