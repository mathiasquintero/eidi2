let todo _ = failwith "TODO"
let (%) g f x = g (f x)

module MyList = struct
  (* you can have a look at types in the REPL: *)
  (*
   * #show_type list;;
   * type nonrec 'a list = [] | :: of 'a * 'a list
   *)
  let is_empty xs = xs = []
  let rec length = function [] -> 0 | _::xs -> 1 + length xs
  let rec sum = function [] -> 0 | x::xs -> x + sum xs

  (* average of an int list as float *)
  let avg l = match (float_of_int (length l)) with
  | 0.0 -> None
  | x -> Some ((float_of_int (sum l)) /. x)
  (* and for float list: *)
  let rec sumf l = match l with
  | [] -> 0.0
  | x::xs -> x +. sumf xs

  let avgf l = match (float_of_int (length l)) with
  | 0.0 -> None
  | x -> Some ( sumf l /. x)

  let rec append a e = match a with
  | [] -> e
  | x::xs -> x::append xs e

  let (@) = append (* we want some infix operators! *)

  (* exceptions are evil! *)
  (*
   * #show_type option;;
   * type nonrec 'a option = None | Some of 'a
   *)
  let head l = match l with
  | [] -> None
  | x::xs -> Some x

  let tail l = match l with
  | [] -> None
  | x::xs -> Some xs

  let rec last l = match l with
  | [] -> None
  | x::xs -> match xs with
    | [] -> Some x
    | _ -> last xs

  let rec reverse l = match l with
  | [] -> []
  | x::xs -> append (reverse xs) [x]

  let palindrome a = append a (reverse a)

  let isLast x l = x = last l

  let is_palindrome l = l = reverse l

  let rec map f l = match l with
  | [] -> []
  | x::xs -> f x :: map f xs

  let double l = map (fun x -> 2*x) l

  let rec filter f l = match l with
  | [] -> []
  | x::xs -> match f x with
    | true -> x::filter f xs
    | false -> filter f xs

  let even x = (x mod 2) = 0

  let neg f = (fun a -> not (f a))

  let odd = neg even

  let only_even l = filter even l

  let rec fold_left f a l = match l with
  | [] -> a
  | x::xs -> (f (fold_left f a xs) x)

  let rec fold_right f l a = match l with
  | [] -> a
  | x::xs -> f x (fold_right f xs a)

  let rec exists f l = match l with
  | [] -> false
  | x::xs -> match f x with
    | true -> true
    | false -> exists f xs

  let rec for_all f l = match l with
  | [] -> true
  | x::xs -> f x && for_all f xs
end

module NonEmptyList = struct
  type 'a t = Cons of 'a * 'a t | Nil of 'a

  let rec from_list l = match l with
  | [] -> None
  | x::xs -> match from_list xs with
  | None -> Some (Nil x)
  | Some b -> Some(Cons(x, b))

  let rec to_list a = match a with
  | Cons(x,y) -> x::(to_list y)
  | Nil(x) -> [x]

  let head a = match a with
  | Cons(x,_) -> x
  | Nil(x) ->  x
  let tail a = match a with
  | Cons(x,y)  -> Some y
  | _ -> None
  let rec last a = match a with
  | Cons(x,y) -> last y
  | Nil(x) -> x
end

module Db = struct
  (* we assume that name is unique here *)
  type student = { sname : string; age : int; semester: int }
  type course = { cname : string; lecturer : string }
  type grade = { student : string; course : string; grade : float }

  let students = [
    { sname = "Student 1"; age = 19; semester = 1 };
    { sname = "Student 2"; age = 24; semester = 7 };
    { sname = "Student 3"; age = 28; semester = 12 };
    { sname = "Student 4"; age = 23; semester = 4 };
  ]
  let courses = [
    { cname = "Course 1"; lecturer = "Prof. 1" };
    { cname = "Course 2"; lecturer = "Prof. 2" };
    { cname = "Course 3"; lecturer = "Prof. 1" };
  ]
  let grades = [
    { student = "Student 1"; course = "Course 1"; grade = 2.7 };
    { student = "Student 1"; course = "Course 2"; grade = 1.0 };
    { student = "Student 2"; course = "Course 1"; grade = 4.0 };
    { student = "Student 2"; course = "Course 2"; grade = 5.0 };
    { student = "Student 3"; course = "Course 3"; grade = 3.7 };
  ]

  open MyList
  (* find a student by name *)
  let find_student n = match MyList.filter (fun a -> a.sname = n) students with
  | [] -> None
  | x::xs -> Some x
  (* all averages are of type float option *)
  (* calculate the average age of students that are in a given semester or above *)
  let avg_age s = MyList.avg (MyList.map (fun a -> a.age) (MyList.filter (fun a -> a.semester >= s) (students)))
  (* calculate the grade average of a student *)
  let avg_grade_student n = MyList.avgf (MyList.map (fun a -> a.grade) (MyList.filter (fun a -> a.student = n) (grades)))
  (* calculate the grade average of a course *)
  let avg_grade_course c = MyList.avgf (MyList.map (fun a -> a.grade) (MyList.filter (fun a -> a.course = c) (grades)))
  (* calculate the grade average of a course (only passed, i.e. grade <= 4.0) *)
  let avg_grade_course_passed c = MyList.avgf (MyList.map (fun a -> a.grade) (MyList.filter (fun a -> a.course = c && a.grade <= 4.0) (grades)))

  (* calculate the grade average of a course for students in a given semester *)
  let unwrapStudent s = match s with
  | None -> { sname = "Student 1"; age = 19; semester = 1 }
  | Some st -> st

  let avg_grade_course_semester c s = MyList.avgf (MyList.map (fun a -> a.grade) (MyList.filter (fun a -> a.course = c && ((unwrapStudent (find_student a.student)).semester = s)) (grades)))

end
