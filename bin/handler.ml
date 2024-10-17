module type DB = Caqti_lwt.CONNECTION

let home request =
  let%lwt payments =
    Dream.sql request
    @@ fun (module Db : DB) ->
    let%lwt payments_or_error = Db.collect_list Sql.select_payments () in
    Caqti_lwt.or_fail payments_or_error
  in
  View.home payments
;;

let payment_details request =
  let payment_id = Dream.param request "payment_id" in
  let%lwt payment =
    Dream.sql request
    @@ fun (module Db) ->
    let%lwt payment_or_error = Db.find Sql.select_payment payment_id in
    Caqti_lwt.or_fail payment_or_error
  in
  View.payment_detail payment
;;
