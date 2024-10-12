module View = struct
  let html page_html = Dream.html (Format.asprintf "%a" (Tyxml.Html.pp ()) page_html)
end

module type DB = Caqti_lwt.CONNECTION

module T = Caqti_type

module Sql = struct
  open Caqti_request.Infix
  open Caqti_type.Std

  let select_payments =
    (unit ->* tup2 string string) "SELECT id, created_at FROM payments"
  ;;

  let select_payment =
    (string ->! tup2 string string) "SELECT id, created_at FROM payments WHERE id = ?"
  ;;
end

let list_payments (module Db : DB) =
  let%lwt payments_or_error = Db.collect_list Sql.select_payments () in
  Caqti_lwt.or_fail payments_or_error
;;

let get_payment payment_id (module Db : DB) =
  let%lwt payment_or_error = Db.find Sql.select_payment payment_id in
  Caqti_lwt.or_fail payment_or_error
;;

let () =
  Dream.run ~port:42069
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" (fun request ->
           let%lwt payments = Dream.sql request list_payments in
           View.html @@ Page.home payments)
       ; (Dream.get "/payments/:payment_id"
          @@ fun request ->
          let payment_id = Dream.param request "payment_id" in
          let%lwt payment = Dream.sql request (get_payment payment_id) in
          View.html (Page.payment_detail payment))
       ]
;;
