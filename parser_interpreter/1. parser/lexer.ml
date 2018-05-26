open SmallCTypes

(* Literal Tokens (from table) *)
let l_paren_tok = Str.regexp "("
let r_paren_tok = Str.regexp ")"
let l_brace_tok = Str.regexp "{"
let r_brace_tok = Str.regexp "}"
let eq_tok = Str.regexp "=="
let not_eq_tok = Str.regexp "!="
let assign_tok = Str.regexp "="
let greater_tok = Str.regexp ">"
let less_tok = Str.regexp "<"
let greater_eq_tok = Str.regexp ">="
let less_eq_tok = Str.regexp "<="
let or_tok = Str.regexp "||"
let and_tok = Str.regexp "&&"
let not_tok = Str.regexp "![^a-zA-Z0-9]"
let semi_tok = Str.regexp ";"
let int_type_tok = Str.regexp "int[^a-zA-Z0-9]"
let bool_type_tok = Str.regexp "bool[^a-zA-Z0-9]"
let print_tok = Str.regexp "printf[^a-zA-Z0-9]"
let main_tok = Str.regexp "main[^a-zA-Z0-9]"
let if_tok = Str.regexp "if[^a-zA-Z0-9]"
let else_tok = Str.regexp "else[^a-zA-Z0-9]"
let while_tok = Str.regexp "while[^a-zA-Z0-9]"
let plus_tok = Str.regexp "\+"
let sub_tok = Str.regexp "-[^0-9]"
let mult_tok = Str.regexp "\*"
let div_tok = Str.regexp "/"
let pow_tok = Str.regexp "\^"

(* Complex Tokens (for values of given type) *)
let bool_tok = Str.regexp "true[^a-zA-Z0-9]\|false[^a-zA-Z0-9]"
let int_tok = Str.regexp "-?[0-9]+"
let id_tok = Str.regexp "[a-zA-Z][a-zA-Z0-9]*"
let space_tok = Str.regexp "[ \t\n]"

let rec tok pos str =
  if pos >= (String.length str) then [EOF]

  else begin
    if (Str.string_match l_paren_tok str pos) then
      Tok_LParen::(tok (pos + 1) str)

    else if (Str.string_match r_paren_tok str pos) then
      Tok_RParen::(tok (pos + 1) str)

    else if (Str.string_match l_brace_tok str pos) then
      Tok_LBrace::(tok (pos + 1) str)

    else if (Str.string_match r_brace_tok str pos) then
      Tok_RBrace::(tok (pos + 1) str)

    else if (Str.string_match eq_tok str pos) then
      Tok_Equal::(tok (pos + 2) str)

    else if (Str.string_match not_eq_tok str pos) then
      Tok_NotEqual::(tok (pos + 2) str)

    else if (Str.string_match assign_tok str pos) then
      Tok_Assign::(tok (pos + 1) str)

    else if (Str.string_match greater_tok str pos) then
      Tok_Greater::(tok (pos + 1) str)

    else if (Str.string_match less_tok str pos) then
      Tok_Less::(tok (pos + 1) str)

    else if (Str.string_match greater_eq_tok str pos) then
      Tok_GreaterEqual::(tok (pos + 2) str)

    else if (Str.string_match less_eq_tok str pos) then
      Tok_LessEqual::(tok (pos + 2) str)

    else if (Str.string_match or_tok str pos) then
      Tok_Or::(tok (pos + 2) str)

    else if (Str.string_match and_tok str pos) then
      Tok_And::(tok (pos + 2) str)

    else if (Str.string_match not_tok str pos) then
      Tok_Not::(tok (pos + 1) str)

    else if (Str.string_match semi_tok str pos) then
      Tok_Semi::(tok (pos + 1) str)

    else if (Str.string_match int_type_tok str pos) then
      Tok_Type_Int::(tok (pos + 3) str)

    else if (Str.string_match bool_type_tok str pos) then
      Tok_Type_Bool::(tok (pos + 4) str)

    else if (Str.string_match print_tok str pos) then
      Tok_Print::(tok (pos + 6) str)

    else if (Str.string_match main_tok str pos) then
      Tok_Main::(tok (pos + 4) str)

    else if (Str.string_match if_tok str pos) then
      Tok_If::(tok (pos + 2) str)

    else if (Str.string_match else_tok str pos) then
      Tok_Else::(tok (pos + 4) str)

    else if (Str.string_match while_tok str pos) then
      Tok_While::(tok (pos + 5) str)

    else if (Str.string_match plus_tok str pos) then
      Tok_Plus::(tok (pos + 1) str)

    else if (Str.string_match sub_tok str pos) then
      Tok_Sub::(tok (pos + 1) str)

    else if (Str.string_match mult_tok str pos) then
      Tok_Mult::(tok (pos + 1) str)

    else if (Str.string_match div_tok str pos) then
      Tok_Div::(tok (pos + 1) str)

    else if (Str.string_match pow_tok str pos) then
      Tok_Pow::(tok (pos + 1) str)

    else if (Str.string_match space_tok str pos) then
      (tok (pos + 1) str)

    else if (Str.string_match bool_tok str pos) then
      let token = Str.matched_string str in
      let position = Str.match_end () in
        if (Str.string_match (Str.regexp "true") token 0) then
          (Tok_Bool true)::(tok position str)
        else
          (Tok_Bool false)::(tok position str)

    else if (Str.string_match int_tok str pos) then
      let token = Str.matched_string str in
      let position = Str.match_end () in
      (Tok_Int (int_of_string token))::(tok position str)

    else if (Str.string_match id_tok str pos) then
      let token = Str.matched_string str in
      let position = Str.match_end () in
      (Tok_ID token)::(tok position str)

    else
      raise (InvalidInputException "tokenize error.")
  end
;;

let tokenize input = tok 0 (input ^ " ") ;;
