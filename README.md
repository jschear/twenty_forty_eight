# twenty_forty_eight
2048 in OCaml, running in the browser with [bonsai](https://github.com/janestreet/bonsai).

## Dev environment
```sh
# Prereq: install opam
# On macOS, homebrew works:
# brew install opam

# Create a local switch for this project, install dependencies
opam switch create . 4.14.1 --deps-only

# Install lsp and formatter if necessary
opam install ocamlformat ocaml-lsp-server
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
- Animations!
