(lang dune 3.7)

(name camlet)

(generate_opam_files true)

(source
 (github gustavomedeiross/camlet))

(authors "Gustavo Medeiros")

(maintainers "Gustavo Medeiros")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name camlet)
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
   (>= "1.0.0~alpha5"))
  ppx_deriving
  ppx_rapper
  ppx_rapper_lwt
  ptime
  (tyxml
   (>= "4.6.0"))
  uuidm)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
