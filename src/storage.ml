module type DB = Rapper_helper.CONNECTION

type err = { db_err : Caqti_error.t }

let err_of_db_err db_err = { db_err }

let get_exn result =
  Lwt_result.get_exn
  @@ Lwt_result.map_error (fun err -> Caqti_error.Exn err.db_err) result
;;

module Wallet : sig
  (* TODO: use better types *)
  type t =
    { id : string
    ; name : string
    ; timestamp : Ptime.t
    }
end = struct
  (* TODO: use better types *)
  type t =
    { id : string
    ; name : string
    ; timestamp : Ptime.t
    }
end

module Transaction : sig
  (* TODO: use better types *)
  type t =
    { id : string
    ; amount : int
    ; sender_wallet_id : string
    ; recipient_wallet_id : string
    ; timestamp : Ptime.t
    }

  val get_all : wallet_id:string -> (module DB) -> (t list, err) Lwt_result.t
  val get_by_id : transaction_id:string -> (module DB) -> (t, err) Lwt_result.t
  val create : t -> (module DB) -> (unit, err) Lwt_result.t
end = struct
  type t =
    { id : string
    ; amount : int
    ; sender_wallet_id : string
    ; recipient_wallet_id : string
    ; timestamp : Ptime.t
    }

  let get_all ~wallet_id db_conn =
    let query =
      [%rapper
        get_many
          {sql|
           SELECT @string{id}, @int{amount}, @string{sender_wallet_id}, @string{recipient_wallet_id}, @ptime{timestamp}
           FROM transactions
           WHERE sender_wallet_id = %string{wallet_id} OR recipient_wallet_id = %string{wallet_id}
           ORDER BY timestamp DESC
           |sql}
          record_out]
    in
    query ~wallet_id db_conn |> Lwt_result.map_error err_of_db_err
  ;;

  let get_by_id ~transaction_id db_conn =
    let query =
      [%rapper
        get_one
          {sql|
           SELECT @string{id}, @int{amount}, @string{sender_wallet_id}, @string{recipient_wallet_id}, @ptime{timestamp}
           FROM transactions
           WHERE id = %string{transaction_id}
           |sql}
          record_out]
    in
    query ~transaction_id db_conn |> Lwt_result.map_error err_of_db_err
  ;;

  let create transaction db_conn =
    let query =
      [%rapper
        execute
          {sql|
           INSERT INTO transactions VALUES (
             %string{id},
             %int{amount},
             %string{sender_wallet_id},
             %string{recipient_wallet_id},
             %ptime{timestamp}
           )
           |sql}
          record_in]
    in
    query transaction db_conn |> Lwt_result.map_error err_of_db_err
  ;;
end
