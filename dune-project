(lang dune 3.7)

(name twenty_forty_eight)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name twenty_forty_eight)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune bonsai virtual_dom ppx_css ppx_jane)
 (allow_empty true)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
