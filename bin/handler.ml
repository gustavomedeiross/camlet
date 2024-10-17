module type DB = Caqti_lwt.CONNECTION

module Payment = Storage.Payment

let home request =
  let account_id = Dream.param request "account_id" in
  let%lwt payments = Storage.get_exn @@ Dream.sql request (Payment.list ~account_id) in
  View.home payments
;;

let payment_details request =
  let payment_id = Dream.param request "payment_id" in
  let%lwt payment = Storage.get_exn @@ Dream.sql request @@ Payment.show ~payment_id in
  View.payment_detail payment
;;
