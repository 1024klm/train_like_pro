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
import Pages.TrainingSession
import Router
import Router.Helpers exposing (onPreventDefaultClick)
import Set exposing (Set)
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
            , mobileMenuOpen = False
            , searchQuery = ""
            , activeFilters =
                { heroFilter = Nothing
                , academyLocation = Nothing
                , eventType = Nothing
                , dateRange = Nothing
                }
            , heroes = Data.initHeroes
            , academies = Data.initAcademies
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
                }
            , notifications = []
            , animations =
                { heroCards = False
                , pageTransition = False
                , scrollProgress = 0
                , xpAnimation = Nothing
                , levelUpAnimation = False
                }
            }
    in
    ( initialModel
    , Cmd.batch
        [ Lamdera.sendToBackend GetInitialData
        , Lamdera.sendToBackend (TrackPageView route)
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
            in
            ( { model | activeFilters = { filters | heroFilter = Just filter } }
            , Cmd.none
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
            , Cmd.none
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

                        AcademyFavorite ->
                            { favorites | academies = toggleSet id favorites.academies }

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
                            { modals | sessionModal = True }

                -- Using sessionModal for now
            in
            ( { model | modals = newModals }, Cmd.none )

        CloseModal ->
            ( { model
                | modals =
                    { sessionModal = False
                    , heroDetailModal = Nothing
                    , shareModal = Nothing
                    , filterModal = False
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

        AnimationTick _ ->
            let
                animations =
                    model.animations
            in
            ( { model | animations = { animations | scrollProgress = animations.scrollProgress + 0.01 } }
            , Cmd.none
            )

        StartSession ->
            let
                newSession =
                    { startTime = Time.millisToPosix 0  -- Will be set properly by backend
                    , currentTechnique = Nothing
                    , techniques = []
                    , totalXP = 0
                    , notes = ""
                    }
            in
            ( { model | activeSession = Just newSession, sessionTimer = 0 }
            , Router.navigateTo model.key TrainingView
            )

        EndSession ->
            case model.activeSession of
                Just session ->
                    let
                        finalSession =
                            { id = "session-" ++ String.fromInt model.sessionTimer  -- Temporary ID
                            , date = session.startTime
                            , planId = Nothing
                            , duration = model.sessionTimer // 60  -- Convert seconds to minutes
                            , techniques = session.techniques
                            , notes = session.notes
                            , sessionType = TechniqueSession  -- Default session type
                            , rating = Nothing
                            , completed = True
                            , xpEarned = session.totalXP
                            , mood = Good  -- Default mood
                            , energy = Normal  -- Default energy
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

        SelectNode techniqueId ->
            case model.activeSession of
                Just session ->
                    ( { model | activeSession = Just { session | currentTechnique = Just techniqueId } }
                    , Cmd.none
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
                                    , xpEarned = 1 * 3 * 5  -- reps * quality * base_xp
                                    } :: session.techniques

                                existingTech :: _ ->
                                    -- Update existing
                                    List.map (\t ->
                                        if t.techniqueId == techniqueId then
                                            let
                                                newReps = t.repetitions + 1
                                                newXP = newReps * t.quality * 5  -- reps * quality * base_xp
                                            in
                                            { t | repetitions = newReps, xpEarned = newXP }
                                        else
                                            t
                                    ) session.techniques

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
                            List.map (\t ->
                                if t.techniqueId == techniqueId && t.repetitions > 0 then
                                    let
                                        newReps = t.repetitions - 1
                                        newXP = newReps * t.quality * 5  -- reps * quality * base_xp
                                    in
                                    { t | repetitions = newReps, xpEarned = newXP }
                                else
                                    t
                            ) session.techniques

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
                            List.map (\t ->
                                if t.techniqueId == techniqueId then
                                    let
                                        newXP = t.repetitions * quality * 5  -- reps * quality * base_xp
                                    in
                                    { t | quality = quality, xpEarned = newXP }
                                else
                                    t
                            ) session.techniques

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
    Task.perform (\_ -> NoOpFrontendMsg) (Task.succeed ())


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        InitialDataReceived data ->
            ( { model
                | heroes = data.heroes
                , academies = data.academies
                , events = data.events
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
        , if model.animations.pageTransition then
            Time.every 16 AnimationTick

          else
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
            "Heroes - BJJ Heroes"

        HeroDetail id ->
            Dict.get id model.heroes
                |> Maybe.map .name
                |> Maybe.withDefault "Hero"
                |> (\name -> name ++ " - BJJ Heroes")

        Academies _ ->
            "Academies - BJJ Heroes"

        AcademyDetail id ->
            Dict.get id model.academies
                |> Maybe.map .name
                |> Maybe.withDefault "Academy"
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
            , p [ class "text-xs text-gray-500 dark:text-gray-400" ] [ text "Train Like Champions" ]
            ]
        ]


viewDesktopNav : Model -> Html Msg
viewDesktopNav model =
    nav [ class "hidden lg:flex items-center space-x-4" ]
        [ navLink model Home "Home" "🏠"
        , navLink model Dashboard "Dashboard" "📊"
        , navLink model (HeroesRoute Nothing) "Heroes" "🥋"
        , navLink model (Academies Nothing) "Academies" "🏛️"
        , navLink model (Events AllEvents) "Events" "📅"
        , navLink model TrainingView "Training" "💪"
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

                ( Academies _, Academies _ ) ->
                    True

                ( AcademyDetail _, Academies _ ) ->
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
    div [ class "relative" ]
        [ input
            [ type_ "search"
            , placeholder "Search heroes, academies..."
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
    div [ class "lg:hidden absolute top-full left-0 right-0 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 shadow-lg" ]
        [ div [ class "p-4 space-y-2" ]
            [ mobileNavLink (NavigateTo Home) "Home" "🏠"
            , mobileNavLink (NavigateTo (HeroesRoute Nothing)) "Heroes" "🥋"
            , mobileNavLink (NavigateTo (Academies Nothing)) "Academies" "🏛️"
            , mobileNavLink (NavigateTo (Events AllEvents)) "Events" "📅"
            , mobileNavLink (NavigateTo Training) "Training" "💪"
            , mobileNavLink (NavigateTo Profile) "Profile" "👤"
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
            viewHeroesPage model filter

        HeroDetail id ->
            viewHeroDetailPage model id

        Academies location ->
            viewAcademiesPage model location

        AcademyDetail id ->
            viewAcademyDetailPage model id

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
                [ span [ class "hero-stat-number" ] [ text value ]
                , span [ class "hero-stat-label" ] [ text label ]
                ]
    in
    section [ class "min-h-[70vh] flex items-center bg-white dark:bg-gray-900" ]
        [ div [ class "hero-bg" ] []
        , div [ class "container-wide" ]
            [ div [ class "hero-content" ]
                [ div [ class "hero-inner text-center lg:text-left" ]
                    [ div [ class "hero-badge" ]
                        [ span [ class "badge-dot" ] []
                        , span [] [ text "Programme d'entraînement élite" ]
                        ]
                    , h1 [ class "hero-title" ]
                        [ text "Libère ton jiu-jitsu"
                        , br [] []
                        , text "avec un plan "
                        , span [ class "text-gradient" ] [ text "prêt à l'emploi" ]
                        ]
                    , p [ class "hero-subtitle" ]
                        [ text "Suivi des séances, tableaux de bord intuitifs et routines inspirées des champions pour rester constant sur le tatami." ]
                    , div [ class "hero-actions" ]
                        [ button
                            [ onClick StartSession
                            , class "btn btn-primary px-10 py-4 text-lg"
                            ]
                            [ text t.startSession ]
                        , button
                            [ onPreventDefaultClick (NavigateTo TrainingView)
                            , class "btn btn-secondary px-8 py-4"
                            ]
                            [ text t.training ]
                        ]
                    , div [ class "hero-stats" ] (List.map heroStat heroStats)
                    ]
                ]
            ]
        ]


viewFighterStylePaths : Model -> Html Msg
viewFighterStylePaths model =
    let
        t =
            model.userConfig.t
    in
    section [ class "section-stack" ]
        [ div [ class "section-header" ]
            [ div [ class "section-header__copy" ]
                [ span [ class "chip chip--outline" ] [ text t.chooseYourPath ]
                , h2 [ class "section-title" ] [ text t.featuredHeroes ]
                , p [ class "section-subtitle" ] [ text t.learnFromLegends ]
                ]
            , button
                [ onPreventDefaultClick (NavigateTo (HeroesRoute Nothing))
                , class "btn btn-secondary"
                ]
                [ text t.viewAllFighters ]
            ]
        , div [ class "path-grid" ]
            [ fighterPathCard model.userConfig.language "Gordon Ryan" "Champion" "Leg locks & back pressure" "gordon-ryan" True 28
            , fighterPathCard model.userConfig.language "Mikey Galvao" "Prodige" "Dynamic inverted entries" "mikey-galvao" False 24
            , fighterPathCard model.userConfig.language "Craig Jones" "Technicien" "Front headlock to legs" "craig-jones" False 20
            , fighterPathCard model.userConfig.language "Marcelo Garcia" "Légende" "Butterfly tempo work" "marcelo-garcia" False 32
            , fighterPathCard model.userConfig.language "Roger Gracie" "Fondamentaux" "Pressure passing blueprint" "roger-gracie" False 16
            , fighterPathCard model.userConfig.language "Leandro Lo" "Flow" "Grip chains & torreando" "leandro-lo" False 24
            ]
        ]


fighterPathCard : I18n.Language -> String -> String -> String -> String -> Bool -> Int -> Html Msg
fighterPathCard language name title specialty slug isActive weeks =
    let
        route =
            StylePath slug

        href_ =
            Router.toPath route

        badgeText =
            if isActive then
                Just <|
                    case language of
                        I18n.FR ->
                            "En cours"

                        I18n.EN ->
                            "Active"

            else
                Nothing

        ctaLabel =
            case language of
                I18n.FR ->
                    if isActive then
                        "Poursuivre"

                    else
                        "Découvrir"

                I18n.EN ->
                    if isActive then
                        "Continue"

                    else
                        "Explore"

        weeksLabel =
            case language of
                I18n.FR ->
                    "semaines"

                I18n.EN ->
                    "weeks"
    in
    a
        [ href href_
        , onPreventDefaultClick (NavigateTo route)
        , class "card path-card"
        ]
        [ case badgeText of
            Just label ->
                span [ class "path-card__badge" ] [ text label ]

            Nothing ->
                text ""
        , div [ class "path-card__body" ]
            [ span [ class "path-card__legend" ] [ text title ]
            , h4 [ class "path-card__title" ] [ text name ]
            , p [ class "path-card__description" ] [ text specialty ]
            ]
        , div [ class "path-card__footer" ]
            [ span [ class "path-card__meta" ] [ text (String.fromInt weeks ++ " " ++ weeksLabel) ]
            , span [ class "path-card__cta" ] [ text ctaLabel ]
            ]
        ]


techniqueCheckItem : String -> String -> Bool -> Int -> Html Msg
techniqueCheckItem name system completed xp =
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
            if completed then
                "✓"

            else
                "+"
    in
    div [ class "plan-item" ]
        [ button
            [ onClick (ShowNotification Success ("+" ++ String.fromInt xp ++ " XP"))
            , class checkboxClass
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

        ( title, subtitle, buttonLabel ) =
            case model.userConfig.language of
                I18n.FR ->
                    ( "Plan d'entrainement", "Structure ta repetition et reste attentif aux details.", "Voir la session" )

                I18n.EN ->
                    ( "Training focus", "Structure your repetition work and stay tuned to details.", "Open session" )

        dateLabel =
            I18n.formatFullDate model.userConfig.language (Time.millisToPosix 1731366000000)
    in
    section [ class "card plan-card" ]
        [ div [ class "plan-card__header" ]
            [ div [ class "plan-card__titles" ]
                [ span [ class "chip chip--outline" ] [ text t.todaysTraining ]
                , h3 [ class "plan-card__title" ] [ text title ]
                , p [ class "plan-card__subtitle" ] [ text subtitle ]
                ]
            , span [ class "plan-card__date" ] [ text dateLabel ]
            ]
        , div [ class "plan-list" ]
            [ techniqueCheckItem "Heel Hook" "Gordon Ryan" False 50
            , techniqueCheckItem "Back take from leg entanglement" "Gordon Ryan" False 75
            , techniqueCheckItem "RNC finish details" "Gordon Ryan" True 100
            ]
        , div [ class "plan-card__footer" ]
            [ span [ class "plan-card__progress" ] [ text "Session progress: 1/3" ]
            , button
                [ onPreventDefaultClick (NavigateTo TrainingView)
                , class "btn btn-outline"
                ]
                [ text buttonLabel ]
            ]
        ]


viewProgressStats : Model -> Html Msg
viewProgressStats model =
    let
        language =
            model.userConfig.language

        t =
            model.userConfig.t

        descriptor =
            case language of
                I18n.FR ->
                    "Garde une vue claire sur ton volume, ton XP et ta constance."

                I18n.EN ->
                    "Keep a clear pulse on volume, XP, and consistency."

        streakSuffix =
            case language of
                I18n.FR ->
                    " jours"

                I18n.EN ->
                    " days"

        beltLabel =
            case language of
                I18n.FR ->
                    "Progression ceinture"

                I18n.EN ->
                    "Belt progress"
    in
    section [ class "card stats-card" ]
        [ div [ class "section-header section-header--compact" ]
            [ div [ class "section-header__copy" ]
                [ span [ class "chip chip--outline" ] [ text t.progress ]
                , h3 [ class "section-title" ] [ text "Momentum overview" ]
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
        description =
            case model.userConfig.language of
                I18n.FR ->
                    "Visualise tes objectifs de la semaine et valide-les un par un."

                I18n.EN ->
                    "Map this week's targets and tick them off with intention."

        buttonLabel =
            case model.userConfig.language of
                I18n.FR ->
                    "Ajuster"

                I18n.EN ->
                    "Adjust"

        bonusText =
            case model.userConfig.language of
                I18n.FR ->
                    " bonus si tous les objectifs sont realises cette semaine."

                I18n.EN ->
                    " bonus if every goal is completed this week."
    in
    section [ class "card goals-card" ]
        [ div [ class "goals-card__header" ]
            [ h3 [ class "goals-card__title" ] [ text model.userConfig.t.weeklyGoal ]
            , button
                [ onClick (ShowNotification Info "Goal customization coming soon!")
                , class "btn btn-outline"
                ]
                [ text buttonLabel ]
            ]
        , p [ class "goals-card__description" ] [ text description ]
        , div [ class "goals-list" ]
            [ weeklyGoalItem "Complete 5 training sessions" 3 5
            , weeklyGoalItem "Master 3 new techniques" 1 3
            , weeklyGoalItem "Log 300 minutes of mat time" 180 300
            , weeklyGoalItem "Review 10 competition videos" 6 10
            ]
        , div [ class "goals-card__bonus" ]
            [ span [ class "goals-card__bonus-xp" ] [ text "+500 XP" ]
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


viewHeroesPage : Model -> Maybe HeroFilter -> Html Msg
viewHeroesPage model filter =
    let
        heroesList =
            model.heroes
                |> Dict.values
                |> filterHeroes filter
                |> List.sortBy .name
    in
    div [ class "page-stack" ]
        [ div [ class "card page-intro" ]
            [ span [ class "chip chip--outline" ] [ text model.userConfig.t.heroes ]
            , h1 [ class "page-intro__title" ] [ text model.userConfig.t.heroes ]
            , p [ class "page-intro__subtitle" ] [ text model.userConfig.t.learnFromLegends ]
            ]
        , viewHeroFilters model filter
        , Keyed.node "div"
            [ class "card-grid" ]
            (heroesList |> List.map (\h -> ( h.id, viewHeroCard model h )))
        ]


viewHeroFilters : Model -> Maybe HeroFilter -> Html Msg
viewHeroFilters model currentFilter =
    div [ class "filter-row" ]
        [ filterButton "All" (currentFilter == Nothing || currentFilter == Just AllHeroes) (ApplyFilter AllHeroes)
        , filterButton "Super Heavy" (currentFilter == Just (ByWeight SuperHeavy)) (ApplyFilter (ByWeight SuperHeavy))
        , filterButton "Leg Locks" (currentFilter == Just (ByStyle LegLocks)) (ApplyFilter (ByStyle LegLocks))
        , filterButton "Guard" (currentFilter == Just (ByStyle Guard)) (ApplyFilter (ByStyle Guard))
        , filterButton "Passing" (currentFilter == Just (ByStyle Passing)) (ApplyFilter (ByStyle Passing))
        ]


filterHeroes : Maybe HeroFilter -> List Hero -> List Hero
filterHeroes maybeFilter heroes =
    case maybeFilter of
        Nothing ->
            heroes

        Just AllHeroes ->
            heroes

        Just (ByWeight weight) ->
            List.filter (\h -> h.weight == weight) heroes

        Just (ByStyle style) ->
            List.filter (\h -> h.style == style) heroes

        Just (ByNationality nationality) ->
            List.filter (\h -> h.nationality == nationality) heroes


filterButton : String -> Bool -> Msg -> Html Msg
filterButton label isActive msg =
    button
        [ onClick msg
        , classList
            [ ( "filter-pill filter-pill--active", isActive )
            , ( "filter-pill", not isActive )
            ]
        ]
        [ text label ]


viewAcademiesPage : Model -> Maybe String -> Html Msg
viewAcademiesPage model location =
    let
        academiesList =
            model.academies
                |> Dict.values
                |> List.sortBy .name
    in
    div [ class "page-stack" ]
        [ div [ class "card page-intro" ]
            [ span [ class "chip chip--outline" ] [ text model.userConfig.t.academies ]
            , h1 [ class "page-intro__title" ] [ text model.userConfig.t.academies ]
            , p [ class "page-intro__subtitle" ] [ text model.userConfig.t.topAcademies ]
            ]
        , Keyed.node "div"
            [ class "card-grid" ]
            (academiesList |> List.map (\a -> ( a.id, viewAcademyListCard model a )))
        ]


viewAcademyListCard : Model -> Academy -> Html Msg
viewAcademyListCard model academy =
    div
        [ onPreventDefaultClick (NavigateTo (AcademyDetail academy.id))
        , class "card list-card list-card--interactive"
        ]
        [ div [ class "list-card__header" ]
            [ h3 [ class "list-card__title" ] [ text academy.name ]
            , span [ class "list-card__meta" ] [ text academy.headCoach ]
            ]
        , span [ class "list-card__location" ] [ text (academy.location.city ++ ", " ++ academy.location.country) ]
        , p [ class "list-card__description" ] [ text academy.description ]
        , span [ class "list-card__link" ] [ text model.userConfig.t.viewDetails ]
        ]


viewEventCard : Event -> Html Msg
viewEventCard event =
    div [ class "card info-card" ]
        [ span [ class "info-card__icon" ] [ text "🏆" ]
        , h4 [ class "info-card__title" ] [ text event.name ]
        , span [ class "info-card__meta" ] [ text event.date ]
        , span [ class "info-card__meta" ] [ text (event.location.city ++ ", " ++ event.location.country) ]
        ]


viewAcademyDetailPage : Model -> String -> Html Msg
viewAcademyDetailPage model academyId =
    case Dict.get academyId model.academies of
        Just academy ->
            div [ class "container mx-auto px-4 py-8" ]
                [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text academy.name ]
                , div [ class "grid grid-cols-1 lg:grid-cols-3 gap-8" ]
                    [ div [ class "lg:col-span-2" ]
                        [ viewAcademyInfo academy
                        , viewAcademyPrograms academy
                        ]
                    , div []
                        [ viewAcademySchedule academy
                        , viewAcademyMembers academy
                        ]
                    ]
                ]

        Nothing ->
            div [ class "container mx-auto px-4 py-8" ]
                [ p [ class "text-center text-gray-500" ] [ text "Academy not found" ] ]


viewAcademyInfo : Academy -> Html Msg
viewAcademyInfo academy =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "About" ]
        , p [ class "text-gray-600 dark:text-gray-300 mb-4" ] [ text academy.description ]
        , div [ class "space-y-2" ]
            [ infoRow "Head Coach" academy.headCoach
            , infoRow "Established" (String.fromInt academy.established)
            , infoRow "Location" (academy.location.city ++ ", " ++ academy.location.country)
            , infoRow "Address" academy.location.address
            ]
        ]


infoRow : String -> String -> Html Msg
infoRow label value =
    div [ class "flex" ]
        [ span [ class "font-medium text-gray-700 dark:text-gray-300 w-32" ] [ text (label ++ ":") ]
        , span [ class "text-gray-600 dark:text-gray-400" ] [ text value ]
        ]


viewAcademyPrograms : Academy -> Html Msg
viewAcademyPrograms academy =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Programs" ]
        , div [ class "space-y-4" ]
            (List.map viewProgram academy.programs)
        ]


viewProgram : Types.Program -> Html Msg
viewProgram program =
    div [ class "border-l-4 border-blue-500 pl-4" ]
        [ h3 [ class "font-bold dark:text-white" ] [ text program.name ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text program.description ]
        , div [ class "flex items-center space-x-4 mt-2" ]
            [ span [ class "text-sm text-gray-500" ] [ text ("Duration: " ++ program.duration) ]
            , case program.price of
                Just price ->
                    span [ class "text-sm font-medium text-green-600" ] [ text ("$" ++ String.fromFloat price ++ "/month") ]

                Nothing ->
                    text ""
            ]
        ]


viewAcademySchedule : Academy -> Html Msg
viewAcademySchedule academy =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Schedule" ]
        , div [ class "space-y-3" ]
            (List.map viewClassSchedule academy.schedule)
        ]


viewClassSchedule : ClassSchedule -> Html Msg
viewClassSchedule schedule =
    div [ class "border-b border-gray-200 dark:border-gray-700 pb-2" ]
        [ div [ class "flex justify-between items-start" ]
            [ div []
                [ p [ class "font-medium dark:text-white" ] [ text schedule.className ]
                , p [ class "text-sm text-gray-500" ] [ text schedule.instructor ]
                ]
            , div [ class "text-right" ]
                [ p [ class "text-sm font-medium dark:text-white" ] [ text (dayToString schedule.dayOfWeek) ]
                , p [ class "text-sm text-gray-500" ] [ text schedule.time ]
                ]
            ]
        ]


dayToString : DayOfWeek -> String
dayToString day =
    case day of
        Monday ->
            "Monday"

        Tuesday ->
            "Tuesday"

        Wednesday ->
            "Wednesday"

        Thursday ->
            "Thursday"

        Friday ->
            "Friday"

        Saturday ->
            "Saturday"

        Sunday ->
            "Sunday"


viewAcademyMembers : Academy -> Html Msg
viewAcademyMembers academy =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Notable Members" ]
        , div [ class "space-y-2" ]
            (List.map
                (\member ->
                    div [ class "flex items-center space-x-2" ]
                        [ span [ class "text-lg" ] [ text "🥋" ]
                        , span [ class "dark:text-white" ] [ text member ]
                        ]
                )
                academy.notableMembers
            )
        ]


viewEventsPage : Model -> EventsFilter -> Html Msg
viewEventsPage model filter =
    let
        eventsList =
            model.events
                |> Dict.values
                |> filterEvents filter
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
            [ class "card-grid" ]
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

        statusClass =
            eventStatusClass event.status

        ctaLabel =
            case ( event.registrationUrl, event.streamUrl ) of
                ( Just _, _ ) ->
                    "Register"

                ( Nothing, Just _ ) ->
                    "Watch"

                _ ->
                    "Details"
    in
    div
        [ onPreventDefaultClick (NavigateTo (EventDetail event.id))
        , class "card list-card list-card--interactive p-5 text-center"
        ]
        [ div [ class "list-card__header" ]
            [ h3 [ class "list-card__title" ] [ text event.name ]
            , span [ class statusClass ] [ text (eventStatusText event.status) ]
            ]
        , div [ class "space-y-1" ]
            [ span [ class "list-card__meta" ] [ text (typeIcon ++ " " ++ eventTypeToString event.type_) ]
            , span [ class "list-card__meta" ] [ text event.date ]
            , span [ class "list-card__location" ] [ text (event.location.city ++ ", " ++ event.location.country) ]
            ]
        , div [ class "list-card__footer" ]
            [ button
                [ onClick (ToggleFavorite EventFavorite event.id)
                , Html.Events.stopPropagationOn "click" (Decode.succeed ( NoOpFrontendMsg, True ))
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


viewHeroCard : Model -> Hero -> Html Msg
viewHeroCard model hero =
    let
        t =
            model.userConfig.t

        isFavorite =
            Set.member hero.id model.favorites.heroes

        recordLabel =
            String.fromInt hero.record.wins ++ " - " ++ String.fromInt hero.record.losses

        weightLabel =
            weightClassToString hero.weight

        detailLabel =
            t.viewDetails

        favoriteLabel =
            if isFavorite then
                t.favorited

            else
                t.addToFavorites
    in
    div
        [ onClick (SelectHero hero.id)
        , class "card hero-tile"
        ]
        [ div [ class "hero-tile__header" ]
            [ span [ class "hero-tile__badge" ] [ text weightLabel ]
            , button
                [ onClick (ToggleFavorite HeroFavorite hero.id)
                , Html.Events.stopPropagationOn "click" (Decode.succeed ( NoOpFrontendMsg, True ))
                , classList
                    [ ( "hero-tile__favorite hero-tile__favorite--active", isFavorite )
                    , ( "hero-tile__favorite", not isFavorite )
                    ]
                ]
                [ span []
                    [ text
                        (if isFavorite then
                            "❤️"

                         else
                            "♡"
                        )
                    ]
                , span [ class "hero-tile__favorite-label" ] [ text favoriteLabel ]
                ]
            ]
        , h4 [ class "hero-tile__title" ] [ text hero.name ]
        , p [ class "hero-tile__subtitle" ] [ text hero.nickname ]
        , p [ class "hero-tile__description" ] [ text hero.bio ]
        , div [ class "hero-tile__footer" ]
            [ span [ class "hero-tile__meta" ] [ text (hero.nationality ++ " · " ++ recordLabel) ]
            , span [ class "hero-tile__cta" ] [ text detailLabel ]
            ]
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


viewHeroDetailPage : Model -> String -> Html Msg
viewHeroDetailPage model heroId =
    case Dict.get heroId model.heroes of
        Just hero ->
            div [ class "space-y-6" ]
                [ viewHeroHeader hero model
                , viewHeroContent hero model
                ]

        Nothing ->
            div [ class "p-8 text-center" ]
                [ p [ class "text-gray-400" ] [ text "Hero not found" ] ]


viewHeroHeader : Hero -> Model -> Html Msg
viewHeroHeader hero model =
    div [ class "relative h-96 bg-gradient-to-br from-red-600 to-red-800" ]
        [ div [ class "absolute inset-0 bg-black/40" ] []
        , div [ class "container mx-auto px-4 h-full flex items-end pb-8" ]
            [ div [ class "text-white" ]
                [ h1 [ class "text-5xl font-bold mb-2" ] [ text hero.name ]
                , p [ class "text-2xl mb-4 opacity-90" ] [ text hero.nickname ]
                , div [ class "flex items-center space-x-4" ]
                    [ span [ class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg" ]
                        [ text hero.team ]
                    , span [ class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg" ]
                        [ text (weightClassToString hero.weight) ]
                    , button
                        [ onClick (ToggleFavorite HeroFavorite hero.id)
                        , class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg hover:bg-white/30 transition-colors"
                        ]
                        [ text
                            (if Set.member hero.id model.favorites.heroes then
                                "❤️ Favorited"

                             else
                                "🤍 Add to Favorites"
                            )
                        ]
                    ]
                ]
            ]
        ]


viewHeroContent : Hero -> Model -> Html Msg
viewHeroContent hero model =
    div [ class "space-y-6 lg:space-y-0" ]
        [ div [ class "grid grid-cols-1 lg:grid-cols-3 gap-4 lg:gap-6" ]
            [ div [ class "lg:col-span-2 space-y-8" ]
                [ viewHeroBio hero
                , viewHeroRecord hero
                , viewHeroTechniques hero
                , viewHeroVideos hero
                ]
            , div [ class "space-y-8" ]
                [ viewHeroStats hero
                , viewHeroSocial hero
                , viewHeroAchievements hero
                ]
            ]
        ]


viewHeroBio : Hero -> Html Msg
viewHeroBio hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Biography" ]
        , p [ class "text-gray-600 dark:text-gray-300 leading-relaxed" ] [ text hero.bio ]
        ]


viewHeroRecord : Hero -> Html Msg
viewHeroRecord hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Competition Record" ]
        , div [ class "grid grid-cols-3 gap-4 mb-6" ]
            [ recordStat "Wins" (String.fromInt hero.record.wins) "text-green-600"
            , recordStat "Losses" (String.fromInt hero.record.losses) "text-red-600"
            , recordStat "Draws" (String.fromInt hero.record.draws) "text-gray-600"
            ]
        , div [ class "space-y-2" ]
            (List.map
                (\title ->
                    div [ class "flex items-center space-x-2" ]
                        [ span [ class "text-xl" ] [ text "🏆" ]
                        , span [ class "text-gray-700 dark:text-gray-300" ] [ text title ]
                        ]
                )
                hero.record.titles
            )
        ]


recordStat : String -> String -> String -> Html Msg
recordStat label value colorClass =
    div [ class "text-center" ]
        [ p [ class ("text-3xl font-bold " ++ colorClass) ] [ text value ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
        ]


viewHeroTechniques : Hero -> Html Msg
viewHeroTechniques hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Signature Techniques" ]
        , Keyed.node "div"
            [ class "space-y-4" ]
            (hero.techniques |> List.sortBy .name |> List.map (\t -> ( t.id, viewTechnique t )))
        ]


viewTechnique : Technique -> Html Msg
viewTechnique technique =
    div [ class "border-l-4 border-red-500 pl-4" ]
        [ h3 [ class "font-bold dark:text-white" ] [ text technique.name ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text technique.description ]
        ]


viewHeroVideos : Hero -> Html Msg
viewHeroVideos hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Videos" ]
        , Keyed.node "div"
            [ class "grid grid-cols-1 md:grid-cols-2 gap-4" ]
            (hero.videos |> List.sortBy .date |> List.map (\v -> ( v.id, viewVideoCard v )))
        ]


viewVideoCard : Video -> Html Msg
viewVideoCard video =
    div [ class "bg-gray-700/50 backdrop-blur-sm rounded-lg p-4 hover:shadow-md transition-all cursor-pointer border border-gray-600/30 hover:border-blue-500/50" ]
        [ h3 [ class "font-medium dark:text-white mb-2" ] [ text video.title ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text video.date ]
        ]


viewHeroStats : Hero -> Html Msg
viewHeroStats hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Statistics" ]
        , div [ class "space-y-3" ]
            [ statRow "Win Rate" (String.fromFloat hero.stats.winRate ++ "%")
            , statRow "Submission Rate" (String.fromFloat hero.stats.submissionRate ++ "%")
            , statRow "Avg Match Time" (String.fromFloat hero.stats.averageMatchTime ++ " min")
            , statRow "Favorite Position" hero.stats.favoritePosition
            , statRow "Favorite Submission" hero.stats.favoriteSubmission
            ]
        ]


statRow : String -> String -> Html Msg
statRow label value =
    div [ class "flex justify-between" ]
        [ span [ class "text-gray-600 dark:text-gray-400" ] [ text label ]
        , span [ class "font-medium dark:text-white" ] [ text value ]
        ]


viewHeroSocial : Hero -> Html Msg
viewHeroSocial hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Social Media" ]
        , div [ class "space-y-3" ]
            [ case hero.socialMedia.instagram of
                Just handle ->
                    socialLink "Instagram" handle "📷"

                Nothing ->
                    text ""
            , case hero.socialMedia.youtube of
                Just channel ->
                    socialLink "YouTube" channel "📺"

                Nothing ->
                    text ""
            , case hero.socialMedia.website of
                Just url ->
                    socialLink "Website" url "🌐"

                Nothing ->
                    text ""
            ]
        ]


socialLink : String -> String -> String -> Html Msg
socialLink platform handle icon =
    div [ class "flex items-center space-x-3 hover:bg-gray-100 dark:hover:bg-gray-700 p-2 rounded-lg cursor-pointer" ]
        [ span [ class "text-xl" ] [ text icon ]
        , div [ class "flex-1" ]
            [ p [ class "font-medium dark:text-white" ] [ text platform ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text handle ]
            ]
        ]


viewHeroAchievements : Hero -> Html Msg
viewHeroAchievements hero =
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Achievements" ]
        , div [ class "space-y-3" ]
            (List.map viewAchievement hero.achievements)
        ]


viewAchievement : Achievement -> Html Msg
viewAchievement achievement =
    div [ class "flex items-center space-x-3" ]
        [ span [ class "text-2xl" ] [ text achievement.icon ]
        , div [ class "flex-1" ]
            [ p [ class "font-medium dark:text-white" ] [ text achievement.name ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text achievement.description ]
            ]
        ]


pageIntro : String -> String -> Html Msg
pageIntro title subtitle =
    div [ class "surface-card p-6 space-y-2" ]
        [ h1 [ class "text-3xl font-semibold text-slate-900 dark:text-white" ] [ text title ]
        , p [ class "text-gray-500 dark:text-gray-400" ] [ text subtitle ]
        ]


filterEvents : EventsFilter -> List Event -> List Event
filterEvents filter events =
    case filter of
        AllEvents ->
            events

        UpcomingEvents ->
            List.filter (\e -> e.status == EventUpcoming || e.status == EventLive) events

        PastEvents ->
            List.filter (\e -> e.status == EventCompleted) events


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


eventStatusText : EventStatus -> String
eventStatusText status =
    case status of
        EventUpcoming ->
            "Upcoming"

        EventLive ->
            "LIVE"

        EventCompleted ->
            "Completed"

        EventCancelled ->
            "Cancelled"


viewEventDetailPage : Model -> String -> Html Msg
viewEventDetailPage model eventId =
    case Dict.get eventId model.events of
        Just event ->
            div [ class "container mx-auto px-4 py-8" ]
                [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text event.name ]
                , div [ class "grid grid-cols-1 lg:grid-cols-3 gap-8" ]
                    [ div [ class "lg:col-span-2" ]
                        [ viewEventInfo event
                        , viewEventBrackets event
                        ]
                    , div []
                        [ viewEventDetails event
                        , viewEventLinks event
                        ]
                    ]
                ]

        Nothing ->
            div [ class "container mx-auto px-4 py-8" ]
                [ p [ class "text-center text-gray-500" ] [ text "Event not found" ] ]


viewEventInfo : Event -> Html Msg
viewEventInfo event =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Event Information" ]
        , p [ class "text-gray-600 dark:text-gray-300 mb-4" ] [ text event.description ]
        , div [ class "space-y-2" ]
            [ infoRow "Date" event.date
            , infoRow "Location" (event.location.city ++ ", " ++ event.location.country)
            , infoRow "Venue" event.location.address
            , infoRow "Organization" event.organization
            , infoRow "Status" (eventStatusText event.status)
            ]
        ]


viewEventBrackets : Event -> Html Msg
viewEventBrackets event =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Brackets" ]
        , div [ class "space-y-4" ]
            (List.map viewBracket event.brackets)
        ]


viewBracket : Bracket -> Html Msg
viewBracket bracket =
    div [ class "border-l-4 border-green-500 pl-4" ]
        [ h3 [ class "font-bold dark:text-white" ]
            [ text (bracket.division ++ " - " ++ weightClassToString bracket.weightClass) ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
            [ text (beltToString bracket.belt ++ " Belt") ]
        , div [ class "mt-2 flex flex-wrap gap-2" ]
            (List.map
                (\comp ->
                    span [ class "px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded text-sm" ] [ text comp ]
                )
                bracket.competitors
            )
        ]


beltToString : BeltLevel -> String
beltToString belt =
    case belt of
        White ->
            "White"

        Blue ->
            "Blue"

        Purple ->
            "Purple"

        Brown ->
            "Brown"

        Black ->
            "Black"


viewEventDetails : Event -> Html Msg
viewEventDetails event =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Details" ]
        , div [ class "space-y-3" ]
            [ detailRow "Type" (eventTypeToString event.type_) (eventTypeIcon event.type_)
            , detailRow "Status" (eventStatusText event.status) "📊"
            , detailRow "Organization" event.organization "🏢"
            ]
        ]


eventTypeToString : EventType -> String
eventTypeToString eventType =
    case eventType of
        Tournament ->
            "Tournament"

        SuperFight ->
            "Super Fight"

        Seminar ->
            "Seminar"

        Camp ->
            "Training Camp"


detailRow : String -> String -> String -> Html Msg
detailRow label value icon =
    div [ class "flex items-center space-x-3" ]
        [ span [ class "text-xl" ] [ text icon ]
        , div [ class "flex-1" ]
            [ p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
            , p [ class "font-medium dark:text-white" ] [ text value ]
            ]
        ]


viewEventLinks : Event -> Html Msg
viewEventLinks event =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Links" ]
        , div [ class "space-y-3" ]
            [ case event.registrationUrl of
                Just url ->
                    linkButton "Register" "🎫"

                Nothing ->
                    text ""
            , case event.streamUrl of
                Just url ->
                    linkButton "Watch Stream" "📺"

                Nothing ->
                    text ""
            ]
        ]


linkButton : String -> String -> Html Msg
linkButton label icon =
    button
        [ onClick (ShowNotification Info (label ++ " - External link will open in new tab"))
        , class "w-full flex items-center justify-center space-x-2 px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors cursor-pointer"
        , type_ "button"
        ]
        [ span [ class "text-xl" ] [ text icon ]
        , span [ class "font-medium" ] [ text label ]
        ]


viewTrainingPage : Model -> Html Msg
viewTrainingPage model =
    div [ class "space-y-6" ]
        [ h1 [ class "text-3xl lg:text-4xl font-bold text-white mb-8" ] [ text "Training Plans" ]
        , div [ class "bg-gradient-to-r from-blue-600/30 to-purple-600/30 backdrop-blur-sm rounded-2xl p-6 lg:p-8 text-white border border-blue-500/30" ]
            [ h2 [ class "text-3xl font-bold mb-4" ] [ text "Start Your Journey" ]
            , p [ class "text-lg mb-6 opacity-90" ] [ text "Choose a hero and follow their training methodology" ]
            , button
                [ onClick StartSession
                , class "px-6 py-3 bg-white text-blue-600 font-bold rounded-lg hover:shadow-xl transition-all cursor-pointer"
                , type_ "button"
                ]
                [ text "Create Training Plan" ]
            ]
        , viewTrainingStats model
        , viewRecentSessions model
        ]


viewTrainingStats : Model -> Html Msg
viewTrainingStats model =
    div [ class "grid grid-cols-1 md:grid-cols-4 gap-4 mb-8" ]
        [ statCard "Total Sessions" "0" "📊" "bg-blue-500"
        , statCard "Hours Trained" "0" "⏱️" "bg-green-500"
        , statCard "Current Streak" "0 days" "🔥" "bg-orange-500"
        , statCard "Techniques" "0" "🎯" "bg-purple-500"
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
    div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-gray-700/50" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Recent Sessions" ]
        , if List.isEmpty model.trainingSessions then
            div [ class "text-center py-8" ]
                [ span [ class "text-5xl mb-4 block" ] [ text "📝" ]
                , p [ class "text-gray-500 dark:text-gray-400" ] [ text "No training sessions yet" ]
                , button
                    [ onClick (OpenModal SessionModal)
                    , class "mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
                    ]
                    [ text "Log Your First Session" ]
                ]

          else
            Keyed.node "div"
                [ class "space-y-4" ]
                (model.trainingSessions |> List.sortBy (\s -> Time.posixToMillis s.date |> negate) |> List.map (\s -> ( s.id, viewSessionCard s )))
        ]


viewSessionCard : TrainingSession -> Html Msg
viewSessionCard session =
    div [ class "border-l-4 border-green-500 pl-4" ]
        [ div [ class "flex justify-between items-start" ]
            [ div []
                [ p [ class "font-medium dark:text-white" ] [ text (sessionTypeToString session.sessionType) ]
                , p [ class "text-sm text-gray-500" ] [ text "Date" ] -- TODO: Format Time.Posix to string
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
            "Drilling"

        SparringSession ->
            "Sparring"

        CompetitionSession ->
            "Competition"

        OpenMatSession ->
            "Open Mat"

        PrivateSession ->
            "Private Lesson"


viewProfilePage : Model -> Html Msg
viewProfilePage model =
    div [ class "space-y-6" ]
        [ h1 [ class "text-3xl lg:text-4xl font-bold text-white mb-8" ] [ text "Profile" ]
        , case model.userProfile of
            Just profile ->
                viewUserProfile profile model

            Nothing ->
                viewGuestProfile model
        ]


viewUserProfile : UserProfile -> Model -> Html Msg
viewUserProfile profile model =
    div [ class "grid grid-cols-1 lg:grid-cols-3 gap-8" ]
        [ div [ class "lg:col-span-2" ]
            [ viewProfileInfo profile
            , viewProfileStats profile
            , viewProfileAchievements profile
            ]
        , div []
            [ viewProfileFavorites model
            , viewProfileGoals profile
            ]
        ]


viewProfileInfo : UserProfile -> Html Msg
viewProfileInfo profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Profile Information" ]
        , div [ class "space-y-3" ]
            [ infoRow "Username" profile.username
            , infoRow "Email" profile.email
            , infoRow "Belt Level" (beltToString profile.beltLevel)
            , infoRow "Training Since" profile.startedTraining
            , case profile.academy of
                Just academy ->
                    infoRow "Academy" academy

                Nothing ->
                    text ""
            ]
        ]


viewProfileStats : UserProfile -> Html Msg
viewProfileStats profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Statistics" ]
        , div [ class "grid grid-cols-2 md:grid-cols-3 gap-4" ]
            [ statBox "Sessions" (String.fromInt profile.stats.totalSessions)
            , statBox "Hours" (String.fromFloat profile.stats.totalHours)
            , statBox "Streak" (String.fromInt profile.stats.currentStreak ++ " days")
            , statBox "Best Streak" (String.fromInt profile.stats.longestStreak ++ " days")
            , statBox "Techniques" (String.fromInt profile.stats.techniquesLearned)
            , case profile.stats.favoritePosition of
                Just position ->
                    statBox "Favorite" position

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


viewProfileAchievements : UserProfile -> Html Msg
viewProfileAchievements profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Achievements" ]
        , if List.isEmpty profile.achievements then
            p [ class "text-gray-500 dark:text-gray-400" ] [ text "No achievements yet" ]

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


viewProfileFavorites : Model -> Html Msg
viewProfileFavorites model =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Favorites" ]
        , div [ class "space-y-4" ]
            [ favoriteSection "Heroes" (Set.toList model.favorites.heroes) "🥋"
            , favoriteSection "Academies" (Set.toList model.favorites.academies) "🏛️"
            , favoriteSection "Events" (Set.toList model.favorites.events) "📅"
            ]
        ]


favoriteSection : String -> List String -> String -> Html Msg
favoriteSection title items icon =
    div []
        [ h3 [ class "font-medium text-gray-700 dark:text-gray-300 mb-2" ] [ text title ]
        , if List.isEmpty items then
            p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text "No favorites yet" ]

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


viewProfileGoals : UserProfile -> Html Msg
viewProfileGoals profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Training Goals" ]
        , if List.isEmpty profile.trainingGoals then
            p [ class "text-gray-500 dark:text-gray-400" ] [ text "No goals set" ]

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
            [ onClick (ShowNotification Info "Goal setting feature coming soon!")
            , class "mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors cursor-pointer"
            , type_ "button"
            ]
            [ text "Add Goal" ]
        ]


viewGuestProfile : Model -> Html Msg
viewGuestProfile model =
    div [ class "flex-1 flex items-center justify-center p-4 lg:p-8" ]
        [ div [ class "max-w-md w-full" ]
            [ -- Card container with better contrast
              div [ class "bg-gray-900/50 backdrop-blur-md rounded-2xl border border-gray-800/50 p-6 lg:p-8 shadow-2xl" ]
                [ -- Icon
                  div [ class "flex justify-center mb-6" ]
                    [ div [ class "w-24 h-24 bg-gradient-to-br from-blue-500/20 to-purple-500/20 rounded-full flex items-center justify-center" ]
                        [ span [ class "text-5xl" ] [ text "👤" ] ]
                    ]
                , -- Title
                  h2 [ class "text-3xl font-bold text-white text-center mb-4" ]
                    [ text "Start Your Journey" ]
                , -- Description
                  p [ class "text-gray-400 text-center mb-8 leading-relaxed" ]
                    [ text "Create an account to track your training progress, save favorites, and unlock achievements." ]
                , -- Buttons with proper handlers and z-index
                  div [ class "space-y-3" ]
                    [ button
                        [ onClick (NavigateTo SignUpPage)
                        , class "w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white font-bold py-3 px-6 rounded-lg hover:shadow-xl hover:scale-105 transition-all duration-200 cursor-pointer relative z-10"
                        , type_ "button"
                        , style "cursor" "pointer"
                        ]
                        [ text "Sign Up" ]
                    , button
                        [ onClick (NavigateTo LoginPage)
                        , class "w-full bg-gray-800 hover:bg-gray-700 text-gray-300 font-medium py-3 px-6 rounded-lg transition-colors cursor-pointer relative z-10"
                        , type_ "button"
                        , style "cursor" "pointer"
                        ]
                        [ text "Already have an account? Log in" ]
                    ]
                ]
            ]
        ]


viewSignUpPage : Model -> Html Msg
viewSignUpPage model =
    div [ class "min-h-screen flex items-center justify-center p-4", style "margin-top" "-72px" ]
        [ div [ class "max-w-md w-full" ]
            [ div [ class "bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-2xl border border-gray-200 dark:border-gray-700" ]
                [ -- Header
                  div [ class "text-center mb-8" ]
                    [ div [ class "inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full mb-4" ]
                        [ span [ class "text-3xl" ] [ text "🥋" ] ]
                    , h1 [ class "text-3xl font-bold text-gray-900 dark:text-white mb-2" ]
                        [ text "Create Account" ]
                    , p [ class "text-gray-600 dark:text-gray-400" ]
                        [ text "Join Train Like Pro and start your journey" ]
                    ]
                , -- Form
                  div [ class "space-y-4" ]
                    [ div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Full Name" ]
                        , input
                            [ type_ "text"
                            , class "form-input w-full"
                            , placeholder "John Doe"
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Email" ]
                        , input
                            [ type_ "email"
                            , class "form-input w-full"
                            , placeholder "john@example.com"
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Password" ]
                        , input
                            [ type_ "password"
                            , class "form-input w-full"
                            , placeholder "••••••••"
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Confirm Password" ]
                        , input
                            [ type_ "password"
                            , class "form-input w-full"
                            , placeholder "••••••••"
                            ]
                            []
                        ]
                    , button
                        [ onClick (ShowNotification Info "Sign up functionality coming soon!")
                        , class "w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white font-bold py-3 px-6 rounded-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
                        , type_ "button"
                        ]
                        [ text "Create Account" ]
                    , div [ class "text-center text-sm text-gray-600 dark:text-gray-400" ]
                        [ text "Already have an account? "
                        , button
                            [ onClick (NavigateTo LoginPage)
                            , class "text-purple-600 dark:text-purple-400 font-semibold hover:underline"
                            ]
                            [ text "Log in" ]
                        ]
                    ]
                ]
            ]
        ]


viewLoginPage : Model -> Html Msg
viewLoginPage model =
    div [ class "min-h-screen flex items-center justify-center p-4", style "margin-top" "-72px" ]
        [ div [ class "max-w-md w-full" ]
            [ div [ class "bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-2xl border border-gray-200 dark:border-gray-700" ]
                [ -- Header
                  div [ class "text-center mb-8" ]
                    [ div [ class "inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full mb-4" ]
                        [ span [ class "text-3xl" ] [ text "👤" ] ]
                    , h1 [ class "text-3xl font-bold text-gray-900 dark:text-white mb-2" ]
                        [ text "Welcome Back" ]
                    , p [ class "text-gray-600 dark:text-gray-400" ]
                        [ text "Log in to continue your training" ]
                    ]
                , -- Form
                  div [ class "space-y-4" ]
                    [ div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Email" ]
                        , input
                            [ type_ "email"
                            , class "form-input w-full"
                            , placeholder "john@example.com"
                            ]
                            []
                        ]
                    , div []
                        [ label [ class "block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" ]
                            [ text "Password" ]
                        , input
                            [ type_ "password"
                            , class "form-input w-full"
                            , placeholder "••••••••"
                            ]
                            []
                        ]
                    , div [ class "flex items-center justify-between" ]
                        [ label [ class "flex items-center" ]
                            [ input [ type_ "checkbox", class "mr-2" ] []
                            , span [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text "Remember me" ]
                            ]
                        , button
                            [ onClick (ShowNotification Info "Password reset coming soon!")
                            , class "text-sm text-purple-600 dark:text-purple-400 hover:underline"
                            ]
                            [ text "Forgot password?" ]
                        ]
                    , button
                        [ onClick (ShowNotification Info "Login functionality coming soon!")
                        , class "w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white font-bold py-3 px-6 rounded-lg hover:shadow-xl hover:scale-105 transition-all duration-200"
                        , type_ "button"
                        ]
                        [ text "Log In" ]
                    , div [ class "text-center text-sm text-gray-600 dark:text-gray-400" ]
                        [ text "Don't have an account? "
                        , button
                            [ onClick (NavigateTo SignUpPage)
                            , class "text-purple-600 dark:text-purple-400 font-semibold hover:underline"
                            ]
                            [ text "Sign up" ]
                        ]
                    ]
                ]
            ]
        ]


viewStylePathPage : Model -> String -> Html Msg
viewStylePathPage model slug =
    div [ class "space-y-6 p-6" ]
        [ h1 [ class "text-3xl font-bold text-white" ]
            [ text ("Fighter Path: " ++ slug) ]
        , p [ class "text-gray-400" ]
            [ text "Learn the complete system and techniques of this fighter." ]
        , div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50" ]
            [ text "Fighter path system coming soon!" ]
        ]


viewTechniqueLibraryPage : Model -> Html Msg
viewTechniqueLibraryPage model =
    div [ class "space-y-6 p-6" ]
        [ h1 [ class "text-3xl font-bold text-white" ]
            [ text "Technique Library" ]
        , p [ class "text-gray-400" ]
            [ text "Browse and learn all available techniques." ]
        , div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50" ]
            [ text "Technique library coming soon!" ]
        ]


viewProgressPage : Model -> Html Msg
viewProgressPage model =
    div [ class "space-y-6 p-6" ]
        [ h1 [ class "text-3xl font-bold text-white" ]
            [ text "Your Progress" ]
        , p [ class "text-gray-400" ]
            [ text "Track your journey and achievements." ]
        , div [ class "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50" ]
            [ text "Progress tracking coming soon!" ]
        ]


viewNotFoundPage : Model -> Html Msg
viewNotFoundPage model =
    div [ class "container mx-auto px-4 py-16 text-center" ]
        [ span [ class "text-8xl mb-4 block" ] [ text "🤷" ]
        , h1 [ class "text-4xl font-bold mb-4 dark:text-white" ] [ text "404 - Page Not Found" ]
        , p [ class "text-gray-600 dark:text-gray-400 mb-8" ]
            [ text "The page you're looking for doesn't exist." ]
        , button
            [ onPreventDefaultClick (NavigateTo Home)
            , class "px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg transition-colors"
            ]
            [ text "Go Home" ]
        ]


viewModals : Model -> Html Msg
viewModals model =
    div [ class "relative z-modal" ]
        [ if model.modals.sessionModal then
            viewSessionModal model

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
    div [ class "fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-modal" ]
        [ div
            [ class "bg-gray-800 border border-gray-700 rounded-xl p-6 max-w-md w-full mx-4 shadow-2xl"
            , attribute "role" "dialog"
            , attribute "aria-modal" "true"
            , attribute "aria-labelledby" "session-modal-title"
            , onModalEscapeKeyDown CloseModal
            , tabindex 0
            ]
            [ h2 [ class "text-2xl font-bold mb-4 dark:text-white", id "session-modal-title" ] [ text "Log Training Session" ]
            , p [ class "text-gray-600 dark:text-gray-400" ] [ text "Session logging coming soon!" ]
            , button
                [ onClick CloseModal
                , class "mt-4 px-4 py-2 bg-gray-200 dark:bg-gray-700 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                , attribute "aria-label" "Close modal"
                ]
                [ text "Close" ]
            ]
        ]


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
                        , attribute "aria-label" "Close modal"
                        ]
                        [ text "Close" ]
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
    footer [ class "bg-gray-900 text-white py-12 mt-20" ]
        [ div [ class "container mx-auto px-4" ]
            [ div [ class "grid grid-cols-1 md:grid-cols-4 gap-8 mb-8" ]
                [ div []
                    [ h3 [ class "text-xl font-bold mb-4" ] [ text "BJJ Heroes" ]
                    , p [ class "text-gray-400" ] [ text "Train like champions with guidance from the greatest athletes in BJJ history." ]
                    ]
                , div []
                    [ h4 [ class "font-bold mb-4" ] [ text "Explore" ]
                    , ul [ class "space-y-2" ]
                        [ footerLink "Heroes" (NavigateTo (HeroesRoute Nothing))
                        , footerLink "Academies" (NavigateTo (Academies Nothing))
                        , footerLink "Events" (NavigateTo (Events AllEvents))
                        , footerLink "Training" (NavigateTo Training)
                        ]
                    ]
                , div []
                    [ h4 [ class "font-bold mb-4" ] [ text "Resources" ]
                    , ul [ class "space-y-2" ]
                        [ li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text "Technique Library" ] ]
                        , li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text "Training Tips" ] ]
                        , li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text "Competition Rules" ] ]
                        , li [] [ a [ href "#", class "text-gray-400 hover:text-white transition-colors" ] [ text "Blog" ] ]
                        ]
                    ]
                , div []
                    [ h4 [ class "font-bold mb-4" ] [ text "Connect" ]
                    , div [ class "flex space-x-4" ]
                        [ span [ class "text-2xl cursor-pointer hover:text-blue-400 transition-colors" ] [ text "📘" ]
                        , span [ class "text-2xl cursor-pointer hover:text-blue-400 transition-colors" ] [ text "🐦" ]
                        , span [ class "text-2xl cursor-pointer hover:text-pink-400 transition-colors" ] [ text "📷" ]
                        , span [ class "text-2xl cursor-pointer hover:text-red-500 transition-colors" ] [ text "📺" ]
                        ]
                    ]
                ]
            , div [ class "border-t border-gray-800 pt-8 text-center text-gray-400" ]
                [ p [] [ text "© 2024 BJJ Heroes. Train Like Champions. All rights reserved." ]
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
