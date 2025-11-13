module Pages.Dashboard exposing (view, viewDashboard)

import Dict exposing (Dict)
import GameMechanics.XP as XP
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, href, id, src, style, title, type_)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy, lazy2, lazy3)
import I18n
import Router.Helpers exposing (onPreventDefaultClick)
import Set exposing (Set)
import Theme exposing (darkTheme)
import Time
import Types exposing (..)



-- MAIN DASHBOARD VIEW


view : FrontendModel -> Html FrontendMsg
view model =
    viewDashboard model


viewDashboard : FrontendModel -> Html FrontendMsg
viewDashboard model =
    div [ class "min-h-screen bg-slate-50 dark:bg-slate-950" ]
        [ div [ class "mx-auto flex max-w-6xl flex-col gap-8 px-4 py-10 md:px-6" ]
            [ viewHeroHeader model
            , viewQuickStats model
            , div [ class "grid gap-6 lg:grid-cols-3" ]
                [ div [ class "space-y-6 lg:col-span-2" ]
                    [ viewTodaysFocus model
                    , viewActiveRoadmaps model
                    , viewRecentAchievements model
                    ]
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
        progress =
            model.userProgress

        ( level, levelProgress ) =
            XP.levelFromXP progress.totalXP

        xpInCurrentLevel =
            round (levelProgress * 1000)

        title =
            XP.getTitleForLevel level

        ( currentBelt, beltProgress ) =
            XP.getBeltProgress progress.totalXP White

        ( progressLabel, rewardsLabel ) =
            case model.userConfig.language of
                I18n.FR ->
                    ( "Progression", "Récompenses à venir" )

                I18n.EN ->
                    ( "Progress", "Next rewards" )
    in
    shCard "relative overflow-hidden p-6 md:p-8 text-slate-900 shadow-purple-xl bg-gradient-to-r from-white via-violet-50 to-indigo-50"
        [ div [ class "pointer-events-none absolute inset-0 opacity-40" ]
            [ div [ class "absolute -top-10 right-4 h-44 w-44 rounded-full bg-purple-200 blur-3xl" ] []
            , div [ class "absolute bottom-0 left-10 h-36 w-36 rounded-full bg-indigo-200 blur-3xl" ] []
            ]
        , div [ class "relative flex flex-col gap-8 lg:flex-row lg:items-center lg:justify-between" ]
            [ div [ class "space-y-4 text-center lg:text-left" ]
                [ span [ class "inline-flex items-center rounded-full bg-violet-100 px-4 py-1 text-xs font-semibold uppercase tracking-[0.4em] text-violet-700" ] [ text "Level" ]
                , div [ class "flex items-center justify-center gap-4 lg:justify-start" ]
                    [ div [ class "text-6xl font-black" ] [ text (String.fromInt level) ]
                    , div []
                        [ p [ class "text-sm text-slate-500" ] [ text "Current title" ]
                        , p [ class "text-2xl font-semibold text-violet-700" ] [ text (String.toUpper title.name) ]
                        ]
                    ]
                , viewBeltBadge currentBelt beltProgress
                ]
            , div [ class "w-full space-y-2 lg:w-96" ]
                [ div [ class "flex items-center justify-between text-sm text-slate-500" ]
                    [ span [] [ text "Experience" ]
                    , span [ class "text-lg font-semibold text-slate-900" ] [ text (String.fromInt progress.totalXP ++ " XP") ]
                    ]
                , div [ class "relative h-5 rounded-full bg-violet-100 ring-1 ring-violet-200" ]
                    [ div
                        [ class "absolute inset-y-0 left-0 rounded-full bg-gradient-to-r from-violet-500 via-indigo-500 to-purple-600"
                        , attribute "style" ("width: " ++ String.fromFloat (levelProgress * 100) ++ "%")
                        ]
                        []
                    , span [ class "absolute inset-0 flex items-center justify-center text-xs font-semibold text-slate-900" ]
                        [ text (String.fromInt xpInCurrentLevel ++ " / 1000 XP") ]
                    ]
                , div [ class "flex items-center justify-between text-xs text-slate-500" ]
                    [ span [] [ text progressLabel ]
                    , span [] [ text rewardsLabel ]
                    ]
                ]
            ]
        ]



-- TODAY'S FOCUS CARD


viewTodaysFocus : FrontendModel -> Html FrontendMsg
viewTodaysFocus model =
    shCard "p-6 space-y-6"
        [ div [ class "flex flex-col gap-1" ]
            [ span [ class "text-xs font-semibold uppercase tracking-[0.35em] text-slate-500" ] [ text "Focus" ]
            , h2 [ class "text-2xl font-semibold text-slate-900 dark:text-white" ] [ text model.userConfig.t.todaysFocus ]
            , p [ class "text-sm text-slate-500 dark:text-slate-400" ] [ text model.userConfig.t.todaysFocusSubtitle ]
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
        [ div [ class "flex flex-col gap-4 rounded-2xl border border-emerald-100 bg-emerald-50/80 p-4 dark:border-emerald-900/40 dark:bg-emerald-900/30 lg:flex-row lg:items-center lg:justify-between" ]
            [ div [ class "flex items-center gap-3" ]
                [ div [ class "flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-500 text-slate-900" ] [ text "▶" ]
                , div []
                    [ p [ class "text-xs font-semibold uppercase tracking-[0.3em] text-emerald-800" ] [ text model.userConfig.t.trainingActive ]
                    , p [ class "text-2xl font-bold text-slate-900 dark:text-white" ] [ text (formatTimer model.sessionTimer) ]
                    ]
                ]
            , button
                [ onClick EndSession
                , class "sh-btn bg-red-500 text-white hover:bg-red-500/90"
                ]
                [ text model.userConfig.t.endSession ]
            ]
        , case session.currentTechnique of
            Just techniqueId ->
                div [ class "rounded-2xl border border-slate-200 bg-slate-50/60 p-4 dark:border-slate-800 dark:bg-slate-900/60" ]
                    [ div [ class "flex items-center justify-between" ]
                        [ h3 [ class "text-sm font-semibold text-slate-600 uppercase tracking-[0.3em]" ] [ text model.userConfig.t.currentDrill ]
                        , span [ class "rounded-full bg-slate-900/5 px-3 py-1 text-xs font-semibold text-slate-500" ] [ text "Focus" ]
                        ]
                    , p [ class "mt-2 text-2xl font-bold text-slate-900 dark:text-white" ] [ text techniqueId ]
                    , div [ class "mt-4 flex gap-3" ]
                        [ button
                            [ onClick (IncrementReps techniqueId)
                            , class "sh-btn w-full bg-slate-900 text-white hover:bg-slate-800"
                            ]
                            [ text model.userConfig.t.addRep ]
                        , button
                            [ onClick (SetQuality techniqueId 5)
                            , class "sh-btn w-full bg-amber-400 text-slate-900 hover:bg-amber-300"
                            ]
                            [ text model.userConfig.t.perfect ]
                        ]
                    ]

            Nothing ->
                div [ class "rounded-2xl border border-dashed border-slate-300 p-6 text-center dark:border-slate-700" ]
                    [ p [ class "text-sm text-slate-500" ] [ text model.userConfig.t.chooseNextTechnique ]
                    , button
                        [ onClick (OpenModal TechniqueSelectionModal)
                        , class "sh-btn mt-4 bg-slate-900 text-white hover:bg-slate-800"
                        , type_ "button"
                        ]
                        [ text model.userConfig.t.selectTechnique ]
                    ]
        , div [ class "grid grid-cols-2 gap-4" ]
            [ shCard "p-4 text-center bg-gradient-to-br from-indigo-50 to-white dark:from-indigo-900/30 dark:to-slate-900/50"
                [ p [ class "text-xs font-semibold uppercase tracking-[0.3em] text-indigo-500" ] [ text "Session XP" ]
                , p [ class "text-2xl font-bold text-slate-900 dark:text-white" ] [ text ("+" ++ String.fromInt session.totalXP ++ " XP") ]
                ]
            , shCard "p-4 text-center bg-gradient-to-br from-amber-50 to-white dark:from-amber-900/30 dark:to-slate-900/50"
                [ p [ class "text-xs font-semibold uppercase tracking-[0.3em] text-amber-500" ] [ text "Techniques" ]
                , p [ class "text-2xl font-bold text-slate-900 dark:text-white" ] [ text (String.fromInt (List.length session.techniques)) ]
                ]
            ]
        ]


viewStartSessionPrompt : FrontendModel -> Html FrontendMsg
viewStartSessionPrompt model =
    div [ class "text-center py-10" ]
        [ div [ class "mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-900 text-white" ] [ text "⚡" ]
        , h3 [ class "text-2xl font-semibold text-slate-900 dark:text-white" ] [ text model.userConfig.t.readyToTrain ]
        , p [ class "mt-2 text-sm text-slate-500" ] [ text model.userConfig.t.readyToTrainSubtitle ]
        , button
            [ onClick StartSession
            , class "sh-btn mt-6 bg-slate-900 text-white hover:bg-slate-800"
            ]
            [ text model.userConfig.t.startTraining ]
        ]



-- QUICK STATS


viewQuickStats : FrontendModel -> Html FrontendMsg
viewQuickStats model =
    div [ class "grid grid-cols-2 gap-4 lg:grid-cols-4" ]
        [ quickStatCard model.userConfig.t.trainingStreak (I18n.formatStreak model.userConfig.language model.userProgress.currentStreak) "🔥"
        , quickStatCard model.userConfig.t.xpToday "245 XP" "⚡"
        , quickStatCard model.userConfig.t.techniques (String.fromInt (Dict.size model.userProgress.techniqueMastery)) "🥋"
        , quickStatCard model.userConfig.t.rank "#127" "🏆"
        ]


quickStatCard : String -> String -> String -> Html FrontendMsg
quickStatCard label value icon =
    shCard "p-4"
        [ div [ class "flex items-center justify-between gap-3" ]
            [ div [ class "text-2xl" ] [ text icon ]
            , span [ class "text-xs font-semibold uppercase tracking-[0.35em] text-slate-500 dark:text-slate-400" ] [ text label ]
            ]
        , div [ class "text-2xl font-bold text-slate-900 dark:text-white" ] [ text value ]
        ]



-- BELT BADGE


viewBeltBadge : BeltLevel -> Float -> Html msg
viewBeltBadge belt progress =
    let
        ( bgColor, textColor, nextBeltName ) =
            case belt of
                White ->
                    ( "bg-gray-100", "text-gray-800", "BLUE BELT" )

                Blue ->
                    ( "bg-blue-500", "text-gray-900", "PURPLE BELT" )

                Purple ->
                    ( "bg-purple-500", "text-gray-900", "BROWN BELT" )

                Brown ->
                    ( "bg-yellow-800", "text-gray-900", "BLACK BELT" )

                Black ->
                    ( "bg-black", "text-gray-900", "MASTER" )
    in
    div [ class "rounded-2xl bg-white/10 p-4 text-left ring-1 ring-white/15" ]
        [ div [ class ("inline-flex items-center rounded-full px-4 py-1 text-xs font-semibold tracking-[0.4em] " ++ bgColor ++ " " ++ textColor) ]
            [ text (String.toUpper (beltLevelToString belt)) ]
        , if belt /= Black then
            div [ class "mt-3 space-y-1" ]
                [ div [ class "flex items-center justify-between text-xs text-white/70" ]
                    [ span [] [ text ("Vers " ++ nextBeltName) ]
                    , span [] [ text (String.fromInt (round (progress * 100)) ++ "%") ]
                    ]
                , div [ class "h-1.5 rounded-full bg-white/20" ]
                    [ div
                        [ class ("h-full rounded-full " ++ beltProgressBarColor belt)
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
        weeklyXP =
            model.userProgress.weeklyGoals.currentXP

        weeklyTarget =
            model.userProgress.weeklyGoals.totalXPTarget

        percentage =
            if weeklyTarget > 0 then
                toFloat weeklyXP / toFloat weeklyTarget * 100

            else
                0
    in
    shCard "p-6 space-y-6"
        [ div []
            [ span [ class "text-xs font-semibold uppercase tracking-[0.35em] text-emerald-500" ] [ text "Weekly goal" ]
            , h3 [ class "text-xl font-semibold text-slate-900 dark:text-white" ] [ text "Objectif XP" ]
            ]
        , div [ class "text-center" ]
            [ p [ class "text-3xl font-bold text-slate-900 dark:text-white" ] [ text (String.fromInt weeklyXP ++ " / " ++ String.fromInt weeklyTarget ++ " XP") ]
            , p [ class "text-sm text-slate-500" ] [ text "cette semaine" ]
            ]
        , div [ class "h-3 rounded-full bg-slate-200" ]
            [ div
                [ class "h-full rounded-full bg-emerald-500"
                , attribute "style" ("width: " ++ String.fromFloat percentage ++ "%")
                ]
                []
            ]
        , p [ class "text-center text-sm font-semibold text-emerald-600" ] [ text (String.fromInt (round percentage) ++ "% complet") ]
        ]


viewTechniqueProgress : FrontendModel -> Html msg
viewTechniqueProgress model =
    let
        totalTechniques =
            Dict.size model.userProgress.techniqueMastery

        masteredCount =
            model.userProgress.techniqueMastery
                |> Dict.values
                |> List.filter (\t -> t.mastery == Mastered)
                |> List.length

        masteryPercentage =
            if totalTechniques > 0 then
                toFloat masteredCount / toFloat totalTechniques * 100

            else
                0
    in
    shCard "p-6 space-y-6"
        [ div []
            [ span [ class "text-xs font-semibold uppercase tracking-[0.35em] text-indigo-500" ] [ text "Techniques" ]
            , h3 [ class "text-xl font-semibold text-slate-900 dark:text-white" ] [ text "Progression de maîtrise" ]
            ]
        , div [ class "text-center" ]
            [ p [ class "text-3xl font-bold text-slate-900 dark:text-white" ]
                [ text (String.fromInt masteredCount ++ " / " ++ String.fromInt totalTechniques) ]
            , p [ class "text-sm text-slate-500" ] [ text "techniques maîtrisées" ]
            ]
        , viewMasteryBreakdownOld model.userProgress.techniqueMastery
        , div [ class "h-3 rounded-full bg-slate-200" ]
            [ div
                [ class "h-full rounded-full bg-gradient-to-r from-indigo-500 to-purple-500"
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
        , span [ class "text-gray-600 dark:text-gray-600" ] [ text (String.fromInt count) ]
        ]


viewNextGoal : FrontendModel -> Html msg
viewNextGoal model =
    case List.head model.userProgress.weeklyGoals.goals of
        Just goal ->
            div []
                [ p [ class "text-sm font-medium text-gray-900 dark:text-gray-900 mb-2" ]
                    [ text goal.description ]
                , div [ class "h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden" ]
                    [ div
                        [ class "h-full bg-gradient-to-r from-yellow-400 to-orange-500 transition-all"
                        , style "width" (String.fromFloat (goal.progress * 100) ++ "%")
                        ]
                        []
                    ]
                , p [ class "text-xs text-gray-600 dark:text-gray-600 mt-1" ]
                    [ text (String.fromInt (round (goal.progress * 100)) ++ "% Complete") ]
                ]

        Nothing ->
            p [ class "text-gray-600 dark:text-gray-600" ] [ text "No active goals" ]



-- ACTIVE ROADMAPS


viewActiveRoadmaps : FrontendModel -> Html FrontendMsg
viewActiveRoadmaps model =
    shCard "p-6 space-y-6"
        [ div []
            [ span [ class "text-xs font-semibold uppercase tracking-[0.35em] text-slate-500" ] [ text "Active roadmaps" ]
            , h3 [ class "text-xl font-semibold text-slate-900 dark:text-white" ] [ text "Tes parcours guidés" ]
            , p [ class "text-sm text-slate-500" ] [ text "Reste concentré sur les étapes qui comptent." ]
            ]
        , case Dict.toList model.roadmaps of
            [] ->
                div [ class "rounded-2xl border border-dashed border-slate-200 p-8 text-center dark:border-slate-700" ]
                    [ p [ class "text-lg font-semibold text-slate-900 dark:text-white" ] [ text "Aucun roadmap actif" ]
                    , p [ class "text-sm text-slate-500" ] [ text "Choisis un parcours pour lancer ton voyage." ]
                    , button
                        [ onPreventDefaultClick (NavigateTo (HeroesRoute Nothing))
                        , class "sh-btn mt-4 bg-slate-900 text-white hover:bg-slate-800"
                        ]
                        [ text "Parcourir les roadmaps" ]
                    ]

            roadmaps ->
                div [ class "space-y-3" ]
                    (List.map viewRoadmapCard roadmaps)
        ]


viewRoadmapCard : ( String, TechniqueRoadmap ) -> Html FrontendMsg
viewRoadmapCard ( id, roadmap ) =
    let
        totalNodes =
            List.length roadmap.nodes

        completedNodes =
            roadmap.nodes
                |> List.filter (\node -> node.status == NodeCompleted || node.status == NodeMastered)
                |> List.length

        progressPct =
            if totalNodes > 0 then
                (toFloat completedNodes / toFloat totalNodes) * 100

            else
                0
    in
    div
        [ class "cursor-pointer rounded-2xl border border-slate-200 bg-white/70 p-5 transition hover:-translate-y-0.5 hover:border-slate-300 dark:border-slate-800 dark:bg-slate-900/50"
        , onClick (SelectRoadmap id)
        ]
        [ div [ class "flex items-center justify-between" ]
            [ div []
                [ h4 [ class "text-lg font-semibold text-slate-900 dark:text-white" ] [ text roadmap.name ]
                , p [ class "text-sm text-slate-500" ] [ text roadmap.description ]
                ]
            , span [ class "rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600 dark:bg-slate-800 dark:text-slate-300" ]
                [ text (String.fromInt roadmap.estimatedWeeks ++ " w") ]
            ]
        , div [ class "mt-4 h-2 rounded-full bg-slate-200" ]
            [ div
                [ class "h-full rounded-full bg-slate-900"
                , attribute "style" ("width: " ++ String.fromFloat progressPct ++ "%")
                ]
                []
            ]
        , div [ class "mt-3 flex items-center justify-between text-xs font-semibold uppercase tracking-[0.3em] text-slate-400" ]
            [ span [] [ text (String.fromInt completedNodes ++ "/" ++ String.fromInt totalNodes ++ " nodes") ]
            , span [] [ text (String.fromInt (round progressPct) ++ "%") ]
            ]
        ]



-- DAILY QUESTS


viewDailyQuests : FrontendModel -> List Quest -> Html FrontendMsg
viewDailyQuests model quests =
    shCard "p-6 space-y-6"
        [ div []
            [ span [ class "text-xs font-semibold uppercase tracking-[0.35em] text-rose-500" ] [ text "Quests" ]
            , h3 [ class "text-xl font-semibold text-slate-900 dark:text-white" ] [ text model.userConfig.t.dailyQuests ]
            , p [ class "text-sm text-slate-500" ] [ text model.userConfig.t.dailyQuestsSubtitle ]
            ]
        , if List.isEmpty quests then
            div [ class "rounded-2xl border border-emerald-100 bg-emerald-50/60 p-6 text-center dark:border-emerald-900/40 dark:bg-emerald-900/20" ]
                [ p [ class "text-lg font-semibold text-emerald-600" ] [ text model.userConfig.t.allQuestsCompleted ]
                , p [ class "text-sm text-emerald-800/80" ] [ text model.userConfig.t.comeBackTomorrow ]
                ]

          else
            div [ class "space-y-3" ] (List.map viewQuest quests)
        ]


viewQuest : Quest -> Html FrontendMsg
viewQuest quest =
    let
        completedClass =
            "border border-emerald-200/60 bg-emerald-50/80 dark:border-emerald-900/40 dark:bg-emerald-900/30 text-emerald-900"

        pendingClass =
            "border border-slate-200 bg-white p-4 dark:border-slate-800 dark:bg-slate-900/50 transition hover:border-slate-300 dark:hover:border-slate-700"
    in
    div
        [ class
            ("rounded-2xl p-4 "
                ++ (if quest.completed then
                        completedClass

                    else
                        pendingClass
                   )
            )
        ]
        [ div [ class "flex items-center gap-4" ]
            [ div
                [ class
                    ("flex h-10 w-10 items-center justify-center rounded-xl "
                        ++ (if quest.completed then
                                "bg-emerald-500 text-white"

                            else
                                "bg-slate-100 text-slate-500"
                           )
                    )
                ]
                [ text
                    (if quest.completed then
                        "✓"

                     else
                        "•"
                    )
                ]
            , div [ class "flex-1 space-y-1" ]
                [ h4 [ class "font-semibold text-slate-900 dark:text-white" ] [ text quest.title ]
                , p [ class "text-sm text-slate-500" ] [ text quest.description ]
                , if quest.completed then
                    text ""

                  else
                    div [ class "mt-2 space-y-1" ]
                        [ div [ class "flex items-center justify-between text-xs text-slate-500" ]
                            [ span [] [ text "Progress" ]
                            , span [] [ text (String.fromInt (round (quest.progress * 100)) ++ "%") ]
                            ]
                        , div [ class "h-1.5 rounded-full bg-slate-200" ]
                            [ div
                                [ class "h-full rounded-full bg-slate-900"
                                , attribute "style" ("width: " ++ String.fromFloat (quest.progress * 100) ++ "%")
                                ]
                                []
                            ]
                        ]
                ]
            , div [ class "text-right" ]
                [ span [ class "text-xs font-semibold uppercase tracking-[0.3em] text-slate-400" ] [ text "XP" ]
                , p [ class "text-lg font-bold text-slate-900 dark:text-white" ] [ text ("+" ++ String.fromInt quest.xpReward) ]
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
    shCard "p-6 space-y-6"
        ([ div []
            [ span [ class "text-xs font-semibold uppercase tracking-[0.35em] text-amber-500" ] [ text "Achievements" ]
            , h3 [ class "text-xl font-semibold text-slate-900 dark:text-white" ] [ text "Tes dernières victoires" ]
            ]
         ]
            ++ (if List.isEmpty recentBadges then
                    [ div [ class "rounded-2xl border border-dashed border-slate-200 p-8 text-center dark:border-slate-700" ]
                        [ p [ class "text-sm text-slate-500" ] [ text "Aucun badge débloqué pour l'instant. Continue ton entraînement !" ]
                        ]
                    ]

                else
                    [ div [ class "grid grid-cols-2 gap-4 lg:grid-cols-3" ]
                        (List.map viewBadge recentBadges)
                    ]
               )
        )


viewBadge : Badge -> Html msg
viewBadge badge =
    div
        [ class "p-4 bg-gradient-to-br from-yellow-500/10 via-orange-500/10 to-red-500/10 border border-yellow-500/20 rounded-xl text-center hover:scale-105 transition-all group"
        , attribute "title" badge.description
        ]
        [ div [ class "w-12 h-12 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center mx-auto mb-3 group-hover:scale-110 transition-transform" ]
            [ span [ class "text-2xl" ] [ text badge.icon ] ]
        , div [ class "font-bold text-gray-900 text-sm" ] [ text badge.name ]
        , div [ class "text-xs text-gray-600 mt-1" ] [ text "EARNED" ]
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
        ( color, textColor ) =
            case belt of
                White ->
                    ( "bg-white", "text-gray-800" )

                Blue ->
                    ( "bg-blue-500", "text-gray-900" )

                Purple ->
                    ( "bg-purple-500", "text-gray-900" )

                Brown ->
                    ( "bg-yellow-800", "text-gray-900" )

                Black ->
                    ( "bg-black", "text-gray-900" )
    in
    div [ class ("px-3 py-1 rounded " ++ color ++ " " ++ textColor ++ " font-bold text-sm") ]
        [ text (beltLevelToString belt) ]


beltLevelToString : BeltLevel -> String
beltLevelToString belt =
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


nextBelt : BeltLevel -> BeltLevel
nextBelt belt =
    case belt of
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


beltProgressBarColor : BeltLevel -> String
beltProgressBarColor belt =
    case belt of
        White ->
            "bg-blue-500"

        Blue ->
            "bg-purple-500"

        Purple ->
            "bg-yellow-700"

        Brown ->
            "bg-gray-800"

        Black ->
            "bg-black"


formatTimer : Int -> String
formatTimer seconds =
    let
        mins =
            seconds // 60

        secs =
            remainderBy 60 seconds
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


shCard : String -> List (Html msg) -> Html msg
shCard extra children =
    div [ class ("sh-card rounded-2xl border border-slate-200/70 bg-white/90 dark:bg-slate-900/70 " ++ extra) ] children


countMastery : TechniqueMastery -> { learning : Int, practicing : Int, proficient : Int, advanced : Int, mastered : Int } -> { learning : Int, practicing : Int, proficient : Int, advanced : Int, mastered : Int }
countMastery technique counts =
    case technique.mastery of
        NotStarted ->
            counts

        -- Not started techniques don't count
        Learning ->
            { counts | learning = counts.learning + 1 }

        Practicing ->
            { counts | practicing = counts.practicing + 1 }

        Proficient ->
            { counts | proficient = counts.proficient + 1 }

        Advanced ->
            { counts | advanced = counts.advanced + 1 }

        Mastered ->
            { counts | mastered = counts.mastered + 1 }
