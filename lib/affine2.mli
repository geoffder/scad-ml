(** A 2d affine transformation matrix.

    To be used with OpenSCADs
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#multmatrix}multmatrix},
    which is applied in this library with {!Scad.affine}. *)

type row = float * float * float

type t =
  { r0c0 : float
  ; r0c1 : float
  ; r0c2 : float
  ; r1c0 : float
  ; r1c1 : float
  ; r1c2 : float
  ; r2c0 : float
  ; r2c1 : float
  ; r2c2 : float
  }

include Affine.Ops with type t := t (** @inline *)

(** {1 Construction by Rows} *)

(** [of_rows rows]

    Create an 2d affine transformation matrix from two rows. The last row is set
    to [0., 0., 1.]. *)
val of_rows : row -> row -> t

(** [of_row_matrix_exn m]

    Convert the float matrix [m] into a [t] if it is the correct shape (3 x 3),
    otherwise raise [Invalid_argument]. *)
val of_row_matrix_exn : float array array -> t

(** [of_row_matrix m]

    Convert the float matrix [m] into a [t] if it is the correct shape (3 x 3). *)
val of_row_matrix : float array array -> (t, string) result

(** {1 Transforms} *)

(** [translation v]

    Create a 2d affine transformation matrix from the xy translation vector [v]. *)
val translate : V2.t -> t

(** [xtrans x]

    Create a 2d affine transformation matrix that applies a translation of [x]
    distance along the x-axis. *)
val xtrans : float -> t

(** [ytrans y]

    Create a 2d affine transformation matrix that applies a translation of [y]
    distance along the y-axis. *)
val ytrans : float -> t

(** [rotate ?about r]

    Create an affine transformation matrix that applies a rotation of [r]
    radians around the origin (or the point [about] if provided). *)
val rotate : ?about:V2.t -> float -> t

(** [zrot ?about r]

    Create an affine transformation matrix that applies a rotation of [r]
    radians around the origin (or the point [about] if provided). Alias of
    {!rotate}. *)
val zrot : ?about:V2.t -> float -> t

(** [align a b]

    Compute an affine transformation matrix that would bring the vector [a] into
    alignment with [b]. *)
val align : V2.t -> V2.t -> t

(** [scaling v]

    Create a 2d affine transformation matrix from the xyz scaling vector [v]. *)
val scale : V2.t -> t

(** [mirror ax]

    Create an affine transformation matrix that applies a reflection across the
    axis [ax]. *)
val mirror : V2.t -> t

(** [skew xa ya]

    Create an affine transformation matrix that applies a skew transformation
    along the xy plane.

    - [xa]: skew angle (in radians) in the direction of the x-axis
    - [ya]: skew angle (in radians) in the direction of the y-axis *)
val skew : float -> float -> t

(** [transform t v]

    Apply the 2d affine transformation matrix [t] to the vector [v]. *)
val transform : t -> V2.t -> V2.t

(** {1 Conversions} *)

val lift : t -> Affine3.t

(** {1 Output} *)

val to_string : t -> string
