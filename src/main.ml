module Handler = Handler
module Storage = Storage

let () =
  Dream.run ~port:42069
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  @@ Dream.logger
  @@ Dream.memory_sessions
  @@ Dream_livereload.inject_script ()
  @@ User_channel.middleware ()
  @@ Dream.router
       [ Dream.get "static/**" @@ Dream.static "./assets"
       ; Dream_livereload.route ()
       ; Dream.get "/" Handler.home
       ; Dream.get "accounts/:account_id" Handler.payments
       ; Dream.get "accounts/:account_id/stream" Handler.payments_stream
       ; Dream.get "/payments/:payment_id" Handler.payment_details
       ; Dream.post "/pay" Handler.pay
       ]
;;
