let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html
let elt_to_string html = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) html
let to_dream_html html = html |> html_to_string |> Dream.html
let elt_to_dream_html html = html |> elt_to_string |> Dream.html

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
       ; script ~a:[ a_src "https://unpkg.com/htmx-ext-sse@2.2.2/sse.js" ] (txt "")
       ; link ~href:"/static/output.css" ~rel:[ `Stylesheet ] ()
       ])
    (body body_html)
;;

let payment_row payment =
  let open Storage.Payment in
  Tyxml.Html.(
    li [ a ~a:[ a_href (Format.sprintf "/payments/%s" payment.id) ] [ txt payment.id ] ])
;;

(* TODO: we'll need to remove this behavior from the form so it doesn't duplicate the new entry *)
let send_payment_form request account_id =
  let open Tyxml.Html in
  form
    ~a:
      [ Unsafe.string_attrib "hx-post" "/pay"
      ; Unsafe.string_attrib "hx-target" "#payments"
      ; Unsafe.string_attrib "hx-swap" "afterbegin"
      ]
    [ Unsafe.data (Dream.csrf_tag request)
    ; div
        [ label [ txt "Recipient key: " ]
        ; input ~a:[ a_input_type `Text; a_name "recipient_account_id" ] ()
        ]
    ; div
        [ label [ txt "Amount: " ]
        ; input ~a:[ a_input_type `Number; a_name "amount" ] ()
        ]
    ; input ~a:[ a_input_type `Hidden; a_name "sender_account_id"; a_value account_id ] ()
    ; br ()
    ; button ~a:[ a_button_type `Submit ] [ txt "Send money" ]
    ]
;;

let payments_live account_id =
  let open Tyxml.Html in
  div
    ~a:
      [ Unsafe.string_attrib "hx-ext" "sse"
      ; Unsafe.string_attrib
          "sse-connect"
          (Format.sprintf "/accounts/%s/stream" account_id)
      ; Unsafe.string_attrib "sse-swap" "message"
      ; Unsafe.string_attrib "hx-target" "#payments"
      ; Unsafe.string_attrib "hx-swap" "afterbegin"
      ]
    [ txt "" ]
;;

let home payments request account_id =
  let open Tyxml.Html in
  html_template
    [ div [ h1 [ txt "Send Payment" ]; send_payment_form request account_id ]
    ; hr ()
    ; div
        [ h1 [ txt "Payments" ]
        ; payments_live account_id
        ; ul ~a:[ a_id "payments" ] (List.map payment_row payments)
        ]
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
        ; li [ txt (Format.sprintf "Timestamp: %s" (Ptime.to_rfc3339 payment.timestamp)) ]
        ]
    ]
;;
