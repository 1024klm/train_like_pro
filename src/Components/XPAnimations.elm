module Components.XPAnimations exposing
    ( viewXPPopup
    , viewLevelUpAnimation
    , animateXPGain
    , viewProgressBar
    , viewComboMultiplier
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Time


-- XP GAIN POPUP ANIMATION

viewXPPopup : Maybe XPAnimation -> Html msg
viewXPPopup maybeAnimation =
    case maybeAnimation of
        Nothing ->
            text ""
            
        Just animation ->
            div 
                [ class "fixed pointer-events-none z-50 animate-bounce"
                , style "left" (String.fromInt animation.position.x ++ "px")
                , style "top" (String.fromInt animation.position.y ++ "px")
                , style "transform" "translate(-50%, -100%)"
                ]
                [ div [ class "bg-gradient-to-r from-yellow-400 to-orange-500 text-white px-4 py-2 rounded-full font-bold shadow-lg animate-pulse" ]
                    [ text ("+" ++ String.fromInt animation.amount ++ " XP") ]
                ]


-- LEVEL UP ANIMATION

viewLevelUpAnimation : Bool -> Int -> Html msg
viewLevelUpAnimation isActive level =
    if isActive then
        div [ class "fixed inset-0 flex items-center justify-center z-50 pointer-events-none" ]
            [ div [ class "bg-black bg-opacity-50 absolute inset-0" ] []
            , div [ class "relative animate-bounce" ]
                [ div [ class "bg-gradient-to-r from-purple-600 to-indigo-600 text-white px-12 py-8 rounded-3xl shadow-2xl text-center transform scale-110" ]
                    [ div [ class "text-6xl mb-4 animate-pulse" ] [ text "🎉" ]
                    , h2 [ class "text-4xl font-bold mb-2" ] [ text "LEVEL UP!" ]
                    , p [ class "text-2xl font-semibold" ] [ text ("Level " ++ String.fromInt level) ]
                    , div [ class "mt-4 flex justify-center space-x-2" ]
                        [ span [ class "text-3xl animate-bounce" ] [ text "⭐" ]
                        , span [ class "text-3xl animate-bounce animation-delay-100" ] [ text "⭐" ]
                        , span [ class "text-3xl animate-bounce animation-delay-200" ] [ text "⭐" ]
                        ]
                    ]
                ]
            ]
    else
        text ""


-- XP ANIMATION TRIGGER

animateXPGain : Int -> Position -> FrontendMsg
animateXPGain amount position =
    AnimateXP amount position


-- ANIMATED PROGRESS BAR

viewProgressBar : Float -> String -> Html msg
viewProgressBar progress colorClass =
    div [ class "relative h-4 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden shadow-inner" ]
        [ -- Background glow effect
          div [ class "absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-20 animate-pulse" ] []
          
          -- Progress fill with gradient
        , div 
            [ class ("h-full rounded-full transition-all duration-1000 ease-out " ++ colorClass)
            , style "width" (String.fromFloat (min 100 progress) ++ "%")
            ]
            [ -- Animated shine effect
              div [ class "h-full w-full bg-gradient-to-r from-transparent via-white to-transparent opacity-30 animate-pulse" ] []
            ]
            
          -- Progress text overlay
        , div [ class "absolute inset-0 flex items-center justify-center" ]
            [ span [ class "text-xs font-bold text-gray-700 dark:text-gray-300 drop-shadow-sm" ]
                [ text (String.fromInt (round progress) ++ "%") ]
            ]
        ]


-- COMBO MULTIPLIER INDICATOR

viewComboMultiplier : Int -> Html msg
viewComboMultiplier combo =
    if combo > 1 then
        div [ class "inline-flex items-center gap-2 px-3 py-1 bg-gradient-to-r from-orange-500 to-red-500 text-white rounded-full font-bold shadow-lg animate-pulse" ]
            [ span [ class "text-lg" ] [ text "🔥" ]
            , text (String.fromInt combo ++ "x COMBO!")
            , span [ class "text-lg" ] [ text "🔥" ]
            ]
    else
        text ""


-- SKILL TREE GLOW EFFECT

viewSkillGlow : SkillProgress -> Html msg
viewSkillGlow skill =
    let
        glowIntensity =
            case skill.level of
                level if level >= 8 -> "shadow-2xl shadow-purple-500/50 animate-pulse"
                level if level >= 5 -> "shadow-xl shadow-blue-500/50"
                level if level >= 3 -> "shadow-lg shadow-green-500/50"
                _ -> ""
    in
    div [ class ("absolute inset-0 rounded-full " ++ glowIntensity) ] []


-- MASTERY LEVEL ANIMATION

viewMasteryAnimation : MasteryLevel -> Html msg
viewMasteryAnimation mastery =
    let
        (color, icon, animation) =
            case mastery of
                Learning -> ("text-yellow-600", "🟫", "")
                Practicing -> ("text-gray-400", "⚪", "animate-bounce")
                Proficient -> ("text-yellow-500", "🟡", "animate-pulse")
                MasteryAdvanced -> ("text-gray-800", "⚫", "animate-spin")
                MasteryComplete -> ("text-blue-400", "💎", "animate-bounce animate-pulse")
    in
    div [ class ("text-4xl " ++ color ++ " " ++ animation) ]
        [ text icon ]


-- STREAK FIRE ANIMATION

viewStreakFire : Int -> Html msg
viewStreakFire streak =
    if streak >= 7 then
        div [ class "flex items-center gap-1" ]
            [ div [ class "text-2xl animate-bounce" ] [ text "🔥" ]
            , span [ class "font-bold text-orange-500" ] [ text (String.fromInt streak) ]
            , div [ class "text-2xl animate-bounce animation-delay-100" ] [ text "🔥" ]
            ]
    else if streak >= 3 then
        div [ class "flex items-center gap-1" ]
            [ div [ class "text-xl animate-pulse" ] [ text "🔥" ]
            , span [ class "font-bold text-orange-500" ] [ text (String.fromInt streak) ]
            ]
    else
        span [ class "font-bold text-gray-600" ] [ text (String.fromInt streak) ]


-- ACHIEVEMENT POPUP

viewAchievementUnlocked : Achievement -> Html msg
viewAchievementUnlocked achievement =
    div [ class "fixed bottom-4 right-4 z-50 animate-slide-in-right" ]
        [ div [ class "bg-gradient-to-r from-yellow-400 to-orange-500 text-white p-6 rounded-lg shadow-2xl max-w-sm" ]
            [ div [ class "flex items-center gap-4" ]
                [ div [ class "text-4xl animate-bounce" ] [ text achievement.icon ]
                , div []
                    [ h3 [ class "font-bold text-lg" ] [ text "Achievement Unlocked!" ]
                    , p [ class "font-semibold" ] [ text achievement.name ]
                    , p [ class "text-sm opacity-90" ] [ text achievement.description ]
                    ]
                ]
            ]
        ]


-- TECHNIQUE MASTERY PARTICLES

viewMasteryParticles : Bool -> Html msg
viewMasteryParticles isActive =
    if isActive then
        div [ class "absolute inset-0 pointer-events-none overflow-hidden" ]
            [ -- Floating particles
              div [ class "absolute top-1/4 left-1/4 w-2 h-2 bg-yellow-400 rounded-full animate-bounce animation-delay-0" ] []
            , div [ class "absolute top-1/3 right-1/4 w-1 h-1 bg-orange-400 rounded-full animate-bounce animation-delay-200" ] []
            , div [ class "absolute bottom-1/4 left-1/3 w-3 h-3 bg-purple-400 rounded-full animate-bounce animation-delay-400" ] []
            , div [ class "absolute bottom-1/3 right-1/3 w-1 h-1 bg-pink-400 rounded-full animate-bounce animation-delay-600" ] []
            ]
    else
        text ""


-- DAILY QUEST COMPLETION CELEBRATION

viewQuestComplete : Quest -> Html msg
viewQuestComplete quest =
    div [ class "animate-bounce" ]
        [ div [ class "flex items-center gap-3 p-4 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-lg shadow-lg" ]
            [ div [ class "text-3xl animate-spin" ] [ text "✅" ]
            , div []
                [ h4 [ class "font-bold" ] [ text "Quest Complete!" ]
                , p [] [ text quest.title ]
                , p [ class "text-sm" ] [ text ("+" ++ String.fromInt quest.xpReward ++ " XP") ]
                ]
            ]
        ]


-- CSS ANIMATIONS (to be added to styles.css)

cssAnimations : String
cssAnimations = """
@keyframes slide-in-right {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes xp-float {
  0% {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
  50% {
    transform: translateY(-20px) scale(1.1);
    opacity: 0.8;
  }
  100% {
    transform: translateY(-40px) scale(0.8);
    opacity: 0;
  }
}

.animation-delay-100 {
  animation-delay: 100ms;
}

.animation-delay-200 {
  animation-delay: 200ms;
}

.animation-delay-400 {
  animation-delay: 400ms;
}

.animation-delay-600 {
  animation-delay: 600ms;
}

.animate-slide-in-right {
  animation: slide-in-right 0.5s ease-out;
}
"""