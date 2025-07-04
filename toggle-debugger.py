#!/usr/bin/env python3

import os
import subprocess
import random
import string
import webbrowser


def check_toggling_state():
    return os.path.exists("src/Debuggy/App.elm")


def toggle_debugger_backend(toggling_on=False):
    file_path = "src/Backend.elm"
    with open(file_path, "r") as file:
        content = file.read()

    if toggling_on:
        # Add Debuggy.App import if it doesn't exist
        if "import Debuggy.App" not in content:
            content = content.replace("import Api", "import Api\nimport Debuggy.App")

        # Generate new token
        new_token = "".join(random.choices(string.ascii_letters + string.digits, k=16))
        
        # Replace the entire app definition with debugger version
        import re
        pattern = r'app =\s*Effect\.Lamdera\.backend\s*Lamdera\.broadcast\s*Lamdera\.sendToFrontend\s*app_'
        replacement = f'app =\n    Debuggy.App.backend NoOpBackendMsg\n        "{new_token}"\n        Lamdera.broadcast\n        Lamdera.sendToFrontend\n        app_'
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)

        print(f"New token generated: {new_token}")
        webbrowser.open(f"https://backend-debugger.lamdera.app/{new_token}")
    else:
        # Remove Debuggy.App import
        content = content.replace("import Debuggy.App\n", "")

        # Replace the entire app definition with standard version
        import re
        pattern = r'app =\s*Debuggy\.App\.backend[^}]*?app_'
        replacement = 'app =\n    Effect.Lamdera.backend\n        Lamdera.broadcast\n        Lamdera.sendToFrontend\n        app_'
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)

    with open(file_path, "w") as file:
        file.write(content)

    subprocess.run(["elm-format", file_path, "--yes"])


def toggle_debugger_app(toggling_on):
    file_path = "src/Debuggy/App.elm"
    if toggling_on:
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "w") as file:
            file.write("""module Debuggy.App exposing (backend)

import Duration
import Effect.Command as Command exposing (BackendOnly, Command)
import Effect.Http
import Effect.Lamdera
import Effect.Subscription exposing (Subscription)
import Effect.Task
import Effect.Time
import Json.Encode
import Lamdera exposing (ClientId, SessionId)


backend :
    backendMsg
    -> String
    -> (toFrontend -> Cmd backendMsg)
    -> (ClientId -> toFrontend -> Cmd backendMsg)
    ->
        { init : ( backendModel, Command BackendOnly toFrontend backendMsg )
        , update :
            backendMsg
            -> backendModel
            -> ( backendModel, Command BackendOnly toFrontend backendMsg )
        , updateFromFrontend :
            Effect.Lamdera.SessionId
            -> Effect.Lamdera.ClientId
            -> toBackend
            -> backendModel
            -> ( backendModel, Command BackendOnly toFrontend backendMsg )
        , subscriptions : backendModel -> Subscription BackendOnly backendMsg
        }
    ->
        { init : ( backendModel, Cmd backendMsg )
        , update : backendMsg -> backendModel -> ( backendModel, Cmd backendMsg )
        , updateFromFrontend :
            SessionId
            -> ClientId
            -> toBackend
            -> backendModel
            -> ( backendModel, Cmd backendMsg )
        , subscriptions : backendModel -> Sub backendMsg
        }
backend backendNoOp sessionName broadcast sendToFrontend { init, update, updateFromFrontend, subscriptions } =
    Effect.Lamdera.backend
        broadcast
        sendToFrontend
        { init =
            let
                ( model, cmd ) =
                    init
            in
            ( model
            , Command.batch
                [ cmd
                , sendToViewer
                    backendNoOp
                    (Init { sessionName = sessionName, model = Debug.toString model, cmd = Debug.toString cmd })
                ]
            )
        , update =
            \msg model ->
                let
                    ( newModel, cmd ) =
                        update msg model
                in
                ( newModel
                , Command.batch
                    [ cmd
                    , if backendNoOp == msg then
                        Command.none

                      else
                        sendToViewer
                            backendNoOp
                            (Update
                                { sessionName = sessionName
                                , msg = Debug.toString msg
                                , newModel = Debug.toString newModel
                                , cmd = Debug.toString cmd
                                }
                            )
                    ]
                )
        , updateFromFrontend =
            \sessionId clientId msg model ->
                let
                    ( newModel, cmd ) =
                        updateFromFrontend sessionId clientId msg model
                in
                ( newModel
                , Command.batch
                    [ cmd
                    , sendToViewer
                        backendNoOp
                        (UpdateFromFrontend
                            { sessionName = sessionName
                            , msg = Debug.toString msg
                            , newModel = Debug.toString newModel
                            , sessionId = Effect.Lamdera.sessionIdToString sessionId
                            , clientId = Effect.Lamdera.clientIdToString clientId
                            , cmd = Debug.toString cmd
                            }
                        )
                    ]
                )
        , subscriptions = subscriptions
        }


type DataType
    = Init { sessionName : String, model : String, cmd : String }
    | Update { sessionName : String, msg : String, newModel : String, cmd : String }
    | UpdateFromFrontend { sessionName : String, msg : String, newModel : String, sessionId : String, clientId : String, cmd : String }


sendToViewer : msg -> DataType -> Command BackendOnly toFrontend msg
sendToViewer backendNoOp data =
    Effect.Time.now
        |> Effect.Task.andThen
            (\time ->
                Effect.Http.task
                    { method = "POST"
                    , headers = []
                    , url = "http://localhost:8001/https://backend-debugger.lamdera.app/_r/data"
                    , body = Effect.Http.jsonBody (encodeDataType time data)
                    , resolver = Effect.Http.bytesResolver (\_ -> Ok ())
                    , timeout = Just (Duration.seconds 10)
                    }
            )
        |> Effect.Task.attempt (\_ -> backendNoOp)


encodeTime : Effect.Time.Posix -> Json.Encode.Value
encodeTime time =
    Effect.Time.posixToMillis time |> Json.Encode.int


encodeDataType : Effect.Time.Posix -> DataType -> Json.Encode.Value
encodeDataType time data =
    Json.Encode.list
        identity
        (case data of
            Init { sessionName, model, cmd } ->
                [ Json.Encode.int 0
                , Json.Encode.string sessionName
                , Json.Encode.string model
                , Json.Encode.string cmd
                , encodeTime time
                ]

            Update { sessionName, msg, newModel, cmd } ->
                [ Json.Encode.int 1
                , Json.Encode.string sessionName
                , Json.Encode.string msg
                , Json.Encode.string newModel
                , Json.Encode.string cmd
                , encodeTime time
                ]

            UpdateFromFrontend { sessionName, msg, newModel, sessionId, clientId, cmd } ->
                [ Json.Encode.int 2
                , Json.Encode.string sessionName
                , Json.Encode.string msg
                , Json.Encode.string newModel
                , Json.Encode.string sessionId
                , Json.Encode.string clientId
                , Json.Encode.string cmd
                , encodeTime time
                ]
        )
"""
            )

    else:
        if os.path.exists(file_path):
            os.remove(file_path)
            # Also remove the directory if it's empty
            try:
                os.rmdir(os.path.dirname(file_path))
            except OSError:
                pass  # Directory not empty or doesn't exist


def main():
    toggling_on = not check_toggling_state()
    toggle_debugger_backend(toggling_on=toggling_on)
    toggle_debugger_app(toggling_on)
    print(f"Debugger {'enabled' if toggling_on else 'disabled'}.")


if __name__ == "__main__":
    main()