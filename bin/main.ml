let () =
  Dream.run ~port:42069
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" (fun _ -> Dream.html "<html><body><h1>Hello!</h1></body></html>") ]
;;

let () = print_endline "Hello, World!"
