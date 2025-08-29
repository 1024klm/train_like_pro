module Components.GameUI exposing (..)

import Html exposing (Html, div, span, text, i, button, p)
import Html.Attributes exposing (class, attribute, style)
import Html.Events exposing (onClick)
import Types exposing (..)
import Theme exposing (darkTheme)

-- XP BAR COMPONENT

type alias XPBarConfig =
    { currentXP : Int
    , maxXP : Int
    , level : Int
    , animated : Bool
    , size : XPBarSize
    }

type XPBarSize 
    = Small
    | Medium 
    | Large

xpBar : XPBarConfig -> Html msg
xpBar config =
    let
        percentage = min 100 (toFloat config.currentXP / toFloat config.maxXP * 100)
        (heightClass, textSize, levelSize) = 
            case config.size of
                Small -> ("h-2", "text-xs", "text-sm")
                Medium -> ("h-4", "text-sm", "text-base")
                Large -> ("h-6", "text-base", "text-lg")
        animationClass = if config.animated then "animate-pulse" else ""
    in
    div [ class "w-full" ]
        [ div [ class ("relative " ++ heightClass ++ " bg-gray-800/50 rounded-full overflow-hidden backdrop-blur-sm") ]
            [ div 
                [ class ("h-full bg-gradient-to-r from-cyan-400 via-blue-500 to-purple-500 transition-all duration-1000 ease-out " ++ animationClass)
                , attribute "style" ("width: " ++ String.fromFloat percentage ++ "%")
                ]
                [ -- Shimmer Effect
                  div [ class "absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-pulse" ] []
                ]
            , if config.size /= Small then
                div [ class "absolute inset-0 flex items-center justify-center" ]
                    [ span [ class (textSize ++ " font-bold text-white drop-shadow-lg") ]
                        [ text (String.fromInt config.currentXP ++ " / " ++ String.fromInt config.maxXP ++ " XP") ]
                    ]
              else
                text ""
            ]
        ]

-- LEVEL BADGE COMPONENT

levelBadge : Int -> String -> Html msg
levelBadge level title =
    div [ class "flex items-center gap-3" ]
        [ div [ class "text-6xl font-black bg-gradient-to-r from-yellow-400 to-orange-500 bg-clip-text text-transparent" ]
            [ text (String.fromInt level) ]
        , div [ class "text-left" ]
            [ div [ class "text-3xl font-bold text-white" ] [ text "LEVEL" ]
            , div [ class "px-4 py-1 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full text-sm font-bold tracking-wider" ]
                [ text (String.toUpper title) ]
            ]
        ]

-- STAT CARD COMPONENT

type alias StatCardConfig =
    { title : String
    , value : String
    , icon : String
    , gradient : String
    , trend : Maybe StatTrend
    }

type StatTrend = Up | Down | Neutral

statCard : StatCardConfig -> Html msg
statCard config =
    div [ class "bg-gray-800/50 backdrop-blur-sm border border-gray-700/50 rounded-xl p-4 hover:bg-gray-800/70 transition-all group" ]
        [ div [ class "flex items-center justify-between mb-3" ]
            [ div [ class ("w-10 h-10 bg-gradient-to-r " ++ config.gradient ++ " rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform") ]
                [ i [ class (config.icon ++ " text-white text-lg") ] [] ]
            , div [ class "text-right" ]
                [ span [ class "text-xs font-medium text-gray-400 uppercase tracking-wider block" ] [ text config.title ]
                , case config.trend of
                    Just Up -> i [ class "fas fa-arrow-up text-green-400 text-xs" ] []
                    Just Down -> i [ class "fas fa-arrow-down text-red-400 text-xs" ] []
                    _ -> text ""
                ]
            ]
        , div [ class "text-2xl font-black text-white" ] [ text config.value ]
        ]

-- PROGRESS RING COMPONENT

type alias ProgressRingConfig =
    { percentage : Float
    , size : Int
    , strokeWidth : Int
    , color : String
    , backgroundColor : String
    , showPercentage : Bool
    }

progressRing : ProgressRingConfig -> Html msg
progressRing config =
    let
        radius = toFloat (config.size // 2 - config.strokeWidth)
        circumference = 2 * pi * radius
        strokeDashoffset = circumference * (1 - config.percentage / 100)
        center = toFloat (config.size // 2)
    in
    div [ class "relative inline-block" ]
        [ Html.node "svg"
            [ attribute "width" (String.fromInt config.size)
            , attribute "height" (String.fromInt config.size)
            , class "transform -rotate-90"
            ]
            [ Html.node "circle"
                [ attribute "cx" (String.fromFloat center)
                , attribute "cy" (String.fromFloat center)
                , attribute "r" (String.fromFloat radius)
                , attribute "stroke" config.backgroundColor
                , attribute "stroke-width" (String.fromInt config.strokeWidth)
                , attribute "fill" "none"
                ]
                []
            , Html.node "circle"
                [ attribute "cx" (String.fromFloat center)
                , attribute "cy" (String.fromFloat center)
                , attribute "r" (String.fromFloat radius)
                , attribute "stroke" config.color
                , attribute "stroke-width" (String.fromInt config.strokeWidth)
                , attribute "fill" "none"
                , attribute "stroke-dasharray" (String.fromFloat circumference)
                , attribute "stroke-dashoffset" (String.fromFloat strokeDashoffset)
                , attribute "stroke-linecap" "round"
                , class "transition-all duration-1000 ease-out"
                ]
                []
            ]
        , if config.showPercentage then
            div [ class "absolute inset-0 flex items-center justify-center" ]
                [ span [ class "text-xl font-bold text-white" ] 
                    [ text (String.fromInt (round config.percentage) ++ "%") ]
                ]
          else
            text ""
        ]

-- QUEST CARD COMPONENT

type alias QuestCardConfig =
    { title : String
    , description : String
    , progress : Float
    , xpReward : Int
    , completed : Bool
    , onComplete : Maybe msg
    }

questCard : QuestCardConfig -> Html msg
questCard config =
    div 
        [ class (if config.completed then 
                    "p-4 bg-green-500/20 border border-green-500/30 rounded-xl opacity-80" 
                 else 
                    "p-4 bg-gray-700/30 border border-gray-600/50 rounded-xl hover:bg-gray-700/50 transition-all group")
        ]
        [ div [ class "flex items-center gap-4" ]
            [ -- Quest Status Icon
              div [ class "flex-shrink-0" ]
                [ if config.completed then
                    div [ class "w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center" ]
                        [ i [ class "fas fa-check text-white text-sm" ] [] ]
                  else
                    div [ class "w-8 h-8 bg-gray-600/50 border-2 border-gray-500 rounded-lg group-hover:border-blue-500 transition-colors" ] []
                ]
                
              -- Quest Details
            , div [ class "flex-1 min-w-0" ]
                [ div [ class (if config.completed then "font-bold text-green-400" else "font-bold text-white") ] 
                    [ text config.title ]
                , p [ class "text-sm text-gray-400 mt-1" ] 
                    [ text config.description ]
                , if not config.completed then
                    div [ class "mt-3" ]
                        [ div [ class "flex items-center justify-between mb-1" ]
                            [ span [ class "text-xs text-gray-400" ] [ text "PROGRESS" ]
                            , span [ class "text-xs text-blue-400 font-medium" ] 
                                [ text (String.fromInt (round (config.progress * 100)) ++ "%") ]
                            ]
                        , div [ class "h-2 bg-gray-800/50 rounded-full overflow-hidden" ]
                            [ div 
                                [ class "h-full bg-gradient-to-r from-blue-500 to-purple-500 transition-all duration-300"
                                , attribute "style" ("width: " ++ String.fromFloat (config.progress * 100) ++ "%")
                                ]
                                []
                            ]
                        ]
                  else
                    text ""
                ]
                
              -- XP Reward
            , div [ class "flex-shrink-0 text-right" ]
                [ if config.completed then
                    div [ class "text-green-400" ]
                        [ i [ class "fas fa-check-circle text-2xl" ] [] ]
                  else
                    div [ class "px-3 py-2 bg-gradient-to-r from-yellow-500/20 to-orange-500/20 border border-yellow-500/30 rounded-lg" ]
                        [ div [ class "text-yellow-400 font-bold text-lg" ] [ text ("+" ++ String.fromInt config.xpReward) ]
                        , div [ class "text-yellow-300/60 text-xs font-medium" ] [ text "XP" ]
                        ]
                ]
            ]
        ]

-- ACHIEVEMENT BADGE COMPONENT

type alias AchievementBadgeConfig =
    { name : String
    , description : String
    , icon : String
    , rarity : AchievementRarity
    , unlocked : Bool
    }

type AchievementRarity = Common | Rare | Epic | Legendary

achievementBadge : AchievementBadgeConfig -> Html msg
achievementBadge config =
    let
        (bgGradient, borderColor, glowClass) = 
            case config.rarity of
                Common -> ("from-gray-500/10 to-gray-600/10", "border-gray-500/30", "")
                Rare -> ("from-blue-500/10 to-cyan-500/10", "border-blue-500/30", "hover:shadow-blue-500/20 hover:shadow-lg")
                Epic -> ("from-purple-500/10 to-pink-500/10", "border-purple-500/30", "hover:shadow-purple-500/20 hover:shadow-lg")
                Legendary -> ("from-yellow-500/10 to-orange-500/10", "border-yellow-500/30", "hover:shadow-yellow-500/20 hover:shadow-2xl")
        
        opacityClass = if config.unlocked then "" else "opacity-50 grayscale"
    in
    div 
        [ class ("p-4 bg-gradient-to-br " ++ bgGradient ++ " border " ++ borderColor ++ " rounded-xl text-center transition-all group hover:scale-105 " ++ glowClass ++ " " ++ opacityClass)
        , attribute "title" config.description
        ]
        [ div [ class "w-12 h-12 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center mx-auto mb-3 group-hover:scale-110 transition-transform" ]
            [ span [ class "text-2xl" ] [ text config.icon ] ]
        , div [ class "font-bold text-white text-sm" ] [ text config.name ]
        , div [ class "text-xs text-gray-400 mt-1" ] 
            [ text (if config.unlocked then "EARNED" else "LOCKED") ]
        ]

-- BELT PROGRESS COMPONENT

type alias BeltProgressConfig =
    { currentBelt : String
    , nextBelt : String
    , progress : Float
    , beltColor : String
    }

beltProgress : BeltProgressConfig -> Html msg
beltProgress config =
    div [ class "flex items-center gap-4" ]
        [ div [ class ("px-4 py-2 " ++ config.beltColor ++ " rounded-lg font-bold") ]
            [ text (String.toUpper config.currentBelt) ]
        , div [ class "flex-1 min-w-0" ]
            [ div [ class "flex items-center justify-between mb-1" ]
                [ span [ class "text-xs text-gray-400" ] [ text ("PROGRESS TO " ++ String.toUpper config.nextBelt) ]
                , span [ class "text-xs text-gray-300 font-medium" ] [ text (String.fromInt (round (config.progress * 100)) ++ "%") ]
                ]
            , div [ class "h-2 bg-gray-800/50 rounded-full overflow-hidden" ]
                [ div 
                    [ class ("h-full transition-all duration-500 " ++ config.beltColor)
                    , attribute "style" ("width: " ++ String.fromFloat (config.progress * 100) ++ "%")
                    ]
                    []
                ]
            ]
        ]

-- ANIMATED COUNTER COMPONENT

type alias AnimatedCounterConfig =
    { value : Int
    , label : String
    , prefix : String
    , suffix : String
    , color : String
    , size : CounterSize
    }

type CounterSize = CounterSmall | CounterMedium | CounterLarge

animatedCounter : AnimatedCounterConfig -> Html msg
animatedCounter config =
    let
        (textSize, labelSize) = 
            case config.size of
                CounterSmall -> ("text-lg", "text-xs")
                CounterMedium -> ("text-2xl", "text-sm")
                CounterLarge -> ("text-4xl", "text-base")
    in
    div [ class "text-center" ]
        [ div [ class (textSize ++ " font-black " ++ config.color ++ " animate-pulse") ]
            [ text (config.prefix ++ String.fromInt config.value ++ config.suffix) ]
        , div [ class (labelSize ++ " text-gray-400 mt-1") ] 
            [ text (String.toUpper config.label) ]
        ]

-- GLOW BUTTON COMPONENT

type alias GlowButtonConfig msg =
    { text : String
    , icon : Maybe String
    , gradient : String
    , size : ButtonSize
    , onClick : Maybe msg
    }

type ButtonSize = ButtonSmall | ButtonMedium | ButtonLarge

glowButton : GlowButtonConfig msg -> Html msg
glowButton config =
    let
        (paddingClass, textSize, iconSize) = 
            case config.size of
                ButtonSmall -> ("px-4 py-2", "text-sm", "text-sm")
                ButtonMedium -> ("px-6 py-3", "text-base", "text-base")
                ButtonLarge -> ("px-8 py-4", "text-lg", "text-xl")
    in
    button 
        [ class ("bg-gradient-to-r " ++ config.gradient ++ " text-white rounded-xl font-bold hover:scale-105 transition-all duration-200 hover:shadow-2xl " ++ paddingClass ++ " " ++ textSize)
        , case config.onClick of
            Just msg -> onClick msg
            Nothing -> class ""
        ]
        [ case config.icon of
            Just iconClass -> 
                span [] 
                    [ i [ class (iconClass ++ " mr-2 " ++ iconSize) ] []
                    , text config.text
                    ]
            Nothing -> 
                text config.text
        ]