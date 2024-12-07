type t = Ptime.t

let t = Caqti_type.ptime
let now () = Ptime_clock.now ()
let of_ptime = Fun.id
let pp = Ptime.pp

(** In portuguese *)
let month_to_string = function
  | 1 -> "JAN"
  | 2 -> "FEV"
  | 3 -> "MAR"
  | 4 -> "ABR"
  | 5 -> "MAI"
  | 6 -> "JUN"
  | 7 -> "JUL"
  | 8 -> "AGO"
  | 9 -> "SET"
  | 10 -> "OUT"
  | 11 -> "NOV"
  | 12 -> "DEZ"
  | m -> raise (Invalid_argument (Format.sprintf "Invalid month provided: %d" m))
;;

(* TODO: currently this implementation doesn't consider user's timezone *)
let to_string_pretty t =
  let date, time = Ptime.to_date_time t in
  let _, mon, day = date in
  let (h, m, s), _ = time in
  Format.sprintf "%02d:%02d:%02d %02d %s" h m s day (month_to_string mon)
;;

let%test _ =
  "2024-12-07T19:16:15.743Z"
  |> Ptime.of_rfc3339
  |> Result.get_ok
  |> fun (dt, _, _) -> dt |> to_string_pretty |> String.equal "19:16:15 07 DEZ"
;;
