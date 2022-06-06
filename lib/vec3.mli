type t = Vec.v3 =
  { x : float
  ; y : float
  ; z : float
  }

include Vec.S with type t := t

(** [v x y z]

    Construct a vector from [x], [y], and [z] coordinates. *)
val v : float -> float -> float -> t

(** [of_tup (x, y, z)]

    Construct a vector from a tuple of xyz coordinates. *)
val of_tup : float * float * float -> t

(** [to_tup t]

    Convert the vector [t] to a tuple of xyz coordinates. *)
val to_tup : t -> float * float * float

(** {1 Transformations}

    Equivalent to those found in {!module:Scad}. Quaternion operations are
    provided when this module is included in {!module:Scad_ml}. *)

(** [rotate_x theta t]

    Rotate [t] by [theta] radians about the x-axis. *)
val rotate_x : float -> t -> t

(** [rotate_y theta t]

    Rotate [t] by [theta] radians about the y-ayis. *)
val rotate_y : float -> t -> t

(** [rotate_z theta t]

    Rotate [t] by [theta] radians about the z-azis. *)
val rotate_z : float -> t -> t

(** [rotate r t]

    Euler (xyz) rotation of [t] by the angles in [theta]. Equivalent to
    [rotate_x rx t |> rotate_y ry |> rotate_z rz], where [(rx, ry, rz) = r]. *)
val rotate : t -> t -> t

(** [rotate_about_pt r pivot t]

    Translates [t] along the vector [pivot], euler rotating the resulting vector
    with [r], and finally, moving back along the vector [pivot]. Functionally,
    rotating about the point in space arrived at by the initial translation
    along the vector [pivot]. *)
val rotate_about_pt : t -> t -> t -> t

(** [translate p t]

    Translate [t] along the vector [p]. Equivalent to {!val:add}. *)
val translate : t -> t -> t

(** [scale s t]

    Scale [t] by factors [s]. Equivalent to {!val:mul}. *)
val scale : t -> t -> t

(** [mirror ax t]

    Mirrors [t] on a plane through the origin, defined by the normal vector
    [ax]. *)
val mirror : t -> t -> t

(** [projection t]

    Project [t] onto the XY plane. *)
val projection : t -> t

(** {1 2d - 3d conversion} *)

(** [of_vec2 ?z v]

    Create a 3d vector from the 2d vector [v] by adding a [z] coordinate
    (default = [0.]) *)
val of_vec2 : ?z:float -> Vec.v2 -> t