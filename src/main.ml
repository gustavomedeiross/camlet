module Handler = Handler
module Storage = Storage

let () =
  Dream.run ~port:42069
  @@ Dream.sql_pool "sqlite3:db/db.sqlite"
  @@ Dream.logger
  @@ Dream.memory_sessions
  @@ Dream_livereload.inject_script ()
  @@ Wallet_channel.middleware ()
  @@ Dream.router
       [ Dream.get "static/**" @@ Dream.static "./assets"
       ; Dream_livereload.route ()
       ; Dream.get "/" Handler.home
       ; Dream.get "wallets/:wallet_id" Handler.transactions
       ; Dream.get "wallets/:wallet_id/stream" Handler.transactions_stream
       ; Dream.get "/transactions/:transaction_id" Handler.transaction_details
       ; Dream.post "/pay" Handler.pay
       ]
;;
