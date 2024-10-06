let hello_page =
  let open Tyxml.Html in
  let page_title = title (txt "My Title") in
  html (head page_title []) (body [ div [ h1 [ txt "Hello World :)" ] ] ])
;;

let html page_html = Dream.html (Format.asprintf "%a" (Tyxml.Html.pp ()) page_html)

let () =
  Dream.run ~port:42069
  @@ Dream.logger
  @@ Dream.router [ Dream.get "/" (fun _ -> html hello_page) ]
;;
