module Backend exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import Lamdera
import Types exposing (..)
import Data
import Time


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
    ( { sessions = Dict.empty
      , heroes = Data.initHeroes
      , events = Data.initEvents
      , userProfiles = Dict.empty
      , analytics =
            { pageViews = Dict.empty
            , heroViews = Dict.empty
            , searchQueries = []
            , popularTechniques = Dict.empty
            }
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        ClientConnected sessionId clientId ->
            let
                newSession =
                    { id = sessionId
                    , clientId = clientId
                    , userProfile = Nothing
                    , lastActivity = Time.millisToPosix 0
                    , favorites = Data.emptyFavorites
                    }
            in
            ( { model | sessions = Dict.insert sessionId newSession model.sessions }
            , Cmd.none
            )

        ClientDisconnected sessionId ->
            ( { model | sessions = Dict.remove sessionId model.sessions }
            , Cmd.none
            )

        UpdateAnalytics ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        GetInitialData ->
            ( model
            , Lamdera.sendToFrontend clientId
                (InitialDataReceived
                    { heroes = model.heroes
                    , events = model.events
                    , roadmaps = Dict.empty -- TODO: Load from Data.Roadmaps
                    , userProgress = Data.defaultUserProgress
                    }
                )
            )

        SaveFavorites favorites ->
            let
                updatedSessions =
                    case Dict.get sessionId model.sessions of
                        Just session ->
                            Dict.insert sessionId { session | favorites = favorites } model.sessions

                        Nothing ->
                            model.sessions
            in
            ( { model | sessions = updatedSessions }
            , Lamdera.sendToFrontend clientId (FavoritesSaved favorites)
            )

        TrackPageView route ->
            let
                pageKey = routeToAnalyticsKey route
                updatedAnalytics = model.analytics
                newPageViews =
                    Dict.update pageKey
                        (\maybeCount -> Just ((Maybe.withDefault 0 maybeCount) + 1))
                        updatedAnalytics.pageViews
            in
            ( { model | analytics = { updatedAnalytics | pageViews = newPageViews } }
            , Cmd.none
            )

        SearchHeroes query ->
            let
                updatedAnalytics = model.analytics
                newQueries = query :: updatedAnalytics.searchQueries
            in
            ( { model | analytics = { updatedAnalytics | searchQueries = List.take 100 newQueries } }
            , Cmd.none
            )

        GetHeroDetail heroId ->
            case Dict.get heroId model.heroes of
                Just hero ->
                    let
                        updatedAnalytics = model.analytics
                        newHeroViews =
                            Dict.update heroId
                                (\maybeCount -> Just ((Maybe.withDefault 0 maybeCount) + 1))
                                updatedAnalytics.heroViews
                    in
                    ( { model | analytics = { updatedAnalytics | heroViews = newHeroViews } }
                    , Lamdera.sendToFrontend clientId (HeroDetailReceived hero)
                    )

                Nothing ->
                    ( model, Cmd.none )

        GetEventDetail eventId ->
            case Dict.get eventId model.events of
                Just event ->
                    ( model
                    , Lamdera.sendToFrontend clientId (EventDetailReceived event)
                    )

                Nothing ->
                    ( model, Cmd.none )

        SaveUserProfile profile ->
            let
                updatedProfiles = Dict.insert profile.id profile model.userProfiles
                updatedSessions =
                    case Dict.get sessionId model.sessions of
                        Just session ->
                            Dict.insert sessionId { session | userProfile = Just profile } model.sessions

                        Nothing ->
                            model.sessions
            in
            ( { model 
                | userProfiles = updatedProfiles
                , sessions = updatedSessions
              }
            , Lamdera.sendToFrontend clientId (UserProfileSaved profile)
            )

        SaveTrainingData trainingSession ->
            ( model
            , Lamdera.sendToFrontend clientId (TrainingDataSaved trainingSession)
            )

        GetAnalytics ->
            ( model
            , Lamdera.sendToFrontend clientId (AnalyticsReceived model.analytics)
            )
            
        SaveProgress progress ->
            -- TODO: Implement progress saving
            ( model
            , Lamdera.sendToFrontend clientId (ProgressUpdated progress)
            )
            
        SaveTechniqueLog log ->
            -- TODO: Implement technique log saving
            ( model, Cmd.none )
            
        CompleteQuestBackend questId ->
            -- TODO: Implement quest completion
            ( model, Cmd.none )
            
        UnlockAchievement achievementId ->
            -- TODO: Implement achievement unlocking
            ( model, Cmd.none )
            
        GetRoadmaps ->
            -- TODO: Send roadmaps from Data.Roadmaps
            ( model, Cmd.none )
            
        UpdateRoadmapProgress roadmapId progress ->
            -- TODO: Implement roadmap progress update
            ( model
            , Lamdera.sendToFrontend clientId (RoadmapProgressUpdated progress)
            )


routeToAnalyticsKey : Route -> String
routeToAnalyticsKey route =
    case route of
        Home -> "home"
        Dashboard -> "dashboard"
        HeroesRoute _ -> "heroes"
        HeroDetail id -> "hero:" ++ id
        Events _ -> "events"
        EventDetail id -> "event:" ++ id
        Training -> "training"
        TrainingView -> "training-session"
        RoadmapView id -> "roadmap:" ++ id
        StylePath slug -> "style:" ++ slug
        TechniqueLibrary -> "techniques"
        Progress -> "progress"
        Profile -> "profile"
        SignUpPage -> "signup"
        LoginPage -> "login"
        NotFound -> "404"