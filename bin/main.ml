open! Core
open! Bonsai_web
open Bonsai.Let_syntax
open Vdom_keyboard
open Twenty_forty_eight
module Js = Js_of_ocaml.Js
module Command = Keyboard_event_handler.Command

module Style =
  [%css
  stylesheet
    {|
  .grid {
    font-family: 'Montserrat', sans-serif;
    width: 250px;
    height: 250px;
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    background: linear-gradient(to bottom right, #FFC371, #FF5F6D);
    border-radius: 8px;
  }

  .row {
    display: flex;
    flex-direction: row;
  }

  .cell {
    width: 50px;
    height: 50px;
    margin: auto;
    background-color: #FFB347;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 5px;
    drop-shadow: 0 0 5px rgba(0, 0, 0, 0.5);
  }

  .content {
    text-align: center;
  }
|}]

module Action = struct
  type t = Restart | GameAction of Game.key [@@deriving equal, sexp]
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
          handler = (fun _ -> inject (Action.GameAction Game.Down));
        };
        {
          Command.keys =
            [ Keystroke.create' Js_of_ocaml.Dom_html.Keyboard_code.ArrowUp ];
          description = "arrow-up";
          group = None;
          handler = (fun _ -> inject (Action.GameAction Game.Up));
        };
        {
          Command.keys =
            [ Keystroke.create' Js_of_ocaml.Dom_html.Keyboard_code.ArrowLeft ];
          description = "arrow-left";
          group = None;
          handler = (fun _ -> inject (Action.GameAction Game.Left));
        };
        {
          Command.keys =
            [ Keystroke.create' Js_of_ocaml.Dom_html.Keyboard_code.ArrowRight ];
          description = "arrow-right";
          group = None;
          handler = (fun _ -> inject (Action.GameAction Game.Right));
        };
      ]
  in
  fun event ->
    match Keyboard_event_handler.handle_event keyboard_handler event with
    | Some event -> event
    | None -> Vdom.Effect.Ignore

let render_cell cell =
  Vdom.Node.div ~attrs:[ Style.cell ]
    [
      Vdom.Node.div ~attrs:[ Style.content ]
        (match cell with
        | 0 -> []
        | _ -> [ Vdom.Node.text (Int.to_string cell) ]);
    ]

let render_row row =
  Vdom.Node.div ~attrs:[ Style.row ]
    (Array.map row ~f:(fun cell -> render_cell cell) |> Array.to_list)

let render_board board =
  Vdom.Node.div ~attrs:[ Style.grid ]
    (Array.map board ~f:(fun row -> render_row row) |> Array.to_list)

let component =
  let%sub model_and_inject =
    Bonsai.state_machine0
      (module Model)
      (module Action)
      ~default_model:(Game.initial_state ())
      ~apply_action:(fun ~inject:_ ~schedule_event:_ model action ->
        match action with
        | Restart -> Game.initial_state ()
        | GameAction action -> Game.handler action model)
  in
  let%arr model, inject = model_and_inject in
  Vdom.Node.div
    ~attrs:[ Vdom.Attr.on_keydown (handle_event inject) ]
    [
      render_board model.board;
      Vdom.Node.div
        ~attrs:
          [
            Vdom.Attr.style
              (match model.status with
              | Game.Playing -> Css_gen.color (`Name "black")
              | Game.GameOver _ -> Css_gen.color (`Name "red"));
          ]
        [
          Vdom.Node.text
            (match model.status with
            | Game.Playing -> "Playing!"
            | Game.GameOver score -> "Game Over! Score: " ^ Int.to_string score);
        ];
      Vdom.Node.div
        [
          Vdom.Node.button
            ~attrs:[ Vdom.Attr.on_click (fun _ -> inject Restart) ]
            [ Vdom.Node.text "Restart" ];
        ];
    ]

let () = Start.start ~bind_to_element_with_id:"app" component
