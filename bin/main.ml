let () =
  Dream.run ~port:42069
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" Handler.home
       ; Dream.get "/payments/:payment_id" Handler.payment_details
       ]
;;
