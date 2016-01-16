open Batteries

type var = int
type t = True | False | Var of var | Neg of t | Conj of t Set.t | Disj of t Set.t

let p s a b = if a <> "" then if b <> "" then a ^ s ^ b else a else b

let fromBool a = if a then True else False

let rec toBoolWithVars a e = match a with
| True -> true
| False -> false
| Conj c -> Set.fold (fun a b -> b && (toBoolWithVars a e)) c true
| Disj d -> (Set.fold (fun a b -> b || (toBoolWithVars a e)) d false)
| Neg a -> not (toBoolWithVars a e)
| _ -> e

let toBool a = toBoolWithVars a false

let rec show = function
  | True -> "T"
  | False -> "F"
  | Var x -> "x" ^ string_of_int x
  | Neg e -> "Not(" ^ show e ^ ")"
  | Conj c -> "(" ^ Set.fold (fun x a -> p " /\\ " a (show x)) c "" ^ ")"
  | Disj d -> "(" ^ Set.fold (fun x a -> p " \\/ " a (show x)) d "" ^ ")"

let rec eval sigma e = match e with
| True -> true
| False -> false
| Conj c -> Set.fold (fun a b -> b && (eval sigma a)) c true
| Disj d -> (Set.fold (fun a b -> b || (eval sigma a)) d false)
| Neg e -> not (eval sigma e)
| Var a -> sigma a

let rec push_neg e = match e with
| Neg a -> (match a with
  | True -> False
  | False -> True
  | Neg e -> push_neg e
  | Conj c -> Disj (Set.map (fun x -> push_neg (Neg x)) c)
  | Disj d -> Conj (Set.map (fun x -> push_neg (Neg x)) d)
  | Var a -> e)
| Conj c -> Conj (Set.map (fun x -> push_neg x) c)
| Disj d -> Disj (Set.map (fun x -> push_neg x) d)
| _ -> e

let append a b = a @ b

let rec cleanup e = match e with
| Conj c -> (match Set.to_list c with
  | [] -> False
  | x::[] -> x
  | _ -> let a = Set.to_list (Set.map (fun x -> cleanup x) c)
  in let x = List.filter (fun c -> match c with
    | Conj c -> false
    | _ -> true) a
  in let y = List.map (fun x -> match x with
      | Conj c -> Set.to_list c
      | _ -> [x])
    (List.filter (fun c -> match c with
      | Conj c -> true
      | _ -> false) a)
  in Conj (Set.union (Set.of_list x) (Set.of_list (List.fold_left append [] y))))
| Disj d -> (match Set.to_list d with
  | [] -> False
  | x::[] -> x
  | _ -> let a = Set.to_list (Set.map (fun x -> cleanup x) d)
  in let x = List.filter (fun c -> match c with
    | Disj d -> false
    | _ -> true) a
  in let y = List.map (fun x -> match x with
      | Disj d -> Set.to_list d
      | _ -> [x])
    (List.filter (fun c -> match c with
      | Disj d -> true
      | _ -> false) a)
  in Disj (Set.union (Set.of_list x) (Set.of_list (List.fold_left append [] y))))
| Neg e -> Neg (cleanup e)
| _ -> e

let contains e v = match e with
| Conj e -> let x = Set.inter (Set.of_list v) e in x != Set.empty
| Disj e -> let x = Set.inter (Set.of_list v) e in x != Set.empty
| _ -> false

let rec varsInMenge e = match e with
| Disj x -> List.filter (fun a -> match a with
  | Var i -> true
  | _ -> false) (Set.to_list x)
| Conj x -> List.filter (fun a -> match a with
  | Var i -> true
  | _ -> false) (Set.to_list x)
| _ -> []

let removeUnnecesaryVars e = let l = varsInMenge e in match e with
| Disj x -> Disj (Set.of_list (List.filter (fun (i) -> match i with
  | Conj x -> not (contains i l)
  | _ -> true) (Set.to_list x)))
| Conj x -> Conj (Set.of_list (List.filter (fun (i) -> match i with
  | Disj x -> not (contains i l)
  | _ -> true) (Set.to_list x)))
| _ -> e

let rec allVars e = match e with
| Var i -> Set.of_list [i]
| Conj c -> Set.fold (fun a b -> Set.union (allVars a) b) c Set.empty
| Disj d -> Set.fold (fun a b -> Set.union (allVars a) b) d Set.empty
| Neg x -> allVars x
| _ -> Set.empty

let rec allOptions l = match l with
| [] -> []
| x::[] -> [[(x,true)];[(x,false)]]
| x::xs -> let a = allOptions xs in List.fold_left (fun r i -> r@[(x,true)::i;(x,false)::i]) [] a

let rec getValue v a = match v with
| [] -> false
| x::xs -> let (n,t) = x in if n = a then t else (getValue xs a)

let evalWithVars e v = eval (fun a -> getValue v a) e

let isVarIndependent e = let v = Set.to_list (allVars e) in let l = allOptions v in match l with
| [] -> (true,toBoolWithVars e true)
| x::xs -> List.fold_left (fun r i -> let (d,v) = r in let s = evalWithVars e i in (d && v=s,v)) (true,evalWithVars e x) l

let rec simplify e = let (a,b) = isVarIndependent e in if a then fromBool b else match e with
| Conj x -> let a = Conj (Set.map (fun x -> simplify x) (Set.of_list (List.filter
  (fun x -> match x with
  | True -> false
  | _ -> true) (Set.to_list x)))) in removeUnnecesaryVars a
| Disj x -> let a = Disj (Set.map (fun a -> simplify a) (Set.of_list (List.filter (fun x -> match x with
  | False -> false
  | _ -> true) (Set.to_list x)))) in removeUnnecesaryVars a
| Neg t -> (match t with
  | Neg e -> simplify e
  | _ -> Neg (simplify t))
| _ -> e

let is_simplified e = e = simplify e

let to_nnf e = cleanup (simplify (cleanup (push_neg e)))

let distributeConj e = match e with
| Conj x -> let dis = List.filter (fun x -> match x with
    | Disj x -> true
    | _ -> false) (Set.to_list x)
  in let r = List.filter (fun x -> match x with
    | Disj x -> false
    | _ -> true) (Set.to_list x) in if dis = [] then e else Conj (Set.of_list (List.map (fun y -> let z = (match y with
    | Disj x -> x
    | _ -> Set.empty) in Disj (Set.of_list (List.map (fun i -> Conj (Set.of_list (i::r))) (Set.to_list z)))) dis))
| _ -> e

let distributeDisj e = match e with
| Disj x -> let dis = List.filter (fun x -> match x with
    | Conj x -> true
    | _ -> false) (Set.to_list x)
  in let r = List.filter (fun x -> match x with
    | Conj x -> false
    | _ -> true) (Set.to_list x) in if dis = [] then e else Disj (Set.of_list (List.map (fun y -> let z = (match y with
    | Conj x -> x
    | _ -> Set.empty) in Conj (Set.of_list (List.map (fun i -> Disj (Set.of_list (i::r))) (Set.to_list z)))) dis))
| _ -> e

let rec hasDisj e = match e with
| [] -> false
| x::xs -> match x with
  | Disj _ -> true
  | _ -> hasDisj xs

let rec hasConj e = match e with
| [] -> false
| x::xs -> match x with
  | Conj _ -> true
  | _ -> hasDisj xs

let rec to_dnf e = let a = to_nnf e in let x = to_nnf (distributeConj a) in match x with
| Conj a -> if hasDisj (Set.to_list a) then to_dnf x else x
| _ -> x

let rec to_cnf e = let a = to_nnf e in let x = to_nnf (distributeDisj a) in match x with
| Disj a -> if hasConj (Set.to_list a) then to_dnf x else x
| _ -> x
