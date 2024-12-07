type t

include Rapper.CUSTOM with type t := t

val gen_v4 : unit -> t
val of_string : string -> t option
val equal : t -> t -> bool
val pp : Format.formatter -> t -> unit
val to_string : t -> string
