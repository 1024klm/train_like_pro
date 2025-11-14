module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Components.Layout exposing (onModalEscapeKeyDown)
import Data
import Dict exposing (Dict)
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Subscription as Subscription exposing (Subscription)
import GameMechanics.XP as XP
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2, lazy3)
import I18n
import Json.Decode as Decode
import Lamdera
import List
import LocalStorage
import Pages.Dashboard
import Pages.Heroes
import Pages.TrainingSession
import Process
import Router
import Router.Helpers exposing (onPreventDefaultClick)
import Set exposing (Set)
import String
import Task
import Theme
import Time
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


type alias Msg =
    FrontendMsg


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init url key =
    let
        route =
            Router.fromUrl url

        initialModel =
            { key = key
            , url = url
            , route = route
            , localStorage = LocalStorage.defaultLocalStorage
            , userConfig =
                { t = I18n.translate I18n.EN
                , isDark = False
                , language = I18n.EN
                }
            , clientId = ""
            , currentTime = Time.millisToPosix 0
            , mobileMenuOpen = False
            , searchQuery = ""
            , techniqueLibraryFilter = Nothing
            , activeFilters =
                { heroFilter = Nothing
                , academyLocation = Nothing
                , eventType = Nothing
                , dateRange = Nothing
                }
            , heroes = Data.initHeroes
            , events = Data.initEvents
            , trainingPlans = Dict.empty
            , trainingSessions = []
            , userProfile = Nothing
            , favorites = Data.emptyFavorites
            , userProgress = Data.defaultUserProgress
            , roadmaps = Dict.empty
            , activeRoadmap = Nothing
            , activeSession = Nothing
            , sessionTimer = 0
            , loadingStates = Dict.empty
            , modals =
                { sessionModal = False
                , heroDetailModal = Nothing
                , shareModal = Nothing
                , filterModal = False
                , techniqueSelectionModal = False
                }
            , notifications = []
            , animations =
                { heroCards = False
                , pageTransition = False
                , scrollProgress = 0
                , xpAnimation = Nothing
                , levelUpAnimation = False
                }
            , claimedPlanItems = Set.empty
            , techniquePreview = Nothing
            , trainingGoal = Nothing
            , selectedChampion = Nothing
            , plannedTechniques = []
            , trainingActions = Data.defaultTrainingActions
            }
    in
    ( initialModel
    , Cmd.batch
        [ Lamdera.sendToBackend GetInitialData
        , Lamdera.sendToBackend (TrackPageView route)
        , Task.perform GotCurrentTime Time.now
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOpFrontendMsg ->
            ( model, Cmd.none )

        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                External url ->
                    ( model, Nav.load url )

        UrlChanged url ->
            let
                newRoute =
                    Router.fromUrl url
            in
            ( { model
                | url = url
                , route = newRoute
                , mobileMenuOpen = False
                , animations = { heroCards = True, pageTransition = True, scrollProgress = 0, xpAnimation = Nothing, levelUpAnimation = False }
              }
            , Cmd.batch
                [ Lamdera.sendToBackend (TrackPageView newRoute)
                , scrollToTop
                ]
            )

        ReceivedLocalStorage localStorage ->
            let
                language =
                    LocalStorage.getLanguage localStorage |> Maybe.withDefault I18n.EN

                isDark =
                    LocalStorage.getTheme localStorage |> Maybe.map (\theme -> theme == Theme.Dark) |> Maybe.withDefault False

                userConfig =
                    model.userConfig
            in
            ( { model
                | localStorage = localStorage
                , userConfig =
                    { userConfig
                        | isDark = isDark
                        , language = language
                        , t = I18n.translate language
                    }
              }
            , Cmd.none
            )

        GotCurrentTime now ->
            ( { model | currentTime = now }
            , Cmd.none
            )

        NavigateTo route ->
            ( model, Router.navigateTo model.key route )

        ToggleMobileMenu ->
            let
                newMenuState =
                    not model.mobileMenuOpen

                focusCmd =
                    if newMenuState then
                        Task.attempt (\_ -> NoOpFrontendMsg) (Dom.focus "mobile-first-link")

                    else
                        Task.attempt (\_ -> NoOpFrontendMsg) (Dom.focus "mobile-menu-toggle")
            in
            ( { model | mobileMenuOpen = newMenuState }, focusCmd )

        FocusMobileToggle ->
            ( model, Task.attempt (\_ -> NoOpFrontendMsg) (Dom.focus "mobile-menu-toggle") )

        TrapFocus { firstId, lastId } ->
            -- Simple focus trap: focus first element (in practice would check activeElement and shiftKey)
            ( model, Task.attempt (\_ -> NoOpFrontendMsg) (Dom.focus firstId) )

        UpdateSearchQuery query ->
            ( { model | searchQuery = query }, Cmd.none )

        ApplyFilter filter ->
            let
                filters =
                    model.activeFilters

                ( newHeroFilter, route ) =
                    case filter of
                        AllHeroes ->
                            ( Nothing, HeroesRoute Nothing )

                        _ ->
                            ( Just filter, HeroesRoute (Just filter) )
            in
            ( { model | activeFilters = { filters | heroFilter = newHeroFilter } }
            , Router.navigateTo model.key route
            )

        ClearFilters ->
            ( { model
                | activeFilters =
                    { heroFilter = Nothing
                    , academyLocation = Nothing
                    , eventType = Nothing
                    , dateRange = Nothing
                    }
              }
            , case model.route of
                HeroesRoute _ ->
                    Router.navigateTo model.key (HeroesRoute Nothing)

                _ ->
                    Cmd.none
            )

        ChangeLanguage language ->
            let
                userConfig =
                    model.userConfig

                updatedModel =
                    { model | userConfig = { userConfig | language = language, t = I18n.translate language } }
            in
            ( updatedModel
            , LocalStorage.save (LocalStorage.setLanguage language model.localStorage)
            )

        ChangeTheme theme ->
            let
                userConfig =
                    model.userConfig

                isDark =
                    False

                -- Default to light theme for now
            in
            ( { model | userConfig = { userConfig | isDark = isDark } }
            , Cmd.none
              -- LocalStorage saving not implemented yet
            )

        ToggleFavorite favoriteType id ->
            let
                favorites =
                    model.favorites

                newFavorites =
                    case favoriteType of
                        HeroFavorite ->
                            { favorites | heroes = toggleSet id favorites.heroes }

                        EventFavorite ->
                            { favorites | events = toggleSet id favorites.events }
            in
            ( { model | favorites = newFavorites }
            , Lamdera.sendToBackend (SaveFavorites newFavorites)
            )

        SelectHero heroId ->
            ( model
            , Cmd.batch
                [ Router.navigateTo model.key (HeroDetail heroId)
                , Lamdera.sendToBackend (GetHeroDetail heroId)
                ]
            )

        OpenModal modalType ->
            let
                modals =
                    model.modals

                newModals =
                    case modalType of
                        SessionModal ->
                            { modals | sessionModal = True }

                        HeroModal id ->
                            { modals | heroDetailModal = Just id }

                        ShareModal id ->
                            { modals | shareModal = Just id }

                        FilterModal ->
                            { modals | filterModal = True }

                        TechniqueSelectionModal ->
                            { modals | techniqueSelectionModal = True }
            in
            ( { model | modals = newModals }, Cmd.none )

        CloseModal ->
            ( { model
                | modals =
                    { sessionModal = False
                    , heroDetailModal = Nothing
                    , shareModal = Nothing
                    , filterModal = False
                    , techniqueSelectionModal = False
                    }
              }
            , Cmd.none
            )

        ShowNotification notifType message ->
            let
                notification =
                    { id = "notif-" ++ String.fromInt (List.length model.notifications)
                    , type_ = notifType
                    , message = message
                    , timestamp = ""
                    }
            in
            ( { model | notifications = notification :: model.notifications }
            , Cmd.none
            )

        DismissNotification id ->
            ( { model | notifications = List.filter (\n -> n.id /= id) model.notifications }
            , Cmd.none
            )

        ClaimPlanXP itemId xp ->
            if Set.member itemId model.claimedPlanItems then
                ( model, Cmd.none )

            else
                let
                    xpNotif =
                        { id = "xp-" ++ itemId
                        , type_ = Success
                        , message = "+" ++ String.fromInt xp ++ " XP"
                        , timestamp = ""
                        }
                in
                ( { model
                    | claimedPlanItems = Set.insert itemId model.claimedPlanItems
                    , notifications = xpNotif :: model.notifications
                  }
                , Task.perform (\_ -> DismissNotification xpNotif.id) (Process.sleep 2500)
                )

        AnimationTick _ ->
            let
                animations =
                    model.animations
            in
            ( { model | animations = { animations | scrollProgress = animations.scrollProgress + 0.01 } }
            , Cmd.none
            )

        SetTechniqueLibraryFilter selection ->
            ( { model | techniqueLibraryFilter = selection }
            , Cmd.none
            )

        StartSession ->
            case ( model.selectedChampion, model.plannedTechniques ) of
                ( Nothing, _ ) ->
                    ( model
                    , send (ShowNotification Warning "Choisis un champion avant de démarrer ta session.")
                    )

                ( Just _, [] ) ->
                    ( model
                    , send (ShowNotification Warning "Sélectionne jusqu'à 3 techniques à travailler aujourd'hui.")
                    )

                ( Just _, planned ) ->
                    let
                        primaryGoal =
                            List.head planned

                        newSession =
                            { startTime = Time.millisToPosix 0 -- backend will update with real time
                            , currentTechnique = primaryGoal
                            , techniques = []
                            , totalXP = 0
                            , notes = ""
                            }
                    in
                    ( { model
                        | activeSession = Just newSession
                        , sessionTimer = 0
                        , trainingGoal = primaryGoal
                      }
                    , Cmd.batch
                        [ Router.navigateTo model.key TrainingView
                        , Task.perform UpdateSessionTimer Time.now
                        ]
                    )

        EndSession ->
            case model.activeSession of
                Just session ->
                    let
                        finalSession =
                            { id = "session-" ++ String.fromInt model.sessionTimer -- Temporary ID
                            , date = session.startTime
                            , planId = Nothing
                            , duration = model.sessionTimer // 60 -- Convert seconds to minutes
                            , techniques = session.techniques
                            , notes = session.notes
                            , sessionType = TechniqueSession -- Default session type
                            , rating = Nothing
                            , completed = True
                            , xpEarned = session.totalXP
                            , mood = Good -- Default mood
                            , energy = Normal -- Default energy
                            }
                    in
                    ( { model
                        | activeSession = Nothing
                        , sessionTimer = 0
                        , trainingSessions = finalSession :: model.trainingSessions
                      }
                    , Cmd.batch
                        [ Lamdera.sendToBackend (SaveTrainingData finalSession)
                        , Router.navigateTo model.key TrainingView
                        ]
                    )

                Nothing ->
                    ( model, Cmd.none )

        UpdateSessionTimer currentTime ->
            case model.activeSession of
                Just session ->
                    let
                        placeholder =
                            Time.millisToPosix 0

                        actualStartTime =
                            if session.startTime == placeholder then
                                currentTime

                            else
                                session.startTime

                        elapsedMillis =
                            Time.posixToMillis currentTime - Time.posixToMillis actualStartTime

                        elapsedSeconds =
                            if elapsedMillis > 0 then
                                elapsedMillis // 1000

                            else
                                0

                        updatedSession =
                            if session.startTime == actualStartTime then
                                session

                            else
                                { session | startTime = actualStartTime }
                    in
                    ( { model
                        | activeSession = Just updatedSession
                        , sessionTimer = elapsedSeconds
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        SelectTrainingChampion heroId ->
            let
                normalizedSelection =
                    let
                        trimmed =
                            String.trim heroId
                    in
                    if String.isEmpty trimmed then
                        Nothing

                    else
                        Just trimmed

                updatedActions =
                    List.map
                        (\action ->
                            if action.id == "plan-session" then
                                case normalizedSelection of
                                    Just _ ->
                                        { action | status = ActionInProgress }

                                    Nothing ->
                                        { action | status = ActionBacklog }

                            else
                                action
                        )
                        model.trainingActions
            in
            ( { model
                | selectedChampion = normalizedSelection
                , plannedTechniques = []
                , trainingGoal = Nothing
                , trainingActions = updatedActions
              }
            , Cmd.none
            )

        TogglePlannedTechnique techniqueId ->
            case model.selectedChampion of
                Nothing ->
                    ( model
                    , send (ShowNotification Info "Choisis un champion avant de sélectionner des techniques.")
                    )

                Just _ ->
                    if List.member techniqueId model.plannedTechniques then
                        let
                            updated =
                                List.filter (\tech -> tech /= techniqueId) model.plannedTechniques
                        in
                        ( { model
                            | plannedTechniques = updated
                            , trainingGoal = List.head updated
                          }
                        , Cmd.none
                        )

                    else if List.length model.plannedTechniques >= 3 then
                        ( model
                        , send (ShowNotification Warning "Maximum 3 techniques par session.")
                        )

                    else
                        let
                            updated =
                                model.plannedTechniques ++ [ techniqueId ]
                        in
                        ( { model
                            | plannedTechniques = updated
                            , trainingGoal = List.head updated
                          }
                        , Cmd.none
                        )

        CycleTrainingActionStatus actionId ->
            let
                advance status =
                    case status of
                        ActionBacklog ->
                            ActionInProgress

                        ActionInProgress ->
                            ActionCompleted

                        ActionCompleted ->
                            ActionBacklog

                ( updatedActions, xpReward ) =
                    List.foldr
                        (\action ( acc, reward ) ->
                            if action.id == actionId then
                                let
                                    nextStatus =
                                        advance action.status

                                    rewardCandidate =
                                        if action.status /= ActionCompleted && nextStatus == ActionCompleted then
                                            Just action.xp

                                        else
                                            Nothing

                                    newReward =
                                        case reward of
                                            Nothing ->
                                                rewardCandidate

                                            Just _ ->
                                                reward
                                in
                                ( { action | status = nextStatus } :: acc, newReward )

                            else
                                ( action :: acc, reward )
                        )
                        ( [], Nothing )
                        model.trainingActions

                notificationCmd =
                    case xpReward of
                        Just xp ->
                            send (ShowNotification Success ("+" ++ String.fromInt xp ++ " XP ajoutés à ton suivi."))

                        Nothing ->
                            Cmd.none
            in
            ( { model | trainingActions = updatedActions }
            , notificationCmd
            )

        SelectNode techniqueId ->
            case model.activeSession of
                Just session ->
                    let
                        currentModals =
                            model.modals

                        updatedModals =
                            { currentModals | techniqueSelectionModal = False }
                    in
                    ( { model
                        | activeSession = Just { session | currentTechnique = Just techniqueId }
                        , modals = updatedModals
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        PreviewTechnique techniqueId ->
            ( { model | techniquePreview = Just techniqueId }, Cmd.none )

        ClearTechniquePreview ->
            ( { model | techniquePreview = Nothing }, Cmd.none )

        SetTrainingGoal techniqueId ->
            ( { model
                | trainingGoal = Just techniqueId
                , techniquePreview = Just techniqueId
              }
            , Cmd.none
            )

        QuickSuccess bonusXP ->
            case model.activeSession of
                Just session ->
                    let
                        updatedSession =
                            { session | totalXP = session.totalXP + bonusXP }

                        notificationId =
                            "quick-success-" ++ String.fromInt (List.length model.notifications + model.sessionTimer + bonusXP)

                        notification =
                            { id = notificationId
                            , type_ = Success
                            , message = "Technique réussie ! +" ++ String.fromInt bonusXP ++ " XP bonus"
                            , timestamp = ""
                            }
                    in
                    ( { model
                        | activeSession = Just updatedSession
                        , notifications = notification :: model.notifications
                      }
                    , Task.perform (\_ -> DismissNotification notificationId) (Process.sleep 2500)
                    )

                Nothing ->
                    ( model, Cmd.none )

        IncrementReps techniqueId ->
            case model.activeSession of
                Just session ->
                    let
                        updatedTechniques =
                            case List.filter (\t -> t.techniqueId == techniqueId) session.techniques of
                                [] ->
                                    -- New technique
                                    { techniqueId = techniqueId
                                    , repetitions = 1
                                    , quality = 3
                                    , partner = Nothing
                                    , notes = ""
                                    , xpEarned = 1 * 3 * 5 -- reps * quality * base_xp
                                    }
                                        :: session.techniques

                                existingTech :: _ ->
                                    -- Update existing
                                    List.map
                                        (\t ->
                                            if t.techniqueId == techniqueId then
                                                let
                                                    newReps =
                                                        t.repetitions + 1

                                                    newXP =
                                                        newReps * t.quality * 5

                                                    -- reps * quality * base_xp
                                                in
                                                { t | repetitions = newReps, xpEarned = newXP }

                                            else
                                                t
                                        )
                                        session.techniques

                        newTotalXP =
                            List.sum (List.map .xpEarned updatedTechniques)
                    in
                    ( { model | activeSession = Just { session | techniques = updatedTechniques, totalXP = newTotalXP } }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        DecrementReps techniqueId ->
            case model.activeSession of
                Just session ->
                    let
                        updatedTechniques =
                            List.map
                                (\t ->
                                    if t.techniqueId == techniqueId && t.repetitions > 0 then
                                        let
                                            newReps =
                                                t.repetitions - 1

                                            newXP =
                                                newReps * t.quality * 5

                                            -- reps * quality * base_xp
                                        in
                                        { t | repetitions = newReps, xpEarned = newXP }

                                    else
                                        t
                                )
                                session.techniques

                        newTotalXP =
                            List.sum (List.map .xpEarned updatedTechniques)
                    in
                    ( { model | activeSession = Just { session | techniques = updatedTechniques, totalXP = newTotalXP } }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        SetQuality techniqueId quality ->
            case model.activeSession of
                Just session ->
                    let
                        updatedTechniques =
                            List.map
                                (\t ->
                                    if t.techniqueId == techniqueId then
                                        let
                                            newXP =
                                                t.repetitions * quality * 5

                                            -- reps * quality * base_xp
                                        in
                                        { t | quality = quality, xpEarned = newXP }

                                    else
                                        t
                                )
                                session.techniques

                        newTotalXP =
                            List.sum (List.map .xpEarned updatedTechniques)
                    in
                    ( { model | activeSession = Just { session | techniques = updatedTechniques, totalXP = newTotalXP } }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


toggleSet : comparable -> Set comparable -> Set comparable
toggleSet item set =
    if Set.member item set then
        Set.remove item set

    else
        Set.insert item set


scrollToTop : Cmd Msg
scrollToTop =
    Task.perform (\_ -> NoOpFrontendMsg) (Dom.setViewport 0 0)



-- Helper to dispatch a message as a Cmd


send : Msg -> Cmd Msg
send message =
    Task.perform (\_ -> message) (Task.succeed ())


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        InitialDataReceived data ->
            let
                seededHeroes =
                    if Dict.isEmpty data.heroes then
                        Data.initHeroes

                    else
                        data.heroes

                seededEvents =
                    if Dict.isEmpty data.events then
                        Data.initEvents

                    else
                        data.events
            in
            ( { model
                | heroes = seededHeroes
                , events = seededEvents
                , roadmaps = data.roadmaps
                , userProgress = data.userProgress
              }
            , Cmd.none
            )

        HeroDetailReceived hero ->
            ( { model | heroes = Dict.insert hero.id hero model.heroes }
            , Cmd.none
            )

        FavoritesSaved favorites ->
            ( { model | favorites = favorites }
            , Cmd.none
            )

        NotificationReceived notification ->
            ( { model | notifications = notification :: model.notifications }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.none -- LocalStorage subscription not implemented yet
        , Time.every (toFloat (60 * 60 * 1000)) GotCurrentTime
        , if model.animations.pageTransition then
            Time.every 16 AnimationTick

          else
            Sub.none
        , case model.activeSession of
            Just _ ->
                Time.every 1000 UpdateSessionTimer

            Nothing ->
                Sub.none
        ]


view : Model -> Browser.Document Msg
view model =
    { title = viewTitle model
    , body =
        [ div [ class "min-h-screen text-slate-800 dark:text-slate-100" ]
            [ Components.Layout.view model (viewPage model)
            , viewNotifications model.notifications
            , viewModals model
            ]
        ]
    }


viewTitle : Model -> String
viewTitle model =
    case model.route of
        Home ->
            "BJJ Heroes - Train Like Champions"

        Dashboard ->
            "Dashboard - Train Like Pro"

        TrainingView ->
            "Training Session - Train Like Pro"

        RoadmapView _ ->
            "Roadmap - Train Like Pro"

        HeroesRoute _ ->
            "Champions - BJJ Heroes"

        HeroDetail id ->
            Dict.get id model.heroes
                |> Maybe.map .name
                |> Maybe.withDefault "Hero"
                |> (\name -> name ++ " - BJJ Heroes")

        Events _ ->
            "Events - BJJ Heroes"

        EventDetail id ->
            Dict.get id model.events
                |> Maybe.map .name
                |> Maybe.withDefault "Event"
                |> (\name -> name ++ " - BJJ Heroes")

        Training ->
            "Training - BJJ Heroes"

        StylePath slug ->
            "Fighter Path: " ++ slug ++ " - Train Like Pro"

        TechniqueLibrary ->
            "Technique Library - Train Like Pro"

        Progress ->
            "Progress Tracking - Train Like Pro"

        Profile ->
            "Profile - BJJ Heroes"

        SignUpPage ->
            "Sign Up - Train Like Pro"

        LoginPage ->
            "Login - Train Like Pro"

        NotFound ->
            "404 - BJJ Heroes"



-- Header removed - now using Layout sidebar navigation


viewHeader : Model -> Html Msg
viewHeader model =
    text ""


viewLogo : Html Msg
viewLogo =
    button
        [ onPreventDefaultClick (NavigateTo Home)
        , class "flex items-center space-x-3 hover:opacity-80 transition-opacity"
        ]
        [ div [ class "w-10 h-10 bg-gradient-to-br from-red-500 to-red-700 rounded-lg flex items-center justify-center shadow-lg" ]
            [ span [ class "text-white font-bold text-lg" ] [ text "BJJ" ] ]
        , div []
            [ h1 [ class "text-xl font-bold text-gray-900 dark:text-white" ] [ text "BJJ Heroes" ]
            , p [ class "text-xs text-gray-500 dark:text-gray-400" ] [ text "Entraîne-toi comme les champions" ]
            ]
        ]


viewDesktopNav : Model -> Html Msg
viewDesktopNav model =
    let
        t =
            model.userConfig.t
    in
    nav [ class "hidden lg:flex items-center space-x-4" ]
        [ navLink model Home t.home "🏠"
        , navLink model Dashboard t.dashboard "📊"
        , navLink model (HeroesRoute Nothing) t.heroes "🥋"
        , navLink model (Events AllEvents) t.events "📅"
        , navLink model TrainingView t.training "💪"
        ]


navLink : Model -> Route -> String -> String -> Html Msg
navLink model route label icon =
    let
        isActive =
            case ( model.route, route ) of
                ( Home, Home ) ->
                    True

                ( Dashboard, Dashboard ) ->
                    True

                ( HeroesRoute _, HeroesRoute _ ) ->
                    True

                ( HeroDetail _, HeroesRoute _ ) ->
                    True

                ( Events _, Events _ ) ->
                    True

                ( EventDetail _, Events _ ) ->
                    True

                ( Training, Training ) ->
                    True

                ( TrainingView, TrainingView ) ->
                    True

                ( RoadmapView _, Dashboard ) ->
                    True

                -- Roadmaps grouped with Dashboard
                ( Profile, Profile ) ->
                    True

                _ ->
                    False
    in
    button
        [ onPreventDefaultClick (NavigateTo route)
        , class "flex items-center space-x-2 px-4 py-2 rounded-lg transition-all duration-200"
        , classList
            [ ( "bg-red-600 text-white shadow-md", isActive )
            , ( "text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800", not isActive )
            ]
        ]
        [ text (icon ++ " " ++ label)
        ]


viewHeaderActions : Model -> Html Msg
viewHeaderActions model =
    div [ class "hidden lg:flex items-center space-x-4" ]
        [ viewSearchBar model
        , viewThemeToggle model
        , viewLanguageSelector model
        , viewProfileButton model
        ]


viewSearchBar : Model -> Html Msg
viewSearchBar model =
    let
        t =
            model.userConfig.t
    in
    div [ class "relative" ]
        [ input
            [ type_ "search"
            , placeholder t.searchPlaceholder
            , value model.searchQuery
            , onInput UpdateSearchQuery
            , class "w-64 px-4 py-2 pl-10 bg-gray-100 dark:bg-gray-800 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-red-500 border border-gray-300 dark:border-gray-600"
            ]
            []
        , span [ class "absolute left-3 top-2" ] [ text "🔍" ]
        ]


viewThemeToggle : Model -> Html Msg
viewThemeToggle model =
    button
        [ onClick
            (ChangeTheme
                (if model.userConfig.isDark then
                    Theme.LightMode

                 else
                    Theme.DarkMode
                )
            )
        , class "p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors border border-gray-300 dark:border-gray-600"
        ]
        [ text
            (if model.userConfig.isDark then
                "☀️"

             else
                "🌙"
            )
        ]


viewLanguageSelector : Model -> Html Msg
viewLanguageSelector model =
    select
        [ onInput
            (\lang ->
                ChangeLanguage
                    (if lang == "fr" then
                        I18n.FR

                     else
                        I18n.EN
                    )
            )
        , class "px-3 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-red-500 border border-gray-300 dark:border-gray-600"
        ]
        [ option [ value "en", selected (model.userConfig.language == I18n.EN) ] [ text "EN" ]
        , option [ value "fr", selected (model.userConfig.language == I18n.FR) ] [ text "FR" ]
        ]


viewProfileButton : Model -> Html Msg
viewProfileButton model =
    button
        [ onPreventDefaultClick (NavigateTo Profile)
        , class "p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors border border-gray-300 dark:border-gray-600"
        ]
        [ text "👤" ]


viewMobileMenuButton : Model -> Html Msg
viewMobileMenuButton model =
    button
        [ onClick ToggleMobileMenu
        , class "lg:hidden p-2 rounded-lg bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-600"
        ]
        [ if model.mobileMenuOpen then
            text "✕"

          else
            text "☰"
        ]


viewMobileMenu : Model -> Html Msg
viewMobileMenu model =
    let
        t =
            model.userConfig.t
    in
    div [ class "lg:hidden absolute top-full left-0 right-0 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 shadow-lg" ]
        [ div [ class "p-4 space-y-2" ]
            [ mobileNavLink (NavigateTo Home) t.home "🏠"
            , mobileNavLink (NavigateTo (HeroesRoute Nothing)) t.heroes "🥋"
            , mobileNavLink (NavigateTo (Events AllEvents)) t.events "📅"
            , mobileNavLink (NavigateTo Training) t.training "💪"
            , mobileNavLink (NavigateTo Profile) t.profile "👤"
            ]
        ]


mobileNavLink : Msg -> String -> String -> Html Msg
mobileNavLink msg label icon =
    button
        [ onClick msg
        , class "w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-left hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
        ]
        [ text (icon ++ " " ++ label) ]


viewNotifications : List Notification -> Html Msg
viewNotifications notifications =
    let
        hasErrors =
            List.any (\n -> n.type_ == Error) notifications

        ariaLive =
            if hasErrors then
                "assertive"

            else
                "polite"
    in
    div
        [ class "fixed top-20 right-4 z-notification space-y-2"
        , attribute "role" "status"
        , attribute "aria-live" ariaLive
        , attribute "aria-atomic" "true"
        ]
        (List.map viewNotification notifications)


viewNotification : Notification -> Html Msg
viewNotification notification =
    let
        ( bgColor, icon ) =
            case notification.type_ of
                Success ->
                    ( "bg-green-500", "✅" )

                Error ->
                    ( "bg-red-500", "❌" )

                Info ->
                    ( "bg-blue-500", "ℹ️" )

                Warning ->
                    ( "bg-yellow-500", "⚠️" )

        roleAttrs =
            if notification.type_ == Error then
                [ attribute "role" "alert" ]

            else
                []
    in
    div
        ([ class ("flex items-center space-x-3 p-4 rounded-lg text-white shadow-lg animate-slide-in " ++ bgColor) ] ++ roleAttrs)
        [ span [ class "text-xl" ] [ text icon ]
        , span [ class "flex-1" ] [ text notification.message ]
        , button
            [ onClick (DismissNotification notification.id)
            , class "hover:opacity-75"
            ]
            [ text "✖️" ]
        ]


viewPage : Model -> Html Msg
viewPage model =
    case model.route of
        Home ->
            viewHomePage model

        Dashboard ->
            Pages.Dashboard.view model

        TrainingView ->
            Pages.TrainingSession.view model

        RoadmapView roadmapId ->
            div [ class "p-8 text-center" ]
                [ text ("Roadmap View: " ++ roadmapId ++ " - Coming Soon!") ]

        HeroesRoute filter ->
            Pages.Heroes.viewList model filter

        HeroDetail id ->
            Pages.Heroes.viewDetail model id

        Events filter ->
            viewEventsPage model filter

        EventDetail id ->
            viewEventDetailPage model id

        Training ->
            viewTrainingPage model

        StylePath slug ->
            viewStylePathPage model slug

        TechniqueLibrary ->
            viewTechniqueLibraryPage model

        Progress ->
            viewProgressPage model

        Profile ->
            viewProfilePage model

        SignUpPage ->
            viewSignUpPage model

        LoginPage ->
            viewLoginPage model

        NotFound ->
            viewNotFoundPage model


viewHomePage : Model -> Html Msg
viewHomePage model =
    div [ class "space-y-12" ]
        [ viewTrainingDashboard model
        , viewFighterStylePaths model
        , viewTodaysPlan model
        , viewProgressStats model
        , viewWeeklyGoals model
        ]


viewTrainingDashboard : Model -> Html Msg
viewTrainingDashboard model =
    let
        t =
            model.userConfig.t

        username =
            Maybe.withDefault t.guest (Maybe.map .username model.userProfile)

        heroStats =
            [ ( String.fromInt model.userProgress.totalXP ++ " XP", t.totalXP )
            , ( I18n.formatStreak model.userConfig.language model.userProgress.currentStreak, t.trainingStreak )
            , ( String.fromInt (List.length model.trainingSessions), t.sessions )
            ]

        heroStat ( value, label ) =
            div [ class "hero-stat" ]
                [ div [ class "hero-stat-number" ] [ text value ]
                , div [ class "hero-stat-label mt-2" ] [ text label ]
                ]
    in
    section [ class "min-h-[70vh] flex items-center bg-white dark:bg-gray-900" ]
        [ div [ class "hero-bg" ] []
        , div [ class "container-wide" ]
            [ div [ class "hero-content" ]
                [ div [ class "hero-inner text-center lg:text-left" ]
                    [ div [ class "hero-badge" ]
                        [ span [ class "badge-dot" ] []
                        , span [] [ text t.heroBadge ]
                        ]
                    , h1 [ class "hero-title" ]
                        [ text t.heroTitleLine1
                        , br [] []
                        , text t.heroTitleLine2
                        , span [ class "text-gradient" ] [ text t.heroTitleHighlight ]
                        ]
                    , p [ class "hero-subtitle" ]
                        [ text t.heroSubtitle ]
                    , div [ class "hero-actions mb-8" ]
                        [ button
                            [ onClick StartSession
                            , class "start-session-button start-session-button--large"
                            ]
                            [ span [ class "start-session-button__icon" ] [ text "⚡" ]
                            , span [ class "start-session-button__label" ] [ text t.startSession ]
                            ]
                        , button
                            [ onPreventDefaultClick (NavigateTo TrainingView)
                            , class "btn btn-secondary px-8 py-4"
                            ]
                            [ text t.training ]
                        ]
                    , div [ class "hero-stats mt-8" ] (List.map heroStat heroStats)
                    ]
                ]
            ]
        ]


viewFighterStylePaths : Model -> Html Msg
viewFighterStylePaths model =
    let
        t =
            model.userConfig.t

        favoriteHeroes =
            model.favorites.heroes
                |> Set.toList
                |> List.filterMap (\heroId -> Dict.get heroId model.heroes)
                |> List.sortBy .name

        subtitleText =
            if List.isEmpty favoriteHeroes then
                t.chooseChampionPrompt

            else
                t.learnFromLegends
    in
    section [ class "section-stack" ]
        [ div [ class "section-header" ]
            [ div [ class "section-header__copy" ]
                [ span [ class "chip chip--outline" ] [ text t.chooseYourPath ]
                , h2 [ class "section-title" ] [ text t.featuredHeroes ]
                , p [ class "section-subtitle" ] [ text subtitleText ]
                ]
            ]
        , if List.isEmpty favoriteHeroes then
            viewFeaturedHeroesPlaceholder model

          else
            div [ class "path-grid" ]
                (List.map (viewSelectedHeroCard model) favoriteHeroes)
        ]


viewFeaturedHeroesPlaceholder : Model -> Html Msg
viewFeaturedHeroesPlaceholder model =
    let
        t =
            model.userConfig.t
    in
    div [ class "card border-2 border-dashed border-slate-200 bg-white/90 text-center dark:border-slate-800 dark:bg-slate-900/60" ]
        [ div [ class "flex flex-col items-center gap-4 p-10" ]
            [ span [ class "text-4xl" ] [ text "🥋" ]
            , h3 [ class "text-2xl font-semibold text-slate-900 dark:text-white" ] [ text t.chooseChampionPrompt ]
            , p [ class "text-sm text-slate-500 dark:text-slate-400 max-w-xl" ] [ text t.learnFromLegends ]
            , button
                [ onPreventDefaultClick (NavigateTo (HeroesRoute Nothing))
                , class "inline-flex items-center gap-2 rounded-full bg-purple-600 px-6 py-3 text-white font-semibold shadow-lg ring-1 ring-purple-400/50 transition hover:-translate-y-0.5 hover:bg-purple-500"
                ]
                [ text t.chooseChampionButton ]
            ]
        ]


viewSelectedHeroCard : Model -> Hero -> Html Msg
viewSelectedHeroCard model hero =
    let
        language =
            model.userConfig.language

        route =
            HeroDetail hero.id

        href_ =
            Router.toPath route

        legend =
            heroHomeLegend language hero

        tagline =
            heroHomeTagline hero

        recordLabel =
            heroHomeRecordLabel language hero.record

        highlightLabel =
            heroHomeHighlight hero
    in
    a
        [ href href_
        , onPreventDefaultClick (NavigateTo route)
        , class "card path-card"
        ]
        [ div [ class "path-card__body flex items-start gap-4" ]
            [ img
                [ src hero.imageUrl
                , alt hero.name
                , class "h-16 w-16 rounded-2xl object-cover ring-2 ring-purple-100 dark:ring-purple-900/60"
                ]
                []
            , div [ class "space-y-2" ]
                ([ span [ class "path-card__legend" ] [ text legend ]
                 , h4 [ class "path-card__title" ] [ text hero.name ]
                 ]
                    ++ (case tagline of
                            Just line ->
                                [ p [ class "text-sm text-slate-500 dark:text-slate-400" ] [ text line ] ]

                            Nothing ->
                                []
                       )
                    ++ (case heroHomeSummary hero of
                            Just summary ->
                                [ p [ class "path-card__description" ] [ text summary ] ]

                            Nothing ->
                                []
                       )
                )
            ]
        , div [ class "path-card__footer" ]
            [ span [ class "path-card__meta" ] [ text recordLabel ]
            , case highlightLabel of
                Just focus ->
                    span [ class "path-card__cta" ] [ text focus ]

                Nothing ->
                    text ""
            ]
        ]


heroHomeLegend : I18n.Language -> Hero -> String
heroHomeLegend language hero =
    [ heroWeightLabel hero.weight
    , featuredFightingStyleLabel language hero.style
    ]
        |> List.filter (\label -> label /= "")
        |> String.join " • "


heroHomeRecordLabel : I18n.Language -> CompetitionRecord -> String
heroHomeRecordLabel language record =
    if record.wins == 0 && record.losses == 0 && record.draws == 0 then
        case language of
            I18n.FR ->
                "Record : non unifié"

            I18n.EN ->
                "Record: not tracked"

    else
        String.fromInt record.wins ++ " - " ++ String.fromInt record.losses


heroHomeTagline : Hero -> Maybe String
heroHomeTagline hero =
    [ maybeNonEmpty hero.nickname, maybeNonEmpty hero.team ]
        |> List.filterMap identity
        |> (\parts ->
                case parts of
                    [] ->
                        Nothing

                    _ ->
                        Just (String.join " · " parts)
           )


heroHomeSummary : Hero -> Maybe String
heroHomeSummary hero =
    hero.bio
        |> maybeNonEmpty
        |> Maybe.map (truncateText 140)


heroHomeHighlight : Hero -> Maybe String
heroHomeHighlight hero =
    case maybeNonEmpty hero.stats.favoriteSubmission of
        Just submission ->
            Just submission

        Nothing ->
            maybeNonEmpty hero.stats.favoritePosition


heroWeightLabel : WeightClass -> String
heroWeightLabel weight =
    case weight of
        Rooster ->
            "Rooster"

        LightFeather ->
            "Light Feather"

        Feather ->
            "Feather"

        Light ->
            "Light"

        Middle ->
            "Middle"

        MediumHeavy ->
            "Medium Heavy"

        Heavy ->
            "Heavy"

        SuperHeavy ->
            "Super Heavy"

        UltraHeavy ->
            "Ultra Heavy"


featuredFightingStyleLabel : I18n.Language -> FightingStyle -> String
featuredFightingStyleLabel language style =
    case ( language, style ) of
        ( I18n.FR, Guard ) ->
            "Jeu de garde"

        ( I18n.FR, Passing ) ->
            "Passing"

        ( I18n.FR, LegLocks ) ->
            "Attaques de jambes"

        ( I18n.FR, Wrestling ) ->
            "Lutte"

        ( I18n.FR, Balanced ) ->
            "Polyvalent"

        ( I18n.FR, Submission ) ->
            "Soumissions"

        ( I18n.FR, Pressure ) ->
            "Jeu en pression"

        ( I18n.EN, Guard ) ->
            "Guard"

        ( I18n.EN, Passing ) ->
            "Passing"

        ( I18n.EN, LegLocks ) ->
            "Leg Locks"

        ( I18n.EN, Wrestling ) ->
            "Wrestling"

        ( I18n.EN, Balanced ) ->
            "Balanced"

        ( I18n.EN, Submission ) ->
            "Submissions"

        ( I18n.EN, Pressure ) ->
            "Pressure"


truncateText : Int -> String -> String
truncateText maxLength textValue =
    let
        trimmed =
            String.trim textValue
    in
    if String.length trimmed <= maxLength then
        trimmed

    else
        String.left maxLength trimmed ++ "…"


maybeNonEmpty : String -> Maybe String
maybeNonEmpty str =
    let
        trimmed =
            String.trim str
    in
    if trimmed == "" then
        Nothing

    else
        Just trimmed


techniqueCheckItem : Model -> String -> String -> Bool -> Int -> Html Msg
techniqueCheckItem model name system completed xp =
    let
        checkboxClass =
            if completed then
                "plan-item__checkbox plan-item__checkbox--done"

            else
                "plan-item__checkbox"

        titleClass =
            if completed then
                "plan-item__title plan-item__title--done"

            else
                "plan-item__title"

        symbol =
            if completed || alreadyClaimed then
                "✓"

            else
                "+"

        itemId =
            name ++ "-" ++ system

        alreadyClaimed =
            Set.member itemId model.claimedPlanItems

        onClaim =
            if alreadyClaimed || completed then
                NoOpFrontendMsg

            else
                ClaimPlanXP itemId xp
    in
    div [ class "plan-item" ]
        [ button
            [ onClick onClaim
            , class checkboxClass
            , disabled (alreadyClaimed || completed)
            ]
            [ text symbol ]
        , div [ class "plan-item__content" ]
            [ p [ class titleClass ] [ text name ]
            , span [ class "plan-item__meta" ] [ text system ]
            ]
        , span [ class "plan-item__xp" ] [ text ("+" ++ String.fromInt xp ++ " XP") ]
        ]


viewTodaysPlan : Model -> Html Msg
viewTodaysPlan model =
    let
        t =
            model.userConfig.t

        dateLabel =
            I18n.formatFullDate model.userConfig.language (Time.millisToPosix 1731366000000)

        sessionProgress =
            t.sessionProgressLabel ++ ": 1/3"
    in
    section [ class "card plan-card" ]
        [ div [ class "plan-card__header" ]
            [ div [ class "plan-card__titles" ]
                [ span [ class "chip chip--outline" ] [ text t.todaysTraining ]
                , h3 [ class "plan-card__title" ] [ text t.planTitle ]
                , p [ class "plan-card__subtitle" ] [ text t.planSubtitle ]
                ]
            , span [ class "plan-card__date" ] [ text dateLabel ]
            ]
        , div [ class "plan-list" ]
            [ techniqueCheckItem model "Heel Hook" "Gordon Ryan" False 50
            , techniqueCheckItem model "Back take from leg entanglement" "Gordon Ryan" False 75
            , techniqueCheckItem model "RNC finish details" "Gordon Ryan" True 100
            ]
        , div [ class "plan-card__footer" ]
            [ span [ class "plan-card__progress" ] [ text sessionProgress ]
            , button
                [ onPreventDefaultClick (NavigateTo TrainingView)
                , class "btn btn-outline"
                ]
                [ text t.planButtonLabel ]
            ]
        ]


viewProgressStats : Model -> Html Msg
viewProgressStats model =
    let
        language =
            model.userConfig.language

        t =
            model.userConfig.t

        streakSuffix =
            if model.userProgress.currentStreak == 1 then
                " " ++ t.day

            else
                " " ++ t.days

        beltLabel =
            model.userConfig.t.beltProgress

        descriptor =
            model.userConfig.t.progressDescriptor
    in
    section [ class "card stats-card" ]
        [ div [ class "section-header section-header--compact" ]
            [ div [ class "section-header__copy" ]
                [ span [ class "chip chip--outline" ] [ text t.progress ]
                , h3 [ class "section-title" ] [ text t.momentumOverview ]
                , p [ class "section-subtitle" ] [ text descriptor ]
                ]
            ]
        , div [ class "stats-grid" ]
            [ progressStatCard t.techniquesLearned "12" "/45" "🧠"
            , progressStatCard t.trainingStreak (String.fromInt model.userProgress.currentStreak) streakSuffix "🔥"
            , progressStatCard (t.thisWeek ++ " XP") "850" "/1000" "⭐"
            , progressStatCard beltLabel "65" "%" "🏆"
            ]
        ]


progressStatCard : String -> String -> String -> String -> Html Msg
progressStatCard label value suffix icon =
    div [ class "stat-card" ]
        [ div [ class "stat-card__icon" ] [ text icon ]
        , div [ class "stat-card__value" ] [ text value ]
        , div [ class "stat-card__suffix" ] [ text suffix ]
        , p [ class "stat-card__label" ] [ text label ]
        ]


viewWeeklyGoals : Model -> Html Msg
viewWeeklyGoals model =
    let
        t =
            model.userConfig.t

        language =
            model.userConfig.language

        bonusXp =
            I18n.formatXP language 500

        bonusText =
            " " ++ t.weeklyBonusReminder
    in
    section [ class "card goals-card" ]
        [ div [ class "goals-card__header" ]
            [ h3 [ class "goals-card__title" ] [ text model.userConfig.t.weeklyGoal ]
            , button
                [ onClick (ShowNotification Info t.goalSettingFeature)
                , class "btn btn-outline"
                ]
                [ text t.adjustGoals ]
            ]
        , p [ class "goals-card__description" ] [ text t.weeklyGoalsDescription ]
        , div [ class "goals-list" ]
            [ weeklyGoalItem t.weeklyGoalSessions 3 5
            , weeklyGoalItem t.weeklyGoalTechniques 1 3
            , weeklyGoalItem t.weeklyGoalMinutes 180 300
            , weeklyGoalItem t.weeklyGoalVideos 6 10
            ]
        , div [ class "goals-card__bonus" ]
            [ span [ class "goals-card__bonus-xp" ] [ text bonusXp ]
            , text bonusText
            ]
        ]


weeklyGoalItem : String -> Int -> Int -> Html Msg
weeklyGoalItem description current target =
    let
        percentage =
            toFloat current / toFloat target * 100

        widthStyle =
            Attr.style "width" (String.fromFloat (Basics.min 100 percentage) ++ "%")

        statusText =
            String.fromInt current ++ "/" ++ String.fromInt target
    in
    div [ class "goal-item" ]
        [ div [ class "goal-item__row" ]
            [ span [ class "goal-item__title" ] [ text description ]
            , span [ class "goal-item__status" ] [ text statusText ]
            ]
        , div [ class "goal-item__progress" ]
            [ div [ class "goal-item__bar", widthStyle ] [] ]
        ]


infoRow : String -> String -> Html Msg
infoRow label value =
    div [ class "flex" ]
        [ span [ class "font-medium text-gray-700 dark:text-gray-300 w-32" ] [ text (label ++ ":") ]
        , span [ class "text-gray-600 dark:text-gray-400" ] [ text value ]
        ]


viewEventCard : Event -> Html Msg
viewEventCard event =
    div [ class "card info-card" ]
        [ span [ class "info-card__icon" ] [ text "🏆" ]
        , h4 [ class "info-card__title" ] [ text event.name ]
        , span [ class "info-card__meta" ] [ text event.date ]
        , span [ class "info-card__meta" ] [ text (event.location.city ++ ", " ++ event.location.country) ]
        ]


viewEventsPage : Model -> EventsFilter -> Html Msg
viewEventsPage model filter =
    let
        eventsList =
            model.events
                |> Dict.values
                |> filterEvents model.currentTime filter
                |> List.sortBy .date

        headerSubtitle =
            case model.userConfig.language of
                I18n.FR ->
                    "Tournois, superfights, séminaires et camps d'entraînement"

                I18n.EN ->
                    "Tournaments, superfights, seminars and training camps"
    in
    div [ class "page-stack" ]
        [ -- Centered page intro
          div [ class "card page-intro" ]
            [ span [ class "chip chip--outline" ] [ text (String.fromInt (List.length eventsList) ++ " events") ]
            , h1 [ class "page-intro__title" ] [ text model.userConfig.t.events ]
            , p [ class "page-intro__subtitle" ] [ text headerSubtitle ]
            ]
        , viewEventFilters filter
        , Keyed.node "div"
            [ class "grid grid-cols-1 md:grid-cols-3 gap-6" ]
            (eventsList |> List.map (\e -> ( e.id, viewEventListCard model e )))
        ]


viewEventFilters : EventsFilter -> Html Msg
viewEventFilters currentFilter =
    let
        btn label active target =
            eventFilterButton label active (NavigateTo target)
    in
    div [ class "filter-row" ]
        [ btn "All" (currentFilter == AllEvents) (Events AllEvents)
        , btn "Upcoming" (currentFilter == UpcomingEvents) (Events UpcomingEvents)
        , btn "Past" (currentFilter == PastEvents) (Events PastEvents)
        ]


eventFilterButton : String -> Bool -> Msg -> Html Msg
eventFilterButton label isActive msg =
    button
        [ onClick msg
        , classList
            [ ( "filter-pill filter-pill--active", isActive )
            , ( "filter-pill", not isActive )
            ]
        ]
        [ text label ]


viewEventListCard : Model -> Event -> Html Msg
viewEventListCard model event =
    let
        isFavorite =
            Set.member event.id model.favorites.events

        typeIcon =
            eventTypeIcon event.type_

        status =
            eventStatusFor model.currentTime event

        statusClass =
            eventStatusClass status

        t =
            model.userConfig.t

        ctaLabel =
            case ( event.registrationUrl, event.streamUrl ) of
                ( Just _, _ ) ->
                    t.register

                ( Nothing, Just _ ) ->
                    t.watchStream

                _ ->
                    t.viewDetails
    in
    div
        [ onPreventDefaultClick (NavigateTo (EventDetail event.id))
        , class "card list-card list-card--interactive p-6"
        ]
        [ div [ class "flex flex-col items-center text-center gap-2" ]
            [ span [ class statusClass ] [ text (eventStatusText t status) ]
            , h3 [ class "list-card__title" ] [ text event.name ]
            , span [ class "list-card__meta" ] [ text (typeIcon ++ " " ++ eventTypeToString event.type_) ]
            , span [ class "list-card__meta" ] [ text event.date ]
            , span [ class "list-card__location" ] [ text (event.location.city ++ ", " ++ event.location.country) ]
            ]
        , div [ class "list-card__footer flex items-center justify-center gap-4" ]
            [ button
                [ Html.Events.stopPropagationOn "click" (Decode.succeed ( ToggleFavorite EventFavorite event.id, True ))
                , classList
                    [ ( "list-card__favorite list-card__favorite--active", isFavorite )
                    , ( "list-card__favorite", not isFavorite )
                    ]
                ]
                [ text
                    (if isFavorite then
                        "★"

                     else
                        "☆"
                    )
                ]
            , span [ class "list-card__link" ] [ text ctaLabel ]
            ]
        ]


pageIntro : String -> String -> Html Msg
pageIntro title subtitle =
    div [ class "surface-card p-6 space-y-2" ]
        [ h1 [ class "text-3xl font-semibold text-slate-900 dark:text-white" ] [ text title ]
        , p [ class "text-gray-500 dark:text-gray-400" ] [ text subtitle ]
        ]


filterEvents : Time.Posix -> EventsFilter -> List Event -> List Event
filterEvents now filter events =
    case filter of
        AllEvents ->
            events

        UpcomingEvents ->
            List.filter
                (\event ->
                    let
                        status =
                            eventStatusFor now event
                    in
                    status == EventUpcoming || status == EventLive
                )
                events

        PastEvents ->
            List.filter (\event -> eventStatusFor now event == EventCompleted) events


eventTypeIcon : EventType -> String
eventTypeIcon eventType =
    case eventType of
        Tournament ->
            "🏆"

        SuperFight ->
            "🥊"

        Seminar ->
            "📚"

        Camp ->
            "🏕️"


eventStatusClass : EventStatus -> String
eventStatusClass status =
    case status of
        EventUpcoming ->
            "px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded text-xs font-medium"

        EventLive ->
            "px-2 py-1 bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded text-xs font-medium animate-pulse"

        EventCompleted ->
            "px-2 py-1 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 rounded text-xs font-medium"

        EventCancelled ->
            "px-2 py-1 bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-500 rounded text-xs font-medium line-through"


eventStatusText : I18n.Translations -> EventStatus -> String
eventStatusText t status =
    case status of
        EventUpcoming ->
            t.eventStatusUpcoming

        EventLive ->
            t.eventStatusLive

        EventCompleted ->
            t.eventStatusCompleted

        EventCancelled ->
            t.eventStatusCancelled


eventStatusFor : Time.Posix -> Event -> EventStatus
eventStatusFor currentTime event =
    if Time.posixToMillis currentTime == 0 then
        event.status

    else
        case dateComparableFromString event.date of
            Just eventValue ->
                let
                    todayValue =
                        currentDateComparable currentTime
                in
                if eventValue > todayValue then
                    EventUpcoming

                else if eventValue == todayValue then
                    EventLive

                else
                    EventCompleted

            Nothing ->
                event.status


currentDateComparable : Time.Posix -> Int
currentDateComparable posix =
    let
        zone =
            Time.utc
    in
    dateComparable (Time.toYear zone posix) (monthToInt (Time.toMonth zone posix)) (Time.toDay zone posix)


dateComparableFromString : String -> Maybe Int
dateComparableFromString isoDate =
    case String.split "-" isoDate of
        yearStr :: monthStr :: dayStr :: _ ->
            case ( String.toInt yearStr, String.toInt monthStr, String.toInt dayStr ) of
                ( Just year, Just month, Just day ) ->
                    Just (dateComparable year month day)

                _ ->
                    Nothing

        _ ->
            Nothing


dateComparable : Int -> Int -> Int -> Int
dateComparable year month day =
    (year * 10000) + (month * 100) + day


monthToInt : Time.Month -> Int
monthToInt month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


viewEventDetailPage : Model -> String -> Html Msg
viewEventDetailPage model eventId =
    let
        t =
            model.userConfig.t
    in
    case Dict.get eventId model.events of
        Just event ->
            div [ class "container mx-auto px-4 py-8" ]
                [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text event.name ]
                , div [ class "grid grid-cols-1 lg:grid-cols-3 gap-8" ]
                    [ div [ class "lg:col-span-2" ]
                        [ viewEventInfo model t event
                        , viewEventBrackets t event
                        ]
                    , div []
                        [ viewEventDetails model t event
                        , viewEventLinks t event
                        ]
                    ]
                ]

        Nothing ->
            div [ class "container mx-auto px-4 py-8" ]
                [ p [ class "text-center text-gray-500" ] [ text t.eventNotFound ] ]


viewEventInfo : Model -> I18n.Translations -> Event -> Html Msg
viewEventInfo model t event =
    let
        status =
            eventStatusFor model.currentTime event
    in
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.eventInformation ]
        , p [ class "text-gray-600 dark:text-gray-300 mb-4" ] [ text event.description ]
        , div [ class "space-y-2" ]
            [ infoRow t.date event.date
            , infoRow t.location (event.location.city ++ ", " ++ event.location.country)
            , infoRow t.venue event.location.address
            , infoRow t.organization event.organization
            , infoRow t.statusLabel (eventStatusText t status)
            ]
        ]


viewEventBrackets : I18n.Translations -> Event -> Html Msg
viewEventBrackets t event =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.brackets ]
        , div [ class "space-y-4" ]
            (List.map viewBracket event.brackets)
        ]


viewBracket : Bracket -> Html Msg
viewBracket bracket =
    div [ class "border-l-4 border-green-500 pl-4" ]
        [ h3 [ class "font-bold dark:text-white" ]
            [ text (bracket.division ++ " - " ++ weightClassToString bracket.weightClass) ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
            [ text ("Ceinture " ++ beltToString bracket.belt) ]
        , div [ class "mt-2 flex flex-wrap gap-2" ]
            (List.map
                (\comp ->
                    span [ class "px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded text-sm" ] [ text comp ]
                )
                bracket.competitors
            )
        ]


weightClassToString : WeightClass -> String
weightClassToString weight =
    case weight of
        Rooster ->
            "Rooster"

        LightFeather ->
            "Light Feather"

        Feather ->
            "Feather"

        Light ->
            "Light"

        Middle ->
            "Middle"

        MediumHeavy ->
            "Medium Heavy"

        Heavy ->
            "Heavy"

        SuperHeavy ->
            "Super Heavy"

        UltraHeavy ->
            "Ultra Heavy"


beltToString : BeltLevel -> String
beltToString belt =
    case belt of
        White ->
            "blanche"

        Blue ->
            "bleue"

        Purple ->
            "Purple"

        Brown ->
            "marron"

        Black ->
            "noire"


viewEventDetails : Model -> I18n.Translations -> Event -> Html Msg
viewEventDetails model t event =
    let
        status =
            eventStatusFor model.currentTime event
    in
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.eventDetails ]
        , div [ class "space-y-3" ]
            [ detailRow t.typeLabel (eventTypeToString event.type_) (eventTypeIcon event.type_)
            , detailRow t.statusLabel (eventStatusText t status) "📊"
            , detailRow t.organization event.organization "🏢"
            ]
        ]


eventTypeToString : EventType -> String
eventTypeToString eventType =
    case eventType of
        Tournament ->
            "Tournoi"

        SuperFight ->
            "Superfight"

        Seminar ->
            "Séminaire"

        Camp ->
            "Camp d'entraînement"


detailRow : String -> String -> String -> Html Msg
detailRow label value icon =
    div [ class "flex items-center space-x-3" ]
        [ span [ class "text-xl" ] [ text icon ]
        , div [ class "flex-1" ]
            [ p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
            , p [ class "font-medium dark:text-white" ] [ text value ]
            ]
        ]


viewEventLinks : I18n.Translations -> Event -> Html Msg
viewEventLinks t event =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.links ]
        , div [ class "space-y-3" ]
            [ case event.registrationUrl of
                Just url ->
                    linkButton t t.register "🎫"

                Nothing ->
                    text ""
            , case event.streamUrl of
                Just url ->
                    linkButton t t.watchStream "📺"

                Nothing ->
                    text ""
            ]
        ]


linkButton : I18n.Translations -> String -> String -> Html Msg
linkButton t label icon =
    button
        [ onClick (ShowNotification Info (label ++ " - " ++ t.externalLink))
        , class "w-full flex items-center justify-center space-x-2 px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors cursor-pointer"
        , type_ "button"
        ]
        [ span [ class "text-xl" ] [ text icon ]
        , span [ class "font-medium" ] [ text label ]
        ]


viewTrainingPage : Model -> Html Msg
viewTrainingPage model =
    let
        t =
            model.userConfig.t
    in
    div [ class "space-y-6" ]
        [ h1 [ class "text-3xl lg:text-4xl font-bold text-white mb-8" ] [ text t.trainingPlans ]
        , div [ class "bg-gradient-to-r from-blue-600/30 to-purple-600/30 backdrop-blur-sm rounded-2xl p-6 lg:p-8 text-white border border-blue-500/30" ]
            [ h2 [ class "text-3xl font-bold mb-4" ] [ text t.startYourJourney ]
            , p [ class "text-lg mb-6 opacity-90" ] [ text t.trainingPlansSubtitle ]
            , button
                [ onClick StartSession
                , class "px-6 py-3 bg-white text-blue-600 font-bold rounded-lg hover:shadow-xl transition-all cursor-pointer"
                , type_ "button"
                ]
                [ text t.createTrainingPlan ]
            ]
        , viewTrainingStats model
        , viewRecentSessions model
        ]


viewTrainingStats : Model -> Html Msg
viewTrainingStats model =
    let
        t =
            model.userConfig.t
    in
    div [ class "grid grid-cols-1 md:grid-cols-4 gap-4 mb-8" ]
        [ statCard t.totalSessionsLabel "0" "📊" "bg-blue-500"
        , statCard t.hoursTrainedLabel "0" "⏱️" "bg-green-500"
        , statCard t.trainingStreak "0" "🔥" "bg-orange-500"
        , statCard t.techniques "0" "🎯" "bg-purple-500"
        ]


statCard : String -> String -> String -> String -> Html Msg
statCard label value icon bgColor =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ div [ class "flex items-center justify-between mb-2" ]
            [ span [ class ("text-3xl p-2 rounded-lg " ++ bgColor ++ " bg-opacity-20") ] [ text icon ]
            , p [ class "text-2xl font-bold dark:text-white" ] [ text value ]
            ]
        , p [ class "text-gray-600 dark:text-gray-400" ] [ text label ]
        ]


viewRecentSessions : Model -> Html Msg
viewRecentSessions model =
    let
        t =
            model.userConfig.t
    in
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.recentSessions ]
        , if List.isEmpty model.trainingSessions then
            div [ class "text-center py-8" ]
                [ span [ class "text-5xl mb-4 block" ] [ text "📝" ]
                , p [ class "text-gray-500 dark:text-gray-400" ] [ text t.noSessionsYet ]
                , button
                    [ onClick (OpenModal SessionModal)
                    , class "mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
                    ]
                    [ text t.logFirstSession ]
                ]

          else
            Keyed.node "div"
                [ class "space-y-4" ]
                (model.trainingSessions
                    |> List.sortBy (\s -> Time.posixToMillis s.date |> negate)
                    |> List.map (\s -> ( s.id, viewSessionCard t s ))
                )
        ]


viewSessionCard : I18n.Translations -> TrainingSession -> Html Msg
viewSessionCard t session =
    div [ class "border-l-4 border-green-500 pl-4" ]
        [ div [ class "flex justify-between items-start" ]
            [ div []
                [ p [ class "font-medium dark:text-white" ] [ text (sessionTypeToString session.sessionType) ]
                , p [ class "text-sm text-gray-500" ] [ text t.date ] -- TODO: Format Time.Posix to string
                ]
            , span [ class "text-sm text-gray-600 dark:text-gray-400" ]
                [ text (String.fromInt session.duration ++ " min") ]
            ]
        ]


sessionTypeToString : SessionType -> String
sessionTypeToString sessionType =
    case sessionType of
        TechniqueSession ->
            "Technique"

        DrillingSession ->
            "Drill"

        SparringSession ->
            "Sparring"

        CompetitionSession ->
            "Compétition"

        OpenMatSession ->
            "Open mat"

        PrivateSession ->
            "Cours privé"


viewProfilePage : Model -> Html Msg
viewProfilePage model =
    div [ class "space-y-6" ]
        [ case model.userProfile of
            Just profile ->
                viewUserProfile profile model

            Nothing ->
                viewGuestProfile model
        ]


viewUserProfile : UserProfile -> Model -> Html Msg
viewUserProfile profile model =
    let
        t =
            model.userConfig.t
    in
    div [ class "grid grid-cols-1 lg:grid-cols-3 gap-8" ]
        [ div [ class "lg:col-span-2" ]
            [ viewProfileInfo t profile
            , viewProfileStats t profile
            , viewProfileAchievements t profile
            ]
        , div []
            [ viewProfileFavorites t model
            , viewProfileGoals t profile
            ]
        ]


viewProfileInfo : I18n.Translations -> UserProfile -> Html Msg
viewProfileInfo t profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.profileInfo ]
        , div [ class "space-y-3" ]
            [ infoRow "Nom d'utilisateur" profile.username
            , infoRow "E-mail" profile.email
            , infoRow "Niveau de ceinture" ("Ceinture " ++ beltToString profile.beltLevel)
            , infoRow "À l'entraînement depuis" profile.startedTraining
            , case profile.academy of
                Just academy ->
                    infoRow "Académie" academy

                Nothing ->
                    text ""
            ]
        ]


viewProfileStats : I18n.Translations -> UserProfile -> Html Msg
viewProfileStats t profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.statistics ]
        , div [ class "grid grid-cols-2 md:grid-cols-3 gap-4" ]
            [ statBox "Sessions" (String.fromInt profile.stats.totalSessions)
            , statBox "Heures" (String.fromFloat profile.stats.totalHours)
            , statBox "Série" (String.fromInt profile.stats.currentStreak ++ " j")
            , statBox "Meilleure série" (String.fromInt profile.stats.longestStreak ++ " j")
            , statBox "Techniques" (String.fromInt profile.stats.techniquesLearned)
            , case profile.stats.favoritePosition of
                Just position ->
                    statBox "Position favorite" position

                Nothing ->
                    text ""
            ]
        ]


statBox : String -> String -> Html Msg
statBox label value =
    div [ class "text-center" ]
        [ p [ class "text-2xl font-bold dark:text-white" ] [ text value ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
        ]


viewProfileAchievements : I18n.Translations -> UserProfile -> Html Msg
viewProfileAchievements t profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.achievements ]
        , if List.isEmpty profile.achievements then
            p [ class "text-gray-500 dark:text-gray-400" ] [ text t.noAchievementsYet ]

          else
            div [ class "grid grid-cols-2 md:grid-cols-3 gap-4" ]
                (List.map viewAchievementBadge profile.achievements)
        ]


viewAchievementBadge : Achievement -> Html Msg
viewAchievementBadge achievement =
    div [ class "text-center p-4 bg-gray-100 dark:bg-gray-700 rounded-lg" ]
        [ span [ class "text-3xl" ] [ text achievement.icon ]
        , p [ class "text-sm font-medium dark:text-white mt-2" ] [ text achievement.name ]
        , p [ class "text-xs text-gray-500 dark:text-gray-400" ]
            [ text (String.fromInt achievement.points ++ " pts") ]
        ]


viewProfileFavorites : I18n.Translations -> Model -> Html Msg
viewProfileFavorites t model =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.favorites ]
        , div [ class "space-y-4" ]
            [ favoriteSection t t.heroes (Set.toList model.favorites.heroes) "🥋"
            , favoriteSection t t.events (Set.toList model.favorites.events) "📅"
            ]
        ]


favoriteSection : I18n.Translations -> String -> List String -> String -> Html Msg
favoriteSection t title items icon =
    div []
        [ h3 [ class "font-medium text-gray-700 dark:text-gray-300 mb-2" ] [ text title ]
        , if List.isEmpty items then
            p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text t.noFavorites ]

          else
            div [ class "space-y-1" ]
                (List.map
                    (\item ->
                        div [ class "flex items-center space-x-2" ]
                            [ span [ class "text-lg" ] [ text icon ]
                            , span [ class "text-sm dark:text-white" ] [ text item ]
                            ]
                    )
                    items
                )
        ]


viewProfileGoals : I18n.Translations -> UserProfile -> Html Msg
viewProfileGoals t profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text t.goals ]
        , if List.isEmpty profile.trainingGoals then
            p [ class "text-gray-500 dark:text-gray-400" ] [ text t.noGoalsSet ]

          else
            div [ class "space-y-2" ]
                (List.map
                    (\goal ->
                        div [ class "flex items-center space-x-2" ]
                            [ span [ class "text-lg" ] [ text "🎯" ]
                            , span [ class "dark:text-white" ] [ text goal ]
                            ]
                    )
                    profile.trainingGoals
                )
        , button
            [ onClick (ShowNotification Info t.goalSettingFeature)
            , class "mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors cursor-pointer"
            , type_ "button"
            ]
            [ text t.addGoal ]
        ]


viewGuestProfile : Model -> Html Msg
viewGuestProfile model =
    let
        t =
            model.userConfig.t
    in
    div [ class "flex-1 flex items-center justify-center p-4 lg:p-8" ]
        [ div [ class "max-w-md w-full" ]
            [ -- Card container styled to site purple theme
              div [ class "bg-white dark:bg-gray-800 rounded-2xl border border-purple-500/20 p-6 lg:p-8 shadow-xl" ]
                [ -- Icon
                  div [ class "flex justify-center mb-6" ]
                    [ div [ class "w-24 h-24 bg-gradient-to-br from-purple-500/20 to-purple-700/20 rounded-full flex items-center justify-center" ]
                        [ span [ class "text-5xl" ] [ text "👤" ] ]
                    ]
                , -- Title
                  h2 [ class "text-3xl font-bold text-slate-900 dark:text-white text-center mb-4" ]
                    [ text t.startYourJourney ]
                , -- Description
                  p [ class "text-gray-600 dark:text-gray-400 text-center mb-8 leading-relaxed" ]
                    [ text t.createAccount ]
                , -- Buttons with proper handlers and z-index
                  div [ class "space-y-3" ]
                    [ button
                        [ onClick (NavigateTo SignUpPage)
                        , class "w-full bg-gradient-to-r from-purple-600 to-purple-700 text-white font-bold py-3 px-6 rounded-lg hover:shadow-xl hover:scale-105 transition-all duration-200 cursor-pointer relative z-10"
                        , type_ "button"
                        ]
                        [ text t.signUp ]
                    , button
                        [ onClick (NavigateTo LoginPage)
                        , class "w-full bg-white dark:bg-gray-800 border border-purple-600 text-purple-700 dark:text-purple-300 font-semibold py-3 px-6 rounded-lg hover:bg-purple-50 dark:hover:bg-gray-700 transition-colors cursor-pointer relative z-10"
                        , type_ "button"
                        ]
                        [ text t.alreadyHaveAccount ]
                    ]
                ]
            ]
        ]


viewSignUpPage : Model -> Html Msg
viewSignUpPage model =
    let
        t =
            model.userConfig.t
    in
    div [ class "min-h-screen flex items-center justify-center p-4", style "margin-top" "-72px" ]
        [ div [ class "max-w-md w-full" ]
            [ div [ class "bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-2xl border border-gray-200 dark:border-gray-700" ]
                [ -- Header
                  div [ class "text-center mb-8" ]
                    [ div [ class "inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full mb-4" ]
                        [ span [ class "text-3xl" ] [ text "🥋" ] ]
                    , h1 [ class "text-3xl font-bold text-gray-900 dark:text-white mb-2" ]
                        [ text t.createAccount ]
                    , p [ class "text-gray-600 dark:text-gray-400" ]
                        [ text t.signUpSubtitle ]
                    ]
                , -- Form
                  div [ class "space-y-4" ]
                    [ div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text t.fullName ]
                        , input
                            [ type_ "text"
                            , class "form-input w-full"
                            , placeholder t.fullNamePlaceholder
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "E-mail" ]
                        , input
                            [ type_ "email"
                            , class "form-input w-full"
                            , placeholder t.emailPlaceholder
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Mot de passe" ]
                        , input
                            [ type_ "password"
                            , class "form-input w-full"
                            , placeholder t.passwordPlaceholder
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text t.confirmPassword ]
                        , input
                            [ type_ "password"
                            , class "form-input w-full"
                            , placeholder t.confirmPasswordPlaceholder
                            ]
                            []
                        ]
                    , button
                        [ onClick (ShowNotification Info t.signUpFeature)
                        , class "w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white font-bold py-3 px-6 rounded-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
                        , type_ "button"
                        ]
                        [ text t.createAccount ]
                    , div [ class "text-center text-sm text-gray-600 dark:text-gray-400" ]
                        [ text
                            (if I18n.languageToString model.userConfig.language == "FR" then
                                "Tu as déjà un compte ? "

                             else
                                "Already have an account? "
                            )
                        , button
                            [ onClick (NavigateTo LoginPage)
                            , class "text-purple-600 dark:text-purple-400 font-semibold hover:underline"
                            ]
                            [ text t.logIn ]
                        ]
                    ]
                ]
            ]
        ]


viewLoginPage : Model -> Html Msg
viewLoginPage model =
    let
        t =
            model.userConfig.t
    in
    div [ class "min-h-screen flex items-center justify-center p-4", style "margin-top" "-72px" ]
        [ div [ class "max-w-md w-full" ]
            [ div [ class "bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-2xl border border-gray-200 dark:border-gray-700" ]
                [ -- Header
                  div [ class "text-center mb-8" ]
                    [ div [ class "inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full mb-4" ]
                        [ span [ class "text-3xl" ] [ text "👤" ] ]
                    , h1 [ class "text-3xl font-bold text-gray-900 dark:text-white mb-2" ]
                        [ text t.welcomeBack ]
                    , p [ class "text-gray-600 dark:text-gray-400" ]
                        [ text t.loginSubtitle ]
                    ]
                , -- Form
                  div [ class "space-y-4" ]
                    [ div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "E-mail" ]
                        , input
                            [ type_ "email"
                            , class "form-input w-full"
                            , placeholder t.emailPlaceholder
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Mot de passe" ]
                        , input
                            [ type_ "password"
                            , class "form-input w-full"
                            , placeholder t.passwordPlaceholder
                            ]
                            []
                        ]
                    , div [ class "flex items-center justify-between" ]
                        [ label [ class "flex items-center" ]
                            [ input [ type_ "checkbox", class "mr-2" ] []
                            , span [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text t.rememberMe ]
                            ]
                        , button
                            [ onClick (ShowNotification Info t.passwordResetFeature)
                            , class "text-sm text-purple-600 dark:text-purple-400 hover:underline"
                            ]
                            [ text t.forgotPassword ]
                        ]
                    , button
                        [ onClick (ShowNotification Info t.loginFeature)
                        , class "w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white font-bold py-3 px-6 rounded-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
                        , type_ "button"
                        ]
                        [ text t.logIn ]
                    , div [ class "text-center text-sm text-gray-600 dark:text-gray-400" ]
                        [ text t.dontHaveAccount
                        , button
                            [ onClick (NavigateTo SignUpPage)
                            , class "text-purple-600 dark:text-purple-400 font-semibold hover:underline"
                            ]
                            [ text t.signUp ]
                        ]
                    ]
                ]
            ]
        ]


viewStylePathPage : Model -> String -> Html Msg
viewStylePathPage model slug =
    case Dict.get slug model.heroes of
        Just hero ->
            viewHeroStylePath model hero

        Nothing ->
            let
                t =
                    model.userConfig.t
            in
            div [ class "space-y-6 p-6" ]
                [ h1 [ class "text-3xl font-bold text-white" ]
                    [ text t.heroBadge ]
                , p [ class "text-gray-400" ]
                    [ text t.fighterPathDescription ]
                , div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50" ]
                    [ text t.fighterPathComingSoon ]
                ]


viewTechniqueLibraryPage : Model -> Html Msg
viewTechniqueLibraryPage model =
    let
        language =
            model.userConfig.language

        t =
            model.userConfig.t

        finishingGroups =
            Data.finishingTechniqueGroups

        guardGroups =
            Data.guardTechniqueGroups

        sweepGroups =
            Data.sweepTechniqueGroups

        finishingTotal =
            finishingGroups |> List.concatMap .entries |> List.length

        guardTotal =
            guardGroups |> List.concatMap .entries |> List.length

        sweepTotal =
            sweepGroups |> List.concatMap .entries |> List.length

        sectionFilter =
            model.techniqueLibraryFilter

        finishingSection =
            if sectionVisible sectionFilter FinishingSection then
                [ section [ class "card space-y-6" ]
                    [ viewTechniqueSectionHeading language FinishingSection
                    , div [ class "space-y-6" ] (List.map (viewTechniqueGroup model language) finishingGroups)
                    , viewTechniqueSummary language finishingTechniqueSummary
                    ]
                ]

            else
                []

        guardSection =
            if sectionVisible sectionFilter GuardSection then
                [ section [ class "card space-y-6" ]
                    [ viewTechniqueSectionHeading language GuardSection
                    , div [ class "space-y-6" ] (List.map (viewTechniqueGroup model language) guardGroups)
                    ]
                ]

            else
                []

        passingSection =
            if sectionVisible sectionFilter PassingSection then
                [ viewTechniqueComingSoon language PassingSection ]

            else
                []

        sweepSection =
            if sectionVisible sectionFilter SweepSection then
                [ section [ class "card space-y-6" ]
                    [ viewTechniqueSectionHeading language SweepSection
                    , div [ class "space-y-6" ] (List.map (viewTechniqueGroup model language) sweepGroups)
                    , viewTechniqueSummary language sweepTechniqueSummary
                    ]
                ]

            else
                []

        techniqueSections =
            finishingSection
                ++ guardSection
                ++ passingSection
                ++ sweepSection
    in
    div [ class "page-stack page-stack--full" ]
        ([ pageIntro t.techniqueLibraryTitle t.techniqueLibraryDescription
         , div [ class "grid gap-6 lg:grid-cols-2" ]
            [ viewTechniqueStats language finishingTotal guardTotal sweepTotal
            , viewTechniqueCategorySelector language sectionFilter
            ]
         , viewTechniquePreviewPanel model language
         ]
            ++ techniqueSections
        )


sectionVisible : Maybe TechniqueSection -> TechniqueSection -> Bool
sectionVisible filter selection =
    case filter of
        Nothing ->
            True

        Just picked ->
            picked == selection


techniqueSectionValue : Maybe TechniqueSection -> String
techniqueSectionValue maybeSection =
    case maybeSection of
        Nothing ->
            "all"

        Just section ->
            case section of
                FinishingSection ->
                    "finishing"

                GuardSection ->
                    "guard"

                PassingSection ->
                    "passing"

                SweepSection ->
                    "sweep"


valueToTechniqueSection : String -> Maybe TechniqueSection
valueToTechniqueSection value =
    case value of
        "all" ->
            Nothing

        "finishing" ->
            Just FinishingSection

        "guard" ->
            Just GuardSection

        "passing" ->
            Just PassingSection

        "sweep" ->
            Just SweepSection

        _ ->
            Nothing


localizeText : I18n.Language -> Data.LocalizedString -> String
localizeText language value =
    case language of
        I18n.FR ->
            value.fr

        I18n.EN ->
            value.en


viewTechniqueStats : I18n.Language -> Int -> Int -> Int -> Html Msg
viewTechniqueStats language finishingTotal guardTotal sweepTotal =
    let
        labels =
            case language of
                I18n.FR ->
                    { heading = "Aperçu"
                    , submissions = "Soumissions listées"
                    , guards = "Gardes détaillées"
                    , sweeps = "Renversements listés"
                    , notes = "Notes pratiques"
                    , sections = "Sections"
                    }

                I18n.EN ->
                    { heading = "Overview"
                    , submissions = "Listed submissions"
                    , guards = "Detailed guards"
                    , sweeps = "Listed sweeps"
                    , notes = "Practical notes"
                    , sections = "Sections"
                    }

        totalSections =
            4

        notesCount =
            Data.guardTechniqueNotes ++ Data.sweepTechniqueNotes |> List.length
    in
    section [ class "card space-y-4" ]
        [ h3 [ class "text-lg font-semibold text-slate-900 dark:text-white" ] [ text labels.heading ]
        , div [ class "grid gap-4 sm:grid-cols-2 lg:grid-cols-5" ]
            [ techStatCard "🗡️" labels.submissions (String.fromInt finishingTotal)
            , techStatCard "🛡️" labels.guards (String.fromInt guardTotal)
            , techStatCard "🔄" labels.sweeps (String.fromInt sweepTotal)
            , techStatCard "📝" labels.notes (String.fromInt notesCount)
            , techStatCard "📚" labels.sections (String.fromInt totalSections)
            ]
        ]


techStatCard : String -> String -> String -> Html Msg
techStatCard icon label value =
    div [ class "surface-card p-4 flex items-center gap-4" ]
        [ span [ class "inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-100 dark:bg-slate-800 text-xl" ]
            [ text icon ]
        , div []
            [ p [ class "text-2xl font-semibold text-slate-900 dark:text-white" ] [ text value ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
            ]
        ]


viewTechniqueCategorySelector : I18n.Language -> Maybe TechniqueSection -> Html Msg
viewTechniqueCategorySelector language selection =
    let
        selectId =
            "technique-library-filter"

        ( titleLabel, helperLabel, options ) =
            case language of
                I18n.FR ->
                    ( "Choisis ta catégorie"
                    , "Mets l'accent sur une famille de techniques."
                    , [ ( Nothing, "Toutes les catégories" )
                      , ( Just FinishingSection, "Soumissions" )
                      , ( Just GuardSection, "Gardes" )
                      , ( Just PassingSection, "Passages (bientôt)" )
                      , ( Just SweepSection, "Renversements" )
                      ]
                    )

                I18n.EN ->
                    ( "Choose your focus"
                    , "Highlight one family of techniques at a time."
                    , [ ( Nothing, "All categories" )
                      , ( Just FinishingSection, "Submissions" )
                      , ( Just GuardSection, "Guards" )
                      , ( Just PassingSection, "Passing (soon)" )
                      , ( Just SweepSection, "Sweeps" )
                      ]
                    )

        currentValue =
            techniqueSectionValue selection

        optionView ( optionSelection, labelText ) =
            let
                optionValue =
                    techniqueSectionValue optionSelection
            in
            option
                [ Attr.value optionValue
                , Attr.selected (optionValue == currentValue)
                ]
                [ text labelText ]
    in
    section [ class "card space-y-6" ]
        [ div [ class "flex flex-wrap items-center justify-between gap-3" ]
            [ label [ Attr.for selectId, class "text-base font-semibold text-slate-900 dark:text-white" ] [ text titleLabel ]
            , span [ class "text-xs text-gray-500 dark:text-gray-400" ] [ text helperLabel ]
            ]
        , div [ class "relative" ]
            [ select
                [ id selectId
                , class "sh-select"
                , onInput (SetTechniqueLibraryFilter << valueToTechniqueSection)
                , Attr.value currentValue
                ]
                (List.map optionView options)
            , span [ class "pointer-events-none absolute inset-y-0 right-4 flex items-center text-xl text-slate-400 dark:text-slate-500" ]
                [ text "⌄" ]
            ]
        , div [ class "flex flex-wrap gap-2" ]
            (List.map (viewTechniqueFilterChip selection) options)
        , viewTechniqueNotes language (Data.guardTechniqueNotes ++ Data.sweepTechniqueNotes)
        ]


viewTechniquePreviewPanel : Model -> I18n.Language -> Html Msg
viewTechniquePreviewPanel model language =
    case techniquePreviewEntry model of
        Nothing ->
            text ""

        Just entry ->
            let
                name =
                    localizeText language entry.name

                description =
                    localizeText language entry.description

                details =
                    entry.details |> List.map (localizeText language)

                ( goalLabel, clearLabel, alreadyLabel ) =
                    case language of
                        I18n.FR ->
                            ( "Définir comme objectif", "Fermer", "Déjà sélectionné" )

                        I18n.EN ->
                            ( "Set as training goal", "Close", "Already selected" )

                isGoal =
                    model.trainingGoal == Just entry.id
            in
            div [ class "sh-card rounded-2xl border border-slate-200/70 bg-white/90 p-6 space-y-4 dark:border-slate-800 dark:bg-slate-900/70" ]
                [ div [ class "flex items-start justify-between gap-4" ]
                    [ div []
                        [ h3 [ class "text-2xl font-semibold text-slate-900 dark:text-white" ] [ text name ]
                        , p [ class "text-sm text-slate-500 dark:text-slate-400" ] [ text description ]
                        ]
                    , button
                        [ onClick ClearTechniquePreview
                        , class "sh-btn bg-slate-100 text-slate-600 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-300"
                        ]
                        [ text clearLabel ]
                    ]
                , ul [ class "space-y-2 text-sm text-slate-600 dark:text-slate-400" ]
                    (List.map (\detail -> li [] [ text detail ]) details)
                , div [ class "flex flex-wrap gap-3" ]
                    [ button
                        [ onClick (SetTrainingGoal entry.id)
                        , class "sh-btn bg-slate-900 text-white hover:bg-slate-800"
                        ]
                        [ text goalLabel ]
                    , if isGoal then
                        span [ class "text-sm font-semibold text-purple-600 dark:text-purple-300" ] [ text alreadyLabel ]

                      else
                        text ""
                    ]
                ]


viewTechniqueFilterChip :
    Maybe TechniqueSection
    -> ( Maybe TechniqueSection, String )
    -> Html Msg
viewTechniqueFilterChip currentSelection ( optionSelection, labelText ) =
    let
        isActive =
            currentSelection == optionSelection
    in
    button
        [ type_ "button"
        , classList
            [ ( "inline-flex items-center rounded-full border px-3 py-1 text-xs font-semibold transition", True )
            , ( "bg-purple-600 text-white border-purple-600 shadow-sm", isActive )
            , ( "bg-white dark:bg-slate-900 border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:border-purple-200 dark:hover:border-purple-500", not isActive )
            ]
        , onClick (SetTechniqueLibraryFilter optionSelection)
        ]
        [ text labelText ]


viewTechniqueGroup : Model -> I18n.Language -> Data.TechniqueGroup -> Html Msg
viewTechniqueGroup model language group =
    div [ class "space-y-3" ]
        [ div [ class "flex items-center gap-3" ]
            [ span [ class "text-3xl" ] [ text group.icon ]
            , div []
                [ h3 [ class "text-lg font-semibold text-slate-900 dark:text-white" ] [ text (localizeText language group.title) ]
                , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text (localizeText language group.subtitle) ]
                ]
            ]
        , div [ class "grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4" ]
            (List.map (viewTechniqueEntry model language) group.entries)
        ]


viewTechniqueEntry : Model -> I18n.Language -> Data.TechniqueEntry -> Html Msg
viewTechniqueEntry model language entry =
    let
        isSelected =
            model.techniquePreview == Just entry.id

        isGoal =
            model.trainingGoal == Just entry.id

        goalLabel =
            case language of
                I18n.FR ->
                    "Objectif"

                I18n.EN ->
                    "Goal"

        baseClasses =
            "surface-card p-4 space-y-2 border transition cursor-pointer"

        selectedClass =
            if isSelected then
                " ring-2 ring-purple-500 border-purple-200"

            else
                ""
    in
    div
        [ onClick (PreviewTechnique entry.id)
        , class (baseClasses ++ selectedClass)
        ]
        [ div [ class "flex items-center justify-between" ]
            [ h4 [ class "text-base font-semibold text-slate-900 dark:text-white" ] [ text (localizeText language entry.name) ]
            , if isGoal then
                span [ class "rounded-full bg-purple-100 px-3 py-1 text-xs font-semibold text-purple-700" ] [ text goalLabel ]

              else
                text ""
            ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400 leading-relaxed" ] [ text (localizeText language entry.description) ]
        , ul [ class "list-disc list-inside text-xs text-gray-500 dark:text-gray-400 space-y-1" ]
            (List.map (\detail -> li [] [ text (localizeText language detail) ]) entry.details)
        ]


viewTechniqueSummary : I18n.Language -> List TechniqueSummaryRow -> Html Msg
viewTechniqueSummary language rows =
    let
        title =
            case language of
                I18n.FR ->
                    "Catégorisation rapide"

                I18n.EN ->
                    "Quick categorization"
    in
    div [ class "space-y-4" ]
        [ h3 [ class "text-lg font-semibold text-slate-900 dark:text-white" ] [ text title ]
        , div [ class "grid grid-cols-1 md:grid-cols-3 gap-4 text-sm" ]
            (List.map
                (\row ->
                    div [ class "surface-card p-4 space-y-1" ]
                        [ p [ class "text-xs uppercase tracking-widest text-gray-500 dark:text-gray-400" ] [ text (localizeText language row.category) ]
                        , p [ class "text-base font-semibold text-slate-900 dark:text-white" ] [ text (localizeText language row.examples) ]
                        , p [ class "text-xs text-gray-500 dark:text-gray-400" ] [ text (localizeText language row.target) ]
                        ]
                )
                rows
            )
        ]


techniqueSectionId : TechniqueSection -> String
techniqueSectionId section =
    case section of
        FinishingSection ->
            "finishing-techniques"

        GuardSection ->
            "guard-techniques"

        PassingSection ->
            "passing-techniques"

        SweepSection ->
            "sweep-techniques"


viewTechniqueSectionHeading : I18n.Language -> TechniqueSection -> Html Msg
viewTechniqueSectionHeading language techSection =
    let
        title =
            case ( language, techSection ) of
                ( I18n.FR, FinishingSection ) ->
                    "Soumissions de finition"

                ( I18n.FR, GuardSection ) ->
                    "Gardes et contrôles"

                ( I18n.FR, PassingSection ) ->
                    "Passages et passing"

                ( I18n.FR, SweepSection ) ->
                    "Renversements"

                ( I18n.EN, FinishingSection ) ->
                    "Finishing submissions"

                ( I18n.EN, GuardSection ) ->
                    "Guards and controls"

                ( I18n.EN, PassingSection ) ->
                    "Passing systems"

                ( I18n.EN, SweepSection ) ->
                    "Sweeps"

        sectionId =
            techniqueSectionId techSection

        subtitle =
            case ( language, techSection ) of
                ( I18n.FR, FinishingSection ) ->
                    "Étudie les étranglements, clés et hybrides essentiels."

                ( I18n.FR, GuardSection ) ->
                    "Maîtrise les gardes traditionnelles et modernes pour contrôler le combat."

                ( I18n.FR, PassingSection ) ->
                    "Cartographie des passings modernes : demi-garde, body lock, toreando..."

                ( I18n.FR, SweepSection ) ->
                    "Atlas complet des renversements classés par garde et mécanique."

                ( I18n.EN, FinishingSection ) ->
                    "Study the most used chokes, joint locks, and hybrids."

                ( I18n.EN, GuardSection ) ->
                    "Master the classic and modern guard systems to control the match."

                ( I18n.EN, PassingSection ) ->
                    "Mapping modern passes: half guard, body lock, toreando, and more."

                ( I18n.EN, SweepSection ) ->
                    "Complete sweep atlas organized by guard families and mechanics."
    in
    div [ Attr.id sectionId, class "space-y-1" ]
        [ h2 [ class "text-2xl font-bold text-slate-900 dark:text-white" ] [ text title ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text subtitle ]
        ]


viewTechniqueComingSoon : I18n.Language -> TechniqueSection -> Html Msg
viewTechniqueComingSoon language techSection =
    let
        ( badgeLabel, message, icon ) =
            case ( language, techSection ) of
                ( I18n.FR, PassingSection ) ->
                    ( "À venir"
                    , "Nous finalisons les séquences de passings : demi-garde, body lock, toreando, etc."
                    , "🚧"
                    )

                ( I18n.FR, SweepSection ) ->
                    ( "À venir"
                    , "Tous les renversements majeurs (papillon, X-guard, De La Riva...) arrivent très bientôt."
                    , "🔄"
                    )

                ( I18n.EN, PassingSection ) ->
                    ( "Coming soon"
                    , "We are mapping the full suite of passing chains: half guard, body lock, toreando, and more."
                    , "🚧"
                    )

                ( I18n.EN, SweepSection ) ->
                    ( "Coming soon"
                    , "A complete sweep atlas (butterfly, X-guard, de la Riva...) is on the way."
                    , "🔄"
                    )

                _ ->
                    ( "Coming soon", "New content is on the way.", "🚧" )
    in
    section [ class "card space-y-4" ]
        [ viewTechniqueSectionHeading language techSection
        , div [ class "surface-card p-5 flex items-start gap-3" ]
            [ span [ class "text-3xl" ] [ text icon ]
            , div [ class "space-y-2" ]
                [ span [ class "inline-flex items-center rounded-full bg-indigo-50 dark:bg-slate-800 px-3 py-1 text-xs font-semibold text-indigo-700 dark:text-indigo-300" ]
                    [ text badgeLabel ]
                , p [ class "text-sm text-gray-600 dark:text-gray-300" ] [ text message ]
                ]
            ]
        ]


viewTechniqueModalPreviewPanel : Model -> I18n.Language -> Html Msg
viewTechniqueModalPreviewPanel model language =
    case techniquePreviewEntry model of
        Nothing ->
            let
                placeholderText =
                    case language of
                        I18n.FR ->
                            "Choisis une technique pour afficher un aperçu détaillé."

                        I18n.EN ->
                            "Pick a technique to see its detailed preview."
            in
            div [ class "sh-card flex h-full items-center justify-center rounded-2xl border border-dashed border-slate-300/70 bg-slate-50/70 p-6 text-center text-sm text-slate-500 dark:border-slate-700/60 dark:bg-slate-900/40 dark:text-slate-400" ]
                [ text placeholderText ]

        Just _ ->
            viewTechniquePreviewPanel model language


viewTechniqueNotes : I18n.Language -> List Data.LocalizedString -> Html Msg
viewTechniqueNotes language notes =
    let
        noteView note =
            div [ class "flex items-start gap-3 rounded-2xl bg-white/70 dark:bg-slate-900/60 px-4 py-3 shadow-inner" ]
                [ span [ class "text-lg text-purple-600 dark:text-purple-300" ] [ text "✦" ]
                , p [ class "text-sm md:text-base text-gray-700 dark:text-gray-200 leading-relaxed" ]
                    [ text (localizeText language note) ]
                ]
    in
    div [ class "border-t border-gray-200 dark:border-gray-800 pt-5 space-y-4" ]
        [ div [ class "space-y-3" ]
            (List.map noteView notes)
        ]


viewProgressPage : Model -> Html Msg
viewProgressPage model =
    let
        t =
            model.userConfig.t
    in
    div [ class "space-y-6 p-6" ]
        [ h1 [ class "text-3xl font-bold text-white" ]
            [ text t.progressPageTitle ]
        , p [ class "text-gray-400" ]
            [ text t.progressPageDescription ]
        , div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50" ]
            [ text t.progressTrackingComingSoon ]
        ]


type alias TechniqueSummaryRow =
    { category : Data.LocalizedString
    , examples : Data.LocalizedString
    , target : Data.LocalizedString
    }


finishingTechniqueSummary : List TechniqueSummaryRow
finishingTechniqueSummary =
    [ { category = Data.localized "Chokes" "Étranglements"
      , examples = Data.localized "RNC, Guillotine, Triangle" "RNC, Guillotine, Triangle"
      , target = Data.localized "Neck / breathing" "Cou / respiration"
      }
    , { category = Data.localized "Arm locks" "Clés bras"
      , examples = Data.localized "Armbar, Kimura, Americana" "Armbar, Kimura, Americana"
      , target = Data.localized "Elbow / shoulder" "Coude / épaule"
      }
    , { category = Data.localized "Leg locks" "Clés jambes"
      , examples = Data.localized "Heel Hook, Toe Hold, Kneebar" "Heel Hook, Toe Hold, Kneebar"
      , target = Data.localized "Ankle / knee" "Cheville / genou"
      }
    , { category = Data.localized "Compression locks" "Écrasements"
      , examples = Data.localized "Bicep Slicer, Calf Slicer" "Bicep Slicer, Calf Slicer"
      , target = Data.localized "Muscles / nerves" "Muscles / nerfs"
      }
    , { category = Data.localized "Hybrid attacks" "Hybrides"
      , examples = Data.localized "Omoplata, Twister, Peruvian Necktie" "Omoplata, Twister, Peruvian Necktie"
      , target = Data.localized "Blend of strangle + joint control" "Mix strangulation + articulation"
      }
    ]


sweepTechniqueSummary : List TechniqueSummaryRow
sweepTechniqueSummary =
    [ { category = Data.localized "Scissor" "Scissor"
      , examples = Data.localized "Closed guard" "Garde fermée"
      , target = Data.localized "Mechanic: Scissor legs" "Mécanique : ciseau jambes"
      }
    , { category = Data.localized "Flower" "Flower"
      , examples = Data.localized "Closed guard" "Garde fermée"
      , target = Data.localized "Mechanic: Pendulum swing" "Mécanique : pendule"
      }
    , { category = Data.localized "Hip Bump" "Hip Bump"
      , examples = Data.localized "Closed guard" "Garde fermée"
      , target = Data.localized "Mechanic: Sit-up + hip drive" "Mécanique : relevé + hanches"
      }
    , { category = Data.localized "Butterfly" "Butterfly"
      , examples = Data.localized "Butterfly guard" "Butterfly guard"
      , target = Data.localized "Mechanic: Hook elevation" "Mécanique : crochet élévateur"
      }
    , { category = Data.localized "X-Guard" "X-Guard"
      , examples = Data.localized "X guard" "X guard"
      , target = Data.localized "Mechanic: Crossed leg extension" "Mécanique : extension jambes croisées"
      }
    , { category = Data.localized "Tripod / Sickle" "Tripod / Sickle"
      , examples = Data.localized "De La Riva" "De La Riva"
      , target = Data.localized "Mechanic: Push-pull ankle control" "Mécanique : push-pull sur chevilles"
      }
    , { category = Data.localized "Old School" "Old School"
      , examples = Data.localized "Half guard" "Demi-garde"
      , target = Data.localized "Mechanic: Underhook + foot trap" "Mécanique : underhook + pied piégé"
      }
    , { category = Data.localized "Waiter" "Waiter"
      , examples = Data.localized "Deep half" "Deep half"
      , target = Data.localized "Mechanic: Leg lift tray" "Mécanique : soulèvement plateau"
      }
    , { category = Data.localized "Single Leg X" "Single Leg X"
      , examples = Data.localized "SLX" "SLX"
      , target = Data.localized "Mechanic: Hip extension" "Mécanique : extension hanche"
      }
    , { category = Data.localized "Tornado" "Tornado"
      , examples = Data.localized "Half / inverted" "Demi / inversée"
      , target = Data.localized "Mechanic: Roll + elevation" "Mécanique : roulade + élévation"
      }
    , { category = Data.localized "Berimbolo" "Berimbolo"
      , examples = Data.localized "De La Riva" "De La Riva"
      , target = Data.localized "Mechanic: Inverted spin" "Mécanique : spin inversé"
      }
    , { category = Data.localized "Kiss of the Dragon" "Kiss of the Dragon"
      , examples = Data.localized "Reverse DLR" "Reverse DLR"
      , target = Data.localized "Mechanic: Inside roll" "Mécanique : roulade intérieure"
      }
    , { category = Data.localized "Balloon" "Balloon"
      , examples = Data.localized "Open guard" "Garde ouverte"
      , target = Data.localized "Mechanic: Aerial momentum" "Mécanique : momentum aérien"
      }
    ]


viewHeroStylePath : Model -> Hero -> Html Msg
viewHeroStylePath model hero =
    let
        t =
            model.userConfig.t
    in
    div [ class "space-y-8 pb-10" ]
        [ stylePathHeader model hero
        , stylePathQuickStats hero
        , styleTechniqueSystems hero
        , styleTrainingBlueprint t hero
        , styleStudyPlaylist hero
        , styleAchievementsSection hero
        , styleNextSteps hero
        ]


stylePathHeader : Model -> Hero -> Html Msg
stylePathHeader model hero =
    let
        coverStyle =
            Attr.style "background-image" ("url(" ++ hero.coverImageUrl ++ ")")

        weightLabel =
            weightClassToString hero.weight

        styleLabel =
            fightingStyleLabel hero.style

        overlayGradient =
            "bg-gradient-to-br from-black/70 via-black/40 to-black/60"
    in
    div [ class "relative overflow-hidden rounded-3xl shadow-2xl border border-red-500/20" ]
        [ div [ class "absolute inset-0 bg-cover bg-center scale-105 blur-sm opacity-60", coverStyle ] []
        , div [ class ("absolute inset-0 " ++ overlayGradient) ] []
        , div [ class "relative p-10 lg:p-14 text-white space-y-6" ]
            [ span [ class "inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/15 backdrop-blur text-sm uppercase tracking-widest" ]
                [ text "Parcours signature" ]
            , div [ class "space-y-3" ]
                [ h1 [ class "text-4xl lg:text-5xl font-black tracking-tight" ] [ text hero.name ]
                , p [ class "text-xl text-white/80" ] [ text ("\"" ++ hero.nickname ++ "\" • " ++ hero.team) ]
                ]
            , div [ class "flex flex-wrap items-center gap-3 text-sm uppercase tracking-widest" ]
                [ span [ class "px-3 py-1 rounded-full bg-white/20 backdrop-blur" ] [ text weightLabel ]
                , span [ class "px-3 py-1 rounded-full bg-white/20 backdrop-blur" ] [ text styleLabel ]
                , span [ class "px-3 py-1 rounded-full bg-white/20 backdrop-blur" ] [ text (String.fromInt hero.record.wins ++ "-" ++ String.fromInt hero.record.losses ++ "-" ++ String.fromInt hero.record.draws) ]
                ]
            , p [ class "max-w-3xl text-lg text-white/80 leading-relaxed" ]
                [ text "Plonge dans le système, la structure d'entraînement et le plan d'étude qui rendent ce champion dominant. Inspires-toi de cette feuille de route puis adapte-la à ton propre jeu." ]
            , div [ class "flex flex-wrap items-center gap-3" ]
                [ button
                    [ onClick (NavigateTo (HeroDetail hero.id))
                    , class "px-5 py-3 bg-red-500 hover:bg-red-600 text-white font-semibold rounded-xl transition-colors"
                    ]
                    [ text ("Voir le profil complet de " ++ hero.name) ]
                , button
                    [ onClick (ToggleFavorite HeroFavorite hero.id)
                    , class "px-5 py-3 bg-white/15 hover:bg-white/25 text-white font-semibold rounded-xl transition-colors"
                    ]
                    [ text "Ajouter aux favoris" ]
                ]
            ]
        ]


stylePathQuickStats : Hero -> Html Msg
stylePathQuickStats hero =
    let
        summaryCard label primary secondary =
            div [ class "bg-gray-800/60 border border-gray-700/60 rounded-2xl p-6 shadow-lg backdrop-blur" ]
                [ p [ class "text-sm uppercase tracking-widest text-gray-400 mb-2" ] [ text label ]
                , p [ class "text-3xl font-bold text-white" ] [ text primary ]
                , p [ class "text-sm text-gray-500 mt-1" ] [ text secondary ]
                ]
    in
    div [ class "grid grid-cols-1 md:grid-cols-3 gap-5" ]
        [ summaryCard "Taux de victoire" (formatPercentage hero.stats.winRate) "Sur le circuit no-gi élite"
        , summaryCard "Taux de soumission" (formatPercentage hero.stats.submissionRate) ("Signature : " ++ hero.stats.favoriteSubmission)
        , summaryCard "Temps moyen par combat" (String.fromFloat hero.stats.averageMatchTime ++ " min") ("Contrôle depuis " ++ hero.stats.favoritePosition)
        ]


styleTechniqueSystems : Hero -> Html Msg
styleTechniqueSystems hero =
    let
        groupedTechniques =
            groupTechniquesByCategory hero.techniques
                |> List.sortBy (\( category, _ ) -> techniqueCategoryOrder category)

        techniqueCard technique =
            div [ class "bg-gray-900/40 border border-gray-700/60 rounded-xl p-5 space-y-3" ]
                [ h4 [ class "text-lg font-semibold text-white" ] [ text technique.name ]
                , p [ class "text-sm text-gray-400" ] [ text technique.description ]
                , div [ class "flex flex-wrap gap-2" ]
                    (technique.keyDetails
                        |> List.take 3
                        |> List.map (\detail -> span [ class "px-3 py-1 bg-red-500/15 text-red-200 rounded-full text-xs tracking-wide" ] [ text detail ])
                    )
                , div [ class "flex flex-wrap items-center gap-x-4 gap-y-2 text-xs text-gray-500 uppercase tracking-wide" ]
                    [ span [] [ text (difficultyToString technique.difficulty) ]
                    , span [] [ text ("Maîtrise : " ++ masteryLevelToString technique.masteryLevel) ]
                    ]
                ]

        categorySection ( category, techniques ) =
            div [ class "space-y-4" ]
                [ h3 [ class "text-xl font-bold text-white flex items-center gap-2" ]
                    [ span [ class "text-red-400" ] [ text "◆" ]
                    , text (techniqueCategoryToString category)
                    ]
                , div [ class "grid grid-cols-1 md:grid-cols-2 gap-4" ]
                    (techniques
                        |> List.sortBy .name
                        |> List.map techniqueCard
                    )
                ]
    in
    div [ class "space-y-6" ]
        [ h2 [ class "text-2xl font-bold text-white" ] [ text "Systèmes signature" ]
        , if List.isEmpty groupedTechniques then
            p [ class "text-gray-500" ] [ text "L'analyse technique sera bientôt disponible." ]

          else
            div [ class "space-y-6" ] (List.map categorySection groupedTechniques)
        ]


styleTrainingBlueprint : I18n.Translations -> Hero -> Html Msg
styleTrainingBlueprint t hero =
    let
        phases =
            [ ( "Fondations", "Construis des mécaniques implacables : passage en pression, entrées sur les jambes et drills de domination positionnelle." )
            , ( "Intégration des systèmes", "Superpose les chaînes de soumissions depuis les positions fortes et alterne les attaques haut/bas du corps." )
            , ( "Simulation de compétition", "Rounds courts chronométrés avec suivi des points pour répéter les ajustements tactiques et la gestion du rythme." )
            ]

        focusAreas =
            [ ( "Flux de contrôle", "Enchaîne les prises de garde assise vers des transitions en entanglement de jambes." )
            , ( "Laboratoire dos", "Entrées quotidiennes vers la prise de dos suivies de répétitions de finalisation pour renforcer ton serrage." )
            , ( "Sparring situationnel", "Pars des défenses adverses pour éprouver la robustesse du système." )
            ]
    in
    div [ class "space-y-6" ]
        [ h2 [ class "text-2xl font-bold text-white" ] [ text "Plan d'entraînement" ]
        , div [ class "grid grid-cols-1 lg:grid-cols-2 gap-5" ]
            [ div [ class "space-y-4" ]
                [ h3 [ class "text-lg font-semibold text-white uppercase tracking-widest" ] [ text "Phases du camp" ]
                , div [ class "space-y-3" ]
                    (List.map
                        (\( title, description ) ->
                            div [ class "bg-gray-800/50 border border-gray-700/50 rounded-xl p-4" ]
                                [ h4 [ class "text-sm font-semibold uppercase tracking-widest text-red-300" ] [ text title ]
                                , p [ class "text-sm text-gray-400 leading-relaxed" ] [ text description ]
                                ]
                        )
                        phases
                    )
                ]
            , div [ class "space-y-4" ]
                [ h3 [ class "text-lg font-semibold text-white uppercase tracking-widest" ] [ text "Axes prioritaires" ]
                , div [ class "space-y-3" ]
                    (List.map
                        (\( title, description ) ->
                            div [ class "bg-gray-800/40 border border-gray-700/40 rounded-xl p-4 flex gap-3" ]
                                [ span [ class "text-red-400 mt-1" ] [ text "●" ]
                                , div []
                                    [ h4 [ class "text-sm font-semibold text-white uppercase tracking-wider" ] [ text title ]
                                    , p [ class "text-sm text-gray-400 leading-relaxed" ] [ text description ]
                                    ]
                                ]
                        )
                        focusAreas
                    )
                , div [ class "bg-gray-900/40 border border-gray-700/60 rounded-xl p-4 space-y-3" ]
                    [ h4 [ class "text-sm font-semibold text-white uppercase tracking-wider" ] [ text "Notes de compétition" ]
                    , ul [ class "text-sm text-gray-400 space-y-2 list-disc list-inside" ]
                        [ li [] [ text ("Armes : " ++ hero.stats.favoriteSubmission ++ " depuis " ++ hero.stats.favoritePosition) ]
                        , li [] [ text "Varie le tempo : alterne pression lourde et entanglements explosifs pour surprendre." ]
                        , li [] [ text "Discipline tes grips pour dicter les scrambles et exposer le dos." ]
                        ]
                    ]
                ]
            ]
        , div [ class "bg-red-500/10 border border-red-500/30 rounded-2xl p-5 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4" ]
            [ div []
                [ h4 [ class "text-lg font-semibold text-red-200" ] [ text "Intégration dans ta semaine" ]
                , p [ class "text-sm text-red-200/80" ] [ text ("Mêle ce plan à ton calendrier : deux sessions système, un sparring positionnel et une mise en situation inspirée par " ++ hero.name ++ ".") ]
                ]
            , button
                [ onClick (NavigateTo Training)
                , class "px-5 py-3 bg-red-500 hover:bg-red-600 text-white rounded-xl font-semibold transition-colors"
                ]
                [ text t.startSession ]
            ]
        ]


styleStudyPlaylist : Hero -> Html Msg
styleStudyPlaylist hero =
    div [ class "space-y-6" ]
        [ h2 [ class "text-2xl font-bold text-white" ] [ text "Playlist d'étude" ]
        , if List.isEmpty hero.videos then
            p [ class "text-gray-500" ] [ text "Le pack de préparation vidéo arrive bientôt." ]

          else
            div [ class "grid grid-cols-1 lg:grid-cols-3 gap-4" ]
                (hero.videos
                    |> List.sortBy .date
                    |> List.map
                        (\video ->
                            div [ class "bg-gray-900/40 border border-gray-700/60 rounded-2xl p-4 space-y-3" ]
                                [ span [ class "inline-flex text-xs px-3 py-1 rounded-full bg-white/10 text-white/70 uppercase tracking-widest" ]
                                    [ text (videoTypeToString video.type_) ]
                                , h3 [ class "text-lg font-semibold text-white" ] [ text video.title ]
                                , p [ class "text-sm text-gray-500" ]
                                    [ text ("Replace la séquence dans son contexte : observe comment " ++ hero.name ++ " contrôle le tempo et alterne entre les systèmes.") ]
                                , span [ class "block text-xs text-gray-500 uppercase tracking-widest" ]
                                    [ text ("Publié : " ++ video.date) ]
                                , a
                                    [ href video.url
                                    , target "_blank"
                                    , rel "noreferrer noopener"
                                    , class "inline-flex items-center gap-2 text-sm text-red-300 hover:text-red-200 transition-colors"
                                    ]
                                    [ span [] [ text "Voir la vidéo" ]
                                    , span [] [ text "↗" ]
                                    ]
                                ]
                        )
                )
        ]


styleAchievementsSection : Hero -> Html Msg
styleAchievementsSection hero =
    div [ class "space-y-6" ]
        [ h2 [ class "text-2xl font-bold text-white" ] [ text "Moments forts" ]
        , if List.isEmpty hero.achievements then
            p [ class "text-gray-500" ] [ text "Les succès détaillés arrivent bientôt." ]

          else
            div [ class "grid grid-cols-1 md:grid-cols-2 gap-4" ]
                (hero.achievements
                    |> List.sortBy .name
                    |> List.map
                        (\achievement ->
                            div [ class "bg-gray-900/40 border border-gray-700/60 rounded-2xl p-4 flex gap-4" ]
                                [ span [ class "text-3xl" ] [ text achievement.icon ]
                                , div [ class "space-y-1" ]
                                    [ h3 [ class "text-lg font-semibold text-white" ] [ text achievement.name ]
                                    , p [ class "text-sm text-gray-500 leading-relaxed" ] [ text achievement.description ]
                                    , span [ class "text-xs uppercase tracking-widest text-gray-500" ]
                                        [ text ("Points : " ++ String.fromInt achievement.points) ]
                                    ]
                                ]
                        )
                )
        ]


styleNextSteps : Hero -> Html Msg
styleNextSteps hero =
    let
        suggestions =
            [ "Associe les drills système à une prise de notes précise : note les contres rencontrés et affine la séquence."
            , "Utilise le sparring positionnel pour recréer les scénarios dominants : saddle, triangles dos et contrôle par body-lock."
            , "En étudiant les vidéos, observe les changements de tempo, la domination des grips et les choix entre passage ou attaque de jambes."
            ]
    in
    div [ class "space-y-5 bg-gray-900/40 border border-gray-700/60 rounded-3xl p-6" ]
        [ h2 [ class "text-2xl font-bold text-white" ] [ text "Prochaines étapes" ]
        , p [ class "text-gray-400 leading-relaxed" ]
            [ text ("Absorbe les concepts puis adapte-les à tes attributs. Peaufine les transitions qui t’amènent vers " ++ hero.stats.favoritePosition ++ " et crée des réactions automatiques face aux défenses.") ]
        , ul [ class "space-y-2 text-gray-300 list-disc list-inside" ]
            (List.map (\item -> li [] [ text item ]) suggestions)
        ]


groupTechniquesByCategory : List Technique -> List ( TechniqueCategory, List Technique )
groupTechniquesByCategory techniques =
    List.foldl insertTechnique [] techniques
        |> List.map (\( category, techs ) -> ( category, List.reverse techs ))


insertTechnique : Technique -> List ( TechniqueCategory, List Technique ) -> List ( TechniqueCategory, List Technique )
insertTechnique technique groups =
    let
        ( matches, others ) =
            List.partition (\( category, _ ) -> category == technique.category) groups
    in
    case matches of
        ( _, existing ) :: _ ->
            ( technique.category, technique :: existing ) :: others

        [] ->
            ( technique.category, [ technique ] ) :: others


techniqueCategoryOrder : TechniqueCategory -> Int
techniqueCategoryOrder category =
    case category of
        GuardTechnique ->
            0

        PassingTechnique ->
            1

        TakedownTechnique ->
            2

        SubmissionTechnique ->
            3

        EscapeTechnique ->
            4

        SweepTechnique ->
            5


techniqueCategoryToString : TechniqueCategory -> String
techniqueCategoryToString category =
    case category of
        GuardTechnique ->
            "Progression de garde"

        PassingTechnique ->
            "Systèmes de passage"

        TakedownTechnique ->
            "Entrées debout"

        SubmissionTechnique ->
            "Chaînes de soumissions"

        EscapeTechnique ->
            "Sorties et défenses"

        SweepTechnique ->
            "Balayages & renversements"


difficultyToString : Difficulty -> String
difficultyToString difficulty =
    case difficulty of
        Beginner ->
            "Débutant"

        Intermediate ->
            "Intermédiaire"

        DifficultyAdvanced ->
            "Avancé"

        Expert ->
            "Expert"


masteryLevelToString : MasteryLevel -> String
masteryLevelToString mastery =
    case mastery of
        NotStarted ->
            "Non démarré"

        Learning ->
            "En apprentissage"

        Practicing ->
            "En pratique"

        Proficient ->
            "Compétent"

        Advanced ->
            "Avancé"

        Mastered ->
            "Maîtrisé"


videoTypeToString : VideoType -> String
videoTypeToString videoType =
    case videoType of
        Match ->
            "Combat"

        Instructional ->
            "Instruction"

        Interview ->
            "Interview"

        Highlight ->
            "Moments forts"


fightingStyleLabel : FightingStyle -> String
fightingStyleLabel style =
    case style of
        Guard ->
            "Stratégiste de garde"

        Passing ->
            "Passing en pression"

        LegLocks ->
            "Spécialiste des attaques de jambes"

        Wrestling ->
            "Hybride lutte"

        Balanced ->
            "Jeu complet"

        Submission ->
            "Chasseur de soumissions"

        Pressure ->
            "Maître de la pression"


formatPercentage : Float -> String
formatPercentage value =
    let
        rounded =
            roundFloat 1 value
    in
    String.fromFloat rounded ++ "%"


roundFloat : Int -> Float -> Float
roundFloat decimals value =
    let
        factor =
            10 ^ decimals
    in
    toFloat (round (value * toFloat factor)) / toFloat factor


viewNotFoundPage : Model -> Html Msg
viewNotFoundPage model =
    let
        t =
            model.userConfig.t
    in
    div [ class "container mx-auto px-4 py-16 text-center" ]
        [ span [ class "text-8xl mb-4 block" ] [ text "🤷" ]
        , h1 [ class "text-4xl font-bold mb-4 dark:text-white" ] [ text t.pageNotFound ]
        , p [ class "text-gray-600 dark:text-gray-400 mb-8" ]
            [ text t.notFoundDescription ]
        , button
            [ onPreventDefaultClick (NavigateTo Home)
            , class "px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg transition-colors"
            ]
            [ text t.goHome ]
        ]


viewModals : Model -> Html Msg
viewModals model =
    div [ class "relative z-modal" ]
        [ if model.modals.sessionModal then
            viewSessionModal model

          else
            text ""
        , if model.modals.techniqueSelectionModal then
            viewTechniqueSelectionModal model

          else
            text ""
        , case model.modals.heroDetailModal of
            Just heroId ->
                viewHeroQuickView model heroId

            Nothing ->
                text ""
        ]


viewSessionModal : Model -> Html Msg
viewSessionModal model =
    let
        t =
            model.userConfig.t
    in
    div [ class "fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-modal" ]
        [ div
            [ class "bg-gray-800 border border-gray-700 rounded-xl p-6 max-w-md w-full mx-4 shadow-2xl"
            , attribute "role" "dialog"
            , attribute "aria-modal" "true"
            , attribute "aria-labelledby" "session-modal-title"
            , onModalEscapeKeyDown CloseModal
            , tabindex 0
            ]
            [ h2 [ class "text-2xl font-bold mb-4 dark:text-white", id "session-modal-title" ] [ text t.logTrainingSession ]
            , p [ class "text-gray-600 dark:text-gray-400" ] [ text t.sessionLoggingSoon ]
            , button
                [ onClick CloseModal
                , class "mt-4 px-4 py-2 bg-gray-200 dark:bg-gray-700 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                , attribute "aria-label" t.close
                ]
                [ text t.close ]
            ]
        ]


viewTechniqueSelectionModal : Model -> Html Msg
viewTechniqueSelectionModal model =
    let
        language =
            model.userConfig.language

        masteryOptions =
            model.userProgress.techniqueMastery
                |> Dict.values
                |> List.sortBy .name
                |> List.map (\tech -> ( tech.techniqueId, tech.name ))

        techniqueOptions =
            if List.isEmpty masteryOptions then
                defaultTechniqueChoices

            else
                masteryOptions

        ( title_, subtitle, emptyLabel ) =
            case language of
                I18n.FR ->
                    ( "Choisis ta technique", "Sélectionne la prochaine technique à travailler.", "Aucune technique disponible pour le moment." )

                I18n.EN ->
                    ( "Pick your technique", "Select what you want to drill next.", "No techniques available yet." )

        techniqueListContent =
            if List.isEmpty techniqueOptions then
                [ div [ class "py-10 text-center text-sm text-slate-500 dark:text-slate-400" ]
                    [ text emptyLabel ]
                ]

            else
                List.map
                    (viewTechniqueChoice language model.techniquePreview model.trainingGoal)
                    techniqueOptions
    in
    div [ class "fixed inset-0 z-modal flex items-center justify-center bg-black/70 backdrop-blur-sm" ]
        [ div
            [ class "mx-4 w-full max-w-2xl rounded-2xl border border-slate-200 bg-white p-6 shadow-2xl dark:border-slate-800 dark:bg-slate-900"
            , attribute "role" "dialog"
            , attribute "aria-modal" "true"
            , onModalEscapeKeyDown CloseModal
            , tabindex 0
            ]
            [ div [ class "flex items-start justify-between gap-4" ]
                [ div []
                    [ h2 [ class "text-2xl font-semibold text-slate-900 dark:text-white" ] [ text title_ ]
                    , p [ class "text-sm text-slate-500 dark:text-slate-400" ] [ text subtitle ]
                    ]
                , button
                    [ onClick CloseModal
                    , class "sh-btn bg-slate-100 text-slate-600 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-300"
                    ]
                    [ text model.userConfig.t.close ]
                ]
            , div [ class "mt-6 flex flex-col gap-6 lg:flex-row" ]
                [ div [ class "max-h-[60vh] space-y-3 overflow-y-auto pr-1 lg:flex-1" ] techniqueListContent
                , div [ class "lg:w-96" ] [ viewTechniqueModalPreviewPanel model language ]
                ]
            ]
        ]


viewTechniqueChoice :
    I18n.Language
    -> Maybe String
    -> Maybe String
    -> ( String, String )
    -> Html Msg
viewTechniqueChoice language currentPreview currentGoal ( techniqueId, label ) =
    let
        entry =
            findTechniqueEntry techniqueId

        displayName =
            entry
                |> Maybe.map (\tech -> localizeText language tech.name)
                |> Maybe.withDefault label

        descriptionText =
            entry
                |> Maybe.map (\tech -> localizeText language tech.description)
                |> Maybe.withDefault ""

        isSelected =
            currentPreview == Just techniqueId

        isGoal =
            currentGoal == Just techniqueId

        labels =
            techniqueChoiceLabels language

        baseClasses =
            [ "rounded-2xl border p-4 text-left transition"
            , "bg-white/95 dark:bg-slate-900/80"
            , "border-slate-200 dark:border-slate-700"
            ]

        highlightClasses =
            if isSelected then
                "border-purple-400/60 ring-2 ring-purple-200/80 dark:border-purple-500/60 dark:ring-purple-500/30"

            else
                ""

        classes =
            case highlightClasses of
                "" ->
                    baseClasses

                _ ->
                    baseClasses ++ [ highlightClasses ]

        goalBadge =
            if isGoal then
                span [ class "rounded-full bg-purple-100 px-3 py-1 text-xs font-semibold text-purple-700 dark:bg-purple-500/20 dark:text-purple-200" ] [ text labels.goalBadge ]

            else
                text ""
    in
    div [ class (String.join " " classes) ]
        [ div [ class "flex items-start justify-between gap-3" ]
            [ div []
                [ span [ class "text-sm font-semibold text-slate-900 dark:text-white" ] [ text displayName ]
                , span [ class "text-xs uppercase tracking-[0.35em] text-slate-400" ] [ text techniqueId ]
                ]
            , goalBadge
            ]
        , if descriptionText == "" then
            text ""

          else
            p [ class "mt-2 text-xs text-slate-500 dark:text-slate-400 leading-relaxed" ] [ text descriptionText ]
        , div [ class "mt-4 flex flex-wrap gap-2" ]
            [ button
                [ onClick (PreviewTechnique techniqueId)
                , class "sh-btn flex-1 bg-slate-100 text-slate-700 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-200"
                ]
                [ text labels.preview ]
            , button
                [ onClick (SetTrainingGoal techniqueId)
                , class "sh-btn flex-1 bg-purple-600 text-white hover:bg-purple-500"
                ]
                [ text labels.setGoal ]
            , button
                [ onClick (SelectNode techniqueId)
                , class "sh-btn flex-1 bg-slate-900 text-white hover:bg-slate-800"
                ]
                [ text labels.selectNow ]
            ]
        ]


techniqueChoiceLabels :
    I18n.Language
    -> { preview : String, setGoal : String, selectNow : String, goalBadge : String }
techniqueChoiceLabels language =
    case language of
        I18n.FR ->
            { preview = "Aperçu"
            , setGoal = "Objectif"
            , selectNow = "Utiliser"
            , goalBadge = "Objectif"
            }

        I18n.EN ->
            { preview = "Preview"
            , setGoal = "Set goal"
            , selectNow = "Use now"
            , goalBadge = "Goal"
            }


defaultTechniqueChoices : List ( String, String )
defaultTechniqueChoices =
    [ ( "butterfly-guard", "Butterfly Guard" )
    , ( "spider-guard", "Spider Guard" )
    , ( "triangle-choke", "Triangle Choke" )
    , ( "armbar", "Armbar" )
    , ( "kimura", "Kimura" )
    , ( "torreando-pass", "Torreando Pass" )
    ]


allTechniqueEntries : List Data.TechniqueEntry
allTechniqueEntries =
    let
        groups =
            Data.finishingTechniqueGroups
                ++ Data.guardTechniqueGroups
                ++ Data.sweepTechniqueGroups
    in
    List.concatMap .entries groups


findTechniqueEntry : String -> Maybe Data.TechniqueEntry
findTechniqueEntry techniqueId =
    allTechniqueEntries
        |> List.filter (\entry -> entry.id == techniqueId)
        |> List.head


techniquePreviewEntry : Model -> Maybe Data.TechniqueEntry
techniquePreviewEntry model =
    model.techniquePreview |> Maybe.andThen findTechniqueEntry


viewHeroQuickView : Model -> String -> Html Msg
viewHeroQuickView model heroId =
    case Dict.get heroId model.heroes of
        Just hero ->
            div [ class "fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-modal" ]
                [ div
                    [ class "bg-gray-800 border border-gray-700 rounded-xl p-6 max-w-2xl w-full mx-4 max-h-[80vh] overflow-y-auto shadow-2xl"
                    , attribute "role" "dialog"
                    , attribute "aria-modal" "true"
                    , attribute "aria-labelledby" ("hero-modal-title-" ++ heroId)
                    , onModalEscapeKeyDown CloseModal
                    , tabindex 0
                    ]
                    [ h2 [ class "text-2xl font-bold mb-4 dark:text-white", id ("hero-modal-title-" ++ heroId) ] [ text hero.name ]
                    , p [ class "text-gray-600 dark:text-gray-400 mb-4" ] [ text hero.bio ]
                    , button
                        [ onClick CloseModal
                        , class "px-4 py-2 bg-gray-200 dark:bg-gray-700 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                        , attribute "aria-label" model.userConfig.t.close
                        ]
                        [ text model.userConfig.t.close ]
                    ]
                ]

        Nothing ->
            text ""



-- NEW HELPER FUNCTIONS FOR TRAINING DASHBOARD


viewLevelProgress : Model -> Html Msg
viewLevelProgress model =
    let
        progress =
            model.userProgress

        currentBelt =
            getBeltFromLevel progress.currentLevel

        nextBelt =
            getNextBelt currentBelt

        beltProgress =
            calculateBeltProgress progress.currentLevel

        beltProgressPercent =
            round beltProgress

        beltLabel =
            beltToString currentBelt

        nextLabel =
            beltToString nextBelt

        progressStyle =
            Attr.style "width" (String.fromFloat beltProgress ++ "%")
    in
    div [ class "progress-card" ]
        [ div [ class "progress-card__row" ]
            [ div []
                [ span [ class "progress-card__label" ] [ text beltLabel ]
                , span [ class "progress-card__caption" ] [ text (String.fromInt progress.totalXP ++ " XP") ]
                ]
            , span [ class "progress-card__value" ] [ text ("Lvl " ++ String.fromInt progress.currentLevel) ]
            ]
        , div [ class "progress-card__track" ]
            [ div [ class "progress-card__fill", progressStyle ] [] ]
        , span [ class "progress-card__next" ] [ text (String.fromInt beltProgressPercent ++ "% → " ++ nextLabel) ]
        ]


getBeltFromLevel : Int -> BeltLevel
getBeltFromLevel level =
    if level <= 20 then
        White

    else if level <= 40 then
        Blue

    else if level <= 65 then
        Purple

    else if level <= 85 then
        Brown

    else
        Black


getNextBelt : BeltLevel -> BeltLevel
getNextBelt current =
    case current of
        White ->
            Blue

        Blue ->
            Purple

        Purple ->
            Brown

        Brown ->
            Black

        Black ->
            Black


calculateBeltProgress : Int -> Float
calculateBeltProgress level =
    if level <= 20 then
        toFloat level / 20 * 100

    else if level <= 40 then
        toFloat (level - 20) / 20 * 100

    else if level <= 65 then
        toFloat (level - 40) / 25 * 100

    else if level <= 85 then
        toFloat (level - 65) / 20 * 100

    else
        100


getBeltColorClass : BeltLevel -> String
getBeltColorClass belt =
    case belt of
        White ->
            "bg-gray-100 text-gray-800"

        Blue ->
            "bg-blue-500 text-white"

        Purple ->
            "bg-purple-500 text-white"

        Brown ->
            "bg-amber-700 text-white"

        Black ->
            "bg-gray-900 text-white"


viewFooter : Model -> Html Msg
viewFooter model =
    let
        t =
            model.userConfig.t
    in
    footer [ class "bg-gray-900 text-white py-12 mt-20" ]
        [ div [ class "container mx-auto px-4" ]
            [ div [ class "grid grid-cols-1 md:grid-cols-4 gap-8 mb-8" ]
                [ div []
                    [ h3 [ class "text-xl font-bold mb-4" ] [ text "BJJ Heroes" ]
                    , p [ class "text-gray-400" ] [ text t.footerTagline ]
                    ]
                , div []
                    [ h4 [ class "font-bold mb-4" ] [ text t.footerExplore ]
                    , ul [ class "space-y-2" ]
                        [ footerLink t.heroes (NavigateTo (HeroesRoute Nothing))
                        , footerLink t.events (NavigateTo (Events AllEvents))
                        , footerLink t.training (NavigateTo Training)
                        ]
                    ]
                , div []
                    [ h4 [ class "font-bold mb-4" ] [ text t.footerResources ]
                    , ul [ class "space-y-2" ]
                        [ li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text t.footerTechniqueLibrary ] ]
                        , li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text t.footerTrainingTips ] ]
                        , li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text t.footerCompetitionRules ] ]
                        , li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text t.footerBlog ] ]
                        ]
                    ]
                , div []
                    [ h4 [ class "font-bold mb-4" ] [ text t.footerConnect ]
                    , div [ class "flex space-x-4" ]
                        [ span [ class "text-2xl cursor-pointer hover:text-blue-400 transition-colors" ] [ text "📘" ]
                        , span [ class "text-2xl cursor-pointer hover:text-blue-400 transition-colors" ] [ text "🐦" ]
                        , span [ class "text-2xl cursor-pointer hover:text-pink-400 transition-colors" ] [ text "📷" ]
                        , span [ class "text-2xl cursor-pointer hover:text-red-500 transition-colors" ] [ text "📺" ]
                        ]
                    ]
                ]
            , div [ class "border-t border-gray-800 pt-8 text-center text-gray-400" ]
                [ p [] [ text t.footerCopyright ]
                ]
            ]
        ]


footerLink : String -> Msg -> Html Msg
footerLink label msg =
    li []
        [ button
            [ onClick msg
            , class "text-gray-400 hover:text-white transition-colors"
            ]
            [ text label ]
        ]


stopPropagationOn : String -> Decode.Decoder ( msg, Bool ) -> Attribute msg
stopPropagationOn event decoder =
    Html.Events.stopPropagationOn event decoder
