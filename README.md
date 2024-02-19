# twenty_forty_eight
2048 in OCaml, running in the browser with [bonsai](https://github.com/janestreet/bonsai).

## Dev environment
```sh
# Prereq: install opam
# On macOS, homebrew works:
# brew install opam

# Create a local switch for this project, install dependencies from lockfile
opam switch create . --deps-only --locked

# Install lsp and formatter for use in editor
opam install ocamlformat ocaml-lsp-server
```

Alternatively, there's a nix flake that includes opam and system dependencies. `nix develop` will drop you into a shell with the system deps installed. Then run the same steps above to install ocaml deps.

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
