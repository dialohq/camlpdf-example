module StringMap = Map.Make(String)

let text_from_page pdf page =
  let custom_fonts = match page.Pdfpage.resources with
  | Dictionary dict -> (
      match List.assoc_opt "/Font" dict with
      | Some (Pdf.Dictionary fonts) -> 
          List.fold_left (fun acc (key, font_obj) ->
            StringMap.add key (
              Pdftext.read_font pdf (Pdf.direct pdf font_obj) |> Pdftext.text_extractor_of_font_real
            ) acc
          ) StringMap.empty fonts
      | _ -> StringMap.empty
  )
      | _ -> StringMap.empty
  in
  let rec read_lines font_key font lines ops =
    match ops with
    | [] -> lines
    | Pdfops.Op_Tf (font, _)::rest when String.equal font_key font = false ->
        read_lines font (Some (StringMap.find font custom_fonts)) ("\n"::lines) rest
    | Pdfops.Op_TJ (Array str)::rest -> (
        match font with
        | None -> read_lines font_key font lines rest
        | Some font' ->
        let line = List.map (function
          | Pdf.String str -> 
              Pdftext.utf8_of_codepoints
                 (Pdftext.codepoints_of_text font' str)
          | _ -> ""
        ) str |> String.concat "" in
        read_lines font_key font (line::lines) rest
    )
    | _::rest -> read_lines font_key font lines rest
  in
  let ops = Pdfops.parse_operators
      pdf page.Pdfpage.resources page.Pdfpage.content in
  read_lines "" None [] ops  |> List.rev |> String.concat ""

  let () =
    let pdf = Pdfread.pdf_of_file None None "./stenograf.pdf" in
    let pages = Pdfpage.pages_of_pagetree pdf in
    List.map (fun page ->
      text_from_page pdf page
    ) pages
    |> String.concat ""
    |> print_endline
