open Scad_ml

let () =
  let path =
    Bezier3.curve ~fn:20
    @@ Bezier3.of_path Vec3.[ v 0. 0. 2.; v 0. 20. 20.; v 40. 10. 0.; v 50. 10. 5. ]
  in
  let scad =
    let holes =
      let s = List.rev @@ Path2.circle ~fn:90 2.
      and d = 1.9 in
      Path2.[ translate (v2 (-.d) (-.d)) s; translate (v2 d d) s ]
    and outer =
      Path2.square ~center:true (v2 10. 10.)
      |> Path2.Round.(flat ~corner:(chamf (`Width 1.)))
      |> Path2.roundover
    in
    Mesh.(
      path_extrude
        ~path
        ~spec:
          Cap.(
            capped
              ~bot:(round ~holes:`Same @@ circ (`Radius (-0.6)))
              ~top:(round @@ circ (`Radius 0.5)))
        (Poly2.make ~holes outer))
    |> Mesh.merge_points
    |> Mesh.to_scad
  in
  Scad.to_file "rounded_polyhole_sweep.scad" scad