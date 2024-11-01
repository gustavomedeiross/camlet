module Handler = Handler
module Storage = Storage

let () =
  Dream.run ~port:42069
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  @@ Dream.logger
  @@ Dream.memory_sessions
  @@ User_channel.middleware ()
  @@ Dream.router
       [ Dream.get "accounts/:account_id" Handler.payments
       ; Dream.get "accounts/:account_id/stream" Handler.payments_stream
       ; Dream.get "/payments/:payment_id" Handler.payment_details
       ; Dream.post "/pay" Handler.pay
       ; Dream.get "/ping" (fun request ->
           let _, tx = User_channel.get request in
           Dream.log "Sending event to Lwt_stream";
           let () = tx (Some User_channel.Payment_created) in
           Dream.empty `OK)
       ]
;;
