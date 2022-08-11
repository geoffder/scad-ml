(** 3d vector *)
type t = Vec.v3 =
  { x : float
  ; y : float
  ; z : float
  }

(** [v x y z]

    Construct a vector from [x], [y], and [z] coordinates. *)
val v : float -> float -> float -> t

(** [of_tup (x, y, z)]

    Construct a vector from a tuple of xyz coordinates. *)
val of_tup : float * float * float -> t

(** [to_tup t]

    Convert the vector [t] to a tuple of xyz coordinates. *)
val to_tup : t -> float * float * float

include Vec.S with type t := t (** @inline *)

(** [bbox_volume bb]

    Compute the volume of the bounding box [bb]. *)
val bbox_volume : bbox -> float

(** {1 Transformations}

    Equivalent to those found in {!module:Scad}. Quaternion operations are
    provided when this module is included in {!module:Scad_ml}. *)

(** [xrot ?about theta t]

    Rotate [t] by [theta] radians in around the x-axis through the origin (or
    the point [about] if provided). *)
val xrot : ?about:t -> float -> t -> t

(** [yrot ?about theta t]

    Rotate [t] by [theta] radians in around the y-axis through the origin (or
    the point [about] if provided). *)
val yrot : ?about:t -> float -> t -> t

(** [zrot ?about theta t]

    Rotate [t] by [theta] radians in around the z-axis through the origin (or
    the point [about] if provided). *)
val zrot : ?about:t -> float -> t -> t

(** [rotate ?about r t]

    Euler (zyx) rotation of [t] by the [r] (in radians) around the origin (or
    the point [about] if provided). Equivalent to [xrot x t |> yrot y |> zrot z],
    where [{x; y; z} = r]. *)
val rotate : ?about:t -> t -> t -> t

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
