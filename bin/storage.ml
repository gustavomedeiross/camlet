module type DB = Rapper_helper.CONNECTION

type err = { db_err : Caqti_error.t }

let err_of_db_err db_err = { db_err }

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

  val list : (module DB) -> account_id:string -> (t list, err) Lwt_result.t
  val show : (module DB) -> payment_id:string -> (t, err) Lwt_result.t
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

  let list db_conn ~account_id =
    let query =
      [%rapper
        get_many
          {sql|
           SELECT @string{id}, @int{amount}, @string{sender_account_id}, @string{recipient_account_id}, @string{timestamp}
           FROM payments
           WHERE account_id = %string{account_id}
           |sql}]
    in
    query ~account_id db_conn
    |> Lwt_result.map @@ List.map of_tuple
    |> Lwt_result.map_error err_of_db_err
  ;;

  let show db_conn ~payment_id =
    let query =
      [%rapper
        get_one
          {sql|
           SELECT @string{id}, @int{amount}, @string{sender_account_id}, @string{recipient_account_id}, @string{timestamp}
           FROM payments
           WHERE payment_id = %string{payment_id}
           |sql}]
    in
    query ~payment_id db_conn
    |> Lwt_result.map of_tuple
    |> Lwt_result.map_error err_of_db_err
  ;;
end
