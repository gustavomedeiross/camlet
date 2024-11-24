module type DB = Caqti_lwt.CONNECTION

module Transaction = Storage.Transaction

let transactions request =
  let wallet_id = Dream.param request "wallet_id" in
  let%lwt transactions =
    Storage.get_exn @@ Dream.sql request (Transaction.get_all ~wallet_id)
  in
  View.to_dream_html @@ View.home transactions request wallet_id
;;

(** Every event must be sent on this format:
    https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format *)
let server_sent_event s = Format.sprintf "data: %s\n\n" s

let write_sse stream html =
  let html = View.elt_to_string html in
  let%lwt () = Dream.write stream (server_sent_event html) in
  Dream.flush stream
;;

(* TODO: ideally each user should have its own channel *)
let rec listen_to_new_transactions wallet_id user_channel stream =
  let open User_channel in
  match%lwt Lwt_stream.get user_channel with
  | Some event ->
    let html_opt =
      match event with
      | Transaction_created transaction
        when String.equal transaction.recipient_wallet_id wallet_id ->
        Some (View.transaction_row transaction)
      | Transaction_created _ -> None
    in
    (match html_opt with
     | Some html ->
       let%lwt () = write_sse stream html in
       listen_to_new_transactions wallet_id user_channel stream
     | None -> listen_to_new_transactions wallet_id user_channel stream)
  | None -> Lwt.return ()
;;

let transactions_stream request =
  let wallet_id = Dream.param request "wallet_id" in
  let rx, _ = User_channel.get request in
  Dream.stream ~headers:[ "Content-Type", "text/event-stream" ]
  @@ listen_to_new_transactions wallet_id rx
;;

let pay request =
  let open Transaction in
  match%lwt Dream.form request with
  | `Ok
      [ ("amount", amount)
      ; ("recipient_wallet_id", recipient_wallet_id)
      ; ("sender_wallet_id", sender_wallet_id)
      ] ->
    let amount = int_of_string amount in
    let transaction_id =
      Uuidm.v4_gen (Random.State.make_self_init ()) () |> Uuidm.to_string
    in
    let transaction =
      { id = transaction_id
      ; amount
      ; recipient_wallet_id
      ; sender_wallet_id
      ; timestamp = Ptime_clock.now ()
      }
    in
    let%lwt () = Storage.get_exn @@ Dream.sql request @@ Transaction.create transaction in
    let _, tx = User_channel.get request in
    let event = User_channel.Transaction_created transaction in
    tx (Some event);
    View.elt_to_dream_html @@ View.transaction_row transaction
  | _ -> Dream.empty `Bad_Request
;;

let transaction_details request =
  let transaction_id = Dream.param request "transaction_id" in
  let%lwt transaction =
    Storage.get_exn @@ Dream.sql request @@ Transaction.get_by_id ~transaction_id
  in
  View.to_dream_html @@ View.transaction_detail transaction
;;

let home _request = View.to_dream_html @@ New_ui.home
