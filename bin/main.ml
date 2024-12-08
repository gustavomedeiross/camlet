module Handler = Camlet.Handler
module Event_channel = Camlet.Event_channel

let () =
  Dream.run ~port:42069
  @@ Dream.sql_pool "sqlite3:db/db.sqlite"
  @@ Dream.logger
  @@ Dream.memory_sessions
  @@ Dream_livereload.inject_script ()
  @@ Event_channel.middleware ()
  @@ Dream.router
       [ Dream.get "static/**" @@ Dream.static "./static"
       ; Dream_livereload.route ()
       ; Dream.get "/:wallet_id" Handler.home
       ; Dream.get "/:wallet_id/transactions/stream" Handler.transactions_stream_v2
       ; Dream.get "wallets/:wallet_id" Handler.transactions
       ; Dream.get "wallets/:wallet_id/stream" Handler.transactions_stream
       ; Dream.get "/transactions/:transaction_id" Handler.transaction_details
       ; Dream.post "/pay" Handler.pay
       ]
;;
