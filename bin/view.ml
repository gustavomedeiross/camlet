let html_to_string page_html = Format.asprintf "%a" (Tyxml.Html.pp ()) page_html

let html_template body_html =
  let open Tyxml.Html in
  let page_title = title (txt "Payments") in
  html
    (head
       page_title
       [ script
           ~a:
             [ a_src "https://unpkg.com/htmx.org@2.0.3"
             ; a_integrity
                 "sha384-0895/pl2MU10Hqc6jd4RvrthNlDiE9U1tWmX7WRESftEDRosgxNsQG/Ze9YMRzHq"
             ; a_crossorigin `Anonymous
             ]
           (txt "")
       ])
    (body body_html)
;;

let payment_row payment =
  let open Storage.Payment in
  Tyxml.Html.(
    li [ a ~a:[ a_href (Format.sprintf "/payments/%s" payment.id) ] [ txt payment.id ] ])
;;

let send_payment_form =
  let open Tyxml.Html in
  form
    ~a:[ Unsafe.string_attrib "hx-post" "/pay" ]
    [ input ~a:[ a_input_type `Text; a_name "account_id" ] ()
    ; br ()
    ; button ~a:[ a_button_type `Submit ] [ txt "My button" ]
    ]
;;

let home payments =
  let open Tyxml.Html in
  html_to_string
  @@ html_template
       [ div [ h1 [ txt "Send Payment" ]; send_payment_form ]
       ; div [ h1 [ txt "Payments" ]; ul (List.map payment_row payments) ]
       ]
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
  |> html_to_string
;;
