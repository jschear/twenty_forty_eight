open Sexplib.Std
open Ppx_compare_lib.Builtin

(* TODO: make a lot of this less mutation-y *)
(* TODO: organize some of this into a module? *)

type key_t = Up | Down | Left | Right [@@deriving equal, sexp]

(* Define a game over exception *)
exception GameOver of int

(* 2048 board type *)
type board_t = int array array [@@deriving sexp, equal]

(* 2048 board size *)
let size = 4
let new_board () = Array.make_matrix size size 0

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

let place_random_tile board =
  let open_positions = find_open_positions board in
  if List.length open_positions = 0 then raise (GameOver (score_board board));
  let idx = Random.int (List.length open_positions) in
  let i, j = List.nth open_positions idx in
  let tile = get_random_tile () in
  board.(i).(j) <- tile

let initial_board () =
  let board = new_board () in
  place_random_tile board;
  place_random_tile board;
  board

exception NotEqual

let rotate_right board =
  let result = new_board () in
  for i = 0 to size - 1 do
    for j = 0 to size - 1 do
      result.(j).(size - i - 1) <- board.(i).(j)
    done
  done;
  result

let shift_left board =
  let result = new_board () in
  for i = 0 to size - 1 do
    let j = ref 0 in
    for k = 0 to size - 1 do
      if board.(i).(k) <> 0 then
        if !j > 0 && result.(i).(!j - 1) = board.(i).(k) then
          result.(i).(!j - 1) <- result.(i).(!j - 1) * 2
        else (
          result.(i).(!j) <- board.(i).(k);
          j := !j + 1)
    done
  done;
  result

let move direction board =
  match direction with
  | Down ->
      rotate_right board |> shift_left |> rotate_right |> rotate_right
      |> rotate_right
  | Up ->
      rotate_right board |> rotate_right |> rotate_right |> shift_left
      |> rotate_right
  | Left -> shift_left board
  | Right ->
      rotate_right board |> rotate_right |> shift_left |> rotate_right
      |> rotate_right

let check_game_over board =
  not
    (List.exists
       (fun direction ->
         let new_board = move direction board in
         not (equal_board_t new_board board))
       [ Up; Down; Left; Right ])

let handler key board =
  if check_game_over board then raise (GameOver (score_board board));
  let new_board = move key board in

  if equal_board_t new_board board then board
  else (
    place_random_tile new_board;
    new_board)
