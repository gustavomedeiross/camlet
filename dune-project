(lang dune 3.7)

(name ocaml_htmx)

(generate_opam_files true)

(source
 (github gustavomedeiross/ocaml-htmx))

(authors "Gustavo Medeiros")

(maintainers "Gustavo Medeiros")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name ocaml_htmx)
 (synopsis "OCaml & HTMX")
 (description "A simple project to play with OCaml and HTMX")
 (depends
  (ocaml
   (and
    (>= "4.06")
    (< "5.3")))
  caqti-driver-sqlite3
  dune
  (dream
   (>= "1.0"))
  ppx_rapper
  ppx_rapper_lwt
  (tyxml
   (>= "4.6.0"))
  uuidm)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
