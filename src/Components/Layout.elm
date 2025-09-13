module Components.Layout exposing (view, sidebar, mobileMenu)

import Html exposing (Html, div, nav, ul, li, a, button, text, span, i, img, h1, h2, main_, select, option)
import Html.Attributes exposing (class, id, href, src, alt, type_, attribute, style, title, value, selected, tabindex)
import Html.Events as Events exposing (onClick, onInput)
import Json.Decode as Decode
import Router.Helpers exposing (onPreventDefaultClick, isInternalHref)
import Types exposing (..)
import Router
import Theme exposing (darkTheme)
import I18n

view : FrontendModel -> Html FrontendMsg -> Html FrontendMsg
view model content =
    div [ class "min-h-screen bg-gradient-to-br from-gray-950 via-gray-900 to-gray-950" ]
        [ -- Desktop sidebar
          div [ class "hidden lg:block" ]
            [ sidebar model ]
        , main_ model content
        , if model.mobileMenuOpen then mobileMenu model else text ""
        ]

main_ : FrontendModel -> Html FrontendMsg -> Html FrontendMsg
main_ model content =
    div ([ class "lg:ml-72" ] ++ (if model.mobileMenuOpen then [ attribute "aria-hidden" "true" ] else []))
        [ topBar model
        , div [ class "p-4 lg:p-6" ]
            [ content ]
        ]

topBar : FrontendModel -> Html FrontendMsg
topBar model =
    div [ class "sticky top-0 z-nav glass border-b border-gray-700 shadow-lg" ]
        [ div [ class "flex items-center justify-between p-4" ]
            [ div [ class "flex items-center gap-4" ]
                [ button
                    [ class "lg:hidden p-2 rounded-lg bg-gray-800 hover:bg-gray-700 transition-colors"
                    , onClick ToggleMobileMenu
                    , id "mobile-menu-toggle"
                    , attribute "aria-controls" "mobile-menu-dialog"
                    , attribute "aria-expanded" (if model.mobileMenuOpen then "true" else "false")
                    , attribute "aria-label" model.userConfig.t.navigation
                    ]
                    [ i [ class "fas fa-bars text-gray-300", attribute "aria-hidden" "true" ] [] ]
                , div [ class "flex items-center gap-3" ]
                    [ xpBar model
                    , streakIndicator model
                    ]
                ]
            , div [ class "flex items-center gap-3" ]
                [ languageSelector model
                , profileSection model
                ]
            ]
        ]

xpBar : FrontendModel -> Html FrontendMsg
xpBar model =
    let
        progress = model.userProgress
        currentLevelXP = progress.totalXP
        nextLevelXP = (progress.currentLevel + 1) * 1000
        percentage = min 100 (toFloat currentLevelXP / toFloat nextLevelXP * 100)
    in
    div [ class "hidden sm:flex items-center gap-2 bg-gray-800/50 rounded-full px-3 py-2" ]
        [ span [ class "text-xs font-medium text-gray-300" ] [ text (I18n.formatLevel model.userConfig.language progress.currentLevel) ]
        , div [ class "w-24 h-2 bg-gray-700 rounded-full overflow-hidden" ]
            [ div 
                [ class "h-full bg-gradient-to-r from-blue-500 to-purple-500 transition-all duration-300"
                , attribute "style" ("width: " ++ String.fromFloat percentage ++ "%")
                ] []
            ]
        , span [ class "text-xs text-gray-400" ] [ text (String.fromInt currentLevelXP ++ " XP") ]
        ]

streakIndicator : FrontendModel -> Html FrontendMsg
streakIndicator model =
    div [ class "hidden sm:flex items-center gap-1 bg-orange-500/10 border border-orange-500/20 rounded-lg px-2 py-1" ]
        [ i [ class "fas fa-fire text-orange-500 text-sm", attribute "aria-hidden" "true" ] []
        , span [ class "text-xs font-medium text-orange-400" ] 
            [ text (I18n.formatStreak model.userConfig.language model.userProgress.currentStreak) ]
        ]

languageSelector : FrontendModel -> Html FrontendMsg
languageSelector model =
    select 
        [ class "bg-gray-800 text-gray-300 border border-gray-700 rounded-lg px-3 py-1 text-sm focus:outline-none focus:border-blue-500 transition-colors cursor-pointer hover:bg-gray-700"
        , value (I18n.languageToString model.userConfig.language)
        , onInput (\val -> ChangeLanguage (I18n.languageFromString val))
        ]
        [ option [ value "EN", selected (model.userConfig.language == I18n.EN) ] 
            [ text "🇬🇧 English" ]
        , option [ value "FR", selected (model.userConfig.language == I18n.FR) ] 
            [ text "🇫🇷 Français" ]
        ]

profileSection : FrontendModel -> Html FrontendMsg
profileSection model =
    div [ class "flex items-center gap-3" ]
        [ div [ class "hidden sm:block text-right" ]
            [ div [ class "text-sm font-medium text-gray-200" ] [ text (Maybe.withDefault "Guest" (Maybe.map .username model.userProfile)) ]
            , div [ class "text-xs text-gray-400" ] [ text (Maybe.withDefault "White Belt" (Maybe.map (\p -> beltToString p.beltLevel ++ " Belt") model.userProfile)) ]
            ]
        , div [ class "w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full flex items-center justify-center" ]
            [ span [ class "text-sm font-bold text-white" ] 
                [ text (String.left 1 (Maybe.withDefault "G" (Maybe.map .username model.userProfile))) ]
            ]
        ]

sidebar : FrontendModel -> Html FrontendMsg
sidebar model =
    nav [ class "fixed left-0 top-0 z-sidebar w-72 h-full glass border-r border-gray-700 shadow-2xl"
        , attribute "role" "navigation"
        , attribute "aria-label" model.userConfig.t.navigation
        ]
        [ div [ class "flex flex-col h-full" ]
            [ header_ model
            , mainNav model  
            , progressSection model
            , div [ class "mt-auto" ]
                [ supportSection model ]
            ]
        ]

header_ : FrontendModel -> Html FrontendMsg
header_ model =
    div [ class "p-6 border-b border-gray-800" ]
        [ div [ class "flex items-center gap-3" ]
            [ div [ class "w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-500 rounded-xl flex items-center justify-center shadow-lg" ]
                [ i [ class "fas fa-fist-raised text-white text-lg", attribute "aria-hidden" "true" ] [] ]
            , div []
                [ h1 [ class "text-lg font-bold text-white" ] [ text model.userConfig.t.appTitle ]
                , div [ class "text-xs text-gray-500" ] [ text model.userConfig.t.appSubtitle ]
                ]
            ]
        ]

mainNav : FrontendModel -> Html FrontendMsg
mainNav model =
    let
        t = model.userConfig.t
    in
    div [ class "flex-1 px-4 py-6 overflow-y-auto" ]
        [ ul [ class "space-y-2" ]
            [ navItem model t.dashboard Dashboard "fas fa-tachometer-alt" False
            , navItem model t.heroes (HeroesRoute Nothing) "fas fa-users" False
            , navItem model t.academies (Academies Nothing) "fas fa-university" False
            , navItem model t.events (Events AllEvents) "fas fa-calendar" False
            , navItem model t.training Training "fas fa-dumbbell" True
            , navItem model t.profile Profile "fas fa-user" False
            ]
        ]

mobileMainNav : FrontendModel -> Html FrontendMsg
mobileMainNav model =
    let
        t = model.userConfig.t
    in
    div [ class "flex-1 px-4 py-6 overflow-y-auto" ]
        [ ul [ class "space-y-2" ]
            [ navItemMobileFirst model t.dashboard Dashboard "fas fa-tachometer-alt" False
            , navItem model t.heroes (HeroesRoute Nothing) "fas fa-users" False
            , navItem model t.academies (Academies Nothing) "fas fa-university" False
            , navItem model t.events (Events AllEvents) "fas fa-calendar" False
            , navItem model t.training Training "fas fa-dumbbell" True
            , navItem model t.profile Profile "fas fa-user" False
            ]
        ]

navItem : FrontendModel -> String -> Route -> String -> Bool -> Html FrontendMsg
navItem =
    navItemWithId ""

navItemMobileFirst : FrontendModel -> String -> Route -> String -> Bool -> Html FrontendMsg
navItemMobileFirst =
    navItemWithId "mobile-first-link"

navItemWithId : String -> FrontendModel -> String -> Route -> String -> Bool -> Html FrontendMsg
navItemWithId itemId model label route iconClass isAccented =
    let
        isActive = model.route == route
        baseClasses = "flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500"
        activeClasses = if isActive then
            "bg-gradient-to-r from-blue-500/30 to-purple-500/30 border border-blue-500/40 text-white shadow-lg shadow-blue-500/20"
          else if isAccented then
            "bg-gradient-to-r from-orange-500/10 to-red-500/10 border border-transparent hover:border-orange-500/30 text-orange-300 hover:from-orange-500/20 hover:to-red-500/20 hover:text-orange-200"
          else
            "text-gray-400 hover:bg-gray-800/50 hover:text-white border border-transparent hover:border-gray-700/50"
        href_ = Router.toPath route
        spaHandlers = if isInternalHref href_ then [ onPreventDefaultClick (NavigateTo route) ] else []
    in
    li []
        [ a ([ class (baseClasses ++ " " ++ activeClasses)
            , href href_
            , if isActive then attribute "aria-current" "page" else class ""
            ] ++ (if String.isEmpty itemId then [] else [ id itemId ]) ++ spaHandlers
            )
            [ i [ class (iconClass ++ " w-5 text-center transition-colors"), attribute "aria-hidden" "true" ] []
            , span [ class "font-medium" ] [ text label ]
            , if isActive then
                span [ class "ml-auto w-2 h-2 bg-blue-400 rounded-full animate-pulse" ] []
              else
                text ""
            ]
        ]

progressSection : FrontendModel -> Html FrontendMsg
progressSection model =
    div [ class "px-6 py-4 bg-gray-800/50 border-t border-gray-800" ]
        [ div [ class "mb-4" ]
            [ div [ class "flex items-center justify-between mb-2" ]
                [ span [ class "text-sm font-medium text-gray-300" ] [ text model.userConfig.t.dailyProgress ]
                , span [ class "text-xs text-gray-500" ] [ text "3/5 " ] -- TODO: Translate quests count
                ]
            , div [ class "w-full h-2 bg-gray-700/50 rounded-full overflow-hidden" ]
                [ div [ class "w-3/5 h-full bg-gradient-to-r from-green-500 to-blue-500 transition-all duration-500" ] [] ]
            ]
        , div [ class "grid grid-cols-2 gap-3 text-center" ]
            [ statCard model.userConfig.t.xpToday "245" "text-blue-400"
            , statCard model.userConfig.t.streak (I18n.formatStreak model.userConfig.language model.userProgress.currentStreak) "text-orange-400"
            ]
        ]

statCard : String -> String -> String -> Html FrontendMsg
statCard label value colorClass =
    div [ class "bg-gray-800/50 rounded-lg p-3" ]
        [ div [ class ("text-lg font-bold " ++ colorClass) ] [ text value ]
        , div [ class "text-xs text-gray-400" ] [ text label ]
        ]

supportSection : FrontendModel -> Html FrontendMsg  
supportSection model =
    div [ class "p-6 border-t border-gray-700/50" ]
        [ button 
            [ onClick (ShowNotification Info model.userConfig.t.helpComingSoon)
            , class "w-full flex items-center gap-3 px-4 py-3 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-xl text-purple-200 hover:from-purple-500/20 hover:to-pink-500/20 transition-all duration-200 cursor-pointer"
            , type_ "button"
            ]
            [ i [ class "fas fa-question-circle", attribute "aria-hidden" "true" ] []
            , span [ class "font-medium" ] [ text model.userConfig.t.helpSupport ]
            ]
        ]

mobileMenu : FrontendModel -> Html FrontendMsg
mobileMenu model =
    div [ class "lg:hidden fixed inset-0 z-mobile-menu" ]
        [ div [ class "fixed inset-0 bg-black/70", onClick ToggleMobileMenu ] []
        , nav [ class "fixed left-0 top-0 w-80 max-w-[85vw] h-full glass border-r border-gray-700 shadow-2xl transform transition-transform duration-300 translate-x-0"
              , attribute "role" "dialog"
              , attribute "aria-modal" "true"
              , attribute "aria-label" model.userConfig.t.navigation
              , tabindex 0
              , Events.on "keydown" (escapeKeyDecoder ToggleMobileMenu)
              , id "mobile-menu-dialog"
              ]
            [ div [ class "flex flex-col h-full" ]
                [ div [ class "flex items-center justify-between p-4 border-b border-gray-700/50" ]
                    [ h2 [ class "text-lg font-bold text-white", id "mobile-menu-title", tabindex -1 ] [ text model.userConfig.t.navigation ]
                    , button [ class "p-2 text-gray-400 hover:text-white", onClick ToggleMobileMenu, attribute "aria-label" "Close menu" ]
                        [ i [ class "fas fa-times", attribute "aria-hidden" "true" ] [] ]
                    ]
                , div [ class "flex-1 overflow-y-auto" ]
                    [ mobileMainNav model
                    , progressSection model
                    ]
                ]
            ]
        ]

beltToString : BeltLevel -> String
beltToString belt =
    case belt of
        White -> "White"
        Blue -> "Blue"
        Purple -> "Purple"
        Brown -> "Brown"
        Black -> "Black"


escapeKeyDecoder : FrontendMsg -> Decode.Decoder FrontendMsg
escapeKeyDecoder msg =
    Decode.field "key" Decode.string
        |> Decode.andThen (\key ->
            if key == "Escape" then
                Decode.succeed msg
            else
                Decode.fail "Not escape key"
        )


