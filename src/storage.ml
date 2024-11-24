module type DB = Rapper_helper.CONNECTION

module Err = struct
  type t = { db_err : Caqti_error.t }

  let of_db_err db_err = { db_err }

  let exn result =
    Lwt_result.get_exn
    @@ Lwt_result.map_error (fun err -> Caqti_error.Exn err.db_err) result
  ;;
end

module Wallet : sig
  type t =
    { id : Uuid.t
    ; name : string
    ; balance : Amount.t
    ; timestamp : Ptime.t
    }
end = struct
  type t =
    { id : Uuid.t
    ; name : string
    ; balance : Amount.t
    ; timestamp : Ptime.t
    }
end

module Transaction : sig
  type t =
    { id : Uuid.t
    ; amount : Amount.t
    ; sender_wallet_id : Uuid.t
    ; recipient_wallet_id : Uuid.t
    ; timestamp : Ptime.t
    }

  val get_all : wallet_id:Uuid.t -> (module DB) -> (t list, Err.t) Lwt_result.t
  val get_by_id : transaction_id:Uuid.t -> (module DB) -> (t, Err.t) Lwt_result.t
  val create : t -> (module DB) -> (unit, Err.t) Lwt_result.t
end = struct
  type t =
    { id : Uuid.t
    ; amount : Amount.t
    ; sender_wallet_id : Uuid.t
    ; recipient_wallet_id : Uuid.t
    ; timestamp : Ptime.t
    }

  let get_all ~wallet_id db_conn =
    let query =
      [%rapper
        get_many
          {sql|
           SELECT @Uuid{id}, @Amount{amount}, @Uuid{sender_wallet_id}, @Uuid{recipient_wallet_id}, @ptime{timestamp}
           FROM transactions
           WHERE sender_wallet_id = %Uuid{wallet_id} OR recipient_wallet_id = %Uuid{wallet_id}
           ORDER BY timestamp DESC
           |sql}
          record_out]
    in
    query ~wallet_id db_conn |> Lwt_result.map_error Err.of_db_err
  ;;

  let get_by_id ~transaction_id db_conn =
    let query =
      [%rapper
        get_one
          {sql|
           SELECT @Uuid{id}, @Amount{amount}, @Uuid{sender_wallet_id}, @Uuid{recipient_wallet_id}, @ptime{timestamp}
           FROM transactions
           WHERE id = %Uuid{transaction_id}
           |sql}
          record_out]
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
             'transfer',
             %Uuid{sender_wallet_id},
             %Uuid{recipient_wallet_id},
             %ptime{timestamp}
           )
           |sql}
          record_in]
    in
    query transaction db_conn |> Lwt_result.map_error Err.of_db_err
  ;;
end
