(** {0 Rounded sweeps} *)
open Scad_ml

(** Create a bezier spline function which passes through all of points in
    [control] using {{!Scad_ml.Bezier3.of_path} [Bezier3.of_path]}, and
   interpolate [20] points along it to create our [path] with
   {{!Scad_ml.Bezier3.curve} [Bezier3.curve]}. *)

let control =
  V3.[ v 5. 5. 12.; v 0. 20. 20.; v 30. 30. 0.; v 50. 20. 5.; v 35. (-10.) 15. ]

let path = Bezier3.curve ~fn:30 @@ Bezier3.of_path control

(** We can quickly visualize [path], and the [control] points that it passes
    through by using the {{!Scad_ml.Path3.show_points} [Path3.show_points]}
    helper, which places a {{!Scad_ml.Scad.d3} [Scad.d3]} shape at each point
    along the path (this takes a function from index to shape, rather than a
    shape directly to allow for differentiating the points, {i e.g.} numbering
    with {{!Scad_ml.Scad.text} [Scad.text]}). *)
let () =
  Scad.to_file "bezier_spline_path.scad"
  @@ Scad.union
       [ Path3.show_points (fun _ -> Scad.sphere 1.) path
       ; Path3.show_points
           (fun _ -> Scad.(color ~alpha:0.3 Color.Magenta @@ sphere 2.))
           control
       ]

(** {%html:
    <p style="text-align:center;">
    <img src="../assets/bezier_spline_path.png" style="width:150mm;"/>
    </p> %}
    *)

(** Draw a 2d polygon with a chamfered square outline, and two circular holes.
    Chamfering the square outer path is accomplished via
    {{!Scad_ml.Path2.roundover} [Path2.roundover]}, which takes a
    {{!Scad_ml.Path2.Round.t} [Path2.Round.t]} specifation, built here
    using the {{!Scad_ml.Path2.Round.flat} [Path2.Round.flat]} constructor,
    that tells {{!Scad_ml.Path2.roundover} [Path2.roundover]} to apply
    [~corner] to all of the points of the given path. *)
let poly =
  let holes =
    let s = Path2.circle ~fn:90 2.
    and d = 1.9 in
    Path2.[ translate (v2 (-.d) (-.d)) s; translate (v2 d d) s ]
  and outer =
    Path2.square ~center:true (v2 10. 10.)
    |> Path2.Round.(flat ~corner:(chamf (`Width 2.)))
    |> Path2.roundover
  in
  Poly2.make ~holes outer

(** 2d shapes defined with {{!Scad_ml.Poly2.t} [Poly2.t]} can be translated into
    OpenSCAD polygons by way of {{!Scad_ml.Poly2.to_scad} [Poly2.to_scad]}. *)
let () = Scad.to_file "chamfered_square_with_holes.scad" (Poly2.to_scad poly)

(** {%html:
    <p style="text-align:center;">
    <img src="../assets/chamfered_square_with_holes.png" style="width:150mm;"/>
    </p> %}
    *)

(** {{!Scad_ml.Mesh.sweep} [Mesh.sweep]} derived functions take a [~caps]
   parameter that specifies what to do with the end faces of the extruded mesh.
   By default, both caps are flat and identical to the input polygon
   ({{!Scad_ml.Mesh.Cap.flat_caps} [Mesh.Cap.flat_caps]}), but in this example, we
   will be rounding them over.

    To build our [caps], we'll use the {{!Scad_ml.Mesh.Cap.capped} [Mesh.Cap.capped]}
    constructor which takes specification types for how we would like to treat the
    bottom and top faces of our extrusion. In this case, we'll be applying
    roundovers to both the [bot]tom and [top] faces, so we use
    {{!Scad_ml.Mesh.Cap.round} [Mesh.Cap.round]} which takes an
    {{!val:Scad_ml.Mesh.Cap.offsets} [Mesh.Cap.offsets]} containing the offset
    distance/radius and "vertical" step for each outline of the outer roundover,
    and optionally, the desired treatment of the inner paths (as [~holes]).
    Typically, the offsets will be generated by a helper such as {{!Scad_ml.Mesh.Cap.chamf}
    [Mesh.Cap.chamf]} and {{!Scad_ml.Mesh.Cap.circ} [Mesh.Cap.circ]} below.

    Here we apply a negative (outward flaring) chamfer to the bottom face,
    setting [holes] to [`Same], so that the circular holes in [poly] are also
    expanded, rather than pinched off (default is ([~holes:`Flip]), which
    negates the outer roundover for inner paths). For the top face, we specify
    a positive (inward) circular roundover, leaving [holes] as its default since
    we want the holes to flare out instead. *)
let caps =
  Mesh.Cap.(
    capped
      ~bot:(round ~holes:`Same @@ chamf ~height:(-1.2) ~angle:(Float.pi /. 8.) ())
      ~top:(round @@ circ (`Radius 0.5)))

(** Extrude [poly] along [path], with rounding over the end caps according to
    [caps] using {{!Scad_ml.Mesh.path_extrude} [Mesh.path_extrude]}. *)
let mesh = Mesh.path_extrude ~path ~caps poly

(** Convert our mesh into an OpenSCAD polyhedron and output to file with
   {{!Scad_ml.Mesh.to_scad} [Mesh.to_scad]}. *)
let () = Scad.to_file "rounded_polyhole_sweep.scad" (Mesh.to_scad mesh)

(** {%html:
    <p style="text-align:center;">
    <img src="../assets/rounded_polyhole_sweep.png" style="width:150mm;"/>
    </p> %}
    *)

(** Rounded 3d paths for sweeping can also be drawn with the help of the
    {{!Scad_ml.Path3.Round} [Path3.Round]} module, which works much the same as
    its counterpart in {{!Scad_ml.Path2} [Path2]} that we used to chamfer our
    [poly] earlier. *)
let rounded_path =
  Path3.(
    roundover ~fn:32
    @@ Round.flat
         ~closed:true
         ~corner:(Round.circ (`Radius 10.))
         (v3 (-25.) 25. 0. :: Path3.square (v2 50. 50.)))

(** {{!Scad_ml.Mesh.path_extrude} [Mesh.path_extrude]} (and other functions
    derived from [Mesh.sweep]) can be given [~caps:`Looped], which will connect
    the final position of the sweep up with the beginning, rather than sealing
    both ends off with caps. If the swept polygon has holes (as our [poly]
    does), they will be included, and continuous much like the outer shape. *)
let () =
  let loop = Mesh.(to_scad @@ path_extrude ~caps:`Looped ~path:rounded_path poly)
  and cut =
    Scad.cylinder ~fn:50 ~center:true ~height:11. 5.
    |> Scad.scale (v3 1.2 1. 1.)
    |> Scad.translate (v3 20. (-4.) 0.)
  in
  Scad.difference loop [ cut ] |> Scad.to_file "chamfered_loop.scad"

(** {%html:
    <p style="text-align:center;">
    <img src="../assets/chamfered_loop.png" style="width:150mm;"/>
    </p> %}
    *)
