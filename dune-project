(lang dune 3.7)

(name ocaml_htmx)

(generate_opam_files true)

(source
 (github gustavomedeiross/ocaml-htmx))

(authors "Author Name")

(maintainers "Gustavo Medeiros")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name ocaml_htmx)
 (synopsis "OCaml & HTMX")
 (description "A simple project to play with OCaml and HTMX")
 (depends (ocaml (and (>= "4.06") (< "5.3"))) dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
