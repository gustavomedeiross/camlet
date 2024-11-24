type t

include Rapper.CUSTOM with type t := t

val of_int : int -> t option
val to_int : t -> int
