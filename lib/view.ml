let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html
let elt_to_string html = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) html
let to_dream_html html = html |> html_to_string |> Dream.html
let elt_to_dream_html html = html |> elt_to_string |> Dream.html

let html_template body_html =
  let open Tyxml.Html in
  let page_title = title (txt "Transactions") in
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

let transaction_row transaction =
  let open Transaction in
  Tyxml.Html.(
    li
      [ a
          ~a:[ a_href (Format.asprintf "/transactions/%a" Uuid.pp transaction.id) ]
          [ txt "Transaction" ]
      ])
;;

let send_transaction_form request wallet_id =
  let open Tyxml.Html in
  form
    ~a:
      [ Unsafe.string_attrib "hx-post" "/pay"
      ; Unsafe.string_attrib "hx-target" "#transactions"
      ; Unsafe.string_attrib "hx-swap" "afterbegin"
      ]
    [ Unsafe.data (Dream.csrf_tag request)
    ; div
        [ label [ txt "Recipient key: " ]
        ; input ~a:[ a_input_type `Text; a_name "recipient_wallet_id" ] ()
        ]
    ; div
        [ label [ txt "Amount: " ]
        ; input ~a:[ a_input_type `Number; a_name "amount" ] ()
        ]
    ; input
        ~a:
          [ a_input_type `Hidden
          ; a_name "sender_wallet_id"
          ; a_value (Uuid.to_string wallet_id)
          ]
        ()
    ; br ()
    ; button ~a:[ a_button_type `Submit ] [ txt "Send money" ]
    ]
;;

let transactions_live wallet_id =
  let open Tyxml.Html in
  div
    ~a:
      [ Unsafe.string_attrib "hx-ext" "sse"
      ; Unsafe.string_attrib "sse-connect" (Format.sprintf "/wallets/%s/stream" wallet_id)
      ; Unsafe.string_attrib "sse-swap" "message"
      ; Unsafe.string_attrib "hx-target" "#transactions"
      ; Unsafe.string_attrib "hx-swap" "afterbegin"
      ]
    [ txt "" ]
;;

let home transactions request wallet_id =
  let open Tyxml.Html in
  html_template
    [ div [ h1 [ txt "Send Transaction" ]; send_transaction_form request wallet_id ]
    ; hr ()
    ; div
        [ h1 [ txt "Transactions" ]
        ; transactions_live (Uuid.to_string wallet_id)
        ; ul ~a:[ a_id "transactions" ] (List.map transaction_row transactions)
        ]
    ]
;;

let transaction_detail transaction =
  let open Transaction in
  let open Tyxml.Html in
  html_template
    [ h1 [ txt (Format.asprintf "Transaction %a!" Uuid.pp transaction.id) ]
    ; ul
        [ li [ txt (Format.asprintf "ID: %a" Uuid.pp transaction.id) ]
        ; li [ txt (Format.sprintf "Amount: %i" (Amount.to_int transaction.amount)) ]
        ; li
            [ txt
                (Format.sprintf
                   "Timestamp: %s"
                   (Datetime.to_string_pretty transaction.timestamp))
            ]
        ]
    ]
;;
