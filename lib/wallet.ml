type t =
  { id : Uuid.t
  ; name : string
  ; balance : Amount.t
  ; timestamp : Datetime.t
  }
[@@deriving show]

let of_rapper ~id ~name ~balance ~timestamp = { id; name; balance; timestamp }

let opt_of_rapper ~id ~name ~balance ~timestamp =
  match id with
  | Some id ->
    Some
      (of_rapper
         ~id
         ~name:(Option.get name)
         ~balance:(Option.get balance)
         ~timestamp:(Option.get timestamp))
  | None -> None
;;

let get_balance ~wallet_id db_conn =
  let open Lwt.Infix in
  let query =
    [%rapper
      get_one
        {sql|
           SELECT @Amount{wallets.balance}
           FROM wallets
           WHERE id = %Uuid{wallet_id}
           |sql}]
  in
  query ~wallet_id db_conn >>= Caqti_lwt.or_fail
;;

let get_income_and_expenses ~wallet_id db_conn =
  let open Lwt.Infix in
  let query =
    [%rapper
      get_one
        {sql|
           SELECT
             COALESCE(SUM(CASE WHEN recipient_wallet_id = %Uuid{wallet_id} THEN amount ELSE 0 END), 0) AS @Amount{income},
             COALESCE(SUM(CASE WHEN sender_wallet_id = %Uuid{wallet_id} THEN amount ELSE 0 END), 0) AS @Amount{expenses}
           FROM transactions
           WHERE sender_wallet_id = %Uuid{wallet_id} OR recipient_wallet_id = %Uuid{wallet_id}
           |sql}]
  in
  query ~wallet_id db_conn >>= Caqti_lwt.or_fail
;;
