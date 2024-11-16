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

let action_box =
  let open Tyxml.Html in
  div
    ~a:[ a_class [ "col-span-1 p-6 bg-gray-200 flex flex-col items-start" ] ]
    [ div
        ~a:[ a_class [ "p-4 bg-gray-100" ] ]
        [ (* TODO: change to icon later *) div ~a:[ a_class [ "h-8 w-8 bg-black" ] ] [] ]
    ; span ~a:[ a_class [ "pt-4 text-2xl" ] ] [ txt "Enviar dinheiro" ]
    ; span ~a:[ a_class [ "text-base" ] ] [ txt "Enviar dinheiro" ]
    ]
;;

let info_box =
  let open Tyxml.Html in
  div
    ~a:[ a_class [ "col-span-2 p-6 bg-gray-200 flex flex-col gap-6" ] ]
    [ div
        ~a:[ a_class [ "flex justify-between" ] ]
        [ span ~a:[ a_class [ "text-2xl" ] ] [ txt "Recebidos" ] (* TODO select *)
        ; div ~a:[ a_class [ "text-xl py-2 px-5 bg-green-300" ] ] [ txt "Esse mês" ]
        ]
    ; div ~a:[ a_class [ (* TODO: font-size: 40px *) "text-4xl" ] ] [ txt "$ 20.000,00" ]
    ]
;;

let transaction_row =
  let open Tyxml.Html in
  div
    ~a:[ a_class [ "bg-red-400 flex flex-row justify-between items-center" ] ]
    [ div
        ~a:[ a_class [ "flex flex-row gap-8" ] ]
        [ div
            ~a:[ a_class [ "bg-gray-200 p-4" ] ]
            [ div ~a:[ a_class [ "h-8 w-8 bg-black" ] ] [ txt "" ] ]
        ; div
            ~a:[ a_class [ "flex flex-col bg-green-100" ] ]
            [ span
                ~a:[ a_class [ (* TODO: font-size: 22px *) "text-2xl " ] ]
                [ txt "Dinheiro recebido" ]
            ; div
                ~a:[ a_class [ "flex flex-row gap-4" ] ]
                [ span ~a:[ a_class [ "text-lg" ] ] [ txt "José Silva" ]
                ; div ~a:[ a_class [ "bg-black w-px h-full" ] ] [ txt " " ]
                ; span ~a:[ a_class [ "text-lg" ] ] [ txt "12:32:15 27 OUT" ]
                ]
            ]
        ]
    ; div
        ~a:[ a_class [ (* TODO: font-size: 22px *) "text-2xl py-1 px-4 bg-gray-200" ] ]
        [ txt "R$ 500,00" ]
    ]
;;

let new_home =
  let open Tyxml.Html in
  html_template
    [ div
        ~a:[ a_class [ "h-screen grid grid-cols-5 gap-6 pt-6 bg-red-400" ] ]
        [ nav
            ~a:[ a_class [ "col-span-1 bg-green-400 pb-6 pl-8" ] ]
            [ div ~a:[ a_class [ "h-full bg-pink-400" ] ] [] ]
        ; main
            ~a:
              [ a_class
                  [ "col-span-4 bg-blue-400 grid grid-cols-4 gap-y-8 gap-x-6 \
                     content-start overflow-y-auto pr-8"
                  ]
              ]
            [ header
                ~a:[ a_class [ "col-span-4 bg-yellow-400" ] ]
                (* TODO: text-3xl doesn't match 100% *)
                [ div
                    ~a:[ a_class [ "text-3xl p-3" ] ]
                    [ div ~a:[ a_class [ "px-2.5" ] ] [ txt "Home" ] ]
                ]
            ; div
                ~a:[ a_class [ "col-span-4" ] ]
                [ (* TODO: 3xl doesn't match 100% *)
                  div ~a:[ a_class [ "text-3xl mb-1" ] ] [ txt "Saldo" ]
                ; div ~a:[ a_class [ "text-5xl" ] ] [ txt "$ 20.000,00" ]
                ]
            ; action_box
            ; action_box
            ; action_box
            ; action_box
            ; info_box
            ; info_box (* TODO: font-size: 32px *)
            ; h2 ~a:[ a_class [ "col-span-4 text-4xl" ] ] [ txt "Transações" ]
            ; div
                ~a:[ a_class [ "col-span-4 bg-yellow-400 p-6 flex flex-col gap-16" ] ]
                [ transaction_row; transaction_row; transaction_row ]
            ]
        ]
    ]
;;
