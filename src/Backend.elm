module Backend exposing (..)

import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)
import Progress
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
                            , trainingSessions = []
                            , techniqueProgress = []
                            , achievements = Progress.getAchievements
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
                            , trainingSessions = []
                            , techniqueProgress = []
                            , achievements = Progress.getAchievements
                            }

                updatedModel =
                    { model | userSessions = Dict.insert sessionId session model.userSessions }
            in
            ( updatedModel
            , Lamdera.sendToFrontend clientId (SessionData session)
            )

        SaveSession session ->
            let
                updatedSession =
                    case Dict.get sessionId model.userSessions of
                        Just userSession ->
                            let
                                newSessions = session :: userSession.trainingSessions
                                possibleAchievements = checkForAchievements newSessions userSession.techniqueProgress userSession.achievements
                            in
                            { userSession 
                                | trainingSessions = newSessions
                                , achievements = possibleAchievements.achievements
                            }

                        Nothing ->
                            { clientId = sessionId
                            , selectedHero = Just session.heroId
                            , visitCount = 1
                            , trainingSessions = [session]
                            , techniqueProgress = Progress.getTechniquesForHero session.heroId
                            , achievements = Progress.getAchievements
                            }

                updatedModel =
                    { model | userSessions = Dict.insert sessionId updatedSession model.userSessions }
            in
            ( updatedModel
            , Cmd.batch
                [ Lamdera.sendToFrontend clientId (SessionSaved session)
                , case Dict.get sessionId model.userSessions of
                    Just userSession ->
                        let
                            result = checkForAchievements updatedSession.trainingSessions updatedSession.techniqueProgress updatedSession.achievements
                        in
                        case result.newlyUnlocked of
                            Just achievement ->
                                Lamdera.sendToFrontend clientId (AchievementUnlocked achievement)
                            Nothing ->
                                Cmd.none
                    Nothing ->
                        Cmd.none
                ]
            )

        DeleteSession deleteId ->
            let
                updatedSession =
                    case Dict.get sessionId model.userSessions of
                        Just session ->
                            { session | trainingSessions = List.filter (\s -> s.id /= deleteId) session.trainingSessions }
                        Nothing ->
                            { clientId = sessionId
                            , selectedHero = Nothing
                            , visitCount = 1
                            , trainingSessions = []
                            , techniqueProgress = []
                            , achievements = Progress.getAchievements
                            }

                updatedModel =
                    { model | userSessions = Dict.insert sessionId updatedSession model.userSessions }
            in
            ( updatedModel
            , Lamdera.sendToFrontend clientId (SessionDeleted deleteId)
            )

        UpdateTechnique techniqueId status ->
            let
                updatedSession =
                    case Dict.get sessionId model.userSessions of
                        Just session ->
                            let
                                updateTech tech =
                                    if tech.techniqueId == techniqueId then
                                        { tech | status = status, lastPracticed = Just "today" }
                                    else
                                        tech
                                
                                newTechniques = List.map updateTech session.techniqueProgress
                                possibleAchievements = checkForAchievements session.trainingSessions newTechniques session.achievements
                            in
                            { session 
                                | techniqueProgress = newTechniques
                                , achievements = possibleAchievements.achievements
                            }
                        Nothing ->
                            { clientId = sessionId
                            , selectedHero = Nothing
                            , visitCount = 1
                            , trainingSessions = []
                            , techniqueProgress = []
                            , achievements = Progress.getAchievements
                            }

                updatedModel =
                    { model | userSessions = Dict.insert sessionId updatedSession model.userSessions }
            in
            ( updatedModel
            , Cmd.batch
                [ Lamdera.sendToFrontend clientId (TechniqueUpdated techniqueId status)
                , case Dict.get sessionId model.userSessions of
                    Just userSession ->
                        let
                            result = checkForAchievements updatedSession.trainingSessions updatedSession.techniqueProgress updatedSession.achievements
                        in
                        case result.newlyUnlocked of
                            Just achievement ->
                                Lamdera.sendToFrontend clientId (AchievementUnlocked achievement)
                            Nothing ->
                                Cmd.none
                    Nothing ->
                        Cmd.none
                ]
            )

        SaveTechniqueNote techniqueId note ->
            let
                updatedSession =
                    case Dict.get sessionId model.userSessions of
                        Just session ->
                            let
                                updateTech tech =
                                    if tech.techniqueId == techniqueId then
                                        { tech | notes = note }
                                    else
                                        tech
                            in
                            { session | techniqueProgress = List.map updateTech session.techniqueProgress }
                        Nothing ->
                            { clientId = sessionId
                            , selectedHero = Nothing
                            , visitCount = 1
                            , trainingSessions = []
                            , techniqueProgress = []
                            , achievements = Progress.getAchievements
                            }

                updatedModel =
                    { model | userSessions = Dict.insert sessionId updatedSession model.userSessions }
            in
            ( updatedModel
            , Cmd.none
            )


checkForAchievements : List TrainingSession -> List TechniqueProgress -> List Achievement -> { achievements : List Achievement, newlyUnlocked : Maybe Achievement }
checkForAchievements sessions techniques achievements =
    let
        totalSessions = List.length sessions
        totalHours = Progress.getTotalTrainingHours sessions
        masteredTechniques = List.filter (\t -> t.status == Mastered) techniques |> List.length
        uniqueHeroes = List.map .heroId sessions |> List.foldl (\h acc -> if List.member h acc then acc else h :: acc) [] |> List.length
        
        checkAchievement achievement =
            case achievement.id of
                "first-session" ->
                    if totalSessions >= 1 && achievement.unlockedAt == Nothing then
                        { achievement | unlockedAt = Just "today" }
                    else
                        achievement
                
                "technique-master" ->
                    if masteredTechniques >= 1 && achievement.unlockedAt == Nothing then
                        { achievement | unlockedAt = Just "today" }
                    else
                        achievement
                
                "all-heroes" ->
                    if uniqueHeroes >= 5 && achievement.unlockedAt == Nothing then
                        { achievement | unlockedAt = Just "today" }
                    else
                        achievement
                
                "100-hours" ->
                    if totalHours >= 100 && achievement.unlockedAt == Nothing then
                        { achievement | unlockedAt = Just "today" }
                    else
                        achievement
                
                _ ->
                    achievement
        
        updatedAchievements = List.map checkAchievement achievements
        newlyUnlocked = filter2 (\old new -> old.unlockedAt == Nothing && new.unlockedAt /= Nothing) achievements updatedAchievements |> List.head
    in
    { achievements = updatedAchievements
    , newlyUnlocked = newlyUnlocked
    }


filter2 : (a -> a -> Bool) -> List a -> List a -> List a
filter2 pred list1 list2 =
    List.map2 Tuple.pair list1 list2
        |> List.filterMap (\(a, b) -> if pred a b then Just b else Nothing)