open! Core
open! Bonsai_web
open Bonsai.Let_syntax
open Vdom_keyboard
open Twenty_forty_eight
module Js = Js_of_ocaml.Js
module Command = Keyboard_event_handler.Command

module Style =
[%css.raw
{|
  .grid {
    width: 500px;
    height: 500px;
  }

  .row {
    display: flex;
    flex-direction: row;
  }

  .cell {
    width: 50px;
    height: 50px;
    margin: auto;
  }
|}]

module Action = struct
  type t = Game.key [@@deriving equal, sexp]
end

module Model = struct
  type t = Game.game_state [@@deriving sexp, equal]
end

let handle_event inject =
  let keyboard_handler =
    Keyboard_event_handler.of_command_list_exn
      [
        {
          Command.keys =
            [ Keystroke.create' Js_of_ocaml.Dom_html.Keyboard_code.ArrowDown ];
          description = "arrow-down";
          group = None;
          handler = (fun _ -> inject Game.Down);
        };
        {
          Command.keys =
            [ Keystroke.create' Js_of_ocaml.Dom_html.Keyboard_code.ArrowUp ];
          description = "arrow-up";
          group = None;
          handler = (fun _ -> inject Game.Up);
        };
        {
          Command.keys =
            [ Keystroke.create' Js_of_ocaml.Dom_html.Keyboard_code.ArrowLeft ];
          description = "arrow-left";
          group = None;
          handler = (fun _ -> inject Game.Left);
        };
        {
          Command.keys =
            [ Keystroke.create' Js_of_ocaml.Dom_html.Keyboard_code.ArrowRight ];
          description = "arrow-right";
          group = None;
          handler = (fun _ -> inject Game.Right);
        };
      ]
  in
  fun event ->
    match Keyboard_event_handler.handle_event keyboard_handler event with
    | Some event -> event
    | None -> Vdom.Effect.Ignore

let render (model : int array array) =
  Array.map model ~f:(fun row ->
      let dom_row =
        Array.map row ~f:(fun x ->
            Vdom.Node.div
              ~attr:(Vdom.Attr.class_ Style.cell)
              [ Vdom.Node.text (Int.to_string x) ])
      in
      Vdom.Node.div ~attr:(Vdom.Attr.class_ Style.row) (Array.to_list dom_row))
  |> Array.to_list

let component =
  let%sub model_and_inject =
    Bonsai.state_machine0 [%here]
      (module Model)
      (module Action)
      ~default_model:(Game.initial_state ())
      ~apply_action:(fun ~inject:_ ~schedule_event:_ model action ->
        Game.handler action model)
  in
  let%arr model, inject = model_and_inject in
  Vdom.Node.div
    ~attr:
      (Vdom.Attr.many
         [
           Vdom.Attr.class_ Style.grid;
           Vdom.Attr.on_keydown (handle_event inject);
         ])
    (List.append (render model.board)
       [
         Vdom.Node.text
           (match model.status with
           | Game.Playing -> "Playing!"
           | Game.GameOver score -> "Game Over! Score: " ^ Int.to_string score);
       ])

let (_ : _ Start.Handle.t) =
  Start.start Start.Result_spec.just_the_view ~bind_to_element_with_id:"app"
    component
