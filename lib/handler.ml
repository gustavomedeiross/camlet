module type DB = Caqti_lwt.CONNECTION

module Relation = Transaction.Relation

let transactions request =
  match Dream.param request "wallet_id" |> Uuid.of_string with
  | Some wallet_id ->
    let%lwt transactions = Dream.sql request (Transaction.get_all ~wallet_id) in
    Html.render @@ View.home transactions request wallet_id
  | None -> Dream.empty `Bad_Request
;;

(** Every event must be sent on this format:
    https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format *)
let server_sent_event s = Format.sprintf "data: %s\n\n" s

let write_sse stream html =
  let html = Html.elt_to_string html in
  let%lwt () = Dream.write stream (server_sent_event html) in
  Dream.flush stream
;;

(* TODO: ideally each wallet should have its own channel *)
let rec listen_to_new_transactions wallet_id event_channel stream =
  let open Event_channel in
  let module Transfer = Transaction.Transfer in
  match%lwt Lwt_stream.get event_channel with
  | Some event ->
    let html_opt =
      match event with
      | Transfer_received ({ kind = Transfer transfer; _ } as transaction)
        when Transfer.is_recipient ~wallet_id transfer ->
        Some (View.transaction_row transaction)
      | Transfer_received _ -> None
    in
    (match html_opt with
     | Some html ->
       let%lwt () = write_sse stream html in
       listen_to_new_transactions wallet_id event_channel stream
     | None -> listen_to_new_transactions wallet_id event_channel stream)
  | None -> Lwt.return ()
;;

let transactions_stream request =
  match Dream.param request "wallet_id" |> Uuid.of_string with
  | Some wallet_id ->
    let rx, _ = Event_channel.get request in
    Dream.stream ~headers:[ "Content-Type", "text/event-stream" ]
    @@ listen_to_new_transactions wallet_id rx
  | None -> Dream.empty `Bad_Request
;;

(* TODO: refactor later *)
let to_transaction_row (transaction : Transaction.t) ~wallet_id =
  let module TR = New_ui.Home.TransactionRow in
  let kind =
    match transaction.kind with
    | Deposit _ -> TR.Deposit
    | Withdrawal _ -> TR.Withdrawal
    | Transfer transfer ->
      let recipient_wallet = Relation.get_data transfer.recipient_wallet in
      let sender_wallet = Relation.get_data transfer.sender_wallet in
      if Uuid.equal recipient_wallet.id wallet_id
      then TR.TransferReceived { from_wallet = sender_wallet.name }
      else TR.TransferSent { to_wallet = recipient_wallet.name }
  in
  let open TR in
  { id = transaction.id
  ; amount = transaction.amount
  ; kind
  ; timestamp = transaction.timestamp
  }
;;

(* TODO: ideally each wallet should have its own channel *)
let rec listen_to_new_transactions_v2 request wallet_id event_channel stream =
  let open Event_channel in
  let module Transfer = Transaction.Transfer in
  match%lwt Lwt_stream.get event_channel with
  | Some event ->
    let html_opt =
      match event with
      | Transfer_received ({ kind = Transfer transfer; _ } as transaction)
        when Transfer.is_recipient ~wallet_id transfer ->
        let%lwt transaction = Dream.sql request @@ Transaction.load_wallets transaction in
        let transaction = to_transaction_row transaction ~wallet_id in
        Lwt.return @@ Some (New_ui.Home.TransactionRow.render transaction)
      | Transfer_received _ -> Lwt.return None
    in
    (match%lwt html_opt with
     | Some html ->
       let%lwt () = write_sse stream html in
       listen_to_new_transactions_v2 request wallet_id event_channel stream
     | None -> listen_to_new_transactions_v2 request wallet_id event_channel stream)
  | None -> Lwt.return ()
;;

(* TODO: render new tx row *)
let transactions_stream_v2 request =
  match Dream.param request "wallet_id" |> Uuid.of_string with
  | Some wallet_id ->
    let rx, _ = Event_channel.get request in
    Dream.stream ~headers:[ "Content-Type", "text/event-stream" ]
    @@ listen_to_new_transactions_v2 request wallet_id rx
  | None -> Dream.empty `Bad_Request
;;

(* TODO: better interactions with forms & avoid exceptions for validation *)
let pay request =
  let open Transaction in
  let open Transaction.Transfer in
  match%lwt Dream.form request with
  | `Ok
      [ ("amount", amount)
      ; ("recipient_wallet_id", recipient_wallet_id)
      ; ("sender_wallet_id", sender_wallet_id)
      ] ->
    let amount = amount |> int_of_string |> Amount.of_int |> Option.get in
    let recipient_wallet =
      recipient_wallet_id |> Uuid.of_string |> Option.get |> Relation.make
    in
    let sender_wallet =
      sender_wallet_id |> Uuid.of_string |> Option.get |> Relation.make
    in
    let transaction =
      { id = Uuid.gen_v4 ()
      ; amount
      ; kind = Transfer { recipient_wallet; sender_wallet }
      ; timestamp = Datetime.now ()
      }
    in
    let%lwt () = Dream.sql request @@ Transaction.create transaction in
    let _, tx = Event_channel.get request in
    let event = Event_channel.Transfer_received transaction in
    tx (Some event);
    Html.render_elt @@ View.transaction_row transaction
  | _ -> Dream.empty `Bad_Request
;;

let transaction_details request =
  match Dream.param request "transaction_id" |> Uuid.of_string with
  | Some transaction_id ->
    let%lwt transaction = Dream.sql request @@ Transaction.get_by_id ~transaction_id in
    Html.render @@ View.transaction_detail transaction
  | None -> Dream.empty `Bad_Request
;;

let home request =
  match Dream.param request "wallet_id" |> Uuid.of_string with
  | Some wallet_id ->
    let%lwt transactions = Dream.sql request (Transaction.get_all_v2 ~wallet_id) in
    let transactions =
      List.map (fun tx -> to_transaction_row tx ~wallet_id) transactions
    in
    let%lwt balance = Dream.sql request (Wallet.get_balance ~wallet_id) in
    let%lwt income, expenses =
      Dream.sql request (Wallet.get_income_and_expenses ~wallet_id)
    in
    Html.render @@ New_ui.Home.render ~wallet_id ~transactions ~balance ~income ~expenses
  (* TODO: Render 4xx page *)
  | None -> Dream.empty `Bad_Request
;;
