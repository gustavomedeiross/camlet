module type DB = Caqti_lwt.CONNECTION

module Payment = Storage.Payment

let home request =
  let account_id = Dream.param request "account_id" in
  let%lwt payments = Storage.get_exn @@ Dream.sql request (Payment.get_all ~account_id) in
  View.to_dream_html @@ View.home payments account_id
;;

let pay request =
  let open Payment in
  match%lwt Dream.form request with
  | `Ok
      [ ("recipient_account_id", recipient_account_id)
      ; ("sender_account_id", sender_account_id)
      ; ("amount", amount)
      ] ->
    let amount = int_of_string amount in
    let payment =
      { id = "216cfc28-55d0-4543-b9bf-3abb6f4cc0d6"
      ; amount
      ; recipient_account_id
      ; sender_account_id
      ; timestamp = "2024-10-21T23:49:16.046Z"
      }
    in
    let%lwt () = Storage.get_exn @@ Dream.sql request @@ Payment.create payment in
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
