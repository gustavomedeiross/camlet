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
        ~a:[ a_class [ "flex justify-between items-center" ] ]
        [ span ~a:[ a_class [ "text-2xl" ] ] [ txt "Recebidos" ]
        ; select
            ~a:
              [ a_class
                  [ "py-2 px-5 bg-green-300 flex flex-row justify-between items-center \
                     w-[45%] text-xl home-select outline-none"
                  ]
              ]
            [ option (txt "Esse mês"); option (txt "Último mês") ]
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

let sidebar_button btn_text =
  let open Tyxml.Html in
  li
    ~a:[ a_class [ "bg-white" ] ]
    [ button
        ~a:
          [ a_class
              [ "bg-green-300 px-5 py-4 text-xl w-full flex justify-start items-center \
                 gap-2"
              ]
          ]
        [ span ~a:[ a_class [ "w-5 h-5" ] ] [ Icons.house () ]
        ; span ~a:[] [ txt btn_text ]
        ]
    ]
;;

let home =
  let open Tyxml.Html in
  View.html_template
    [ div
        ~a:[ a_class [ "h-screen grid grid-cols-5 gap-6 pt-6 bg-red-400" ] ]
        [ nav
            ~a:[ a_class [ "col-span-1 bg-green-400 pb-6 pl-8" ] ]
            [ div
                ~a:[ a_class [ "h-full bg-pink-400 py-10 px-5 flex flex-col gap-14" ] ]
                [ h1
                    ~a:
                      [ a_class
                          [ (* TODO: font-size: 40px *) "text-4xl bg-white text-center" ]
                      ]
                    [ txt "Camlet" ]
                ; ul
                    ~a:[ a_class [ "bg-red-700 flex-1 flex flex-col gap-6" ] ]
                    [ sidebar_button "Home"; sidebar_button "Minha Conta" ]
                ]
            ]
        ; main
            ~a:
              [ a_class
                  [ "col-span-4 bg-blue-400 grid grid-cols-4 gap-y-8 gap-x-6 \
                     content-start overflow-y-auto pr-8"
                  ]
              ]
            [ header
                ~a:
                  [ a_class
                      [ "col-span-4 bg-yellow-400 p-3 flex flex-row justify-between \
                         items-center"
                      ]
                  ]
                [ h2
                    ~a:[ a_class [ (* TODO: font-size: 28px *) "text-3xl  px-2.5" ] ]
                    [ txt "Home" ]
                ; div
                    ~a:[ a_class [ "flex flex-row items-center gap-6" ] ]
                    [ div ~a:[ a_class [ "w-6 h-6 bg-black" ] ] [ txt "" ]
                    ; div
                        ~a:[ a_class [ "p-3 bg-gray-300" ] ]
                        [ div ~a:[ a_class [ "w-6 h-6 bg-black" ] ] [ txt "" ] ]
                    ]
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
