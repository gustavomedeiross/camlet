let to_dream_html page_html =
  Dream.html (Format.asprintf "%a" (Tyxml.Html.pp ()) page_html)
;;

let html_template body_html =
  let open Tyxml.Html in
  let page_title = title (txt "Payments") in
  html (head page_title []) (body body_html)
;;

let home payments =
  let open Storage.Payment in
  let open Tyxml.Html in
  let list =
    payments
    |> List.map
       @@ fun { id; timestamp; _ } ->
       li
         [ a
             ~a:[ a_href (Format.sprintf "/payments/%s" id) ]
             [ txt (Format.sprintf "Payment ID: %s, created_at: %s" id timestamp) ]
         ]
  in
  to_dream_html @@ html_template [ div [ h1 [ txt "Payments" ]; ul list ] ]
;;

let payment_detail payment =
  let open Storage.Payment in
  let open Tyxml.Html in
  html_template
    [ div [ txt (Format.sprintf "Hello to %s!" payment.id) ]
    ; div [ txt (Format.sprintf "created_at is %s" payment.timestamp) ]
    ]
  |> to_dream_html
;;
