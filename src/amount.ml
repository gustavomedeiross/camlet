type t = int [@@deriving show]

let of_int v = if v >= 0 then Some v else None
let to_int = Fun.id
let t = Caqti_type.int
