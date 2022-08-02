(** {0 Skins and Morphs} *)

open Scad_ml

let () =
  let sq = Path3.square ~center:true (v2 2. 2.)
  and circ =
    Path3.circle ~fn:36 0.6
    |> Path3.rotate (v3 0. (Float.pi /. 4.) 0.)
    |> Path3.translate (v3 0. 0. 1.)
  and ellipse =
    Path3.ellipse ~fn:21 (v2 0.5 1.5)
    |> Path3.rotate (v3 0. (Float.pi /. 1.5) 0.)
    |> Path3.translate (v3 3. 0. 1.)
  and rect =
    Path3.square ~center:true (v2 0.2 1.) |> Path3.translate (v3 4. 0. 0.) |> List.rev
  and circ2 =
    Path3.circle ~fn:50 1.
    |> Path3.rotate (v3 0. (Float.pi /. 2.) 0.)
    |> Path3.translate (v3 2. 1. (-2.))
    |> List.rev
  and ellipse2 =
    Path3.ellipse ~fn:60 (v2 0.25 0.5)
    |> Path3.rotate (v3 0. (Float.pi /. 1.5) 0.)
    |> Path3.translate (v3 1. 0. (-2.))
    |> List.rev
  and sq2 =
    Path3.square ~center:true (v2 1. 1.)
    |> Path3.rotate (v3 0. 0. (Float.pi /. 4.))
    |> Path3.translate (v3 0. 0. (-1.))
  in
  ignore [ sq; circ; ellipse; rect; circ2; ellipse2; sq2 ];
  Mesh.skin
    ~refine:2
    ~endcaps:`Loop (* ~endcaps:`Bot *)
    ~slices:(`Flat 35)
    ~mapping:
      (`Mix
        [ `Reindex `ByLen
        ; `Reindex `ByLen
        ; `Reindex `ByLen
        ; `Reindex `ByLen
        ; `Reindex `ByLen
        ; `Reindex `BySeg
        ; `Distance
        ; `Direct `BySeg
        ] )
    [ sq
    ; circ
    ; ellipse
    ; rect
    ; circ2
    ; ellipse2
    ; sq2
    ; Path3.translate (v3 0. 0. (-0.5)) sq
    ]
  |> Mesh.to_scad
  |> fun s -> Scad.union [ s; Scad.sphere 1. ] |> Scad.to_file "skin_test.scad"

let () =
  Mesh.skin
    ~refine:2
    ~slices:(`Flat 25)
    ~mapping:(`Flat `Tangent)
    Path3.[ circle ~fn:5 4.; translate (v3 0. 0. 3.) @@ circle ~fn:80 2. ]
  |> Mesh.to_scad
  |> Scad.to_file "tangent_skin_test.scad"

let () =
  let test_union s = Scad.union [ s; Scad.sphere 2.5 ] in
  let path =
    let control = Vec3.[ v 0. 0. 2.; v 0. 20. 20.; v 40. 20. 10.; v 30. 0. 10. ] in
    Bezier3.curve ~fn:60 @@ Bezier3.of_path ~size:(`FlatRel 0.3) control
  and caps =
    Mesh.Cap.(
      capped
        ~bot:(round ~holes:`Same @@ chamf ~height:(-1.2) ~angle:(Float.pi /. 8.) ())
        ~top:(round @@ circ (`Radius 0.5)))
  and a = Poly2.ring ~fn:5 ~thickness:(v2 2.5 2.5) (v2 6. 6.)
  and b = Poly2.ring ~fn:80 ~thickness:(v2 2. 2.) (v2 4. 4.) in
  Mesh.path_morph ~refine:2 ~caps ~path ~outer_map:`Tangent a b
  |> Mesh.to_scad
  |> test_union
  |> Scad.to_file "tangent_morph_test.scad"

let () =
  let test_union s = Scad.union [ s; Scad.(translate (v3 4. 0. 0.) @@ sphere 1.) ] in
  Mesh.linear_morph
    ~refine:2
    ~ez:(v2 0.42 0., v2 1. 1.)
    ~slices:60
    ~outer_map:`Tangent
    ~height:3.
    (Poly2.ring ~fn:5 ~thickness:(v2 1. 1.) (v2 4. 4.))
    (Poly2.ring ~fn:80 ~thickness:(v2 0.2 0.2) (v2 1. 1.))
  |> Mesh.to_scad
  |> test_union
  |> Scad.to_file "eased_morph.scad"
