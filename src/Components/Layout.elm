module Components.Layout exposing (mobileMenu, onModalEscapeKeyDown, sidebar, view)

import Html exposing (Html, a, button, div, footer, h1, h2, h3, header, input, li, nav, option, p, select, span, text, ul)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder, selected, tabindex, type_, value)
import Html.Events as Events exposing (onClick, onInput)
import I18n
import Json.Decode as Decode
import List exposing (indexedMap, length, map)
import Router
import Router.Helpers exposing (isInternalHrefWithUrl, onPreventDefaultClick)
import String
import Types exposing (..)



-- VIEW -----------------------------------------------------------------------


view : FrontendModel -> Html FrontendMsg -> Html FrontendMsg
view model content =
    let
        hasOverlayOpen =
            model.mobileMenuOpen
                || model.modals.sessionModal
                || (model.modals.heroDetailModal /= Nothing)
                || (model.modals.shareModal /= Nothing)
                || model.modals.filterModal

        skipLinkClass =
            if hasOverlayOpen then
                "sr-only"

            else
                "sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:px-4 focus:py-2 focus:rounded-full focus:bg-violet-700 focus:text-white focus:shadow-lg"
    in
    div [ class "min-h-screen bg-gray-50 dark:bg-gray-900" ]
        [ a [ href "#main", class skipLinkClass ] [ text model.userConfig.t.skipToContent ]
        , headerBar model
        , mainArea model content hasOverlayOpen
        , if model.mobileMenuOpen then
            mobileMenu model

          else
            text ""
        ]



-- HEADER ---------------------------------------------------------------------


headerBar : FrontendModel -> Html FrontendMsg
headerBar model =
    let
        navItems =
            primaryNavigationItems

        t =
            model.userConfig.t
    in
    header [ class "navbar-modern" ]
        [ div [ class "navbar-container" ]
            [ brandButton t
            , nav [ class "nav-links-modern hidden lg:flex" ]
                (map (viewDesktopNavItem model) navItems)
            , div [ class "flex items-center gap-4" ]
                [ languageSelector model
                , profileSummary model
                , button
                    [ onClick StartSession
                    , class "hidden lg:inline-flex btn btn-primary"
                    ]
                    [ text t.startSession ]
                , button
                    [ onClick ToggleMobileMenu
                    , class "mobile-menu-button lg:hidden"
                    , id "mobile-menu-toggle"
                    , attribute "aria-controls" "mobile-menu-dialog"
                    , attribute "aria-expanded"
                        (if model.mobileMenuOpen then
                            "true"

                         else
                            "false"
                        )
                    , attribute "aria-label" t.navigation
                    ]
                    [ text "☰" ]
                ]
            ]
        ]


brandButton : I18n.Translations -> Html FrontendMsg
brandButton t =
    button
        [ onPreventDefaultClick (NavigateTo Home)
        , class "logo-modern"
        ]
        [ div [ class "logo-icon" ] [ text "TL" ]
        , div []
            [ h1 [ class "logo-text" ] [ text t.appTitle ]
            ]
        ]


viewDesktopNavItem : FrontendModel -> NavItem -> Html FrontendMsg
viewDesktopNavItem model item =
    let
        label =
            navLabel model item

        isActive =
            isRouteActive model item.route

        href_ =
            Router.toPath item.route

        spaHandlers =
            if isInternalHrefWithUrl model.url href_ then
                [ onPreventDefaultClick (NavigateTo item.route) ]

            else
                []

        classes =
            if isActive then
                "nav-link-modern nav-link-active"

            else
                "nav-link-modern"
    in
    button
        ([ class classes ] ++ spaHandlers)
        [ text label ]


mainArea : FrontendModel -> Html FrontendMsg -> Bool -> Html FrontendMsg
mainArea model content hasOverlayOpen =
    let
        inertAttrs =
            if hasOverlayOpen then
                [ attribute "inert" "", attribute "aria-hidden" "true" ]

            else
                []
    in
    Html.main_ ([ class "py-16", id "main" ] ++ inertAttrs)
        [ div [ class "container-wide" ] [ content ] ]


languageSelector : FrontendModel -> Html FrontendMsg
languageSelector model =
    let
        currentLanguage =
            I18n.languageToString model.userConfig.language
    in
    select
        [ class "hidden lg:inline-flex rounded-full border border-gray-200 bg-white px-3 py-2 text-xs font-semibold uppercase tracking-[0.18em] text-gray-600 shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-purple-400 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-200"
        , value currentLanguage
        , onInput (\val -> ChangeLanguage (I18n.languageFromString val))
        ]
        [ option [ value "EN", selected (currentLanguage == "EN") ] [ text "EN" ]
        , option [ value "FR", selected (currentLanguage == "FR") ] [ text "FR" ]
        ]


profileSummary : FrontendModel -> Html FrontendMsg
profileSummary model =
    let
        username =
            Maybe.withDefault model.userConfig.t.guest (Maybe.map .username model.userProfile)

        initial =
            String.left 1 username |> String.toUpper

        beltLabel =
            Maybe.withDefault "White Belt" (Maybe.map (.beltLevel >> beltToString) model.userProfile)
    in
    button
        [ onPreventDefaultClick (NavigateTo Profile)
        , class "hidden lg:inline-flex items-center gap-3"
        ]
        [ div [ class "navbar-avatar" ] [ text initial ]
        , div [ class "hidden xl:grid gap-1 text-left" ]
            [ span [ class "text-sm font-semibold" ] [ text username ]
            , span [ class "text-xs text-gray-500" ] [ text beltLabel ]
            ]
        ]


sidebar : FrontendModel -> Html FrontendMsg
sidebar _ =
    text ""


mobileMenu : FrontendModel -> Html FrontendMsg
mobileMenu model =
    let
        navItems =
            primaryNavigationItems

        t =
            model.userConfig.t
    in
    div [ class "lg:hidden" ]
        [ div [ class "fixed inset-0 bg-black/40 backdrop-blur-sm z-40", onClick ToggleMobileMenu ] []
        , nav
            [ class "fixed inset-x-4 top-5 z-50 rounded-2xl bg-white dark:bg-gray-900 p-6 shadow-2xl"
            , attribute "role" "dialog"
            , attribute "aria-modal" "true"
            , attribute "aria-label" t.navigation
            , id "mobile-menu-dialog"
            , tabindex 0
            , onEscapeKeyDown
            ]
            [ div [ class "flex items-center justify-between mb-6" ]
                [ h2 [ class "text-sm font-semibold uppercase tracking-[0.18em] text-gray-500" ] [ text t.navigation ]
                , button
                    [ onClick ToggleMobileMenu
                    , class "mobile-menu-button"
                    , attribute "aria-label" "Close menu"
                    ]
                    [ text "✕" ]
                ]
            , ul [ class "space-y-2" ]
                (indexedMap
                    (\index item ->
                        li []
                            [ viewMobileNavItem index (length navItems) model item ]
                    )
                    navItems
                )
            , div [ class "mt-6 space-y-3" ]
                [ button
                    [ onClick StartSession
                    , class "btn btn-primary w-full"
                    ]
                    [ text t.startSession ]
                , languageSelectorMobile model
                ]
            ]
        ]


viewMobileNavItem : Int -> Int -> FrontendModel -> NavItem -> Html FrontendMsg
viewMobileNavItem index total model item =
    let
        isActive =
            isRouteActive model item.route

        label =
            navLabel model item

        attrs =
            if index == 0 then
                [ id "mobile-first-link", onFirstItemKeyDown "mobile-last-link" ]

            else if index == total - 1 then
                [ id "mobile-last-link", onLastItemKeyDown "mobile-first-link" ]

            else
                []
    in
    button
        ([ onPreventDefaultClick (NavigateTo item.route)
         , classList
            [ ( "w-full text-left px-4 py-3 text-sm font-medium rounded-lg transition-all duration-200", True )
            , ( "bg-purple-100 text-purple-700", isActive )
            , ( "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-200", not isActive )
            ]
         ]
            ++ attrs
        )
        [ text label ]


languageSelectorMobile : FrontendModel -> Html FrontendMsg
languageSelectorMobile model =
    let
        currentLanguage =
            I18n.languageToString model.userConfig.language
    in
    select
        [ class "w-full rounded-full border border-gray-200 bg-white px-3 py-2 text-sm font-medium text-gray-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-purple-400 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-200"
        , value currentLanguage
        , onInput (\val -> ChangeLanguage (I18n.languageFromString val))
        ]
        [ option [ value "EN", selected (currentLanguage == "EN") ] [ text "EN" ]
        , option [ value "FR", selected (currentLanguage == "FR") ] [ text "FR" ]
        ]



-- NAVIGATION -----------------------------------------------------------------


type alias NavItem =
    { id : String
    , labelEn : String
    , labelFr : String
    , icon : String
    , route : Route
    }


primaryNavigationItems : List NavItem
primaryNavigationItems =
    [ { id = "nav-home", labelEn = "Home", labelFr = "Accueil", icon = "🏠", route = Home }
    , { id = "nav-dashboard", labelEn = "Dashboard", labelFr = "Tableau", icon = "📊", route = Dashboard }
    , { id = "nav-heroes", labelEn = "Heroes", labelFr = "Héros", icon = "🥋", route = HeroesRoute Nothing }
    , { id = "nav-academies", labelEn = "Academies", labelFr = "Académies", icon = "🏛️", route = Academies Nothing }
    , { id = "nav-events", labelEn = "Events", labelFr = "Évènements", icon = "🗓", route = Events AllEvents }
    , { id = "nav-training", labelEn = "Training", labelFr = "Entraînement", icon = "💪", route = TrainingView }
    , { id = "nav-profile", labelEn = "Profile", labelFr = "Profil", icon = "👤", route = Profile }
    ]


navLabel : FrontendModel -> NavItem -> String
navLabel model item =
    case model.userConfig.language of
        I18n.FR ->
            item.labelFr

        I18n.EN ->
            item.labelEn


isRouteActive : FrontendModel -> Route -> Bool
isRouteActive model routeToMatch =
    case ( model.route, routeToMatch ) of
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

        ( Profile, Profile ) ->
            True

        ( _, _ ) ->
            False


beltToString : BeltLevel -> String
beltToString belt =
    case belt of
        White ->
            "White Belt"

        Blue ->
            "Blue Belt"

        Purple ->
            "Purple Belt"

        Brown ->
            "Brown Belt"

        Black ->
            "Black Belt"



-- MOBILE FOCUS MANAGEMENT ----------------------------------------------------


onFirstItemKeyDown : String -> Html.Attribute FrontendMsg
onFirstItemKeyDown lastId =
    Events.preventDefaultOn "keydown"
        (Decode.map2
            (\key shift ->
                if key == "Tab" && shift then
                    ( TrapFocus { firstId = lastId, lastId = lastId }, True )

                else
                    ( NoOpFrontendMsg, False )
            )
            (Decode.field "key" Decode.string)
            (Decode.field "shiftKey" Decode.bool)
        )


onLastItemKeyDown : String -> Html.Attribute FrontendMsg
onLastItemKeyDown firstId =
    Events.preventDefaultOn "keydown"
        (Decode.map2
            (\key shift ->
                if key == "Tab" && not shift then
                    ( TrapFocus { firstId = firstId, lastId = firstId }, True )

                else
                    ( NoOpFrontendMsg, False )
            )
            (Decode.field "key" Decode.string)
            (Decode.field "shiftKey" Decode.bool)
        )


onEscapeKeyDown : Html.Attribute FrontendMsg
onEscapeKeyDown =
    Events.preventDefaultOn "keydown"
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    if key == "Escape" then
                        Decode.succeed ( ToggleMobileMenu, True )

                    else
                        Decode.fail "not escape"
                )
        )


onModalEscapeKeyDown : FrontendMsg -> Html.Attribute FrontendMsg
onModalEscapeKeyDown closeMsg =
    Events.preventDefaultOn "keydown"
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    if key == "Escape" then
                        Decode.succeed ( closeMsg, True )

                    else
                        Decode.fail "not escape"
                )
        )
