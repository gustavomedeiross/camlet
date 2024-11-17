module type DB = Caqti_lwt.CONNECTION

module Payment = Storage.Payment

let payments request =
  let account_id = Dream.param request "account_id" in
  let%lwt payments = Storage.get_exn @@ Dream.sql request (Payment.get_all ~account_id) in
  View.to_dream_html @@ View.home payments request account_id
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
let rec listen_to_new_payments account_id user_channel stream =
  let open User_channel in
  match%lwt Lwt_stream.get user_channel with
  | Some event ->
    let html_opt =
      match event with
      | Payment_created payment when String.equal payment.recipient_account_id account_id
        -> Some (View.payment_row payment)
      | Payment_created _ -> None
    in
    (match html_opt with
     | Some html ->
       let%lwt () = write_sse stream html in
       listen_to_new_payments account_id user_channel stream
     | None -> listen_to_new_payments account_id user_channel stream)
  | None -> Lwt.return ()
;;

let payments_stream request =
  let account_id = Dream.param request "account_id" in
  let rx, _ = User_channel.get request in
  Dream.stream ~headers:[ "Content-Type", "text/event-stream" ]
  @@ listen_to_new_payments account_id rx
;;

let pay request =
  let open Payment in
  match%lwt Dream.form request with
  | `Ok
      [ ("amount", amount)
      ; ("recipient_account_id", recipient_account_id)
      ; ("sender_account_id", sender_account_id)
      ] ->
    let amount = int_of_string amount in
    let payment_id =
      Uuidm.v4_gen (Random.State.make_self_init ()) () |> Uuidm.to_string
    in
    let payment =
      { id = payment_id
      ; amount
      ; recipient_account_id
      ; sender_account_id
      ; timestamp = Ptime_clock.now ()
      }
    in
    let%lwt () = Storage.get_exn @@ Dream.sql request @@ Payment.create payment in
    let _, tx = User_channel.get request in
    let event = User_channel.Payment_created payment in
    tx (Some event);
    View.elt_to_dream_html @@ View.payment_row payment
  | _ -> Dream.empty `Bad_Request
;;

let payment_details request =
  let payment_id = Dream.param request "payment_id" in
  let%lwt payment =
    Storage.get_exn @@ Dream.sql request @@ Payment.get_by_id ~payment_id
  in
  View.to_dream_html @@ View.payment_detail payment
;;

let home _request = View.to_dream_html @@ New_ui.home
