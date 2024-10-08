module Page = struct
  let html_template body_html =
    let open Tyxml.Html in
    let page_title = title (txt "Pix") in
    html
      (head page_title [])
      (* [ script ~a:[ a_src (Xml.uri_of_string "https://cdn.tailwindcss.com") ] (txt "") ]) *)
      (body body_html)
  ;;

  let home =
    let open Tyxml.Html in
    let payments = [ "payment_1"; "payment_2"; "payment_3"; "payment_4" ] in
    let list =
      payments
      |> List.map
         @@ fun payment_id ->
         li
           [ a ~a:[ a_href (Format.sprintf "/payments/%s" payment_id) ] [ txt payment_id ]
           ]
    in
    html_template [ ul list ]
  ;;

  let payment_detail payment_id =
    let open Tyxml.Html in
    html_template [ div [ txt (Format.sprintf "Hello to %s!" payment_id) ] ]
  ;;
end

module View = struct
  let html page_html = Dream.html (Format.asprintf "%a" (Tyxml.Html.pp ()) page_html)
end

let () =
  Dream.run ~port:42069
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" (fun _ -> View.html Page.home)
       ; (Dream.get "/payments/:payment_id"
          @@ fun request ->
          let payment_id = Dream.param request "payment_id" in
          View.html (Page.payment_detail payment_id))
       ]
;;
