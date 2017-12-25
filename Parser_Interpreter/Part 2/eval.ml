(* -------------------------------------Nishant Arora:P4B--------------------------------------- *)

open Types
open Utils

(* --------------------------------------------------------------------------------------------- *)

exception TypeError of string
exception DeclarationError of string
exception DivByZeroError

(* --------------------------------------------------------------------------------------------- *)

let rec lookup env x =
  match env with
  | [] -> raise (DeclarationError "error in lookup")
  | (y, v)::env' -> if x = y then v else (lookup env' x)

(* --------------------------------------------------------------------------------------------- *)

let rec lookup2 env x =
  match env with
    | [] -> false
    | (y, v)::env' -> if x = y then true else (lookup2 env' x)

(* --------------------------------------------------------------------------------------------- *)

let rec eval_expr env e =
  match e with
  | Id (v) -> (lookup env v)
  | Int (v) -> Val_Int (v)
  | Bool (v) -> Val_Bool (v)

  | Plus (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Int (a + b)
    | (_, _) -> raise (TypeError "error in plus."))

  | Sub (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Int (a - b)
    | (_, _) -> raise (TypeError "error in sub."))

  | Mult (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Int (a * b)
    | (_, _) -> raise (TypeError "error in mult."))

  | Div (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> if b = 0 then raise (DivByZeroError) else Val_Int (a / b)
    | (_, _) -> raise (TypeError "error in div."))

  | Pow (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Int (int_of_float ((float_of_int a) ** (float_of_int b)))
    | (_, _) -> raise (TypeError "error in pow."))

  | Greater (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Bool (a > b)
    | (_, _) -> raise (TypeError "error in greater."))

  | Less (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Bool (a < b)
    | (_, _) -> raise (TypeError "error in less."))

  | GreaterEqual (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Bool (a >= b)
    | (_, _) -> raise (TypeError "error in greater_equal."))

  | LessEqual (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Bool (a <= b)
    | (_, _) -> raise (TypeError "error in less_equal."))

  | Equal (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Bool (a = b)
    | (Val_Bool (a), Val_Bool (b)) -> Val_Bool (a = b)
    | (_, _) -> raise (TypeError "error in equal."))

  | NotEqual (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Int (a), Val_Int (b)) -> Val_Bool (a != b)
    | (Val_Bool (a), Val_Bool (b)) -> Val_Bool (a != b)
    | (_, _) -> raise (TypeError "error in not_equal."))

  | Or (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Bool (a), Val_Bool (b)) -> Val_Bool (a || b)
    | (_, _) -> raise (TypeError "error in or."))

  | And (v1, v2) -> let x1 = (eval_expr env v1) in let x2 = (eval_expr env v2) in
    (match (x1, x2) with
    | (Val_Bool (a), Val_Bool (b)) -> Val_Bool (a && b)
    | (_, _) -> raise (TypeError "error in and."))

  | Not (v1) -> let x1 = (eval_expr env v1) in
    (match x1 with
    | Val_Bool (a) -> Val_Bool (not a)
    | _ -> raise (TypeError "error in not."))

(* --------------------------------------------------------------------------------------------- *)

let rec eval_stmt env s =
  match s with
  | NoOp -> env
  | Seq (stmt1, stmt2) -> let stmt = (eval_stmt env stmt1) in (eval_stmt stmt stmt2)

  | Declare (t, v) -> if (lookup2 env v) = true then raise (DeclarationError "already been declared.") else
		(match t with
		| Type_Int -> (v, Val_Int (0))::env
		| Type_Bool -> (v, Val_Bool (false))::env)

  | Assign (v, a) -> let x1 = (lookup env v) in let x2 = (eval_expr env a) in
    (match (x1, x2) with
    | (Val_Bool (v1), Val_Bool (v2)) -> (v, x2)::(List.remove_assoc v env)
    | (Val_Int (v1), Val_Int (v2)) -> (v, x2)::(List.remove_assoc v env)
    | (_, _) -> raise (TypeError "error in assign."))

  | If (g, i, e) -> let v1 = (eval_expr env g) in
    (match v1 with
    | Val_Bool v -> if v then (eval_stmt env  i) else (eval_stmt env e)
    | _ -> raise (TypeError "error in if."))

  | While (g, b) -> let v1 = (eval_expr env g) in
    (match v1 with
    | Val_Bool v -> if v then (eval_stmt (eval_stmt env b) s) else env
    | _ -> raise (TypeError "error in while."))

  | Print (e) -> let expr = (eval_expr env e) in
    (match expr with
    | Val_Int (v) -> print_output_int v; print_output_newline (); env
    | Val_Bool (v) -> print_output_bool v; print_output_newline (); env)

(* --------------------------------------------------------------------------------------------- *)
