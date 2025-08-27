module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Set exposing (Set)
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Lamdera
import Effect.Subscription as Subscription exposing (Subscription)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2, lazy3)
import I18n
import LocalStorage
import Theme
import Types exposing (..)
import Router
import Data
import Url
import Time
import Task
import Json.Decode as Decode


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
        route = Router.fromUrl url
        initialModel =
            { key = key
            , url = url
            , route = route
            , localStorage = LocalStorage.defaultLocalStorage
            , userConfig = 
                { t = I18n.translations I18n.EN
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
                newRoute = Router.fromUrl url
            in
            ( { model 
                | url = url
                , route = newRoute
                , mobileMenuOpen = False
                , animations = { heroCards = True, pageTransition = True, scrollProgress = 0 }
              }
            , Cmd.batch
                [ Lamdera.sendToBackend (TrackPageView newRoute)
                , scrollToTop
                ]
            )

        ReceivedLocalStorage localStorage ->
            let
                language = I18n.EN -- Default to English for now
                isDark = False -- Default to light theme for now
                userConfig = model.userConfig
            in
            ( { model 
                | localStorage = localStorage
                , userConfig = 
                    { userConfig 
                        | isDark = isDark
                        , language = language
                        , t = I18n.translations language
                    }
              }
            , Cmd.none
            )

        NavigateTo route ->
            ( model, Router.navigateTo model.key route )

        ToggleMobileMenu ->
            ( { model | mobileMenuOpen = not model.mobileMenuOpen }, Cmd.none )

        UpdateSearchQuery query ->
            ( { model | searchQuery = query }, Cmd.none )

        ApplyFilter filter ->
            let
                filters = model.activeFilters
            in
            ( { model | activeFilters = { filters | heroFilter = Just filter } }
            , Cmd.none
            )

        ClearFilters ->
            ( { model | activeFilters = 
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
                userConfig = model.userConfig
            in
            ( { model | userConfig = { userConfig | language = language, t = I18n.translations language } }
            , Cmd.none -- LocalStorage saving not implemented yet
            )

        ChangeTheme theme ->
            let
                userConfig = model.userConfig
                isDark = False -- Default to light theme for now
            in
            ( { model | userConfig = { userConfig | isDark = isDark } }
            , Cmd.none -- LocalStorage saving not implemented yet
            )

        ToggleFavorite favoriteType id ->
            let
                favorites = model.favorites
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
                modals = model.modals
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
            in
            ( { model | modals = newModals }, Cmd.none )

        CloseModal ->
            ( { model | modals = 
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
                animations = model.animations
            in
            ( { model | animations = { animations | scrollProgress = animations.scrollProgress + 0.01 } }
            , Cmd.none
            )

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
        [ div 
            [ class "min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-black transition-colors duration-300"
            , classList [ ("dark", model.userConfig.isDark) ]
            ]
            [ viewHeader model
            , viewNotifications model.notifications
            , main_ [ class "relative" ]
                [ viewPage model ]
            , viewModals model
            , viewFooter model
            ]
        ]
    }


viewTitle : Model -> String
viewTitle model =
    case model.route of
        Home -> "BJJ Heroes - Train Like Champions"
        HeroesRoute _ -> "Heroes - BJJ Heroes"
        HeroDetail id -> 
            Dict.get id model.heroes
                |> Maybe.map .name
                |> Maybe.withDefault "Hero"
                |> (\name -> name ++ " - BJJ Heroes")
        Academies _ -> "Academies - BJJ Heroes"
        AcademyDetail id -> 
            Dict.get id model.academies
                |> Maybe.map .name
                |> Maybe.withDefault "Academy"
                |> (\name -> name ++ " - BJJ Heroes")
        Events _ -> "Events - BJJ Heroes"
        EventDetail id ->
            Dict.get id model.events
                |> Maybe.map .name
                |> Maybe.withDefault "Event"
                |> (\name -> name ++ " - BJJ Heroes")
        Training -> "Training - BJJ Heroes"
        Profile -> "Profile - BJJ Heroes"
        NotFound -> "404 - BJJ Heroes"


viewHeader : Model -> Html Msg
viewHeader model =
    header 
        [ class "sticky top-0 z-50 bg-white/95 dark:bg-gray-900/95 backdrop-blur-lg border-b border-gray-200 dark:border-gray-800 shadow-sm" ]
        [ div [ class "container mx-auto px-4 py-4" ]
            [ div [ class "flex items-center justify-between" ]
                [ viewLogo
                , viewDesktopNav model
                , viewHeaderActions model
                , viewMobileMenuButton model
                ]
            , if model.mobileMenuOpen then
                viewMobileMenu model
              else
                text ""
            ]
        ]


viewLogo : Html Msg
viewLogo =
    button 
        [ onClick (NavigateTo Home)
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
        , navLink model (HeroesRoute Nothing) "Heroes" "🥋"
        , navLink model (Academies Nothing) "Academies" "🏛️"
        , navLink model (Events AllEvents) "Events" "📅"
        , navLink model Training "Training" "💪"
        ]


navLink : Model -> Route -> String -> String -> Html Msg
navLink model route label icon =
    let
        isActive = 
            case (model.route, route) of
                (Home, Home) -> True
                (HeroesRoute _, HeroesRoute _) -> True
                (HeroDetail _, HeroesRoute _) -> True
                (Academies _, Academies _) -> True
                (AcademyDetail _, Academies _) -> True
                (Events _, Events _) -> True
                (EventDetail _, Events _) -> True
                (Training, Training) -> True
                (Profile, Profile) -> True
                _ -> False
    in
    button
        [ onClick (NavigateTo route)
        , class "flex items-center space-x-2 px-4 py-2 rounded-lg transition-all duration-200"
        , classList
            [ ("bg-red-600 text-white shadow-md", isActive)
            , ("text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800", not isActive)
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
        [ onClick (ChangeTheme (if model.userConfig.isDark then Theme.LightMode else Theme.DarkMode))
        , class "p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors border border-gray-300 dark:border-gray-600"
        ]
        [ text (if model.userConfig.isDark then "☀️" else "🌙") ]


viewLanguageSelector : Model -> Html Msg
viewLanguageSelector model =
    select
        [ onInput (\lang -> ChangeLanguage (if lang == "fr" then I18n.FR else I18n.EN))
        , class "px-3 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-red-500 border border-gray-300 dark:border-gray-600"
        ]
        [ option [ value "en", selected (model.userConfig.language == I18n.EN) ] [ text "EN" ]
        , option [ value "fr", selected (model.userConfig.language == I18n.FR) ] [ text "FR" ]
        ]


viewProfileButton : Model -> Html Msg
viewProfileButton model =
    button
        [ onClick (NavigateTo Profile)
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
    div [ class "fixed top-20 right-4 z-50 space-y-2" ]
        (List.map viewNotification notifications)


viewNotification : Notification -> Html Msg
viewNotification notification =
    let
        (bgColor, icon) =
            case notification.type_ of
                Success -> ("bg-green-500", "✅")
                Error -> ("bg-red-500", "❌")
                Info -> ("bg-blue-500", "ℹ️")
                Warning -> ("bg-yellow-500", "⚠️")
    in
    div 
        [ class ("flex items-center space-x-3 p-4 rounded-lg text-white shadow-lg animate-slide-in " ++ bgColor) ]
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

        Profile ->
            viewProfilePage model

        NotFound ->
            viewNotFoundPage model


viewHomePage : Model -> Html Msg
viewHomePage model =
    div [ class "animate-fade-in" ]
        [ viewHeroSection model
        , viewFeaturedHeroes model
        , viewUpcomingEvents model
        , viewTopAcademies model
        , viewCallToAction model
        ]


viewHeroSection : Model -> Html Msg
viewHeroSection model =
    section [ class "relative h-screen flex items-center justify-center overflow-hidden bg-gradient-to-br from-gray-900 via-red-900 to-black" ]
        [ div [ class "absolute inset-0 bg-black/40" ] []
        , div [ class "relative z-10 text-center px-4 animate-slide-up" ]
            [ h1 [ class "text-5xl md:text-7xl font-bold text-white mb-6 drop-shadow-2xl" ]
                [ text "Train Like a "
                , span [ class "text-red-400 drop-shadow-2xl" ] [ text "Champion" ]
                ]
            , p [ class "text-xl md:text-2xl text-gray-100 mb-8 max-w-3xl mx-auto drop-shadow-lg" ]
                [ text "Learn from the greatest BJJ athletes in history. Master their techniques, follow their training methods, and elevate your game." ]
            , div [ class "flex flex-col sm:flex-row gap-4 justify-center" ]
                [ button
                    [ onClick (NavigateTo (HeroesRoute Nothing))
                    , class "px-8 py-4 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg shadow-xl transform hover:scale-105 transition-all duration-200"
                    ]
                    [ text "Explore Heroes" ]
                , button
                    [ onClick (NavigateTo Training)
                    , class "px-8 py-4 bg-white/10 backdrop-blur hover:bg-white/20 text-white font-bold rounded-lg shadow-xl transform hover:scale-105 transition-all duration-200 border border-white/30"
                    ]
                    [ text "Start Training" ]
                ]
            ]
        , div [ class "absolute bottom-10 left-1/2 transform -translate-x-1/2 animate-bounce" ]
            [ span [ class "text-white text-3xl drop-shadow-lg" ] [ text "↓" ] ]
        ]


viewFeaturedHeroes : Model -> Html Msg
viewFeaturedHeroes model =
    section [ class "py-20 px-4 bg-gray-50 dark:bg-gray-900" ]
        [ div [ class "container mx-auto" ]
            [ h2 [ class "text-4xl font-bold text-center mb-4 text-gray-900 dark:text-white" ] [ text "Featured Heroes" ]
            , p [ class "text-center text-gray-600 dark:text-gray-400 mb-12" ] [ text "Learn from the legends who shaped the sport" ]
            , div [ class "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" ]
                (model.heroes
                    |> Dict.values
                    |> List.take 6
                    |> List.map (viewHeroCard model)
                )
            ]
        ]


viewHeroCard : Model -> Hero -> Html Msg
viewHeroCard model hero =
    div 
        [ onClick (SelectHero hero.id)
        , class "group cursor-pointer transform hover:scale-105 transition-all duration-300"
        ]
        [ div [ class "relative overflow-hidden rounded-xl shadow-xl bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700" ]
            [ div [ class "h-64 bg-gradient-to-br from-red-500 to-red-700 relative" ]
                [ div [ class "absolute inset-0 bg-black/40" ] []
                , div [ class "absolute bottom-4 left-4 text-white z-10" ]
                    [ h3 [ class "text-2xl font-bold drop-shadow-lg" ] [ text hero.name ]
                    , p [ class "text-sm opacity-90 drop-shadow-md" ] [ text hero.nickname ]
                    ]
                , if Set.member hero.id model.favorites.heroes then
                    span [ class "absolute top-4 right-4 text-2xl drop-shadow-lg" ] [ text "⭐" ]
                  else
                    text ""
                ]
            , div [ class "p-6" ]
                [ div [ class "flex items-center justify-between mb-4" ]
                    [ span [ class "px-3 py-1 bg-red-600 text-white rounded-full text-sm font-medium shadow-sm" ]
                        [ text (weightClassToString hero.weight) ]
                    , span [ class "text-gray-600 dark:text-gray-400 text-sm font-medium" ]
                        [ text hero.nationality ]
                    ]
                , p [ class "text-gray-600 dark:text-gray-300 mb-4 line-clamp-2" ] [ text hero.bio ]
                , div [ class "flex items-center justify-between" ]
                    [ div [ class "flex items-center space-x-2" ]
                        [ span [ class "text-green-600 dark:text-green-400 font-bold" ] 
                            [ text (String.fromInt hero.record.wins ++ "W") ]
                        , span [ class "text-gray-400" ] [ text "-" ]
                        , span [ class "text-red-600 dark:text-red-400" ] 
                            [ text (String.fromInt hero.record.losses ++ "L") ]
                        ]
                    , button
                        [ onClick (ToggleFavorite HeroFavorite hero.id)
                        , class "p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                        , Html.Events.stopPropagationOn "click" (Decode.succeed (NoOpFrontendMsg, True))
                        ]
                        [ text (if Set.member hero.id model.favorites.heroes then "❤️" else "♥") ]
                    ]
                ]
            ]
        ]


weightClassToString : WeightClass -> String
weightClassToString weight =
    case weight of
        Rooster -> "Rooster"
        LightFeather -> "Light Feather"
        Feather -> "Feather"
        Light -> "Light"
        Middle -> "Middle"
        MediumHeavy -> "Medium Heavy"
        Heavy -> "Heavy"
        SuperHeavy -> "Super Heavy"
        UltraHeavy -> "Ultra Heavy"


viewUpcomingEvents : Model -> Html Msg
viewUpcomingEvents model =
    section [ class "py-20 px-4 bg-white dark:bg-gray-800" ]
        [ div [ class "container mx-auto" ]
            [ h2 [ class "text-4xl font-bold text-center mb-12 text-gray-900 dark:text-white" ] [ text "Upcoming Events" ]
            , div [ class "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" ]
                (model.events
                    |> Dict.values
                    |> List.filter (\e -> e.status == Upcoming)
                    |> List.take 3
                    |> List.map viewEventCard
                )
            ]
        ]


viewEventCard : Event -> Html Msg
viewEventCard event =
    div [ class "bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow border border-gray-200 dark:border-gray-700" ]
        [ div [ class "h-48 bg-gradient-to-br from-blue-500 to-blue-700 relative" ]
            [ div [ class "absolute inset-0 flex items-center justify-center" ]
                [ span [ class "text-6xl drop-shadow-lg" ] [ text "🏆" ] ]
            ]
        , div [ class "p-6" ]
            [ h3 [ class "text-xl font-bold mb-2 text-gray-900 dark:text-white" ] [ text event.name ]
            , p [ class "text-gray-600 dark:text-gray-400 mb-4" ] [ text event.date ]
            , p [ class "text-sm text-gray-500 dark:text-gray-400" ] 
                [ text (event.location.city ++ ", " ++ event.location.country) ]
            ]
        ]


viewTopAcademies : Model -> Html Msg
viewTopAcademies model =
    section [ class "py-20 px-4 bg-gray-50 dark:bg-gray-900" ]
        [ div [ class "container mx-auto" ]
            [ h2 [ class "text-4xl font-bold text-center mb-12 text-gray-900 dark:text-white" ] [ text "Top Academies" ]
            , div [ class "grid grid-cols-1 md:grid-cols-2 gap-6" ]
                (model.academies
                    |> Dict.values
                    |> List.take 2
                    |> List.map viewAcademyCard
                )
            ]
        ]


viewAcademyCard : Academy -> Html Msg
viewAcademyCard academy =
    div [ class "bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow border border-gray-200 dark:border-gray-700" ]
        [ div [ class "flex items-start space-x-4" ]
            [ div [ class "w-20 h-20 bg-gradient-to-br from-purple-500 to-purple-700 rounded-lg flex items-center justify-center shadow-md" ]
                [ span [ class "text-3xl drop-shadow-md" ] [ text "🏛️" ] ]
            , div [ class "flex-1" ]
                [ h3 [ class "text-xl font-bold mb-2 text-gray-900 dark:text-white" ] [ text academy.name ]
                , p [ class "text-gray-600 dark:text-gray-400 mb-2" ] 
                    [ text ("Head Coach: " ++ academy.headCoach) ]
                , p [ class "text-sm text-gray-500 dark:text-gray-500" ] 
                    [ text (academy.location.city ++ ", " ++ academy.location.country) ]
                ]
            ]
        ]


viewCallToAction : Model -> Html Msg
viewCallToAction model =
    section [ class "py-20 px-4 bg-gradient-to-r from-red-600 to-red-800" ]
        [ div [ class "container mx-auto text-center" ]
            [ h2 [ class "text-4xl font-bold text-white mb-6 drop-shadow-lg" ] [ text "Ready to Level Up?" ]
            , p [ class "text-xl text-red-100 mb-8 max-w-2xl mx-auto" ]
                [ text "Join thousands of practitioners learning from the best in the world" ]
            , button
                [ onClick (NavigateTo Training)
                , class "px-8 py-4 bg-white text-red-600 font-bold rounded-lg shadow-xl hover:shadow-2xl transform hover:scale-105 transition-all duration-200"
                ]
                [ text "Start Your Journey" ]
            ]
        ]


viewHeroesPage : Model -> Maybe HeroFilter -> Html Msg
viewHeroesPage model filter =
    div [ class "container mx-auto px-4 py-8" ]
        [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text "BJJ Heroes" ]
        , viewHeroFilters model filter
        , div [ class "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6" ]
            (model.heroes
                |> Dict.values
                |> filterHeroes filter
                |> List.map (viewHeroCard model)
            )
        ]


viewHeroFilters : Model -> Maybe HeroFilter -> Html Msg
viewHeroFilters model currentFilter =
    div [ class "mb-8 flex flex-wrap gap-2" ]
        [ filterButton "All" (currentFilter == Nothing || currentFilter == Just AllHeroes) (ApplyFilter AllHeroes)
        , filterButton "Super Heavy" (currentFilter == Just (ByWeight SuperHeavy)) (ApplyFilter (ByWeight SuperHeavy))
        , filterButton "Leg Locks" (currentFilter == Just (ByStyle LegLocks)) (ApplyFilter (ByStyle LegLocks))
        , filterButton "Guard" (currentFilter == Just (ByStyle Guard)) (ApplyFilter (ByStyle Guard))
        , filterButton "Passing" (currentFilter == Just (ByStyle Passing)) (ApplyFilter (ByStyle Passing))
        ]


filterButton : String -> Bool -> Msg -> Html Msg
filterButton label isActive msg =
    button
        [ onClick msg
        , class "px-4 py-2 rounded-lg font-medium transition-all"
        , classList
            [ ("bg-red-600 text-white", isActive)
            , ("bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600", not isActive)
            ]
        ]
        [ text label ]


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


viewHeroDetailPage : Model -> String -> Html Msg
viewHeroDetailPage model heroId =
    case Dict.get heroId model.heroes of
        Just hero ->
            div []
                [ viewHeroHeader hero model
                , viewHeroContent hero model
                ]

        Nothing ->
            div [ class "container mx-auto px-4 py-8" ]
                [ p [ class "text-center text-gray-500" ] [ text "Hero not found" ] ]


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
                        [ text (hero.team) ]
                    , span [ class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg" ]
                        [ text (weightClassToString hero.weight) ]
                    , button
                        [ onClick (ToggleFavorite HeroFavorite hero.id)
                        , class "px-4 py-2 bg-white/20 backdrop-blur rounded-lg hover:bg-white/30 transition-colors"
                        ]
                        [ text (if Set.member hero.id model.favorites.heroes then "❤️ Favorited" else "🤍 Add to Favorites") ]
                    ]
                ]
            ]
        ]


viewHeroContent : Hero -> Model -> Html Msg
viewHeroContent hero model =
    div [ class "container mx-auto px-4 py-8" ]
        [ div [ class "grid grid-cols-1 lg:grid-cols-3 gap-8" ]
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
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Biography" ]
        , p [ class "text-gray-600 dark:text-gray-300 leading-relaxed" ] [ text hero.bio ]
        ]


viewHeroRecord : Hero -> Html Msg
viewHeroRecord hero =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Competition Record" ]
        , div [ class "grid grid-cols-3 gap-4 mb-6" ]
            [ recordStat "Wins" (String.fromInt hero.record.wins) "text-green-600"
            , recordStat "Losses" (String.fromInt hero.record.losses) "text-red-600"
            , recordStat "Draws" (String.fromInt hero.record.draws) "text-gray-600"
            ]
        , div [ class "space-y-2" ]
            (List.map (\title -> 
                div [ class "flex items-center space-x-2" ]
                    [ span [ class "text-xl" ] [ text "🏆" ]
                    , span [ class "text-gray-700 dark:text-gray-300" ] [ text title ]
                    ]
            ) hero.record.titles)
        ]


recordStat : String -> String -> String -> Html Msg
recordStat label value colorClass =
    div [ class "text-center" ]
        [ p [ class ("text-3xl font-bold " ++ colorClass) ] [ text value ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text label ]
        ]


viewHeroTechniques : Hero -> Html Msg
viewHeroTechniques hero =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Signature Techniques" ]
        , div [ class "space-y-4" ]
            (List.map viewTechnique hero.techniques)
        ]


viewTechnique : Technique -> Html Msg
viewTechnique technique =
    div [ class "border-l-4 border-red-500 pl-4" ]
        [ h3 [ class "font-bold dark:text-white" ] [ text technique.name ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text technique.description ]
        ]


viewHeroVideos : Hero -> Html Msg
viewHeroVideos hero =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Videos" ]
        , div [ class "grid grid-cols-1 md:grid-cols-2 gap-4" ]
            (List.map viewVideoCard hero.videos)
        ]


viewVideoCard : Video -> Html Msg
viewVideoCard video =
    div [ class "bg-gray-100 dark:bg-gray-700 rounded-lg p-4 hover:shadow-md transition-shadow cursor-pointer" ]
        [ h3 [ class "font-medium dark:text-white mb-2" ] [ text video.title ]
        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text video.date ]
        ]


viewHeroStats : Hero -> Html Msg
viewHeroStats hero =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
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
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
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
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
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


viewAcademiesPage : Model -> Maybe String -> Html Msg
viewAcademiesPage model location =
    div [ class "container mx-auto px-4 py-8" ]
        [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text "BJJ Academies" ]
        , div [ class "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" ]
            (model.academies
                |> Dict.values
                |> List.map (viewAcademyListCard model)
            )
        ]


viewAcademyListCard : Model -> Academy -> Html Msg
viewAcademyListCard model academy =
    div 
        [ onClick (NavigateTo (AcademyDetail academy.id))
        , class "bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-all cursor-pointer"
        ]
        [ h3 [ class "text-xl font-bold mb-2 dark:text-white" ] [ text academy.name ]
        , p [ class "text-gray-600 dark:text-gray-400 mb-2" ] 
            [ text ("Head Coach: " ++ academy.headCoach) ]
        , p [ class "text-sm text-gray-500 dark:text-gray-500 mb-4" ] 
            [ text (academy.location.city ++ ", " ++ academy.location.country) ]
        , p [ class "text-gray-600 dark:text-gray-300 line-clamp-3" ] [ text academy.description ]
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
        Monday -> "Monday"
        Tuesday -> "Tuesday"
        Wednesday -> "Wednesday"
        Thursday -> "Thursday"
        Friday -> "Friday"
        Saturday -> "Saturday"
        Sunday -> "Sunday"


viewAcademyMembers : Academy -> Html Msg
viewAcademyMembers academy =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Notable Members" ]
        , div [ class "space-y-2" ]
            (List.map (\member ->
                div [ class "flex items-center space-x-2" ]
                    [ span [ class "text-lg" ] [ text "🥋" ]
                    , span [ class "dark:text-white" ] [ text member ]
                    ]
            ) academy.notableMembers)
        ]


viewEventsPage : Model -> EventsFilter -> Html Msg
viewEventsPage model filter =
    div [ class "container mx-auto px-4 py-8" ]
        [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text "BJJ Events" ]
        , viewEventFilters filter
        , div [ class "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" ]
            (model.events
                |> Dict.values
                |> filterEvents filter
                |> List.map (viewEventListCard model)
            )
        ]


viewEventFilters : EventsFilter -> Html Msg
viewEventFilters currentFilter =
    div [ class "mb-8 flex gap-2" ]
        [ eventFilterButton "All" (currentFilter == AllEvents) (NavigateTo (Events AllEvents))
        , eventFilterButton "Upcoming" (currentFilter == UpcomingEvents) (NavigateTo (Events UpcomingEvents))
        , eventFilterButton "Past" (currentFilter == PastEvents) (NavigateTo (Events PastEvents))
        ]


eventFilterButton : String -> Bool -> Msg -> Html Msg
eventFilterButton label isActive msg =
    button
        [ onClick msg
        , class "px-4 py-2 rounded-lg font-medium transition-all"
        , classList
            [ ("bg-blue-600 text-white", isActive)
            , ("bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300", not isActive)
            ]
        ]
        [ text label ]


filterEvents : EventsFilter -> List Event -> List Event
filterEvents filter events =
    case filter of
        AllEvents ->
            events

        UpcomingEvents ->
            List.filter (\e -> e.status == Upcoming || e.status == Live) events

        PastEvents ->
            List.filter (\e -> e.status == Completed) events


viewEventListCard : Model -> Event -> Html Msg
viewEventListCard model event =
    div 
        [ onClick (NavigateTo (EventDetail event.id))
        , class "bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-all cursor-pointer"
        ]
        [ div [ class "h-32 bg-gradient-to-br from-blue-400 to-blue-600 relative" ]
            [ div [ class "absolute inset-0 flex items-center justify-center" ]
                [ span [ class "text-5xl" ] [ text (eventTypeIcon event.type_) ] ]
            ]
        , div [ class "p-6" ]
            [ h3 [ class "text-xl font-bold mb-2 dark:text-white" ] [ text event.name ]
            , p [ class "text-gray-600 dark:text-gray-400 mb-2" ] [ text event.date ]
            , p [ class "text-sm text-gray-500 dark:text-gray-500" ] 
                [ text (event.location.city ++ ", " ++ event.location.country) ]
            , div [ class "mt-4 flex justify-between items-center" ]
                [ span [ class (eventStatusClass event.status) ] [ text (eventStatusText event.status) ]
                , button
                    [ onClick (ToggleFavorite EventFavorite event.id)
                    , Html.Events.stopPropagationOn "click" (Decode.succeed (NoOpFrontendMsg, True))
                    , class "p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                    ]
                    [ text (if Set.member event.id model.favorites.events then "⭐" else "☆") ]
                ]
            ]
        ]


eventTypeIcon : EventType -> String
eventTypeIcon eventType =
    case eventType of
        Tournament -> "🏆"
        SuperFight -> "🥊"
        Seminar -> "📚"
        Camp -> "🏕️"


eventStatusClass : EventStatus -> String
eventStatusClass status =
    case status of
        Upcoming -> "px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded text-xs font-medium"
        Live -> "px-2 py-1 bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded text-xs font-medium animate-pulse"
        Completed -> "px-2 py-1 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 rounded text-xs font-medium"
        Cancelled -> "px-2 py-1 bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-500 rounded text-xs font-medium line-through"


eventStatusText : EventStatus -> String
eventStatusText status =
    case status of
        Upcoming -> "Upcoming"
        Live -> "LIVE"
        Completed -> "Completed"
        Cancelled -> "Cancelled"


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
            (List.map (\comp ->
                span [ class "px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded text-sm" ] [ text comp ]
            ) bracket.competitors)
        ]


beltToString : BeltLevel -> String
beltToString belt =
    case belt of
        White -> "White"
        Blue -> "Blue"
        Purple -> "Purple"
        Brown -> "Brown"
        Black -> "Black"


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
        Tournament -> "Tournament"
        SuperFight -> "Super Fight"
        Seminar -> "Seminar"
        Camp -> "Training Camp"


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
    button [ class "w-full flex items-center justify-center space-x-2 px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors" ]
        [ span [ class "text-xl" ] [ text icon ]
        , span [ class "font-medium" ] [ text label ]
        ]


viewTrainingPage : Model -> Html Msg
viewTrainingPage model =
    div [ class "container mx-auto px-4 py-8" ]
        [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text "Training Plans" ]
        , div [ class "bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl p-8 text-white mb-8" ]
            [ h2 [ class "text-3xl font-bold mb-4" ] [ text "Start Your Journey" ]
            , p [ class "text-lg mb-6 opacity-90" ] [ text "Choose a hero and follow their training methodology" ]
            , button [ class "px-6 py-3 bg-white text-blue-600 font-bold rounded-lg hover:shadow-xl transition-all" ]
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
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ div [ class "flex items-center justify-between mb-2" ]
            [ span [ class ("text-3xl p-2 rounded-lg " ++ bgColor ++ " bg-opacity-20") ] [ text icon ]
            , p [ class "text-2xl font-bold dark:text-white" ] [ text value ]
            ]
        , p [ class "text-gray-600 dark:text-gray-400" ] [ text label ]
        ]


viewRecentSessions : Model -> Html Msg
viewRecentSessions model =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
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
            div [ class "space-y-4" ]
                (List.map viewSessionCard model.trainingSessions)
        ]


viewSessionCard : TrainingSession -> Html Msg
viewSessionCard session =
    div [ class "border-l-4 border-green-500 pl-4" ]
        [ div [ class "flex justify-between items-start" ]
            [ div []
                [ p [ class "font-medium dark:text-white" ] [ text (sessionTypeToString session.sessionType) ]
                , p [ class "text-sm text-gray-500" ] [ text session.date ]
                ]
            , span [ class "text-sm text-gray-600 dark:text-gray-400" ] 
                [ text (String.fromInt session.duration ++ " min") ]
            ]
        ]


sessionTypeToString : SessionType -> String
sessionTypeToString sessionType =
    case sessionType of
        TechniqueSession -> "Technique"
        DrillingSession -> "Drilling"
        SparringSession -> "Sparring"
        CompetitionSession -> "Competition"
        OpenMatSession -> "Open Mat"
        PrivateSession -> "Private Lesson"


viewProfilePage : Model -> Html Msg
viewProfilePage model =
    div [ class "container mx-auto px-4 py-8" ]
        [ h1 [ class "text-4xl font-bold mb-8 dark:text-white" ] [ text "Profile" ]
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
                (List.map (\item ->
                    div [ class "flex items-center space-x-2" ]
                        [ span [ class "text-lg" ] [ text icon ]
                        , span [ class "text-sm dark:text-white" ] [ text item ]
                        ]
                ) items)
        ]


viewProfileGoals : UserProfile -> Html Msg
viewProfileGoals profile =
    div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg" ]
        [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Training Goals" ]
        , if List.isEmpty profile.trainingGoals then
            p [ class "text-gray-500 dark:text-gray-400" ] [ text "No goals set" ]
          else
            div [ class "space-y-2" ]
                (List.map (\goal ->
                    div [ class "flex items-center space-x-2" ]
                        [ span [ class "text-lg" ] [ text "🎯" ]
                        , span [ class "dark:text-white" ] [ text goal ]
                        ]
                ) profile.trainingGoals)
        , button [ class "mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors" ]
            [ text "Add Goal" ]
        ]


viewGuestProfile : Model -> Html Msg
viewGuestProfile model =
    div [ class "max-w-md mx-auto text-center py-12" ]
        [ span [ class "text-6xl mb-4 block" ] [ text "👤" ]
        , h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Welcome, Guest!" ]
        , p [ class "text-gray-600 dark:text-gray-400 mb-6" ] 
            [ text "Create an account to track your training progress, save favorites, and more." ]
        , button [ class "px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg transition-colors" ]
            [ text "Sign Up" ]
        ]


viewNotFoundPage : Model -> Html Msg
viewNotFoundPage model =
    div [ class "container mx-auto px-4 py-16 text-center" ]
        [ span [ class "text-8xl mb-4 block" ] [ text "🤷" ]
        , h1 [ class "text-4xl font-bold mb-4 dark:text-white" ] [ text "404 - Page Not Found" ]
        , p [ class "text-gray-600 dark:text-gray-400 mb-8" ] 
            [ text "The page you're looking for doesn't exist." ]
        , button 
            [ onClick (NavigateTo Home)
            , class "px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg transition-colors"
            ]
            [ text "Go Home" ]
        ]


viewModals : Model -> Html Msg
viewModals model =
    div []
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
    div [ class "fixed inset-0 bg-black/50 flex items-center justify-center z-50" ]
        [ div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 max-w-md w-full mx-4" ]
            [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text "Log Training Session" ]
            , p [ class "text-gray-600 dark:text-gray-400" ] [ text "Session logging coming soon!" ]
            , button 
                [ onClick CloseModal
                , class "mt-4 px-4 py-2 bg-gray-200 dark:bg-gray-700 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                ]
                [ text "Close" ]
            ]
        ]


viewHeroQuickView : Model -> String -> Html Msg
viewHeroQuickView model heroId =
    case Dict.get heroId model.heroes of
        Just hero ->
            div [ class "fixed inset-0 bg-black/50 flex items-center justify-center z-50" ]
                [ div [ class "bg-white dark:bg-gray-800 rounded-xl p-6 max-w-2xl w-full mx-4 max-h-[80vh] overflow-y-auto" ]
                    [ h2 [ class "text-2xl font-bold mb-4 dark:text-white" ] [ text hero.name ]
                    , p [ class "text-gray-600 dark:text-gray-400 mb-4" ] [ text hero.bio ]
                    , button 
                        [ onClick CloseModal
                        , class "px-4 py-2 bg-gray-200 dark:bg-gray-700 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                        ]
                        [ text "Close" ]
                    ]
                ]

        Nothing ->
            text ""


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


stopPropagationOn : String -> Decode.Decoder (msg, Bool) -> Attribute msg
stopPropagationOn event decoder =
    Html.Events.stopPropagationOn event decoder