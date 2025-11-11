module Pages.TrainingSession exposing (view, viewTrainingSession)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Types exposing (..)
import GameMechanics.XP as XP
import Time
import Dict


-- MAIN SESSION VIEW

view : FrontendModel -> Html FrontendMsg
view model =
    case model.activeSession of
        Just session ->
            viewActiveSession model session
        Nothing ->
            viewStartSession model


viewTrainingSession : FrontendModel -> Html FrontendMsg
viewTrainingSession =
    view


-- START SESSION VIEW

viewStartSession : FrontendModel -> Html FrontendMsg
viewStartSession model =
    div [ class "min-h-screen bg-gray-50 dark:bg-gray-900 py-8" ]
        [ div [ class "max-w-4xl mx-auto px-4" ]
            [ -- Header
              div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-8 text-center" ]
                [ h1 [ class "text-3xl font-bold mb-4 text-gray-900 dark:text-white" ]
                    [ text "Ready to Train?" ]
                , p [ class "text-gray-600 dark:text-gray-400 mb-8" ]
                    [ text "Start a new training session to track your progress and earn XP!" ]
                    
                  -- Session Type Selection
                , div [ class "grid grid-cols-2 md:grid-cols-3 gap-4 mb-8" ]
                    [ sessionTypeCard "🥋" "Technique Class" TechniqueSession
                    , sessionTypeCard "🤼" "Open Mat" OpenMatSession
                    , sessionTypeCard "🏆" "Competition" CompetitionSession
                    , sessionTypeCard "👨‍🏫" "Private Lesson" PrivateSession
                    , sessionTypeCard "📝" "Solo Drilling" OpenMatSession
                    , sessionTypeCard "🎥" "Video Study" OpenMatSession
                    ]
                    
                  -- Quick Start Button
                , button
                    [ onClick StartSession
                    , class "start-session-button start-session-button--large mx-auto"
                    ]
                    [ span [ class "start-session-button__icon" ] [ text "⚡" ]
                    , span [ class "start-session-button__label" ] [ text model.userConfig.t.startSession ]
                    ]
                ]
                
              -- Today's Goals
            , viewTodaysGoals model
            
              -- Recent Sessions
            , viewRecentSessions model.trainingSessions
            ]
        ]


sessionTypeCard : String -> String -> SessionType -> Html FrontendMsg
sessionTypeCard icon label sessionType =
    div 
        [ class "p-6 bg-gray-50 dark:bg-gray-700 rounded-lg cursor-pointer hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors border-2 border-transparent hover:border-blue-500"
        , onClick (StartSession) -- TODO: Pass session type
        ]
        [ div [ class "text-4xl mb-2 text-center" ] [ text icon ]
        , p [ class "font-medium text-gray-900 dark:text-white text-center" ] [ text label ]
        ]


-- ACTIVE SESSION VIEW

viewActiveSession : FrontendModel -> ActiveSession -> Html FrontendMsg
viewActiveSession model session =
    div [ class "min-h-screen bg-gray-50 dark:bg-gray-900" ]
        [ -- Fixed Header with Timer
          viewSessionHeader model session
          
          -- Main Content
        , div [ class "max-w-4xl mx-auto px-4 pt-24 pb-8" ]
            [ -- Current Technique Section
              viewCurrentTechnique model session
              
              -- Quick Log Actions
            , viewQuickActions
              
              -- Technique List
            , viewTechniquesList session.techniques
              
              -- Session Stats
            , viewSessionStats session model.sessionTimer
            ]
        ]


viewSessionHeader : FrontendModel -> ActiveSession -> Html FrontendMsg
viewSessionHeader model session =
    div [ class "fixed top-0 left-0 right-0 bg-white dark:bg-gray-800 shadow-lg z-50" ]
        [ div [ class "max-w-4xl mx-auto px-4 py-4" ]
            [ div [ class "flex items-center justify-between" ]
                [ -- Session Info
                  div []
                    [ h2 [ class "text-2xl font-bold text-gray-900 dark:text-white" ] 
                        [ text "Training Session Active" ]
                    , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
                        [ text ("Started " ++ formatTime session.startTime) ]
                    ]
                    
                  -- Timer and XP
                , div [ class "flex items-center gap-6" ]
                    [ -- Timer
                      div [ class "text-center" ]
                        [ p [ class "text-3xl font-mono font-bold text-gray-900 dark:text-white" ]
                            [ text (formatDuration model.sessionTimer) ]
                        , p [ class "text-xs text-gray-500 dark:text-gray-400" ]
                            [ text "Duration" ]
                        ]
                        
                      -- XP Counter
                    , div [ class "text-center" ]
                        [ p [ class "text-2xl font-bold text-green-600 dark:text-green-400" ]
                            [ text ("+" ++ String.fromInt session.totalXP ++ " XP") ]
                        , p [ class "text-xs text-gray-500 dark:text-gray-400" ]
                            [ text "Earned" ]
                        ]
                        
                      -- End Button
                    , button 
                        [ onClick EndSession
                        , class "px-6 py-3 bg-red-500 hover:bg-red-600 text-white rounded-lg font-semibold transition-colors"
                        ]
                        [ text "End Session" ]
                    ]
                ]
            ]
        ]


viewCurrentTechnique : FrontendModel -> ActiveSession -> Html FrontendMsg
viewCurrentTechnique model session =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-6" ]
        [ h3 [ class "text-xl font-bold mb-4 text-gray-900 dark:text-white" ]
            [ text "Current Technique" ]
            
        , case session.currentTechnique of
            Just techniqueId ->
                viewTechniqueTracker techniqueId model
                
            Nothing ->
                viewSelectTechnique model
        ]


viewTechniqueTracker : String -> FrontendModel -> Html FrontendMsg
viewTechniqueTracker techniqueId model =
    div [ class "space-y-4" ]
        [ -- Technique Name
          div [ class "p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg" ]
            [ h4 [ class "text-lg font-semibold text-gray-900 dark:text-white mb-2" ]
                [ text techniqueId ] -- TODO: Get actual technique name
            , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
                [ text "Butterfly Guard → Basic Sweep" ] -- TODO: Get category
            ]
            
          -- Rep Counter
        , div [ class "flex items-center justify-between" ]
            [ span [ class "text-lg font-medium text-gray-700 dark:text-gray-300" ] 
                [ text "Repetitions:" ]
            , div [ class "flex items-center gap-3" ]
                [ button 
                    [ onClick (DecrementReps techniqueId)
                    , class "w-10 h-10 rounded-full bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 flex items-center justify-center font-bold"
                    ]
                    [ text "-" ]
                , span [ class "text-3xl font-bold w-16 text-center text-gray-900 dark:text-white" ] 
                    [ text "0" ] -- TODO: Get actual count
                , button 
                    [ onClick (IncrementReps techniqueId)
                    , class "w-10 h-10 rounded-full bg-green-500 hover:bg-green-600 text-white flex items-center justify-center font-bold"
                    ]
                    [ text "+" ]
                ]
            ]
            
          -- Quality Rating
        , div [ class "flex items-center justify-between" ]
            [ span [ class "text-lg font-medium text-gray-700 dark:text-gray-300" ] 
                [ text "Quality:" ]
            , viewStarRating 3 techniqueId
            ]
            
          -- Quick Tags
        , div []
            [ p [ class "text-sm font-medium text-gray-700 dark:text-gray-300 mb-2" ]
                [ text "Quick Notes:" ]
            , div [ class "flex flex-wrap gap-2" ]
                [ quickTag "💪 Strong side"
                , quickTag "🔄 Need more reps"
                , quickTag "⏱️ Timing issue"
                , quickTag "📐 Wrong angle"
                , quickTag "✅ Feeling good"
                , quickTag "🎯 Nailed it!"
                ]
            ]
            
          -- Switch Technique Button
        , button 
            [ onClick (SelectNode "")
            , class "w-full py-2 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg transition-colors"
            ]
            [ text "Switch Technique" ]
        ]


viewSelectTechnique : FrontendModel -> Html FrontendMsg
viewSelectTechnique model =
    div [ class "text-center py-8" ]
        [ p [ class "text-gray-600 dark:text-gray-400 mb-4" ]
            [ text "Select a technique to practice" ]
        , div [ class "grid grid-cols-2 gap-4" ]
            [ techniqueOption "🦋" "Butterfly Guard"
            , techniqueOption "🕷️" "Spider Guard"
            , techniqueOption "🔺" "Triangle Choke"
            , techniqueOption "💪" "Armbar"
            ]
        ]


techniqueOption : String -> String -> Html FrontendMsg
techniqueOption icon name =
    button 
        [ onClick (SelectNode name)
        , class "p-4 bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors"
        ]
        [ div [ class "text-2xl mb-1" ] [ text icon ]
        , p [ class "font-medium text-gray-900 dark:text-white" ] [ text name ]
        ]


viewQuickActions : Html FrontendMsg
viewQuickActions =
    div [ class "grid grid-cols-2 gap-4 mb-6" ]
        [ quickActionButton "✅" "Réussite" (QuickSuccess 10) "bg-green-500 hover:bg-green-600"
        , quickActionButton "💡" "Insight" (ShowNotification Info "Note ajoutée à la session") "bg-purple-500 hover:bg-purple-600"
        ]


quickActionButton : String -> String -> FrontendMsg -> String -> Html FrontendMsg
quickActionButton icon label action colorClass =
    button
        [ onClick action
        , class ("w-full py-4 rounded-lg text-white font-semibold transition-colors " ++ colorClass)
        ]
        [ div [ class "text-2xl mb-1" ] [ text icon ]
        , text label
        ]


viewTechniquesList : List TechniqueLog -> Html FrontendMsg
viewTechniquesList techniques =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-6" ]
        [ h3 [ class "text-xl font-bold mb-4 text-gray-900 dark:text-white" ]
            [ text "Session Techniques" ]
        , if List.isEmpty techniques then
            p [ class "text-gray-600 dark:text-gray-400" ]
                [ text "No techniques logged yet" ]
          else
            div [ class "space-y-3" ]
                (List.map viewTechniqueLogItem techniques)
        ]


viewTechniqueLogItem : TechniqueLog -> Html msg
viewTechniqueLogItem log =
    div [ class "flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg" ]
        [ div []
            [ p [ class "font-medium text-gray-900 dark:text-white" ]
                [ text log.techniqueId ]
            , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
                [ text (String.fromInt log.repetitions ++ " reps • Quality: " ++ String.fromInt log.quality ++ "/5") ]
            ]
        , div [ class "text-right" ]
            [ p [ class "font-bold text-green-600 dark:text-green-400" ]
                [ text ("+" ++ String.fromInt log.xpEarned ++ " XP") ]
            ]
        ]


viewSessionStats : ActiveSession -> Int -> Html msg
viewSessionStats session elapsedSeconds =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ h3 [ class "text-xl font-bold mb-4 text-gray-900 dark:text-white" ]
            [ text "Session Stats" ]
        , div [ class "grid grid-cols-2 md:grid-cols-4 gap-4" ]
            [ statCard "⏱️" "Duration" (formatDuration elapsedSeconds)
            , statCard "🔄" "Techniques" (String.fromInt (List.length session.techniques))
            , statCard "💯" "Total Reps" (String.fromInt (List.sum (List.map .repetitions session.techniques)))
            , statCard "⚡" "XP Earned" (String.fromInt session.totalXP)
            ]
        ]


statCard : String -> String -> String -> Html msg
statCard icon label value =
    div [ class "text-center p-4 bg-gray-50 dark:bg-gray-700 rounded-lg" ]
        [ div [ class "text-2xl mb-1" ] [ text icon ]
        , p [ class "text-xs text-gray-600 dark:text-gray-400" ] [ text label ]
        , p [ class "text-xl font-bold text-gray-900 dark:text-white" ] [ text value ]
        ]


viewTodaysGoals : FrontendModel -> Html FrontendMsg
viewTodaysGoals model =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mt-6" ]
        [ h3 [ class "text-xl font-bold mb-4 text-gray-900 dark:text-white" ]
            [ text "Today's Goals" ]
        , div [ class "space-y-3" ]
            (if List.isEmpty model.userProgress.dailyQuests then
                [ p [ class "text-gray-600 dark:text-gray-400" ]
                    [ text "All goals completed! Great job! 🎉" ]
                ]
             else
                List.map viewGoalItem model.userProgress.dailyQuests
            )
        ]


viewGoalItem : Quest -> Html FrontendMsg
viewGoalItem quest =
    div [ class "flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg" ]
        [ div [ class "flex-1" ]
            [ p [ class "font-medium text-gray-900 dark:text-white" ]
                [ text quest.title ]
            , div [ class "flex items-center gap-2 mt-1" ]
                [ div [ class "flex-1 h-2 bg-gray-200 dark:bg-gray-600 rounded-full overflow-hidden" ]
                    [ div 
                        [ class "h-full bg-gradient-to-r from-blue-500 to-blue-600 transition-all"
                        , style "width" (String.fromFloat (quest.progress / toFloat quest.target * 100) ++ "%")
                        ]
                        []
                    ]
                , p [ class "text-xs text-gray-600 dark:text-gray-400" ]
                    [ text (String.fromInt (round quest.progress) ++ "/" ++ String.fromInt quest.target) ]
                ]
            ]
        , div [ class "ml-4" ]
            [ p [ class "text-sm font-bold text-indigo-600 dark:text-indigo-400" ]
                [ text ("+" ++ String.fromInt quest.xpReward ++ " XP") ]
            ]
        ]


viewRecentSessions : List TrainingSession -> Html FrontendMsg
viewRecentSessions sessions =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mt-6" ]
        [ h3 [ class "text-xl font-bold mb-4 text-gray-900 dark:text-white" ]
            [ text "Recent Sessions" ]
        , if List.isEmpty sessions then
            p [ class "text-gray-600 dark:text-gray-400" ]
                [ text "No sessions yet. Start training to see your history!" ]
          else
            div [ class "space-y-3" ]
                (sessions |> List.take 5 |> List.map viewSessionItem)
        ]


viewSessionItem : TrainingSession -> Html msg
viewSessionItem session =
    div [ class "flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg" ]
        [ div []
            [ p [ class "font-medium text-gray-900 dark:text-white" ]
                [ text (sessionTypeToString session.sessionType) ]
            , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
                [ text ("Duration: " ++ String.fromInt session.duration ++ " min") ]
            ]
        , div [ class "text-right" ]
            [ p [ class "font-bold text-green-600 dark:text-green-400" ]
                [ text ("+" ++ String.fromInt session.xpEarned ++ " XP") ]
            , viewMoodIcon session.mood
            ]
        ]


viewMoodIcon : MoodRating -> Html msg
viewMoodIcon mood =
    let
        (icon, color) =
            case mood of
                FlowState -> ("🔥", "text-orange-500")
                Excellent -> ("😄", "text-green-500")
                Good -> ("🙂", "text-blue-500")
                Neutral -> ("😐", "text-gray-500")
                Frustrated -> ("😤", "text-red-500")
    in
    span [ class ("text-xl " ++ color) ] [ text icon ]


viewStarRating : Int -> String -> Html FrontendMsg
viewStarRating rating techniqueId =
    div [ class "flex gap-1" ]
        (List.range 1 5
            |> List.map (\i ->
                button 
                    [ onClick (SetQuality techniqueId i)
                    , class "text-2xl transition-colors"
                    ]
                    [ text (if i <= rating then "⭐" else "☆") ]
            )
        )


quickTag : String -> Html msg
quickTag label =
    button 
        [ class "px-3 py-1 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-full text-sm transition-colors"
        ]
        [ text label ]


-- HELPERS

formatTime : Time.Posix -> String
formatTime time =
    -- TODO: Implement proper time formatting
    "a few moments ago"


formatDuration : Int -> String
formatDuration seconds =
    let
        hours = seconds // 3600
        minutes = (seconds - hours * 3600) // 60
        secs = seconds - hours * 3600 - minutes * 60
    in
    if hours > 0 then
        String.padLeft 2 '0' (String.fromInt hours) ++ ":" ++ 
        String.padLeft 2 '0' (String.fromInt minutes) ++ ":" ++ 
        String.padLeft 2 '0' (String.fromInt secs)
    else
        String.padLeft 2 '0' (String.fromInt minutes) ++ ":" ++ 
        String.padLeft 2 '0' (String.fromInt secs)


sessionTypeToString : SessionType -> String
sessionTypeToString sessionType =
    case sessionType of
        TechniqueSession -> "Technique Class"
        DrillingSession -> "Drilling Session"
        SparringSession -> "Sparring Session"
        CompetitionSession -> "Competition"
        OpenMatSession -> "Open Mat"
        PrivateSession -> "Private Lesson"
