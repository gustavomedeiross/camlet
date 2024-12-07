type t

include Rapper.CUSTOM with type t := t

val pp : Format.formatter -> t -> unit
val of_int : int -> t option
val to_int : t -> int
val to_string_pretty : t -> string
