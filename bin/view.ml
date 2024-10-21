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
       @@ fun { id; _ } ->
       li [ a ~a:[ a_href (Format.sprintf "/payments/%s" id) ] [ txt id ] ]
  in
  to_dream_html @@ html_template [ div [ h1 [ txt "Payments" ]; ul list ] ]
;;

let payment_detail payment =
  let open Storage.Payment in
  let open Tyxml.Html in
  html_template
    [ h1 [ txt (Format.sprintf "Payment %s!" payment.id) ]
    ; ul
        [ li [ txt (Format.sprintf "ID: %s" payment.id) ]
        ; li [ txt (Format.sprintf "Amount: %i" payment.amount) ]
        ; li
            [ txt "Sender Account ID: "
            ; a
                ~a:[ a_href (Format.sprintf "/accounts/%s" payment.sender_account_id) ]
                [ txt payment.sender_account_id ]
            ]
        ; li
            [ txt "Recipient Account ID: "
            ; a
                ~a:[ a_href (Format.sprintf "/accounts/%s" payment.recipient_account_id) ]
                [ txt payment.recipient_account_id ]
            ]
        ; li [ txt (Format.sprintf "Timestamp: %s" payment.timestamp) ]
        ]
    ]
  |> to_dream_html
;;
