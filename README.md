# twenty_forty_eight
2048 in OCaml, running in the browser with [bonsai](https://github.com/janestreet/bonsai).

## Dev environment
```sh
# Create a local switch for this project
opam switch create . 4.14.1

# Install tooling deps, lsp
opam install ocamlformat ocaml-lsp-server dune

# Install dependencies
opam install . --deps-only
```

## Running
```sh
# Start an HTTP server for public/
make serve

# Build the JavaScript and copy it into public/
make run
```

## Running tests
```sh
dune runtest
```

## TODO
- Change game state representation to include ending the game. (Get rid of the GameOver exception.)
- Build a real UI instead of using a simple sexp.
- Animations!
