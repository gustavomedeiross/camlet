module View = struct
  let html page_html = Dream.html (Format.asprintf "%a" (Tyxml.Html.pp ()) page_html)
end

module type DB = Caqti_lwt.CONNECTION

module T = Caqti_type

let list_payments =
  let query =
    let open Caqti_request.Infix in
    (T.unit ->* T.(tup2 string string)) "SELECT id, created_at FROM payments"
  in
  fun (module Db : DB) ->
    let%lwt payments_or_error = Db.collect_list query () in
    Caqti_lwt.or_fail payments_or_error
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
          View.html (Page.payment_detail payment_id))
       ]
;;
