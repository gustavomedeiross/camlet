type t

include Rapper.CUSTOM with type t := t

val pp : Format.formatter -> t -> unit
val now : unit -> t
val of_ptime : Ptime.t -> t
val to_string_pretty : t -> string
