module Backend exposing (..)

import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { userSessions = Dict.empty }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        TrackHeroSelection maybeHeroId ->
            let
                updatedSession =
                    case Dict.get sessionId model.userSessions of
                        Just session ->
                            { session | selectedHero = maybeHeroId }

                        Nothing ->
                            { clientId = sessionId
                            , selectedHero = maybeHeroId
                            , visitCount = 1
                            }

                updatedModel =
                    { model | userSessions = Dict.insert sessionId updatedSession model.userSessions }
            in
            ( updatedModel
            , Lamdera.sendToFrontend clientId (SessionData updatedSession)
            )

        GetUserSession ->
            let
                session =
                    case Dict.get sessionId model.userSessions of
                        Just existingSession ->
                            { existingSession | visitCount = existingSession.visitCount + 1 }

                        Nothing ->
                            { clientId = sessionId
                            , selectedHero = Nothing
                            , visitCount = 1
                            }

                updatedModel =
                    { model | userSessions = Dict.insert sessionId session model.userSessions }
            in
            ( updatedModel
            , Lamdera.sendToFrontend clientId (SessionData session)
            )