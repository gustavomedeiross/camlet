type event = Payment_created
type t = event Lwt_stream.t * (event option -> unit)

exception Middleware_not_set

let create () : t = Lwt_stream.create ()
let field = Dream.new_field () ~name:"user channel"

let get request : t =
  match Dream.field request field with
  | Some chan -> chan
  | None -> raise Middleware_not_set
;;

let middleware inner_handler request =
  Dream.log "User_channel.middleware";
  let channel = create () in
  let () = Dream.set_field request field channel in
  inner_handler request
;;
