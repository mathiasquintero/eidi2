module Future : sig
  type 'a t
  val create : ('a -> 'b) -> 'a -> float -> 'b t
  val get : 'a t -> 'a option
end = struct

  (* Our Future consists of a Channel for the response,
  a channel for the timeout and the thread calculating *)

  type 'a t = 'a Event.channel * bool Event.channel * Thread.t

  let create f a t = let channel = Event.new_channel () in let timeChannel = Event.new_channel ()
    in let rec loop f = f (); loop f
    in let task () = let result = f a in loop (fun ( ) -> Event.sync (Event.send channel result))
    in let timeout () = let _ = Thread.delay t in loop (fun ( ) -> Event.sync (Event.send timeChannel true))
    in let th = Thread.create task ()
    in let _ = Thread.create timeout ()
    in channel,timeChannel,th

    (* Select the first channel with a message. If the timeout comes kill the calculation *)

  let get a = let (res,time,th) = a
    in Event.select [
      Event.wrap (Event.receive res) (fun x -> Some(x));
      Event.wrap (Event.receive time) (fun x -> let _ = Thread.kill th in None)
    ]

    (* Should print 2 almost instantly *)

  let test1 = let f x = x+1 in let ff = create f 1 2.0 in match get ff with
  | None -> print_string "None"
  | Some x -> print_int x

  (* Should print None after a 2 seconds *)
  let test2 = let rec f x = f (x+1) in let ff = create f 1 2.0 in match get ff with
  | None -> print_string "None"
  | Some x -> print_int x

end
