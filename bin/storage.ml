module type DB = Rapper_helper.CONNECTION

type err = { db_err : Caqti_error.t }

let err_of_db_err db_err = { db_err }

let get_exn result =
  Lwt_result.get_exn
  @@ Lwt_result.map_error (fun err -> Caqti_error.Exn err.db_err) result
;;

module Account : sig
  (* TODO: use better types *)
  type t =
    { id : string
    ; name : string
    ; timestamp : string
    }
end = struct
  (* TODO: use better types *)
  type t =
    { id : string
    ; name : string
    ; timestamp : string
    }
end

module Payment : sig
  (* TODO: use better types *)
  type t =
    { id : string
    ; amount : int
    ; sender_account_id : string
    ; recipient_account_id : string
    ; timestamp : string
    }

  val get_all : account_id:string -> (module DB) -> (t list, err) Lwt_result.t
  val get_by_id : payment_id:string -> (module DB) -> (t, err) Lwt_result.t
  val create : t -> (module DB) -> (unit, err) Lwt_result.t
end = struct
  type t =
    { id : string
    ; amount : int
    ; sender_account_id : string
    ; recipient_account_id : string
    ; timestamp : string
    }

  let of_tuple (id, amount, sender_account_id, recipient_account_id, timestamp) =
    { id; amount; sender_account_id; recipient_account_id; timestamp }
  ;;

  let get_all ~account_id db_conn =
    let query =
      [%rapper
        get_many
          {sql|
           SELECT @string{id}, @int{amount}, @string{sender_account_id}, @string{recipient_account_id}, @string{timestamp}
           FROM payments
           WHERE sender_account_id = %string{account_id} OR recipient_account_id = %string{account_id}
           |sql}]
    in
    query ~account_id db_conn
    |> Lwt_result.map @@ List.map of_tuple
    |> Lwt_result.map_error err_of_db_err
  ;;

  let get_by_id ~payment_id db_conn =
    let query =
      [%rapper
        get_one
          {sql|
           SELECT @string{id}, @int{amount}, @string{sender_account_id}, @string{recipient_account_id}, @string{timestamp}
           FROM payments
           WHERE id = %string{payment_id}
           |sql}]
    in
    query ~payment_id db_conn
    |> Lwt_result.map of_tuple
    |> Lwt_result.map_error err_of_db_err
  ;;

  let create _payment _db_conn = Lwt.return (Ok ())
end
