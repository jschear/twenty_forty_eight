open Sexplib.Std
open Ppx_compare_lib.Builtin

(* TODO: make a lot of this less mutation-y? *)
(* TODO: organize some of this into a module? *)

type key = Up | Down | Left | Right [@@deriving equal, sexp]
type board = int array array [@@deriving sexp, equal]
type status = Playing | GameOver of int [@@deriving sexp, equal]
type game_state = { board : board; status : status } [@@deriving sexp, equal]

let size = 4
let new_board () = Array.make_matrix size size 0

let find_open_positions board =
  let indices = List.init size (fun i -> List.init size (fun j -> (i, j))) in
  List.filter (fun (i, j) -> board.(i).(j) = 0) (List.concat indices)

let get_random_tile () =
  let r = Random.int 10 in
  if r = 0 then 4 else 2

let score_board board =
  let row_max = Array.fold_left max in
  Array.fold_left row_max 0 board

let place_random_tile board =
  let open_positions = find_open_positions board in
  let idx = Random.int (List.length open_positions) in
  let i, j = List.nth open_positions idx in
  let tile = get_random_tile () in
  board.(i).(j) <- tile

let initial_state () =
  let board = new_board () in
  place_random_tile board;
  place_random_tile board;
  { board; status = Playing }

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
         not (equal_board new_board board))
       [ Up; Down; Left; Right ])

let handler key { board; status } =
  let new_board = move key board in
  if equal_board new_board board then { board; status }
  else
    let () = place_random_tile new_board in
    if check_game_over new_board then
      { board = new_board; status = GameOver (score_board new_board) }
    else { board = new_board; status }
