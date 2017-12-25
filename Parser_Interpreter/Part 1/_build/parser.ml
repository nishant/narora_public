open SmallCTypes
open Utils

type stmt_result = token list * stmt
type expr_result = token list * expr

(* Provided helper function - takes a token list and an exprected token.
 * Handles error cases and returns the tail of the list *)
let match_token (toks : token list) (tok : token) : token list = match toks with
  | [] -> raise (InvalidInputException(string_of_token tok))
  | h::t when h = tok -> t
  | h::_ -> raise (InvalidInputException(
      Printf.sprintf "Expected %s from input %s, got %s"
        (string_of_token tok)
        (string_of_list string_of_token toks)
        (string_of_token h)
    ))

let rec lookahead (toks : token list) =
  match toks with
	| [] -> raise (InvalidInputException "Error in lookahead: list is empty.")
	| h::_ -> h

let rec parse_expr toks =
  match toks with
  | [] -> raise (InvalidInputException "Error in parse_expr: list is empty.")
  | _ -> parse_or toks

and parse_or toks = let (l, e) = (parse_and toks) in
  match (lookahead l) with
  | Tok_Or -> let (l1, e1) = (parse_or (match_token l Tok_Or)) in (l1, Or(e, e1))
  | _ -> (l, e)

and parse_and toks = let (l, e) = (parse_eq toks) in
  match (lookahead l) with
  | Tok_And -> let (l1, e1) = (parse_and (match_token l Tok_And)) in (l1, And(e, e1))
  | _ -> (l, e)

and parse_eq toks = let (l, e) = (parse_rel toks) in
  match (lookahead l) with
  | Tok_Equal -> let (l1, e1) = (parse_eq (match_token l Tok_Equal)) in (l1, Equal(e, e1))
  | Tok_NotEqual -> let (l1, e1) = (parse_eq (match_token l Tok_NotEqual)) in (l1, NotEqual(e, e1))
  | _ -> (l, e)

and parse_rel toks = let (l, e) = (parse_add toks) in
  match (lookahead l) with
  | Tok_Greater -> let (l1, e1) = (parse_rel (match_token l Tok_Greater)) in (l1, Greater(e, e1))
  | Tok_GreaterEqual -> let (l1, e1) = (parse_rel (match_token l Tok_GreaterEqual)) in (l1, GreaterEqual(e, e1))
  | Tok_Less -> let (l1, e1) = (parse_rel (match_token l Tok_Less)) in (l1, Less(e, e1))
  | Tok_LessEqual -> let (l1, e1) = (parse_rel (match_token l Tok_LessEqual)) in (l1, LessEqual(e, e1))
  | _ -> (l, e)

and parse_add toks = let (l, e) = (parse_mult toks) in
  match (lookahead l) with
  | Tok_Plus -> let (l1, e1) = (parse_add (match_token l Tok_Plus)) in (l1, Plus(e, e1))
  | Tok_Sub -> let (l1, e1) = (parse_add (match_token l Tok_Sub)) in (l1, Sub(e, e1))
  | _ -> (l, e)

and parse_mult toks = let (l, e) = (parse_pow toks) in
  match (lookahead l) with
  | Tok_Mult -> let (l1, e1) = (parse_mult (match_token l Tok_Mult)) in (l1, Mult(e, e1))
  | Tok_Div -> let (l1, e1) = (parse_mult (match_token l Tok_Div)) in (l1, Div(e, e1))
  | _ -> (l, e)

and parse_pow toks = let (l, e) = (parse_not toks) in
  match (lookahead l) with
  | Tok_Pow -> let (l1, e1) = (parse_pow (match_token l Tok_Pow)) in (l1, Pow(e, e1))
  | _ -> (l, e)

and parse_not toks =
  match (lookahead toks) with
  | Tok_Not -> let (l, e) = (parse_not (match_token toks Tok_Not)) in (l, Not(e))
  | _ -> parse_primary toks

and parse_primary toks =
  (match (lookahead toks) with
  | Tok_Int x -> ((match_token toks (Tok_Int x)), Int(x))
  | Tok_Bool x -> ((match_token  toks (Tok_Bool x)), Bool(x))
  | Tok_ID x -> ((match_token toks (Tok_ID x)), Id(x))
  | Tok_LParen -> let (l, e) = (parse_expr (match_token toks Tok_LParen)) in
    (match (lookahead l) with
    | Tok_RParen -> ((match_token l Tok_RParen), e)
    | _ -> raise (InvalidInputException "Error in parse_expr."))
  | _ -> raise (InvalidInputException "Error in parse_expr: invalid."))
;;

let rec parse_stmt toks =
  (match toks with
    | Tok_Type_Int::(Tok_ID x)::Tok_Semi::t -> let (l, e) = parse_stmt t in
      (l, Seq(Declare(Type_Int, x), e))

    | Tok_Type_Bool::(Tok_ID x)::Tok_Semi::t -> let (l, e) = parse_stmt t in
      (l, Seq(Declare(Type_Bool, x), e))

    | Tok_ID x::Tok_Assign::t -> let (l, e) = (parse_expr t) in
      let l1 = match_token l Tok_Semi in
      let (l2, e1) = parse_stmt l1 in
      (l2, Seq(Assign(x, e), e1))

    | Tok_Print::Tok_LParen::t -> let (l, e) = (parse_expr t) in
      let l1 = match_token l Tok_RParen in
      let l2 = match_token l1 Tok_Semi in
      let (l3, e1) = parse_stmt l2 in
      (l3, Seq(Print(e), e1))

      | Tok_If::t -> let (l, e) = (parse_expr t) in
        (match (lookahead l) with
        | Tok_LBrace ->
          let (l1, e1) = (parse_stmt (match_token l Tok_LBrace)) in
            let token = match_token l1 Tok_RBrace in
              (match (lookahead token) with
                | Tok_Else ->
                  let (l2, e2) = parse_stmt (match_token (match_token token Tok_Else) Tok_LBrace) in
                  let (l3, e3) = parse_stmt (match_token l2 Tok_RBrace) in
                  (l3, Seq(If(e, e1, e2), e3))
                | _ ->
                  let (l4, e4) = parse_stmt token in
                  (l4, Seq(If(e, e1, NoOp), e4)))
        | _ -> raise (InvalidInputException "tok_if err."))

      | Tok_While::t ->
  		  let (l, e) = (parse_expr t) in
      	(match (lookahead l) with
        	| Tok_LBrace ->
        		let (l1, e1) = (parse_stmt (match_token l Tok_LBrace)) in
            	(match (lookahead l1) with
              		| Tok_RBrace ->
                			let (l2, e2) = parse_stmt (match_token l1 Tok_RBrace) in
                 			(l2, Seq(While(e, e1), e2))
              		| _ -> raise (InvalidInputException "while rbrace err."))
        	| _ -> raise (InvalidInputException "while lbrace err."))

    | _ -> (toks, NoOp))


let parse_main toks = match toks with
	| (Tok_Type_Int::Tok_Main::Tok_LParen::Tok_RParen::Tok_LBrace::t) ->
		(let (e,stmt) = parse_stmt t in
		match e with
			| Tok_RBrace::EOF::[] -> stmt
			| _ -> raise (InvalidInputException("parse main err")))
	| _ -> raise (InvalidInputException("parse main err"))
