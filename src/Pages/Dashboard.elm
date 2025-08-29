module Pages.Dashboard exposing (view, viewDashboard)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Types exposing (..)
import GameMechanics.XP as XP
import Dict exposing (Dict)
import Set exposing (Set)
import Time
import I18n


-- MAIN DASHBOARD VIEW

view : FrontendModel -> Html FrontendMsg
view model =
    viewDashboard model


viewDashboard : FrontendModel -> Html FrontendMsg
viewDashboard model =
    div [ class "min-h-screen bg-gray-50 dark:bg-gray-900 transition-colors" ]
        [ -- XP Header Bar
          viewXPHeader model.userProgress model.userConfig.isDark
          
          -- Main Content
        , div [ class "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6" ]
            [ -- Today's Focus Card
              viewTodaysFocus model
              
              -- Quick Actions Grid
            , viewQuickActions model
            
              -- Stats Grid
            , div [ class "grid grid-cols-1 md:grid-cols-3 gap-6 mb-6" ]
                [ viewStatCard "This Week" (weeklyStatsIcon model) (viewWeeklyStats model)
                , viewStatCard "Techniques" "🥋" (viewTechniqueStats model)
                , viewStatCard "Next Goal" "🎯" (viewNextGoal model)
                ]
                
              -- Active Roadmaps Section
            , viewActiveRoadmaps model
            
              -- Daily Quests
            , viewDailyQuests model.userProgress.dailyQuests
            
              -- Recent Achievements
            , viewRecentAchievements model
            ]
        ]


-- XP HEADER BAR

viewXPHeader : UserProgress -> Bool -> Html FrontendMsg
viewXPHeader progress isDark =
    let
        (level, levelProgress) = XP.levelFromXP progress.totalXP
        xpInCurrentLevel = round (levelProgress * 1000)
        xpToNext = XP.xpToNextLevel progress.totalXP
        title = XP.getTitleForLevel level
        (currentBelt, beltProgress) = XP.getBeltProgress progress.totalXP White -- TODO: get actual belt
    in
    div [ class "bg-white dark:bg-gray-800 shadow-lg border-b border-gray-200 dark:border-gray-700" ]
        [ div [ class "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4" ]
            [ -- Level and Title
              div [ class "flex items-center justify-between mb-3" ]
                [ div [ class "flex items-center space-x-4" ]
                    [ -- Level Badge
                      div [ class "flex items-center" ]
                        [ div [ class "text-3xl font-bold text-gray-900 dark:text-white" ]
                            [ text ("Level " ++ String.fromInt level) ]
                        , div [ class "ml-3 px-3 py-1 bg-gradient-to-r from-purple-500 to-indigo-600 text-white rounded-full text-sm font-medium" ]
                            [ text title.name ]
                        ]
                    
                      -- Belt Icon
                    , viewBeltIcon currentBelt
                    ]
                    
                  -- Total XP
                , div [ class "text-right" ]
                    [ div [ class "text-sm text-gray-500 dark:text-gray-400" ]
                        [ text "Total XP" ]
                    , div [ class "text-2xl font-bold text-indigo-600 dark:text-indigo-400" ]
                        [ text (String.fromInt progress.totalXP ++ " XP") ]
                    ]
                ]
                
              -- XP Progress Bar
            , div [ class "relative" ]
                [ div [ class "h-8 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden" ]
                    [ div 
                        [ class "h-full bg-gradient-to-r from-blue-500 via-purple-500 to-indigo-600 transition-all duration-500 ease-out flex items-center justify-end"
                        , style "width" (String.fromFloat (levelProgress * 100) ++ "%")
                        ]
                        [ if levelProgress > 0.1 then
                            span [ class "text-white text-sm font-bold mr-2" ]
                                [ text (String.fromInt xpInCurrentLevel ++ " / 1000 XP") ]
                          else
                            text ""
                        ]
                    ]
                    
                  -- XP Text Overlay (for when bar is too small)
                , if levelProgress <= 0.1 then
                    div [ class "absolute inset-0 flex items-center justify-center" ]
                        [ span [ class "text-gray-700 dark:text-gray-300 text-sm font-bold" ]
                            [ text (String.fromInt xpInCurrentLevel ++ " / 1000 XP") ]
                        ]
                  else
                    text ""
                ]
                
              -- Belt Progress
            , if currentBelt /= Black then
                div [ class "mt-2" ]
                    [ div [ class "flex items-center justify-between text-xs text-gray-600 dark:text-gray-400 mb-1" ]
                        [ span [] [ text ("Belt Progress: " ++ beltLevelToString currentBelt) ]
                        , span [] [ text (String.fromInt (round (beltProgress * 100)) ++ "% to " ++ beltLevelToString (nextBelt currentBelt)) ]
                        ]
                    , div [ class "h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden" ]
                        [ div 
                            [ class (beltProgressBarColor currentBelt ++ " h-full transition-all duration-500")
                            , style "width" (String.fromFloat (beltProgress * 100) ++ "%")
                            ]
                            []
                        ]
                    ]
              else
                text ""
            ]
        ]


-- TODAY'S FOCUS CARD

viewTodaysFocus : FrontendModel -> Html FrontendMsg
viewTodaysFocus model =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 flex items-center text-gray-900 dark:text-white" ]
            [ span [ class "text-3xl mr-3" ] [ text "🎯" ]
            , text "Today's Focus"
            ]
            
        , case model.activeSession of
            Just session ->
                viewActiveSessionCard session
                
            Nothing ->
                viewStartSessionPrompt model
        ]


viewActiveSessionCard : ActiveSession -> Html FrontendMsg
viewActiveSessionCard session =
    div [ class "space-y-4" ]
        [ -- Session Timer
          div [ class "flex items-center justify-between p-4 bg-green-50 dark:bg-green-900/20 rounded-lg" ]
            [ div [ class "flex items-center" ]
                [ span [ class "text-2xl mr-3" ] [ text "⏱️" ]
                , div []
                    [ p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text "Session Active" ]
                    , p [ class "text-xl font-bold text-green-600 dark:text-green-400" ] 
                        [ text (formatTimer 0) ] -- TODO: calculate from session.startTime
                    ]
                ]
            , button 
                [ onClick EndSession
                , class "px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg transition-colors"
                ]
                [ text "End Session" ]
            ]
            
          -- Current Technique
        , case session.currentTechnique of
            Just techniqueId ->
                div [ class "p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg" ]
                    [ h3 [ class "font-semibold mb-2" ] [ text "Current Technique" ]
                    , p [ class "text-lg" ] [ text techniqueId ] -- TODO: get technique name
                    , div [ class "flex gap-2 mt-3" ]
                        [ button [ onClick (IncrementReps techniqueId), class "btn-primary" ] [ text "+1 Rep" ]
                        , button [ onClick (SetQuality techniqueId 5), class "btn-secondary" ] [ text "⭐ Perfect!" ]
                        ]
                    ]
                    
            Nothing ->
                text ""
                
          -- Session XP
        , div [ class "text-center p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg" ]
            [ p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text "Session XP" ]
            , p [ class "text-2xl font-bold text-purple-600 dark:text-purple-400" ] 
                [ text ("+" ++ String.fromInt session.totalXP ++ " XP") ]
            ]
        ]


viewStartSessionPrompt : FrontendModel -> Html FrontendMsg
viewStartSessionPrompt model =
    div [ class "text-center py-8" ]
        [ p [ class "text-gray-600 dark:text-gray-400 mb-4" ] 
            [ text "No active training session. Ready to train?" ]
        , button 
            [ onClick StartSession
            , class "px-6 py-3 bg-gradient-to-r from-blue-500 to-indigo-600 text-white rounded-lg font-semibold hover:from-blue-600 hover:to-indigo-700 transition-all transform hover:scale-105"
            ]
            [ text "Start Training Session" ]
        ]


-- QUICK ACTIONS

viewQuickActions : FrontendModel -> Html FrontendMsg
viewQuickActions model =
    div [ class "grid grid-cols-2 md:grid-cols-4 gap-4 mb-6" ]
        [ quickActionButton "📚" "Roadmaps" (NavigateTo (HeroesRoute Nothing))
        , quickActionButton "🎥" "Videos" (NavigateTo Training)
        , quickActionButton "📝" "Notes" (NavigateTo Profile)
        , quickActionButton "🏆" "Achievements" (NavigateTo Profile)
        ]


quickActionButton : String -> String -> FrontendMsg -> Html FrontendMsg
quickActionButton icon label msg =
    button 
        [ onClick msg
        , class "p-4 bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-md transition-all hover:scale-105 flex flex-col items-center justify-center"
        ]
        [ span [ class "text-3xl mb-2" ] [ text icon ]
        , span [ class "text-sm font-medium text-gray-700 dark:text-gray-300" ] [ text label ]
        ]


-- STATS CARDS

viewStatCard : String -> String -> Html msg -> Html msg
viewStatCard title icon content =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ div [ class "flex items-center justify-between mb-3" ]
            [ h3 [ class "text-lg font-semibold text-gray-900 dark:text-white" ] [ text title ]
            , span [ class "text-2xl" ] [ text icon ]
            ]
        , content
        ]


viewWeeklyStats : FrontendModel -> Html msg
viewWeeklyStats model =
    let
        weeklyXP = model.userProgress.weeklyGoals.currentXP
        weeklyTarget = model.userProgress.weeklyGoals.totalXPTarget
        percentage = if weeklyTarget > 0 then
                        toFloat weeklyXP / toFloat weeklyTarget * 100
                     else
                        0
    in
    div []
        [ p [ class "text-2xl font-bold text-gray-900 dark:text-white" ] 
            [ text (String.fromInt weeklyXP ++ " XP") ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] 
            [ text ("of " ++ String.fromInt weeklyTarget ++ " goal") ]
        , div [ class "mt-2 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden" ]
            [ div 
                [ class "h-full bg-gradient-to-r from-green-400 to-green-600 transition-all"
                , style "width" (String.fromFloat percentage ++ "%")
                ]
                []
            ]
        ]


viewTechniqueStats : FrontendModel -> Html msg
viewTechniqueStats model =
    let
        totalTechniques = Dict.size model.userProgress.techniqueMastery
        masteredCount = 
            model.userProgress.techniqueMastery
                |> Dict.values
                |> List.filter (\t -> t.mastery == MasteryComplete)
                |> List.length
    in
    div []
        [ p [ class "text-2xl font-bold text-gray-900 dark:text-white" ] 
            [ text (String.fromInt masteredCount ++ "/" ++ String.fromInt totalTechniques) ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] 
            [ text "Techniques Mastered" ]
        , viewMasteryBreakdown model.userProgress.techniqueMastery
        ]


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
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-6" ]
        [ h3 [ class "text-xl font-bold mb-4 text-gray-900 dark:text-white" ] 
            [ text "Active Learning Paths" ]
            
        , case Dict.toList model.roadmaps of
            [] ->
                div [ class "text-center py-8" ]
                    [ p [ class "text-gray-600 dark:text-gray-400 mb-4" ] 
                        [ text "No active roadmaps. Start your journey!" ]
                    , button 
                        [ onClick (NavigateTo (HeroesRoute Nothing))
                        , class "btn-primary"
                        ]
                        [ text "Browse Roadmaps" ]
                    ]
                    
            roadmaps ->
                div [ class "grid grid-cols-1 md:grid-cols-2 gap-4" ]
                    (List.map viewRoadmapCard roadmaps)
        ]


viewRoadmapCard : (String, TechniqueRoadmap) -> Html FrontendMsg
viewRoadmapCard (id, roadmap) =
    div 
        [ class "p-4 border border-gray-200 dark:border-gray-700 rounded-lg hover:shadow-md transition-all cursor-pointer"
        , onClick (SelectRoadmap id)
        ]
        [ div [ class "flex items-center justify-between mb-2" ]
            [ h4 [ class "font-semibold text-gray-900 dark:text-white" ] 
                [ text roadmap.name ]
            , span [ class "text-sm text-gray-500 dark:text-gray-400" ] 
                [ text (String.fromInt roadmap.estimatedWeeks ++ " weeks") ]
            ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400 mb-3" ] 
            [ text roadmap.description ]
        , div [ class "h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden" ]
            [ div 
                [ class "h-full bg-gradient-to-r from-blue-400 to-blue-600"
                , style "width" "25%" -- TODO: calculate actual progress
                ]
                []
            ]
        ]


-- DAILY QUESTS

viewDailyQuests : List Quest -> Html FrontendMsg
viewDailyQuests quests =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-6" ]
        [ h3 [ class "text-xl font-bold mb-4 flex items-center text-gray-900 dark:text-white" ]
            [ span [ class "text-2xl mr-2" ] [ text "⚔️" ]
            , text "Daily Quests"
            ]
            
        , if List.isEmpty quests then
            p [ class "text-gray-600 dark:text-gray-400" ] [ text "All quests completed! Come back tomorrow." ]
          else
            div [ class "space-y-3" ]
                (List.map viewQuest quests)
        ]


viewQuest : Quest -> Html FrontendMsg
viewQuest quest =
    div 
        [ class (if quest.completed then 
                    "p-4 bg-green-50 dark:bg-green-900/20 rounded-lg opacity-75" 
                 else 
                    "p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors")
        ]
        [ div [ class "flex items-center justify-between" ]
            [ div [ class "flex-1" ]
                [ h4 [ class "font-medium text-gray-900 dark:text-white" ] 
                    [ text quest.title ]
                , p [ class "text-sm text-gray-600 dark:text-gray-400" ] 
                    [ text quest.description ]
                ]
            , div [ class "ml-4 text-right" ]
                [ if quest.completed then
                    span [ class "text-green-600 dark:text-green-400 font-bold" ] 
                        [ text "✓ Complete" ]
                  else
                    div []
                        [ p [ class "text-sm font-medium text-indigo-600 dark:text-indigo-400" ] 
                            [ text ("+" ++ String.fromInt quest.xpReward ++ " XP") ]
                        , div [ class "w-20 h-2 bg-gray-200 dark:bg-gray-600 rounded-full overflow-hidden mt-1" ]
                            [ div 
                                [ class "h-full bg-indigo-500 transition-all"
                                , style "width" (String.fromFloat (quest.progress * 100) ++ "%")
                                ]
                                []
                            ]
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
                |> List.take 5
    in
    if List.isEmpty recentBadges then
        text ""
    else
        div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
            [ h3 [ class "text-xl font-bold mb-4 text-gray-900 dark:text-white" ] 
                [ text "Recent Achievements" ]
            , div [ class "flex flex-wrap gap-4" ]
                (List.map viewBadge recentBadges)
            ]


viewBadge : Badge -> Html msg
viewBadge badge =
    div 
        [ class "flex flex-col items-center p-3 bg-gradient-to-br from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 rounded-lg"
        , title badge.description
        ]
        [ span [ class "text-3xl mb-1" ] [ text badge.icon ]
        , span [ class "text-xs font-medium text-gray-700 dark:text-gray-300" ] [ text badge.name ]
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


countMastery : TechniqueMastery -> { learning : Int, practicing : Int, proficient : Int, advanced : Int, mastered : Int } -> { learning : Int, practicing : Int, proficient : Int, advanced : Int, mastered : Int }
countMastery technique counts =
    case technique.mastery of
        Learning -> { counts | learning = counts.learning + 1 }
        Practicing -> { counts | practicing = counts.practicing + 1 }
        Proficient -> { counts | proficient = counts.proficient + 1 }
        MasteryAdvanced -> { counts | advanced = counts.advanced + 1 }
        MasteryComplete -> { counts | mastered = counts.mastered + 1 }