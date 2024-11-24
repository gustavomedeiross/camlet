# Camlet

Simple web server to play a bit with OCaml, Dream and HTMX.

## Running

You should have `nix` and `direnv` installed.

Setup the database:

```sh
# Setup the database schema
make db.init

# Run seeds
make db.seed
```

Running the server in watch mode (dev):

```sh
dune exec -w camlet
```
