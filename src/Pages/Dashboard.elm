module Pages.Dashboard exposing (view, viewDashboard)

import Html exposing (..)
import Html.Attributes exposing (class, id, href, src, alt, type_, attribute, style, title)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Types exposing (..)
import GameMechanics.XP as XP
import Dict exposing (Dict)
import Set exposing (Set)
import Time
import I18n
import Theme exposing (darkTheme)


-- MAIN DASHBOARD VIEW

view : FrontendModel -> Html FrontendMsg
view model =
    viewDashboard model


viewDashboard : FrontendModel -> Html FrontendMsg
viewDashboard model =
    div [ class "min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900" ]
        [ -- Hero Header with XP and Level
          viewHeroHeader model
          
          -- Main Dashboard Grid
        , div [ class "px-4 lg:px-6 pb-8 space-y-6" ]
            [ -- Quick Stats Row
              viewQuickStats model
              
              -- Main Content Grid
            , div [ class "grid grid-cols-1 lg:grid-cols-3 gap-6" ]
                [ -- Left Column (2/3 width)
                  div [ class "lg:col-span-2 space-y-6" ]
                    [ viewTodaysFocus model
                    , viewActiveRoadmaps model
                    , viewRecentAchievements model
                    ]
                    
                  -- Right Column (1/3 width)
                , div [ class "space-y-6" ]
                    [ viewDailyQuests model model.userProgress.dailyQuests
                    , viewWeeklyProgress model
                    , viewTechniqueProgress model
                    ]
                ]
            ]
        ]


-- XP HEADER BAR

viewHeroHeader : FrontendModel -> Html FrontendMsg
viewHeroHeader model =
    let
        progress = model.userProgress
        (level, levelProgress) = XP.levelFromXP progress.totalXP
        xpInCurrentLevel = round (levelProgress * 1000)
        title = XP.getTitleForLevel level
        (currentBelt, beltProgress) = XP.getBeltProgress progress.totalXP White
    in
    div [ class "relative overflow-hidden bg-gradient-to-r from-gray-900 via-blue-900 to-purple-900" ]
        [ -- Background Glow Effects
          div [ class "absolute inset-0 opacity-30" ]
            [ div [ class "absolute top-0 left-0 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl animate-pulse" ] []
            , div [ class "absolute bottom-0 right-0 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl animate-pulse delay-1000" ] []
            ]
            
          -- Content
        , div [ class "relative px-4 lg:px-6 py-8" ]
            [ div [ class "flex flex-col lg:flex-row items-center justify-between gap-6" ]
                [ -- Left: Level and Title
                  div [ class "text-center lg:text-left" ]
                    [ div [ class "flex items-center justify-center lg:justify-start gap-4 mb-3" ]
                        [ div [ class "text-6xl font-black bg-gradient-to-r from-yellow-400 to-orange-500 bg-clip-text text-transparent" ]
                            [ text (String.fromInt level) ]
                        , div [ class "text-left" ]
                            [ div [ class "text-3xl font-bold text-white" ] [ text "LEVEL" ]
                            , div [ class "px-4 py-1 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full text-sm font-bold tracking-wider" ]
                                [ text (String.toUpper title.name) ]
                            ]
                        ]
                    , viewBeltBadge currentBelt beltProgress
                    ]
                    
                  -- Right: XP Progress
                , div [ class "w-full lg:w-96" ]
                    [ div [ class "flex items-center justify-between mb-2" ]
                        [ span [ class "text-sm font-medium text-gray-300" ] [ text "EXPERIENCE" ]
                        , span [ class "text-2xl font-bold text-blue-400" ] [ text (String.fromInt progress.totalXP ++ " XP") ]
                        ]
                    , div [ class "relative h-6 bg-gray-800/50 rounded-full overflow-hidden backdrop-blur-sm border border-gray-700/50" ]
                        [ div 
                            [ class "h-full bg-gradient-to-r from-cyan-400 via-blue-500 to-purple-500 transition-all duration-1000 ease-out relative"
                            , attribute "style" ("width: " ++ String.fromFloat (levelProgress * 100) ++ "%")
                            ]
                            [ -- Shimmer Effect
                              div [ class "absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-pulse" ] []
                            ]
                        , div [ class "absolute inset-0 flex items-center justify-center" ]
                            [ span [ class "text-xs font-bold text-white drop-shadow-lg" ]
                                [ text (String.fromInt xpInCurrentLevel ++ " / 1000 " ++ model.userConfig.t.xpToLevelUp) ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


-- TODAY'S FOCUS CARD

viewTodaysFocus : FrontendModel -> Html FrontendMsg
viewTodaysFocus model =
    div [ class "bg-gray-800/30 backdrop-blur-sm border border-gray-700/50 rounded-2xl p-6" ]
        [ div [ class "flex items-center gap-3 mb-6" ]
            [ div [ class "w-12 h-12 bg-gradient-to-r from-orange-500 to-red-500 rounded-xl flex items-center justify-center" ]
                [ i [ class "fas fa-crosshairs text-white text-xl" ] [] ]
            , div []
                [ h2 [ class "text-2xl font-bold text-white" ] [ text model.userConfig.t.todaysFocus ]
                , p [ class "text-gray-400 text-sm" ] [ text model.userConfig.t.todaysFocusSubtitle ]
                ]
            ]
            
        , case model.activeSession of
            Just session ->
                viewActiveSessionCard model session
                
            Nothing ->
                viewStartSessionPrompt model
        ]


viewActiveSessionCard : FrontendModel -> ActiveSession -> Html FrontendMsg
viewActiveSessionCard model session =
    div [ class "space-y-4" ]
        [ -- Active Session Header
          div [ class "flex items-center justify-between p-4 bg-gradient-to-r from-green-500/20 to-emerald-500/20 border border-green-500/30 rounded-xl" ]
            [ div [ class "flex items-center gap-3" ]
                [ div [ class "w-10 h-10 bg-green-500 rounded-full flex items-center justify-center animate-pulse" ]
                    [ i [ class "fas fa-play text-white" ] [] ]
                , div []
                    [ p [ class "text-sm font-medium text-green-400" ] [ text model.userConfig.t.trainingActive ]
                    , p [ class "text-2xl font-bold text-white" ] 
                        [ text (formatTimer 0) ] -- TODO: calculate from session.startTime
                    ]
                ]
            , button 
                [ onClick EndSession
                , class "px-6 py-2 bg-red-500/80 hover:bg-red-500 text-white rounded-lg font-medium transition-all hover:scale-105"
                ]
                [ i [ class "fas fa-stop mr-2" ] []
                , text model.userConfig.t.endSession
                ]
            ]
            
          -- Current Technique Focus
        , case session.currentTechnique of
            Just techniqueId ->
                div [ class "p-4 bg-gradient-to-r from-blue-500/20 to-purple-500/20 border border-blue-500/30 rounded-xl" ]
                    [ div [ class "flex items-center justify-between mb-3" ]
                        [ h3 [ class "font-bold text-white" ] [ text model.userConfig.t.currentDrill ]
                        , span [ class "px-3 py-1 bg-blue-500/50 text-blue-200 rounded-full text-xs font-medium" ] [ text "FOCUS" ]
                        ]
                    , p [ class "text-xl text-blue-300 mb-4" ] [ text techniqueId ]
                    , div [ class "flex gap-3" ]
                        [ button 
                            [ onClick (IncrementReps techniqueId)
                            , class "flex-1 py-3 bg-gradient-to-r from-cyan-500 to-blue-500 text-white rounded-lg font-bold hover:scale-105 transition-transform"
                            ] 
                            [ i [ class "fas fa-plus mr-2" ] []
                            , text model.userConfig.t.addRep
                            ]
                        , button 
                            [ onClick (SetQuality techniqueId 5)
                            , class "flex-1 py-3 bg-gradient-to-r from-yellow-500 to-orange-500 text-white rounded-lg font-bold hover:scale-105 transition-transform"
                            ] 
                            [ i [ class "fas fa-star mr-2" ] []
                            , text model.userConfig.t.perfect
                            ]
                        ]
                    ]
                    
            Nothing ->
                div [ class "p-4 bg-gray-700/50 border border-gray-600 rounded-xl text-center" ]
                    [ p [ class "text-gray-400 mb-3" ] [ text model.userConfig.t.chooseNextTechnique ]
                    , button 
                        [ onClick (OpenModal (TechniqueSelectionModal))
                        , class "px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-medium cursor-pointer"
                        , type_ "button"
                        ]
                        [ text model.userConfig.t.selectTechnique ]
                    ]
                
          -- Session Stats
        , div [ class "grid grid-cols-2 gap-4" ]
            [ div [ class "p-4 bg-purple-500/20 border border-purple-500/30 rounded-xl text-center" ]
                [ p [ class "text-sm text-purple-300 mb-1" ] [ text "SESSION XP" ]
                , p [ class "text-2xl font-bold text-purple-400" ] 
                    [ text ("+" ++ String.fromInt session.totalXP) ]
                ]
            , div [ class "p-4 bg-orange-500/20 border border-orange-500/30 rounded-xl text-center" ]
                [ p [ class "text-sm text-orange-300 mb-1" ] [ text "TECHNIQUES" ]
                , p [ class "text-2xl font-bold text-orange-400" ] [ text "3" ]
                ]
            ]
        ]


viewStartSessionPrompt : FrontendModel -> Html FrontendMsg
viewStartSessionPrompt model =
    div [ class "text-center py-12" ]
        [ div [ class "w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-500 rounded-2xl flex items-center justify-center mx-auto mb-6" ]
            [ i [ class "fas fa-dumbbell text-white text-2xl" ] [] ]
        , h3 [ class "text-2xl font-bold text-white mb-3" ] [ text model.userConfig.t.readyToTrain ]
        , p [ class "text-gray-400 mb-6" ] [ text model.userConfig.t.readyToTrainSubtitle ]
        , button 
            [ onClick StartSession
            , class "px-8 py-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-xl font-bold text-lg hover:from-blue-600 hover:to-purple-600 transition-all transform hover:scale-105 hover:shadow-2xl"
            ]
            [ i [ class "fas fa-play mr-3" ] []
            , text model.userConfig.t.startTraining
            ]
        ]


-- QUICK STATS

viewQuickStats : FrontendModel -> Html FrontendMsg
viewQuickStats model =
    div [ class "grid grid-cols-2 lg:grid-cols-4 gap-4" ]
        [ quickStatCard model.userConfig.t.trainingStreak (I18n.formatStreak model.userConfig.language model.userProgress.currentStreak) "fas fa-fire" "from-orange-500 to-red-500"
        , quickStatCard model.userConfig.t.xpToday "245 XP" "fas fa-bolt" "from-cyan-500 to-blue-500"
        , quickStatCard model.userConfig.t.techniques (String.fromInt (Dict.size model.userProgress.techniqueMastery)) "fas fa-fist-raised" "from-purple-500 to-pink-500"
        , quickStatCard model.userConfig.t.rank "#127" "fas fa-trophy" "from-yellow-500 to-orange-500"
        ]

quickStatCard : String -> String -> String -> String -> Html FrontendMsg
quickStatCard label value iconClass gradient =
    div [ class ("bg-gray-800/50 backdrop-blur-sm border border-gray-700/50 rounded-xl p-4 hover:bg-gray-800/70 transition-all group") ]
        [ div [ class "flex items-center justify-between mb-3" ]
            [ div [ class ("w-10 h-10 bg-gradient-to-r " ++ gradient ++ " rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform") ]
                [ i [ class (iconClass ++ " text-white text-lg") ] [] ]
            , span [ class "text-xs font-medium text-gray-400 uppercase tracking-wider" ] [ text label ]
            ]
        , div [ class "text-2xl font-black text-white" ] [ text value ]
        ]


-- BELT BADGE

viewBeltBadge : BeltLevel -> Float -> Html msg
viewBeltBadge belt progress =
    let
        (bgColor, textColor, nextBeltName) = 
            case belt of
                White -> ("bg-gray-100", "text-gray-800", "BLUE BELT")
                Blue -> ("bg-blue-500", "text-white", "PURPLE BELT")
                Purple -> ("bg-purple-500", "text-white", "BROWN BELT")
                Brown -> ("bg-yellow-800", "text-white", "BLACK BELT")
                Black -> ("bg-black", "text-white", "MASTER")
    in
    div [ class "flex items-center gap-4" ]
        [ div [ class ("px-4 py-2 " ++ bgColor ++ " " ++ textColor ++ " rounded-lg font-bold") ]
            [ text (String.toUpper (beltLevelToString belt)) ]
        , if belt /= Black then
            div [ class "flex-1 min-w-0" ]
                [ div [ class "flex items-center justify-between mb-1" ]
                    [ span [ class "text-xs text-gray-400" ] [ text ("PROGRESS TO " ++ nextBeltName) ]
                    , span [ class "text-xs text-gray-300 font-medium" ] [ text (String.fromInt (round (progress * 100)) ++ "%") ]
                    ]
                , div [ class "h-2 bg-gray-800/50 rounded-full overflow-hidden" ]
                    [ div 
                        [ class ("h-full transition-all duration-500 " ++ beltProgressBarColor belt)
                        , attribute "style" ("width: " ++ String.fromFloat (progress * 100) ++ "%")
                        ]
                        []
                    ]
                ]
          else
            text ""
        ]


viewWeeklyProgress : FrontendModel -> Html msg
viewWeeklyProgress model =
    let
        weeklyXP = model.userProgress.weeklyGoals.currentXP
        weeklyTarget = model.userProgress.weeklyGoals.totalXPTarget
        percentage = if weeklyTarget > 0 then
                        toFloat weeklyXP / toFloat weeklyTarget * 100
                     else
                        0
    in
    div [ class "bg-gray-800/30 backdrop-blur-sm border border-gray-700/50 rounded-2xl p-6" ]
        [ div [ class "flex items-center gap-3 mb-6" ]
            [ div [ class "w-12 h-12 bg-gradient-to-r from-green-500 to-emerald-500 rounded-xl flex items-center justify-center" ]
                [ i [ class "fas fa-chart-line text-white text-xl" ] [] ]
            , div []
                [ h3 [ class "text-xl font-bold text-white" ] [ text "WEEKLY GOAL" ]
                , p [ class "text-gray-400 text-sm" ] [ text "XP target progress" ]
                ]
            ]
        , div [ class "text-center mb-4" ]
            [ div [ class "text-4xl font-black text-white mb-2" ] 
                [ text (String.fromInt weeklyXP) ]
            , div [ class "text-gray-400" ] 
                [ text ("of " ++ String.fromInt weeklyTarget ++ " XP") ]
            ]
        , div [ class "h-4 bg-gray-800/50 rounded-full overflow-hidden mb-3" ]
            [ div 
                [ class "h-full bg-gradient-to-r from-green-400 to-emerald-500 transition-all duration-500"
                , attribute "style" ("width: " ++ String.fromFloat percentage ++ "%")
                ]
                []
            ]
        , div [ class "text-center" ]
            [ span [ class "text-2xl font-bold text-green-400" ] [ text (String.fromInt (round percentage) ++ "%") ]
            , span [ class "text-gray-400 ml-2" ] [ text "COMPLETE" ]
            ]
        ]


viewTechniqueProgress : FrontendModel -> Html msg
viewTechniqueProgress model =
    let
        totalTechniques = Dict.size model.userProgress.techniqueMastery
        masteredCount = 
            model.userProgress.techniqueMastery
                |> Dict.values
                |> List.filter (\t -> t.mastery == MasteryComplete)
                |> List.length
        masteryPercentage = if totalTechniques > 0 then
                               toFloat masteredCount / toFloat totalTechniques * 100
                           else
                               0
    in
    div [ class "bg-gray-800/30 backdrop-blur-sm border border-gray-700/50 rounded-2xl p-6" ]
        [ div [ class "flex items-center gap-3 mb-6" ]
            [ div [ class "w-12 h-12 bg-gradient-to-r from-purple-500 to-indigo-500 rounded-xl flex items-center justify-center" ]
                [ i [ class "fas fa-fist-raised text-white text-xl" ] [] ]
            , div []
                [ h3 [ class "text-xl font-bold text-white" ] [ text "TECHNIQUES" ]
                , p [ class "text-gray-400 text-sm" ] [ text "Mastery progress" ]
                ]
            ]
        , div [ class "text-center mb-4" ]
            [ div [ class "text-4xl font-black text-white mb-2" ] 
                [ text (String.fromInt masteredCount ++ "/" ++ String.fromInt totalTechniques) ]
            , div [ class "text-gray-400" ] 
                [ text "MASTERED" ]
            ]
        , viewMasteryBreakdownOld model.userProgress.techniqueMastery
        , div [ class "mt-4 h-4 bg-gray-800/50 rounded-full overflow-hidden" ]
            [ div 
                [ class "h-full bg-gradient-to-r from-purple-400 to-indigo-500 transition-all duration-500"
                , attribute "style" ("width: " ++ String.fromFloat masteryPercentage ++ "%")
                ]
                []
            ]
        ]


viewMasteryBreakdownOld : Dict String TechniqueMastery -> Html msg
viewMasteryBreakdownOld techniques =
    let
        counts = 
            techniques
                |> Dict.values
                |> List.foldl countMastery 
                    { learning = 0
                    , practicing = 0
                    , proficient = 0
                    , advanced = 0
                    , mastered = 0
                    }
    in
    div [ class "flex justify-between mt-3 text-xs" ]
        [ masteryIcon "🟫" counts.learning "Learning"
        , masteryIcon "⚪" counts.practicing "Practicing"
        , masteryIcon "🟡" counts.proficient "Proficient"
        , masteryIcon "⚫" counts.advanced "Advanced"
        , masteryIcon "💎" counts.mastered "Mastered"
        ]


masteryIcon : String -> Int -> String -> Html msg
masteryIcon icon count label =
    div [ class "flex flex-col items-center", title label ]
        [ span [] [ text icon ]
        , span [ class "text-gray-600 dark:text-gray-400" ] [ text (String.fromInt count) ]
        ]


viewNextGoal : FrontendModel -> Html msg
viewNextGoal model =
    case List.head model.userProgress.weeklyGoals.goals of
        Just goal ->
            div []
                [ p [ class "text-sm font-medium text-gray-900 dark:text-white mb-2" ] 
                    [ text goal.description ]
                , div [ class "h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden" ]
                    [ div 
                        [ class "h-full bg-gradient-to-r from-yellow-400 to-orange-500 transition-all"
                        , style "width" (String.fromFloat (goal.progress * 100) ++ "%")
                        ]
                        []
                    ]
                , p [ class "text-xs text-gray-600 dark:text-gray-400 mt-1" ] 
                    [ text (String.fromInt (round (goal.progress * 100)) ++ "% Complete") ]
                ]
                
        Nothing ->
            p [ class "text-gray-600 dark:text-gray-400" ] [ text "No active goals" ]


-- ACTIVE ROADMAPS

viewActiveRoadmaps : FrontendModel -> Html FrontendMsg
viewActiveRoadmaps model =
    div [ class "bg-gray-800/30 backdrop-blur-sm border border-gray-700/50 rounded-2xl p-6" ]
        [ div [ class "flex items-center gap-3 mb-6" ]
            [ div [ class "w-12 h-12 bg-gradient-to-r from-green-500 to-blue-500 rounded-xl flex items-center justify-center" ]
                [ i [ class "fas fa-route text-white text-xl" ] [] ]
            , div []
                [ h3 [ class "text-xl font-bold text-white" ] [ text "ACTIVE ROADMAPS" ]
                , p [ class "text-gray-400 text-sm" ] [ text "Your learning pathways" ]
                ]
            ]
            
        , case Dict.toList model.roadmaps of
            [] ->
                div [ class "text-center py-8" ]
                    [ div [ class "w-16 h-16 bg-gray-700/50 rounded-2xl flex items-center justify-center mx-auto mb-4" ]
                        [ i [ class "fas fa-map text-gray-400 text-2xl" ] [] ]
                    , p [ class "text-gray-400 mb-6" ] [ text "No active roadmaps. Start your learning journey!" ]
                    , button 
                        [ onClick (NavigateTo (HeroesRoute Nothing))
                        , class "px-6 py-3 bg-gradient-to-r from-green-500 to-blue-500 text-white rounded-xl font-bold hover:from-green-600 hover:to-blue-600 transition-all hover:scale-105"
                        ]
                        [ i [ class "fas fa-plus mr-2" ] []
                        , text "BROWSE ROADMAPS"
                        ]
                    ]
                    
            roadmaps ->
                div [ class "space-y-4" ]
                    (List.map viewRoadmapCard roadmaps)
        ]


viewRoadmapCard : (String, TechniqueRoadmap) -> Html FrontendMsg
viewRoadmapCard (id, roadmap) =
    div 
        [ class "p-5 bg-gray-700/30 border border-gray-600/50 rounded-xl hover:bg-gray-700/50 transition-all cursor-pointer group hover:scale-105"
        , onClick (SelectRoadmap id)
        ]
        [ div [ class "flex items-start justify-between mb-3" ]
            [ div [ class "flex-1" ]
                [ h4 [ class "font-bold text-white text-lg group-hover:text-blue-400 transition-colors" ] 
                    [ text roadmap.name ]
                , p [ class "text-gray-400 text-sm mt-1" ] 
                    [ text roadmap.description ]
                ]
            , div [ class "text-right" ]
                [ div [ class "px-3 py-1 bg-blue-500/20 text-blue-400 rounded-lg text-sm font-medium mb-2" ]
                    [ text (String.fromInt roadmap.estimatedWeeks ++ " WEEKS") ]
                , div [ class "text-right" ]
                    [ span [ class "text-2xl font-bold text-green-400" ] [ text "25%" ] -- TODO: calculate actual progress
                    , div [ class "text-xs text-gray-400" ] [ text "COMPLETE" ]
                    ]
                ]
            ]
        , div [ class "mt-4 h-3 bg-gray-800/50 rounded-full overflow-hidden" ]
            [ div 
                [ class "h-full bg-gradient-to-r from-green-400 to-blue-500 transition-all duration-300"
                , attribute "style" "width: 25%" -- TODO: calculate actual progress
                ]
                []
            ]
        ]


-- DAILY QUESTS

viewDailyQuests : FrontendModel -> List Quest -> Html FrontendMsg
viewDailyQuests model quests =
    div [ class "bg-gray-800/30 backdrop-blur-sm border border-gray-700/50 rounded-2xl p-6" ]
        [ div [ class "flex items-center gap-3 mb-6" ]
            [ div [ class "w-12 h-12 bg-gradient-to-r from-red-500 to-pink-500 rounded-xl flex items-center justify-center" ]
                [ i [ class "fas fa-sword text-white text-xl" ] [] ]
            , div []
                [ h3 [ class "text-xl font-bold text-white" ] [ text model.userConfig.t.dailyQuests ]
                , p [ class "text-gray-400 text-sm" ] [ text model.userConfig.t.dailyQuestsSubtitle ]
                ]
            ]
            
        , if List.isEmpty quests then
            div [ class "text-center py-8" ]
                [ div [ class "w-16 h-16 bg-green-500/20 rounded-2xl flex items-center justify-center mx-auto mb-4" ]
                    [ i [ class "fas fa-check-circle text-green-400 text-2xl" ] [] ]
                , p [ class "text-green-400 font-bold mb-2" ] [ text model.userConfig.t.allQuestsCompleted ]
                , p [ class "text-gray-400 text-sm" ] [ text model.userConfig.t.comeBackTomorrow ]
                ]
          else
            div [ class "space-y-3" ]
                (List.map viewQuest quests)
        ]


viewQuest : Quest -> Html FrontendMsg
viewQuest quest =
    div 
        [ class (if quest.completed then 
                    "p-4 bg-green-500/20 border border-green-500/30 rounded-xl opacity-80" 
                 else 
                    "p-4 bg-gray-700/30 border border-gray-600/50 rounded-xl hover:bg-gray-700/50 transition-all group")
        ]
        [ div [ class "flex items-center gap-4" ]
            [ -- Quest Icon/Checkbox
              div [ class "flex-shrink-0" ]
                [ if quest.completed then
                    div [ class "w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center" ]
                        [ i [ class "fas fa-check text-white text-sm" ] [] ]
                  else
                    div [ class "w-8 h-8 bg-gray-600/50 border-2 border-gray-500 rounded-lg group-hover:border-blue-500 transition-colors" ] []
                ]
                
              -- Quest Details
            , div [ class "flex-1 min-w-0" ]
                [ h4 [ class (if quest.completed then "font-bold text-green-400" else "font-bold text-white") ] 
                    [ text quest.title ]
                , p [ class "text-sm text-gray-400 mt-1" ] 
                    [ text quest.description ]
                , if not quest.completed then
                    div [ class "mt-3" ]
                        [ div [ class "flex items-center justify-between mb-1" ]
                            [ span [ class "text-xs text-gray-400" ] [ text "PROGRESS" ]
                            , span [ class "text-xs text-blue-400 font-medium" ] [ text (String.fromInt (round (quest.progress * 100)) ++ "%") ]
                            ]
                        , div [ class "h-2 bg-gray-800/50 rounded-full overflow-hidden" ]
                            [ div 
                                [ class "h-full bg-gradient-to-r from-blue-500 to-purple-500 transition-all duration-300"
                                , attribute "style" ("width: " ++ String.fromFloat (quest.progress * 100) ++ "%")
                                ]
                                []
                            ]
                        ]
                  else
                    text ""
                ]
                
              -- XP Reward
            , div [ class "flex-shrink-0 text-right" ]
                [ if quest.completed then
                    div [ class "text-green-400" ]
                        [ i [ class "fas fa-check-circle text-2xl" ] [] ]
                  else
                    div [ class "px-3 py-2 bg-gradient-to-r from-yellow-500/20 to-orange-500/20 border border-yellow-500/30 rounded-lg" ]
                        [ div [ class "text-yellow-400 font-bold text-lg" ] [ text ("+" ++ String.fromInt quest.xpReward) ]
                        , div [ class "text-yellow-300/60 text-xs font-medium" ] [ text "XP" ]
                        ]
                ]
            ]
        ]


-- RECENT ACHIEVEMENTS

viewRecentAchievements : FrontendModel -> Html FrontendMsg
viewRecentAchievements model =
    let
        recentBadges = 
            model.userProgress.badges
                |> List.take 6
    in
    if List.isEmpty recentBadges then
        div [ class "bg-gray-800/30 backdrop-blur-sm border border-gray-700/50 rounded-2xl p-6" ]
            [ div [ class "flex items-center gap-3 mb-6" ]
                [ div [ class "w-12 h-12 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-xl flex items-center justify-center" ]
                    [ i [ class "fas fa-trophy text-white text-xl" ] [] ]
                , div []
                    [ h3 [ class "text-xl font-bold text-white" ] [ text "ACHIEVEMENTS" ]
                    , p [ class "text-gray-400 text-sm" ] [ text "Your recent victories" ]
                    ]
                ]
            , div [ class "text-center py-8" ]
                [ div [ class "w-16 h-16 bg-gray-700/50 rounded-2xl flex items-center justify-center mx-auto mb-4" ]
                    [ i [ class "fas fa-medal text-gray-400 text-2xl" ] [] ]
                , p [ class "text-gray-400" ] [ text "No achievements yet. Keep training!" ]
                ]
            ]
    else
        div [ class "bg-gray-800/30 backdrop-blur-sm border border-gray-700/50 rounded-2xl p-6" ]
            [ div [ class "flex items-center gap-3 mb-6" ]
                [ div [ class "w-12 h-12 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-xl flex items-center justify-center" ]
                    [ i [ class "fas fa-trophy text-white text-xl" ] [] ]
                , div []
                    [ h3 [ class "text-xl font-bold text-white" ] [ text "ACHIEVEMENTS" ]
                    , p [ class "text-gray-400 text-sm" ] [ text "Your recent victories" ]
                    ]
                ]
            , div [ class "grid grid-cols-2 lg:grid-cols-3 gap-4" ]
                (List.map viewBadge recentBadges)
            ]


viewBadge : Badge -> Html msg
viewBadge badge =
    div 
        [ class "p-4 bg-gradient-to-br from-yellow-500/10 via-orange-500/10 to-red-500/10 border border-yellow-500/20 rounded-xl text-center hover:scale-105 transition-all group"
        , attribute "title" badge.description
        ]
        [ div [ class "w-12 h-12 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center mx-auto mb-3 group-hover:scale-110 transition-transform" ]
            [ span [ class "text-2xl" ] [ text badge.icon ] ]
        , div [ class "font-bold text-white text-sm" ] [ text badge.name ]
        , div [ class "text-xs text-gray-400 mt-1" ] [ text "EARNED" ]
        ]


-- HELPER FUNCTIONS

weeklyStatsIcon : FrontendModel -> String
weeklyStatsIcon model =
    if model.userProgress.currentStreak >= 7 then
        "🔥"
    else
        "📊"


viewBeltIcon : BeltLevel -> Html msg
viewBeltIcon belt =
    let
        (color, textColor) = 
            case belt of
                White -> ("bg-white", "text-gray-800")
                Blue -> ("bg-blue-500", "text-white")
                Purple -> ("bg-purple-500", "text-white")
                Brown -> ("bg-yellow-800", "text-white")
                Black -> ("bg-black", "text-white")
    in
    div [ class ("px-3 py-1 rounded " ++ color ++ " " ++ textColor ++ " font-bold text-sm") ]
        [ text (beltLevelToString belt) ]


beltLevelToString : BeltLevel -> String
beltLevelToString belt =
    case belt of
        White -> "White Belt"
        Blue -> "Blue Belt"
        Purple -> "Purple Belt"
        Brown -> "Brown Belt"
        Black -> "Black Belt"


nextBelt : BeltLevel -> BeltLevel
nextBelt belt =
    case belt of
        White -> Blue
        Blue -> Purple
        Purple -> Brown
        Brown -> Black
        Black -> Black


beltProgressBarColor : BeltLevel -> String
beltProgressBarColor belt =
    case belt of
        White -> "bg-blue-500"
        Blue -> "bg-purple-500"
        Purple -> "bg-yellow-700"
        Brown -> "bg-gray-800"
        Black -> "bg-black"


formatTimer : Int -> String
formatTimer seconds =
    let
        mins = seconds // 60
        secs = remainderBy 60 seconds
    in
    String.padLeft 2 '0' (String.fromInt mins) ++ ":" ++ String.padLeft 2 '0' (String.fromInt secs)


viewMasteryBreakdown : Dict String TechniqueMastery -> Html msg
viewMasteryBreakdown techniques =
    let
        counts = 
            techniques
                |> Dict.values
                |> List.foldl countMastery 
                    { learning = 0
                    , practicing = 0
                    , proficient = 0
                    , advanced = 0
                    , mastered = 0
                    }
    in
    div [ class "grid grid-cols-5 gap-2 mt-4" ]
        [ masteryBadge "LEARNING" counts.learning "bg-red-500/20 text-red-400 border-red-500/30"
        , masteryBadge "PRACTICING" counts.practicing "bg-orange-500/20 text-orange-400 border-orange-500/30"
        , masteryBadge "PROFICIENT" counts.proficient "bg-yellow-500/20 text-yellow-400 border-yellow-500/30"
        , masteryBadge "ADVANCED" counts.advanced "bg-blue-500/20 text-blue-400 border-blue-500/30"
        , masteryBadge "MASTERED" counts.mastered "bg-green-500/20 text-green-400 border-green-500/30"
        ]

masteryBadge : String -> Int -> String -> Html msg
masteryBadge label count colorClass =
    div [ class ("border rounded-lg p-2 text-center transition-all hover:scale-105 " ++ colorClass) ]
        [ div [ class "font-bold text-lg" ] [ text (String.fromInt count) ]
        , div [ class "text-xs font-medium opacity-80" ] [ text label ]
        ]

countMastery : TechniqueMastery -> { learning : Int, practicing : Int, proficient : Int, advanced : Int, mastered : Int } -> { learning : Int, practicing : Int, proficient : Int, advanced : Int, mastered : Int }
countMastery technique counts =
    case technique.mastery of
        Learning -> { counts | learning = counts.learning + 1 }
        Practicing -> { counts | practicing = counts.practicing + 1 }
        Proficient -> { counts | proficient = counts.proficient + 1 }
        MasteryAdvanced -> { counts | advanced = counts.advanced + 1 }
        MasteryComplete -> { counts | mastered = counts.mastered + 1 }