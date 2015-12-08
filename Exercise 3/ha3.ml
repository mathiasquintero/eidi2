let todo _ = failwith "TODO"

(* shortcuts *)
let (%) g f x = g (f x)
let id x = x
let flip f x y = f y x
let neg f x = not (f x)
module Tuple2 = struct
  let fst (x,y) = x
  let snd (x,y) = y
  let map1 f (x,y) = f x, y
  let map2 f (x,y) = x, f y
end

module MyList = struct
  let cons x xs = x :: xs
  let rec length = function [] -> 0 | _::xs -> 1 + length xs
  let rec map f = function [] -> [] | x::xs -> f x :: map f xs
  let rec filter p = function [] -> [] | x::xs -> if p x then x :: filter p xs else filter p xs
  let rec fold_left f a = function [] -> a | x::xs -> fold_left f (f a x) xs
  let rec fold_right f = function [] -> (fun x -> x) | x::xs -> fun a -> f x (fold_right f xs a) (* not tail recursive! *)

  let rec contains e l = match l with
  | [] -> false
  | x::xs -> x = e || contains e xs

  let rec append x y = match x with
  | [] -> y
  | a::b -> a::(append b y)

  let rec reverse l = match l with
  | [] -> []
  | x::xs -> append (reverse xs) [x]



  (* return Some element at index i or None if out of bounds. e.g. at 1 [1;2;3] = Some 2, at 1 [] = None *)
  let rec at i xs = match xs with
  | [] -> None
  | x::y -> match i with
  | 0 -> Some x
  | _ -> (at (i-1) y)
  (* concatenate a list of lists. e.g. flatten [[1];[2;3]] = [1;2;3] *)
  let rec flatten xs = match xs with
  | [] -> []
  | x::y -> match x with
  | [] -> flatten y
  | a::b -> a::(flatten (b::y))
  (* a list containing n elements x. e.g. make 3 1 = [1;1;1], make 2 'x' = ['x';'x'] *)
  let rec make n x = match n with
  | 0 -> []
  | _ -> x::(make (n-1) x)
  (* range 1 3 = [1;2;3], range 1 (-1) = [1;0;-1] *)
  let rec range a b = if a = b then [b] else if a < b then a::(range (a+1) b) else a::(range (a-1) b)
  (* [f 0; f 1; ...; f (n-1)]. e.g. init 3 (fun x -> Char.chr (x+65)) = ['A'; 'B'; 'C'], [] for n<1 *)
  let init n f = if n > 0 then map f (range 0 (n-1)) else []
  (* reduce f [] = None, reduce f [1] = Some [1], reduce f [1;2;3] = Some (f (f 1 2) 3) *)

  let rec reversed_reduce f xs = match xs with
  | [] -> None
  | x::y -> match reversed_reduce f y with
  | None -> Some x
  | Some a -> Some (f a x)

  let reduce f xs = reversed_reduce f (reverse xs)
  (* maximum element of a list. e.g. max_el [2;1;3] = Some 3, max_el [] = None *)
  let rec max_el xs = match xs with
  | [] -> None
  | x::y -> match max_el y with
  | None -> Some x
  | Some a -> if a > x then Some a else Some x
  let rec min_el xs = match xs with
  | [] -> None
  | x::y -> match min_el y with
  | None -> Some x
  | Some a -> if a < x then Some a else Some x
  (* min_max [] = None, min_max [2;4;1;2] = (1,4) *)
  let min_max xs = match min_el xs with
  | None -> None
  | Some min -> match max_el xs with
  | None -> None
  | Some max -> Some (min, max)
  (* mem 2 [1;2;3] = true; mem 2 [1;3] = false *)
  let rec mem e xs = match xs with
  | [] -> false
  | x::xs -> x=e || mem e xs
  (* find even [1;2;3] = Some 2, find even [1;3] = None *)
  let rec find p xs = match xs with
  | [] -> None
  | x::y -> match p x with
  | true -> Some x
  | false -> find p y
  (* filter_map (fun x -> if even x then Some (x*2) else None) [1;2;3;4] = [4;8], filter_map (const None) [1;2;3] = [] *)
  let filter_map f xs = match xs with
  | [] -> []
  | _ -> (map (function x -> match f x with
  | Some a -> a) (filter (function x -> match f x with
  | None -> false
  | _ -> true) xs))
  (* partition even [1;2;3;4] = ([2;4],[1;3]) *)
  let partition p s = filter p s , filter (function x -> not (p x)) s
  (* index_of 2 [1;2;3] = Some 1, index_of 2 [] = None *)
  let rec index_of e xs = match xs with
  | [] -> None
  | x::y -> if x = e then Some 0
  else match index_of e y with
  | None -> None
  | Some a -> Some (1 + a)
  (* split_at 1 [1;2;3] = ([1],[2;3]), split_at 2 [1] = ([1],[]) *)
  let rec split_at i xs = if i <= 0 then ([],xs)
  else match xs with
  | [] -> ([],[])
  | x::y -> let (a,b) = split_at (i-1) y in (x::a, b)
  (* remove_all even [1;2;3;4] = [1;3] *)
  let remove_all p xs = filter (function x -> not (p x)) xs
  (* remove_first even [1;2;3;4] = [1;3;4] *)
  let rec remove_first p xs = match xs with
  | [] -> []
  | x::y -> if p x then y else x::(remove_first p y)
  (* take 2 [1;2;3;4] = [1;2], take 2 [] = [] *)
  let rec take n xs = if n > 0 then match xs with
  | [] -> []
  | x::y -> x::(take (n-1) y)
  else []
  (* drop 2 [1;2;3;4] = [3;4], drop 2 [] = [] *)
  let rec drop n xs = if n > 0 then match xs with
  | [] -> []
  | x::y -> drop (n-1) y
  else xs
  (* interleave 0 [1;2;3] = [1;0;2;0;3], interleave 0 [] = [] *)
  let rec interleave e xs = match xs with
  | [] -> []
  | x::[] -> [x]
  | x::y -> x::e::(interleave e y)
  (* split [1,2;2,3;3,4] = ([1;2;3],[2;3;4]), split [] = ([],[]) *)

  let rec split xs = match xs with
  | [] -> ([],[])
  | x::y -> let (a,b) = x in let (c,d) = split y in (a::c,b::d)

  (* combine [1;2] [3;4] = Some [1,3;2,4], combine [1] [2;3] = None *)
  let rec combine a b = if length a != length b then None
  else match a with
  | [] -> Some []
  | x::y -> match b with
    | [] -> Some []
    | c::d -> match combine y d with
      | None -> None
      | Some xs -> Some ((x,c)::xs)
end

module MySet = struct
  type 'a t = Con of 'a list (* this is abstract in the interface so that one has to use {from,to}_list *)

  open MyList

  let distinctFromX x y = remove_all ((fun a -> (contains a x))) y

  let rec removeDuplicates xs = match xs with
  | [] -> []
  | x::y -> x::removeDuplicates(remove_all ((fun (a) -> a=x)) y)

  let unite x y = append x (distinctFromX x y)
  (* from_list [1;2;1] = [1;2] *)

  let from_list xs = Con(removeDuplicates xs)
  let to_list x = match x with
  | Con xs -> xs
  (* union [1;2] [2;3] = [1;2;3] *)
  let union a b = let x = to_list a in let y = to_list b in Con(unite x y)
  (* inter [1;2] [2;3] = [2] *)
  let inter a b = let x = to_list a in let y = to_list b in let s = filter (fun c -> contains c x) y in Con(removeDuplicates s)
  (* diff [1;2;3] [1;3] = [2] *)
  let diff a b = let x = to_list a in let y = to_list b in let c = append x y in Con(distinctFromX y (reverse c))
end
