module T = Caqti_type
open Caqti_request.Infix
open Caqti_type.Std

let select_payments = (unit ->* tup2 string string) "SELECT id, created_at FROM payments"

let select_payment =
  (string ->! tup2 string string) "SELECT id, created_at FROM payments WHERE id = ?"
;;
