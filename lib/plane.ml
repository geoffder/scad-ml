open V

type t =
  { a : float
  ; b : float
  ; c : float
  ; d : float
  }

let to_tup { a; b; c; d } = a, b, c, d

let make p1 p2 p3 =
  let ({ x; y; z } as crx) = V3.(cross (sub p3 p1) (sub p2 p1)) in
  let n = V3.norm crx in
  if Math.approx 0. n then invalid_arg "Plane points must not be collinear";
  { a = x /. n; b = y /. n; c = z /. n; d = V3.dot crx p1 /. n }

let of_normal ?(point = V3.zero) ({ x; y; z } as normal) =
  let n = V3.norm normal in
  if Math.approx 0. n then invalid_arg "Normal cannot be zero.";
  { a = x /. n; b = y /. n; c = z /. n; d = V3.dot normal point /. n }

let xy = { a = 0.; b = 0.; c = 1.; d = 0. }
let xz = { a = 0.; b = 1.; c = 0.; d = 0. }
let yz = { a = 1.; b = 0.; c = 0.; d = 0. }

let project { a; b; c; d } =
  let n = v3 a b c in
  let cp = V3.(sdiv (smul n d) (dot n n)) in
  let rot = Quaternion.(to_affine @@ align n (v3 0. 0. 1.)) in
  let m = Affine3.(mul rot (translate (V3.negate cp))) in
  fun p -> V3.to_v2 @@ Affine3.transform m p

let lift { a; b; c; d } =
  let n = v3 a b c in
  let cp = V3.(sdiv (smul n d) (dot n n)) in
  let rot = Quaternion.(to_affine @@ align (v3 0. 0. 1.) n) in
  let m = Affine3.(mul (translate cp) rot) in
  fun p -> Affine3.transform m (V3.of_v2 p)

let normal { a; b; c; _ } = V3.normalize (v3 a b c)
let offset { a; b; c; d } = d /. V3.norm (v3 a b c)

let normalize { a; b; c; d } =
  let n = V3.norm (v3 a b c) in
  { a = a /. n; b = b /. n; c = c /. n; d = d /. n }

let negate { a; b; c; d } = { a = -.a; b = -.b; c = -.c; d = -.d }
let distance_to_point { a; b; c; d } p = V3.dot (v3 a b c) p -. d

(** TODO: do some testing, and open an issue / PR with BOSL2 about greatest
   distance having different results depending on winding direction (which
   result in opposite polarity planes). For distance to point, the polarity
   gives information, but I still think there is an issue, since a point on
   the plane is still able to give a non-zero distance depending on winding.  *)
let greatest_distance t ps =
  let { a; b; c; d } = normalize t in
  let normal = v3 a b c in
  let f (min, max) p =
    let n = V3.dot p normal in
    Float.min min n, Float.max max n
  in
  let min_norm, max_norm = List.fold_left f (Float.max_float, Float.min_float) ps in
  (* Negate offset and norm products to check distance from negative plane [t].
      Without this, non-zero distances can be returned for points that should be
      on the plane. *)
  Float.min
    (Float.max (max_norm -. d) (d -. min_norm))
    (Float.max (-.max_norm -. -.d) (-.min_norm -. -.d))

let are_points_on ?(eps = Util.epsilon) t ps = greatest_distance t ps < eps
let is_point_above t p = distance_to_point t p > Util.epsilon

let line_angle t V3.{ a; b } =
  let dir = V3.(normalize @@ sub b a)
  and n = normal t in
  let sin_angle = V3.dot dir n
  and cos_angle = V3.(norm @@ cross dir n) in
  Float.atan2 sin_angle cos_angle

let to_string { a; b; c; d } = Printf.sprintf "[%f, %f, %f, %f]" a b c d
