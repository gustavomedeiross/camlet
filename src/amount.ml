type t = int [@@deriving show]

let of_int v = if v >= 0 then Some v else None
let to_int = Fun.id
let t = Caqti_type.int
let to_string_pretty t = float_of_int t /. 100.0 |> Format.sprintf "%.2f"
