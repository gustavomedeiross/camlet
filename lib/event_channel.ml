type event = Transaction_created of Transaction.t
type t = event Lwt_stream.t * (event option -> unit)

exception Middleware_not_set

let create () : t = Lwt_stream.create ()
let field = Dream.new_field () ~name:"event channel"

let get request : t =
  match Dream.field request field with
  | Some chan -> chan
  | None -> raise Middleware_not_set
;;

let middleware () =
  let channel = create () in
  fun inner_handler request ->
    let () = Dream.set_field request field channel in
    inner_handler request
;;
