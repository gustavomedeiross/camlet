module type DB = Rapper_helper.CONNECTION

module Err = struct
  type t = { db_err : Caqti_error.t }

  let of_db_err db_err = { db_err }

  let exn result =
    Lwt_result.get_exn
    @@ Lwt_result.map_error (fun err -> Caqti_error.Exn err.db_err) result
  ;;
end

module Wallet = struct
  type t =
    { id : Uuid.t
    ; name : string
    ; balance : Amount.t
    ; timestamp : Ptime.t
    }

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
end

module Transaction_kind : sig
  type t =
    | Transfer
    | Deposit
    | Withdrawal

  val pp : Format.formatter -> t -> unit

  include Rapper.CUSTOM with type t := t
end = struct
  type t =
    | Transfer
    | Deposit
    | Withdrawal
  [@@deriving show]

  let t =
    let encode = function
      | Transfer -> Ok "transfer"
      | Deposit -> Ok "deposit"
      | Withdrawal -> Ok "withdrawal"
    in
    let decode = function
      | "transfer" -> Ok Transfer
      | "deposit" -> Ok Deposit
      | "withdrawal" -> Ok Withdrawal
      | _ -> Error "invalid transaction kind"
    in
    Caqti_type.(custom ~encode ~decode string)
  ;;
end

(* TODO: this about a better API/better option for this *)
module Relation = struct
  type ('key, 'data) t =
    | Loaded of 'key * 'data
    | Not_loaded of 'key

  let key = function
    | Loaded (k, _) -> k
    | Not_loaded k -> k
  ;;

  let make k = Not_loaded k

  let load t d =
    match t with
    | Loaded (k, _) -> Loaded (k, d)
    | Not_loaded k -> Loaded (k, d)
  ;;
end

module Transaction : sig
  type kind =
    | Transfer of
        { sender_wallet : (Uuid.t, Wallet.t) Relation.t
        ; recipient_wallet : (Uuid.t, Wallet.t) Relation.t
        }
    | Deposit of { recipient_wallet : (Uuid.t, Wallet.t) Relation.t }
    | Withdrawal of { sender_wallet : (Uuid.t, Wallet.t) Relation.t }

  type t =
    { id : Uuid.t
    ; amount : Amount.t
    ; kind : kind
    ; timestamp : Ptime.t
    }

  val get_all : wallet_id:Uuid.t -> (module DB) -> (t list, Err.t) Lwt_result.t
  val get_by_id : transaction_id:Uuid.t -> (module DB) -> (t, Err.t) Lwt_result.t
  val create : t -> (module DB) -> (unit, Err.t) Lwt_result.t
end = struct
  type kind =
    | Transfer of
        { sender_wallet : (Uuid.t, Wallet.t) Relation.t
        ; recipient_wallet : (Uuid.t, Wallet.t) Relation.t
        }
    | Deposit of { recipient_wallet : (Uuid.t, Wallet.t) Relation.t }
    | Withdrawal of { sender_wallet : (Uuid.t, Wallet.t) Relation.t }

  type t =
    { id : Uuid.t
    ; amount : Amount.t
    ; kind : kind
    ; timestamp : Ptime.t
    }

  type record =
    { id : Uuid.t
    ; amount : Amount.t
    ; kind : Transaction_kind.t
    ; sender_wallet_id : Uuid.t option
    ; recipient_wallet_id : Uuid.t option
    ; timestamp : Ptime.t
    }

  (* TODO: introduce newtypes for sender and receiver, this is very error prone *)
  (* let load_wallets tx sender_wlt recipient_wlt = *)
  (*   match tx.kind, sender_wlt, recipient_wlt with *)
  (*   | Transfer { sender_wallet; recipient_wallet }, Some sw, Some rw -> *)
  (*     Transfer *)
  (*       { sender_wallet = *)
  (*           ( Relation.load sender_wallet sw *)
  (*           , recipient_wallet = Relation.load recipient_wlt rw ) *)
  (*       } *)
  (*   | _ -> failwith "not implemented" *)
  (* ;; *)

  let to_record (tx : t) : record =
    let module TK = Transaction_kind in
    let kind, sender_wallet_id, recipient_wallet_id =
      match tx.kind with
      | Transfer { sender_wallet; recipient_wallet } ->
        ( TK.Transfer
        , Some (Relation.key sender_wallet)
        , Some (Relation.key recipient_wallet) )
      | Deposit { recipient_wallet } ->
        TK.Deposit, None, Some (Relation.key recipient_wallet)
      | Withdrawal { sender_wallet } ->
        TK.Withdrawal, Some (Relation.key sender_wallet), None
    in
    { id = tx.id
    ; amount = tx.amount
    ; kind
    ; sender_wallet_id
    ; recipient_wallet_id
    ; timestamp = tx.timestamp
    }
  ;;

  let of_rapper ~id ~amount ~kind ~sender_wallet_id ~recipient_wallet_id ~timestamp : t =
    let module TK = Transaction_kind in
    let kind =
      match kind, sender_wallet_id, recipient_wallet_id with
      | TK.Transfer, Some sender_wallet_id, Some recipient_wallet_id ->
        Transfer
          { sender_wallet = Relation.make sender_wallet_id
          ; recipient_wallet = Relation.make recipient_wallet_id
          }
      | TK.Deposit, None, Some recipient_wallet_id ->
        Deposit { recipient_wallet = Relation.make recipient_wallet_id }
      | TK.Withdrawal, Some sender_wallet_id, None ->
        Withdrawal { sender_wallet = Relation.make sender_wallet_id }
      | k, s, r ->
        raise
          (Invalid_argument
             (Format.sprintf
                "Invalid transaction (%s, %s %s)"
                ([%show: TK.t] k)
                ([%show: Uuid.t option] s)
                ([%show: Uuid.t option] r)))
    in
    { id; amount; kind : kind; timestamp : Ptime.t }
  ;;

  let get_all ~wallet_id db_conn =
    let query =
      [%rapper
        get_many
          {sql|
           SELECT @Uuid{id}, @Amount{amount}, @Transaction_kind{kind}, @Uuid?{sender_wallet_id}, @Uuid?{recipient_wallet_id}, @ptime{timestamp}
           FROM transactions
           WHERE sender_wallet_id = %Uuid{wallet_id} OR recipient_wallet_id = %Uuid{wallet_id}
           ORDER BY timestamp DESC
           |sql}
          function_out]
        of_rapper
    in
    query ~wallet_id db_conn |> Lwt_result.map_error Err.of_db_err
  ;;

  (* TODO: this is way more painful than it should be, see if there's a better alternative to Caqti *)
  (* let get_all_v2 ~wallet_id db_conn = *)
  (*   let open Lwt_result.Infix in *)
  (*   let query = *)
  (*     [%rapper *)
  (*       get_many *)
  (*         {sql| *)
  (*          SELECT @Uuid{txs.id}, @Amount{txs.amount}, *)
  (*                 @Transaction_kind{txs.kind}, @Uuid?{txs.sender_wallet_id}, *)
  (*                 @Uuid?{txs.recipient_wallet_id}, *)
  (*                 @ptime{txs.timestamp}, *)
  (*                 @Uuid?{sw.id}, @string?{sw.name}, @Amount?{sw.balance}, @ptime?{sw.timestamp} *)
  (*          FROM transactions AS txs *)
  (*          LEFT JOIN wallets AS sw ON sw.id = txs.sender_wallet_id *)
  (*          LEFT JOIN wallets AS rw ON rw.id = txs.recipient_wallet_id *)
  (*          WHERE txs.sender_wallet_id = %Uuid{wallet_id} OR txs.recipient_wallet_id = %Uuid{wallet_id} *)
  (*          ORDER BY txs.timestamp DESC *)
  (*          |sql} *)
  (*         function_out] *)
  (*       (of_rapper, Wallet.opt_of_rapper) *)
  (*   in *)
  (*   let bla = query ~wallet_id db_conn |> Lwt_result.map_error Err.of_db_err in *)
  (*   let blo = *)
  (*     bla >|= fun txs -> List.map (fun (tx, sw) -> failwith "not implemented") txs *)
  (*   in *)
  (*   failwith "Not implemented" *)
  (* ;; *)

  let get_by_id ~transaction_id db_conn =
    let query =
      [%rapper
        get_one
          {sql|
           SELECT @Uuid{id}, @Amount{amount}, @Transaction_kind{kind}, @Uuid?{sender_wallet_id}, @Uuid?{recipient_wallet_id}, @ptime{timestamp}
           FROM transactions
           WHERE id = %Uuid{transaction_id}
           |sql}
          function_out]
        of_rapper
    in
    query ~transaction_id db_conn |> Lwt_result.map_error Err.of_db_err
  ;;

  let create transaction db_conn =
    let query =
      [%rapper
        execute
          {sql|
           INSERT INTO transactions VALUES (
             %Uuid{id},
             %Amount{amount},
             %Transaction_kind{kind},
             %Uuid?{sender_wallet_id},
             %Uuid?{recipient_wallet_id},
             %ptime{timestamp}
           )
           |sql}
          record_in]
    in
    query (transaction |> to_record) db_conn |> Lwt_result.map_error Err.of_db_err
  ;;
end
