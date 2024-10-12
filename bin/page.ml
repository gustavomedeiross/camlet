let html_template body_html =
  let open Tyxml.Html in
  let page_title = title (txt "Pix") in
  html
    (head page_title [])
    (* [ script ~a:[ a_src (Xml.uri_of_string "https://cdn.tailwindcss.com") ] (txt "") ]) *)
    (body body_html)
;;

let home payments =
  let open Tyxml.Html in
  let list =
    payments
    |> List.map
       @@ fun (payment_id, created_at) ->
       li
         [ a
             ~a:[ a_href (Format.sprintf "/payments/%s" payment_id) ]
             [ txt (Format.sprintf "Payment ID: %s, created_at: %s" payment_id created_at)
             ]
         ]
  in
  html_template [ div [ h1 [ txt "Payments" ]; ul list ] ]
;;

let payment_detail payment_id =
  let open Tyxml.Html in
  html_template [ div [ txt (Format.sprintf "Hello to %s!" payment_id) ] ]
;;
