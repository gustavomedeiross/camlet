type t = Uuidm.t

let gen_v4 () = Uuidm.v4_gen (Random.State.make_self_init ()) ()
let of_string = Uuidm.of_string ~pos:0
let pp = Uuidm.pp
let to_string = Uuidm.to_string ~upper:false
let equal = Uuidm.equal

let t =
  let encode t = Ok (Uuidm.to_string t) in
  let decode string =
    string |> Uuidm.of_string |> Option.to_result ~none:"Invalid uuid provided"
  in
  Caqti_type.(custom ~encode ~decode string)
;;
