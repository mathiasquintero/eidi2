let todo _ = failwith "TODO"

(* Ungültige Eingaben werden nicht getestet, Sie können in diesen Fällen aber folgene Exception werfen: *)
exception Invalid_input

(* hello "test" = "Hello test!" *)
let hello x = "Hello " ^ x ^ "!"

(* Fakultät *)
let rec fac n = match n with
| 0 -> 1
| _ -> n * fac (n-1)

(* Fibonacci-Zahlen beginnend mit fib 0 = 0 *)
let rec fib n = match n with
| 0 -> 0
| 1 -> 1
| _ -> (fib (n-1)) + (fib (n-2))

(* Summe gerader Zahlen von 0 bis n *)
let rec even_sum n = match n with
| 0 -> 0
| _ -> match n mod 2 with
  | 0 -> n + even_sum (n-2)
  | _ -> even_sum (n-1)

(* Ist die Liste leer? *)
let is_empty l = match l with
| [] -> true
| _  -> false

(* Länge einer Liste *)
let rec length l = match l with
| [] -> 0
| x::[] -> 1
| x::y -> 1 + (length y)

(* Summe einer Integer-Liste *)
let rec sum l = match l with
| [] -> 0
| x::[] -> x
| x::y  -> x + (sum y)
