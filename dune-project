(lang dune 3.3)

(using directory-targets 0.1)

(cram enable)

(name scad_ml)

(generate_opam_files true)

(source
 (github geoffder/scad-ml))

(documentation https://geoffder.github.io/scad-ml)

(license BSL-1.0)

(authors
 "Masaki Nakano<namachan10777@gmail.com>"
 "Geoff deRosenroll<geoffderosenroll@gmail.com")

(maintainers
 "Masaki Nakano<namachan10777@gmail.com>"
 "Geoff deRosenroll<geoffderosenroll@gmail.com")

(package
 (name scad_ml)
 (synopsis "OCaml DSL for 3D solid modelling in OpenSCAD")
 (description
  "Scad_ml is an OCaml front-end to the OpenSCAD CAD programming language.")
 (depends
  (ocaml
   (>= 4.08.0))
  (cairo2
   (>= 0.6.2))))
