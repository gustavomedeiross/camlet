let to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html
let elt_to_string html = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) html
let render html = html |> to_string |> Dream.html
let render_elt html = html |> elt_to_string |> Dream.html
