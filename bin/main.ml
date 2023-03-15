(* Set up stdin to read one character at a time *)
let read_key () =
  let termio = Unix.tcgetattr Unix.stdin in
  let () =
    Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
      { termio with Unix.c_icanon = false; Unix.c_vmin = 1; Unix.c_vtime = 0; c_echo = false }
  in
  let res = input_char stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSADRAIN termio;
  res

type key = Up | Down | Left | Right

(* Define a game over exception *)
exception GameOver of int

let listen_for_keys = fun handler ->
  let rec loop () =
    (* Listen for arrow key sequence *)
    match read_key () with
    | '\027' -> (
      match read_key () with
      | '[' -> (
        match read_key () with
        | 'A' -> handler Up; loop ()
        | 'B' -> handler Down; loop ()
        | 'C' -> handler Right; loop ()
        | 'D' -> handler Left; loop ()
        | _ -> loop ()
      )
      | _ -> loop ()
    )
    | 'q' -> ()
    | _ -> loop ()
  in
  try loop () with GameOver score ->
    Printf.printf "Game over! Final score: %d\n" score


(* 2048 board type *)
(* type board_t = int array array *)

(* 2048 board size *)
let size = 4

let new_board () = Array.make_matrix size size 0

(* 2048 board initial state *)
let board = ref (new_board ())

(* 2048 board printing *)
let print_board = fun board ->
  print_endline "----------------";
  let print_row = fun row ->
    Array.iter (fun x -> Printf.printf "%4d" x) row;
    print_newline ()
  in
  Array.iter print_row board

let find_open_positions board =
  let open_positions = ref [] in
  for i = 0 to size - 1 do
    for j = 0 to size - 1 do
      if board.(i).(j) = 0 then open_positions := (i, j) :: !open_positions
    done
  done;
  !open_positions

let get_random_tile () =
  let r = Random.int 10 in
  if r = 0 then 4 else 2

let score_board board =
  let row_max = Array.fold_left max in
  Array.fold_left row_max 0 board

let place_random_tile = fun board ->
  let open_positions = find_open_positions board in
  if List.length open_positions = 0 then raise (GameOver (score_board board));
  let idx = Random.int (List.length open_positions) in
  let (i, j) = List.nth open_positions idx in
  let tile = get_random_tile () in
  board.(i).(j) <- tile

exception NotEqual
let board_equals left right =
  try(for i = 0 to size - 1 do
    for j = 0 to size - 1 do
      if left.(i).(j) <> right.(i).(j) then raise NotEqual
    done
  done; true) with NotEqual -> false

let board_from_list tiles = List.map Array.of_list tiles |> Array.of_list

let test_board = [
  [2; 0; 0; 0];
  [4; 0; 0; 0];
  [6; 0; 0; 0];
  [8; 0; 0; 0];
] |> board_from_list

let rotate_right board =
  let result = new_board () in
  for i = 0 to size - 1 do
    for j = 0 to size - 1 do
      result.(j).(size - i - 1) <- board.(i).(j)
    done
  done;
  result

(* Creates a new board *)
let shift_left board =
  let result = new_board () in
  for i = 0 to size - 1 do
    let j = ref 0 in
    for k = 0 to size - 1 do
      if board.(i).(k) <> 0 then (
        if !j > 0 && result.(i).(!j - 1) = board.(i).(k) then
          result.(i).(!j - 1) <- result.(i).(!j - 1) * 2
        else
          (result.(i).(!j) <- board.(i).(k);
          j := !j + 1)
      );
    done
  done;
  result

let assert_equal expected actual =
  let result = board_equals expected actual in
  let print_failure = fun () ->
    Printf.printf "Expected:\n";
    print_board expected;
    Printf.printf "Actual:\n";
    print_board actual in
  let () = if not result then print_failure () in
  assert result

(* TODO: move these into a test file *)
let () = assert_equal (board_from_list [
  [8; 6; 4; 2];
  [0; 0; 0; 0];
  [0; 0; 0; 0];
  [0; 0; 0; 0];
]) (rotate_right test_board)

let () = assert_equal(board_from_list [
  [2; 0; 0; 0];
  [4; 0; 0; 0];
  [6; 0; 0; 0];
  [8; 0; 0; 0];
]) (board_from_list [
  [2; 0; 0; 0];
  [4; 0; 0; 0];
  [6; 0; 0; 0];
  [8; 0; 0; 0];
] |> shift_left)

let () = assert_equal(board_from_list [
  [2; 0; 0; 0];
  [4; 0; 0; 0];
  [6; 0; 0; 0];
  [8; 0; 0; 0];
]) (board_from_list [
  [0; 2; 0; 0];
  [0; 4; 0; 0];
  [0; 6; 0; 0];
  [0; 8; 0; 0];
] |> shift_left)

let () = assert_equal(board_from_list [
  [4; 0; 0; 0];
  [8; 0; 0; 0];
  [16; 0; 0; 0];
  [32; 0; 0; 0];
]) (board_from_list [
  [2; 2; 0; 0];
  [4; 4; 0; 0];
  [8; 8; 0; 0];
  [16; 16; 0; 0];
] |> shift_left)

let () = assert_equal(board_from_list [
  [4; 2; 0; 0];
  [8; 4; 0; 0];
  [16; 8; 0; 0];
  [32; 16; 0; 0];
]) (board_from_list [
  [2; 2; 2; 0];
  [4; 4; 4; 0];
  [8; 8; 8; 0];
  [16; 16; 16; 0];
] |> shift_left)

let () = assert_equal(board_from_list [
  [4; 0; 0; 0];
  [4; 4; 0; 0];
  [16; 16; 0; 0];
  [0; 0; 0; 0];
]) (board_from_list [
  [2; 0; 0; 2];
  [4; 0; 2; 2];
  [8; 8; 8; 8];
  [0; 0; 0; 0];
] |> shift_left)

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

let move direction board = match direction with
  | Down -> rotate_right board |> shift_left |> rotate_right |> rotate_right |> rotate_right
  | Up -> rotate_right board |> rotate_right |> rotate_right |> shift_left |> rotate_right
  | Left -> shift_left board
  | Right -> rotate_right board |> rotate_right |> shift_left |> rotate_right |> rotate_right

let check_game_over board =
  not (List.exists (fun direction ->
    let new_board = move direction board in
    not (board_equals new_board board)
  ) [ Up; Down; Left; Right ])

let () = place_random_tile !board
let () = place_random_tile !board
let () = print_board !board

let handler key =
  if check_game_over !board then raise (GameOver (score_board !board));
  let new_board = move key !board in

  if board_equals new_board !board then
    ()
  else (
    board := new_board;
    place_random_tile !board;
    print_board !board
  )

let () = listen_for_keys handler
