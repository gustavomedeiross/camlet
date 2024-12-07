type t = int [@@deriving show]

let of_int v = if v >= 0 then Some v else None
let to_int = Fun.id
let t = Caqti_type.int

let divide n divisor =
  let quotient = n / divisor in
  let remainder = abs (n mod divisor) in
  quotient, remainder
;;

let to_string_pretty amount =
  let quotient, remainder = divide amount 100 in
  let quotient =
    Format.sprintf "%#d" quotient
    |> String.map (function
      | '_' -> '.'
      | c -> c)
  in
  Format.sprintf "R$ %s,%02d" quotient remainder
;;

let%test _ =
  1000000 |> of_int |> Option.get |> to_string_pretty |> String.equal "R$ 10.000,00"
;;

let%test _ =
  1234567 |> of_int |> Option.get |> to_string_pretty |> String.equal "R$ 12.345,67"
;;

let%test _ = 12345 |> of_int |> Option.get |> to_string_pretty |> String.equal "R$ 123,45"
