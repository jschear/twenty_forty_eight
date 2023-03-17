open Twenty_forty_eight

(* TODO: convert these to proper test cases. *)

let board_from_list tiles = List.map Array.of_list tiles |> Array.of_list

let test_board =
  [ [ 2; 0; 0; 0 ]; [ 4; 0; 0; 0 ]; [ 6; 0; 0; 0 ]; [ 8; 0; 0; 0 ] ]
  |> board_from_list

(* 2048 board printing *)
let print_board board =
  print_endline "----------------";
  let print_row row =
    Array.iter (fun x -> Printf.printf "%4d" x) row;
    print_newline ()
  in
  Array.iter print_row board

let assert_equal expected actual =
  let result = Game.equal_board_t expected actual in
  let print_failure () =
    Printf.printf "Expected:\n";
    print_board expected;
    Printf.printf "Actual:\n";
    print_board actual
  in
  let () = if not result then print_failure () in
  assert result

(* TODO: move these into a test file *)
let () =
  assert_equal
    (board_from_list
       [ [ 8; 6; 4; 2 ]; [ 0; 0; 0; 0 ]; [ 0; 0; 0; 0 ]; [ 0; 0; 0; 0 ] ])
    (Game.rotate_right test_board)

let () =
  assert_equal
    (board_from_list
       [ [ 2; 0; 0; 0 ]; [ 4; 0; 0; 0 ]; [ 6; 0; 0; 0 ]; [ 8; 0; 0; 0 ] ])
    (board_from_list
       [ [ 2; 0; 0; 0 ]; [ 4; 0; 0; 0 ]; [ 6; 0; 0; 0 ]; [ 8; 0; 0; 0 ] ]
    |> Game.shift_left)

let () =
  assert_equal
    (board_from_list
       [ [ 2; 0; 0; 0 ]; [ 4; 0; 0; 0 ]; [ 6; 0; 0; 0 ]; [ 8; 0; 0; 0 ] ])
    (board_from_list
       [ [ 0; 2; 0; 0 ]; [ 0; 4; 0; 0 ]; [ 0; 6; 0; 0 ]; [ 0; 8; 0; 0 ] ]
    |> Game.shift_left)

let () =
  assert_equal
    (board_from_list
       [ [ 4; 0; 0; 0 ]; [ 8; 0; 0; 0 ]; [ 16; 0; 0; 0 ]; [ 32; 0; 0; 0 ] ])
    (board_from_list
       [ [ 2; 2; 0; 0 ]; [ 4; 4; 0; 0 ]; [ 8; 8; 0; 0 ]; [ 16; 16; 0; 0 ] ]
    |> Game.shift_left)

let () =
  assert_equal
    (board_from_list
       [ [ 4; 2; 0; 0 ]; [ 8; 4; 0; 0 ]; [ 16; 8; 0; 0 ]; [ 32; 16; 0; 0 ] ])
    (board_from_list
       [ [ 2; 2; 2; 0 ]; [ 4; 4; 4; 0 ]; [ 8; 8; 8; 0 ]; [ 16; 16; 16; 0 ] ]
    |> Game.shift_left)

let () =
  assert_equal
    (board_from_list
       [ [ 4; 0; 0; 0 ]; [ 4; 4; 0; 0 ]; [ 16; 16; 0; 0 ]; [ 0; 0; 0; 0 ] ])
    (board_from_list
       [ [ 2; 0; 0; 2 ]; [ 4; 0; 2; 2 ]; [ 8; 8; 8; 8 ]; [ 0; 0; 0; 0 ] ]
    |> Game.shift_left)

(* TODO: fix this. *)
(* let () = assert_equal(board_from_list [
     [4; 0; 0; 0];
     [4; 4; 0; 0];
     [16; 16; 0; 0];
     [0; 0; 0; 0];
   ]) (board_from_list [
     [2; 0; 0; 2];
     [4; 0; 2; 2];
     [8; 8; 16; 0];
     [0; 0; 0; 0];
   ] |> shift_left) *)
