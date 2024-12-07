module type DB = Caqti_lwt.CONNECTION

module Transaction = Storage.Transaction
module Wallet = Storage.Wallet
module Relation = Storage.Relation
module Transaction_kind = Storage.Transaction_kind

let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html
let elt_to_string html = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) html
let to_dream_html html = html |> html_to_string |> Dream.html
let elt_to_dream_html html = html |> elt_to_string |> Dream.html

let transactions request =
  match Dream.param request "wallet_id" |> Uuid.of_string with
  | Some wallet_id ->
    let%lwt transactions = Dream.sql request (Transaction.get_all ~wallet_id) in
    View.to_dream_html @@ View.home transactions request wallet_id
  | None -> Dream.empty `Bad_Request
;;

(** Every event must be sent on this format:
    https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format *)
let server_sent_event s = Format.sprintf "data: %s\n\n" s

let write_sse stream html =
  let html = View.elt_to_string html in
  let%lwt () = Dream.write stream (server_sent_event html) in
  Dream.flush stream
;;

(* TODO: ideally each wallet should have its own channel *)
let rec listen_to_new_transactions wallet_id wallet_channel stream =
  let open Wallet_channel in
  match%lwt Lwt_stream.get wallet_channel with
  | Some event ->
    let html_opt =
      match event with
      | Transaction_created ({ kind = Deposit { recipient_wallet }; _ } as transaction)
        when Uuid.equal (Relation.key recipient_wallet) wallet_id ->
        Some (View.transaction_row transaction)
      | Transaction_created _ -> None
    in
    (match html_opt with
     | Some html ->
       let%lwt () = write_sse stream html in
       listen_to_new_transactions wallet_id wallet_channel stream
     | None -> listen_to_new_transactions wallet_id wallet_channel stream)
  | None -> Lwt.return ()
;;

let transactions_stream request =
  match Dream.param request "wallet_id" |> Uuid.of_string with
  | Some wallet_id ->
    let rx, _ = Wallet_channel.get request in
    Dream.stream ~headers:[ "Content-Type", "text/event-stream" ]
    @@ listen_to_new_transactions wallet_id rx
  | None -> Dream.empty `Bad_Request
;;

(* TODO: better interactions with forms & avoid exceptions for validation *)
let pay request =
  let open Transaction in
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
    let _, tx = Wallet_channel.get request in
    let event = Wallet_channel.Transaction_created transaction in
    tx (Some event);
    View.elt_to_dream_html @@ View.transaction_row transaction
  | _ -> Dream.empty `Bad_Request
;;

let transaction_details request =
  match Dream.param request "transaction_id" |> Uuid.of_string with
  | Some transaction_id ->
    let%lwt transaction = Dream.sql request @@ Transaction.get_by_id ~transaction_id in
    View.to_dream_html @@ View.transaction_detail transaction
  | None -> Dream.empty `Bad_Request
;;

let to_transaction_row (transaction : Transaction.t) wallet_id =
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

let home request =
  match Dream.param request "wallet_id" |> Uuid.of_string with
  | Some wallet_id ->
    let%lwt transactions = Dream.sql request (Transaction.get_all_v2 ~wallet_id) in
    let transactions =
      List.map (fun tx -> to_transaction_row tx wallet_id) transactions
    in
    let%lwt balance = Dream.sql request (Wallet.get_balance ~wallet_id) in
    let%lwt income, expenses =
      Dream.sql request (Wallet.get_income_and_expenses ~wallet_id)
    in
    View.to_dream_html @@ New_ui.Home.render ~transactions ~balance ~income ~expenses
  (* TODO: Render 4xx page *)
  | None -> Dream.empty `Bad_Request
;;
