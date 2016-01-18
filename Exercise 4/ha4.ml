open Batteries
let todo _ = failwith "TODO"

module MyMap = struct
  (* type ('k,'v) t = ('k*'v) list (* this would not be very efficient *) *)
  (* implement map as binary trees, since we don't have functors yet, we split up the content and only compare on 'k *)
  type ('k,'v) t = Empty | Node of 'k * 'v * ('k,'v) t * ('k,'v) t

  open Option

  let empty = Empty

  let show sk sv m =
    let sp k v = sk k ^ " -> " ^ sv v in
    let (|^) a b = if a <> "" then if b <> "" then a ^ ", " ^ b else a else b in
    let rec f = function
      | Empty -> ""
      | Node (k, v, l, r) -> sp k v |^ f l |^ f r
    in
    "{ " ^ f m ^ " }"

  let rec to_list = function
    | Empty -> []
    | Node (k, v, l, r) -> (k,v) :: to_list l @ to_list r

  let show sk sv m = to_list m |> List.map (fun (k,v) -> sk k ^ " -> " ^ sv v) |> String.concat ", " |> fun s -> "{ " ^ s ^ " }"

  let rec add k' v' = function
    | Empty -> Node (k', v', Empty, Empty)
    | Node (k, v, l, r) ->
        let v,l,r = if k'=k then v',l,r else if k'<k then v, add k' v' l, r else v, l, add k' v' r in
        Node (k, v, l, r)

  let from_list xs = List.fold_left (fun m (k,v) -> add k v m) empty xs

  let rec find k = function
    | Empty -> None
    | Node (k', v', l, r) ->
        if k = k' then Some v'
        else find k (if k < k' then l else r)

  (* homework *)
  (* mem k m returns true if m contains a binding for k, and false otherwise *)
  let mem k m = (find k m) != None

  (* return the smallest binding of the given map *)
  let rec min m = match m with
  | Empty -> None
  | Node(a,b,c,d) -> match min c with
    | None -> Some (a,b)
    | Some x -> Some x

  (* return the largest binding of the given map *)
  let rec max m = match m with
  | Empty -> None
  | Node(a,b,c,d) -> match max d with
    | None -> Some (a,b)
    | Some x -> Some x

  (* remove k m returns a map containing the same bindings as m, except the binding for k *)
  let rec remove k m = match m with
  | Empty -> Empty
  | Node(a,b,c,d) ->
    if a = k then
      match max c with
      | Some x -> let (y,z) = x in let c = remove y c in Node(y,z,c, d)
      | None -> match min d with
        | Some x -> let (y,z) = x in let d = remove y d in Node(y,z,c,d)
        | None -> Empty
    else
      if k < a then Node(a,b,remove k c, d) else Node(a,b,c, remove k d)

  (* map f m returns a map with same domain as m, where the associated value a of all bindings of m has been replaced by the result of the application of f to a *)
  let rec map f m = match m with
  | Empty -> Empty
  | Node (a,b,c,d) -> Node(a,f b, map f c, map f d)

  let rec replace s v m = match m with
  | Empty -> Node(s,v,Empty,Empty)
  | Node (a,b,c,d) -> if a = s then Node(a,v,c,d) else if s < a then Node(a,b,replace s v c,d) else Node(a,b,c,replace s v d)

  (* filter f m returns the map with all the bindings in m that satisfy predicate f *)

  let filter f m = let x = to_list m in let r = List.filter f x in from_list r

  (* let rec filter f m = match m with
  | Empty -> Empty
  | Node(a,b,c,d) -> if f (a,b) then Node(a,b,filter f c, filter f d)
  else let x = remove a m in filter f x *)

    let decideFirst f a = let (x,y) = a in match f x (Some y) None with
    | None -> None
    | Some a -> Some a

    let decideSecond f b = let (x,y) = b in match f x None (Some y) with
    | None -> None
    | Some a -> Some a

    let decideBoth f a b = let (x,y) = a in let (v,w) = b in if x = v then (match f x (Some y) (Some w) with
    | None -> None
    | Some a -> Some a)
    else decideFirst f a

  let rec withLists f a b = match a with
  | [] -> (match b with
      | [] -> []
      | (x,y)::xs -> (match decideSecond f (x,y) with
        | None -> withLists f a b
        | Some y -> (x,y)::withLists f a xs))
  | (x,y)::xs -> (match List.filter (fun (c,d) -> c = x) b with
      | [] -> (match decideFirst f (x,y) with
        | None -> withLists f xs b
        | Some y -> (x,y)::withLists f xs b)
      | r::d -> match decideBoth f (x,y) r with
        | None -> (withLists f xs (List.filter (fun (c,d) -> c != x) b))
        | Some y -> (x,y)::(withLists f xs (List.filter (fun (c,d) -> c != x) b)))

  (* merge f m1 m2 computes a map whose keys are a subset of the union of keys of m1 and of m2. The presence of each such binding, and the corresponding value, is determined with the function f *)
  (* let a = from_list [1,"a";  2,"b"; 3,"c"]f  in
   * let b = from_list [1,1;    2,2;   4,4] in
   * then merge f a b contains the bindings f 1 (Some "a") (Some 1), f 2 (Some "b") (Some 2), f 3 (Some "c") None, f 4 None (Some 4) that return something *)
  let merge f a b = let a = to_list a in let b = to_list b in from_list (withLists f a b)
end

module Json = struct
  (* our json datatype using maps and lists *)
  type t =
    | Null
    | Bool of bool
    | Number of float
    | String of string
    | Object of (string,t) MyMap.t
    | Array  of t list
  (* t is recursive! offset is used for accesssing inner json values *)
  type offset = Field of string | Index of int (* Field for Object, Index for Array *)
  (* we write foo.bar[1].baz for [Field "foo"; Field "bar"; Index 1' Field "baz"] *)
  type path = offset list

  (*
    This is an overly complicated mapper for lists.
    It runs every element through f and combines them with c
    while n is the empty return value.
    Warning! n will only be the result for an empty list from the start.
  *)

  let rec iterateArray f c l n = match l with
  | [] -> n
  | x::[] -> (f x)
  | x::xs -> (c (f x) (iterateArray f c xs n))

  let concatenateElements a b = a ^ ", " ^ b

  let concatenateElementsObject a b = a ^ ",\n" ^b

  let rec append a e = match a with
  | [] -> e
  | x::xs -> x::append xs e

  let rec getFromIndex l i = match l with
  | [] -> None
  | x::xs -> if i == 0 then Some x else getFromIndex xs (i-1)

  let rec findInTupleList s xs = match xs with
  | [] -> None
  | x::y -> let (a,b) = x in if a = s then Some b else findInTupleList s y

  let rec setAtIndex l i e = (match l with
  | [] -> None
  | x::xs -> if i = 0 then Some (e::xs) else match setAtIndex xs (i-1) e with
  | None -> None
  | Some a -> Some (x::a))

  (* example:
    { "a": null, "b": true, "c": 1.2, "d": "hello \"you\"!", "e": {  }, "f": [0, false, "no"] }
  *)

  let rec show json = match json with
  | Null -> "null"
  | Bool a -> if a then "true" else "false"
  | Number a -> (string_of_float a)
  | String a -> "\"" ^ a ^ "\""
  | Array a -> "[" ^ (iterateArray (fun (x) -> show x) concatenateElements a "") ^ "]"
  | Object a -> let l = MyMap.to_list a in
    "{ " ^ (iterateArray (fun (x) -> let (y,z) = x in "\"" ^ y ^ "\": " ^ show z) concatenateElements l "") ^ " }"

  (* map f over all values of type t *)
  let rec map f json = match json with
  | Array a -> f (Array(iterateArray (fun (x) -> [map f x]) append a []))
  | Object a -> f (Object(MyMap.map ((fun (x) -> map f x)) a))
  | _ -> f json

  (* return the content of a Field or Index of a json value or None *)
  (* e.g. get (Index 1) (Array [Null, Bool true, Bool false]) = Some (Bool true)
   *      get_offset (Index 1) (Array []) = None
   *      get_offset (Index 1) Null = None
   *)
   let get_offset offset json = match offset with
   | Index i -> (match json with
     | Array a -> getFromIndex a i
     | _ -> None)
   | Field i -> (match json with
     | Object a -> MyMap.find i a
     | _ -> None)

  (* same as get_offset, but now on a whole path. if any part of the path fails we return None, otherwise the value. *)
  (* e.g. get [Field "a"; Index 0] (Object (MyMap.from_list ["a", Array [Null]])) = Some Null
   *      get [Field "a"; Index 1] (Object (MyMap.from_list ["a", Array [Null]])) = None
   *)
  let rec get path json = (let (a:path) = path in
    match a with
    | [] -> Some json
    | x::xs -> match (get_offset x json) with
      | Some y -> let a = (xs:path) in get a y
      | None -> None
  )

  (* same as get_offset, but now we want to set some value *)
  (* e.g. set_offset (Field "a") Null (Object MyMap.empty) = Some (Object (MyMap.from_list ["a", Null]))
          set_offset (Index 1) (Bool true) (Array [Null; Null; Null] = Some (Array [Null; Bool true; Null]
          if the index is out of range we just return None:
          set_offset (Index 1) (Bool true) (Array [Null]) = None

   *)

  let set_offset offset v json = match offset with
  | Index i -> (match json with
    | Array a -> (match setAtIndex a i v with
      | Some x -> Some(Array x)
      | None -> None)
    | _ -> None)
    | Field i -> (match json with
      | Object a -> Some(Object(MyMap.replace i v a))
      | _ -> None)

  (* same as set_offset, but for setting a json value at some path *)
  (* e.g. set [Field "a"; Index 1] (Bool true) (Object (MyMap.from_list ["a", Array [Null; Null]])) = Some (Object (MyMap.from_list ["a", Array [Null; Bool true]]))
   *      set [Field "a"; Index 2] (Bool true) (Object (MyMap.from_list ["a", Array [Null; Null]])) = None
   *      set [Field "a"] (Bool true) (Object (MyMap.empty)) = Some (Object MyMap.(add "a" (Bool true) empty))
   *)
  let rec set path value json = (let (a:path) = path in match a with
    | [] -> Some value
    | x::[] -> set_offset x value json
    | x::xs -> match get_offset x json with
      | None -> None
      | Some a -> let y = (xs:path) in match set y value a with
        | None -> None
        | Some s -> set_offset x s json
  )
end
