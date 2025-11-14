module Pages.TrainingSession exposing (view, viewTrainingSession)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Types exposing (..)
import GameMechanics.XP as XP
import Time
import Dict
import String


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
    div [ class "min-h-screen bg-gray-50 dark:bg-gray-900 py-10" ]
        [ div [ class "max-w-6xl mx-auto px-4 space-y-8" ]
            [ viewTrainingHero model
            , div [ class "grid gap-6 lg:grid-cols-3" ]
                [ viewChampionSelectorCard model
                , viewChampionSnapshot model
                , viewPlanSummaryCard model
                ]
            , viewTechniquePlanner model
            , viewActionTracker model
            , div [ class "grid gap-6 lg:grid-cols-2" ]
                [ viewTodaysGoals model
                , viewRecentSessions model.trainingSessions
                ]
            ]
        ]


viewTrainingHero : FrontendModel -> Html FrontendMsg
viewTrainingHero model =
    let
        plannedCount =
            List.length model.plannedTechniques

        hasChampion =
            Maybe.withDefault False (Maybe.map (\_ -> True) model.selectedChampion)

        canStart =
            hasChampion && plannedCount > 0

        championName =
            model.selectedChampion
                |> Maybe.andThen (\id -> Dict.get id model.heroes)
                |> Maybe.map .name
                |> Maybe.withDefault "Aucun champion sélectionné"

        planText =
            if plannedCount == 0 then
                "Sélectionne jusqu'à 3 techniques pour ton focus du jour."

            else
                "Plan du jour : " ++ String.fromInt plannedCount ++ "/3 techniques prêtes."

        buttonClass =
            "start-session-button start-session-button--large w-full md:w-auto"
                ++ (if canStart then "" else " opacity-60 cursor-not-allowed")
    in
    div [ class "bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-gray-100 dark:border-gray-800 p-8" ]
        [ div [ class "flex flex-col gap-4" ]
            [ div []
                [ h1 [ class "text-3xl font-bold text-gray-900 dark:text-white" ]
                    [ text "Ready to Train?" ]
                , p [ class "text-gray-600 dark:text-gray-400" ]
                    [ text "Start a new training session to track your progress and earn XP!" ]
                ]
            , div [ class "flex flex-wrap gap-3 text-sm" ]
                [ viewHeroMetaBadge "Champion" championName
                , viewHeroMetaBadge "Techniques planifiées" (String.fromInt plannedCount ++ "/3")
                ]
            , div [ class "flex flex-col md:flex-row md:items-center gap-4" ]
                [ button
                    ([ onClick StartSession
                     , class buttonClass
                     ]
                        ++ (if canStart then [] else [ disabled True ])
                    )
                    [ span [ class "start-session-button__icon" ] [ text "⚡" ]
                    , span [ class "start-session-button__label" ] [ text model.userConfig.t.startSession ]
                    ]
                , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text planText ]
                ]
            ]
        ]


viewHeroMetaBadge : String -> String -> Html msg
viewHeroMetaBadge label value =
    div [ class "px-4 py-2 rounded-full bg-gray-100 dark:bg-gray-700" ]
        [ span [ class "text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block" ] [ text label ]
        , span [ class "text-sm font-semibold text-gray-900 dark:text-white" ] [ text value ]
        ]


viewChampionSelectorCard : FrontendModel -> Html FrontendMsg
viewChampionSelectorCard model =
    let
        heroesList =
            model.heroes |> Dict.values |> List.sortBy .name

        selectedValue =
            Maybe.withDefault "" model.selectedChampion
    in
    div [ class "bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800 p-6 flex flex-col gap-4" ]
        [ div []
            [ span [ class "text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400" ] [ text "Étape 1" ]
            , h3 [ class "text-xl font-semibold text-gray-900 dark:text-white" ] [ text "Choisis ton champion" ]
            , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
                [ text "Récupère automatiquement ses techniques signature pour construire ton plan." ]
            ]
        , select
            [ class "px-4 py-2 rounded-xl border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900 text-sm text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
            , value selectedValue
            , onInput SelectTrainingChampion
            ]
            (option [ value "" ] [ text "— Choisis un champion —" ]
                :: List.map
                    (\hero ->
                        option
                            [ value hero.id
                            , selected (selectedValue == hero.id)
                            ]
                            [ text hero.name ]
                    )
                    heroesList
            )
        , div [ class "flex flex-wrap gap-2" ]
            (heroesList
                |> List.take 4
                |> List.map (viewChampionQuickPick selectedValue)
            )
        ]


viewChampionQuickPick : String -> Hero -> Html FrontendMsg
viewChampionQuickPick selectedValue hero =
    button
        [ onClick (SelectTrainingChampion hero.id)
        , class
            ("px-3 py-2 rounded-xl border text-sm transition-colors"
                ++ (if selectedValue == hero.id then
                        " border-blue-500 bg-blue-50 text-blue-700 dark:border-blue-400 dark:bg-blue-900/40 dark:text-blue-100"

                    else
                        " border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-200 hover:border-blue-400"
                   )
            )
        ]
        [ text hero.name ]


viewChampionSnapshot : FrontendModel -> Html FrontendMsg
viewChampionSnapshot model =
    case model.selectedChampion |> Maybe.andThen (\id -> Dict.get id model.heroes) of
        Nothing ->
            viewEmptyCard "Profil champion" "Choisis un champion pour visualiser son style, son équipe et ses techniques favorites." "🧑‍🎓"

        Just hero ->
            div [ class "bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800 p-6" ]
                [ span [ class "text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400" ] [ text "Étape 2" ]
                , h3 [ class "text-xl font-semibold text-gray-900 dark:text-white mb-4" ] [ text "Focus champion" ]
                , div [ class "flex items-center gap-4" ]
                    [ img
                        [ src hero.imageUrl
                        , alt hero.name
                        , class "h-16 w-16 rounded-2xl object-cover ring-2 ring-blue-200 dark:ring-blue-900/60"
                        ]
                        []
                    , div []
                        [ h4 [ class "text-lg font-semibold text-gray-900 dark:text-white" ] [ text hero.name ]
                        , p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text hero.team ]
                        , div [ class "flex flex-wrap gap-2 mt-2 text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400" ]
                            [ span [ class "px-2 py-1 rounded-full bg-gray-100 dark:bg-gray-700" ] [ text (styleLabel hero.style) ]
                            , span [ class "px-2 py-1 rounded-full bg-gray-100 dark:bg-gray-700" ] [ text (weightLabel hero.weight) ]
                            ]
                        ]
                    ]
                , div [ class "grid grid-cols-2 gap-4 mt-6 text-sm" ]
                    [ viewSnapshotStat "Position favorite" hero.stats.favoritePosition
                    , viewSnapshotStat "Soumission signature" hero.stats.favoriteSubmission
                    ]
                ]


viewSnapshotStat : String -> String -> Html msg
viewSnapshotStat label value =
    div [ class "p-3 rounded-xl bg-gray-50 dark:bg-gray-900/60 border border-gray-100 dark:border-gray-700" ]
        [ span [ class "text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400" ] [ text label ]
        , p [ class "text-base font-semibold text-gray-900 dark:text-white mt-1" ] [ text value ]
        ]


viewPlanSummaryCard : FrontendModel -> Html FrontendMsg
viewPlanSummaryCard model =
    let
        plannedCount =
            List.length model.plannedTechniques

        championName =
            model.selectedChampion
                |> Maybe.andThen (\id -> Dict.get id model.heroes)
                |> Maybe.map .name
                |> Maybe.withDefault "À définir"

        completedXp =
            model.trainingActions
                |> List.filter (\action -> action.status == ActionCompleted)
                |> List.map .xp
                |> List.sum

        progressPercent =
            (toFloat plannedCount / 3) * 100
    in
    div [ class "bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800 p-6" ]
        [ span [ class "text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400" ] [ text "Étape 3" ]
        , h3 [ class "text-xl font-semibold text-gray-900 dark:text-white mb-4" ] [ text "Blueprint de la session" ]
        , div [ class "space-y-3 text-sm" ]
            [ viewPlanSummaryRow "Champion focus" championName
            , viewPlanSummaryRow "Techniques retenues" (String.fromInt plannedCount ++ "/3")
            , viewPlanSummaryRow "XP actions validées" ("+" ++ String.fromInt completedXp ++ " XP")
            ]
        , div [ class "mt-4" ]
            [ div [ class "h-2 rounded-full bg-gray-100 dark:bg-gray-900/60 overflow-hidden" ]
                [ div
                    [ class "h-full bg-gradient-to-r from-blue-500 to-indigo-500"
                    , style "width" (String.fromFloat (Basics.min 100 progressPercent) ++ "%")
                    ]
                    []
                ]
            , p [ class "text-xs text-gray-500 dark:text-gray-400 mt-2" ]
                [ text "Rappelle-toi : focus sur la qualité, pas la quantité." ]
            ]
        ]


viewPlanSummaryRow : String -> String -> Html msg
viewPlanSummaryRow label value =
    div [ class "flex items-center justify-between" ]
        [ span [ class "text-gray-500 dark:text-gray-400" ] [ text label ]
        , span [ class "font-semibold text-gray-900 dark:text-white" ] [ text value ]
        ]


viewTechniquePlanner : FrontendModel -> Html FrontendMsg
viewTechniquePlanner model =
    let
        maybeHero =
            model.selectedChampion |> Maybe.andThen (\id -> Dict.get id model.heroes)

        availableTechniques =
            maybeHero |> Maybe.map .techniques |> Maybe.withDefault []
    in
    div [ class "bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800 p-6" ]
        [ div [ class "flex flex-col gap-1 mb-4" ]
            [ span [ class "text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400" ] [ text "Étape 4" ]
            , h3 [ class "text-xl font-semibold text-gray-900 dark:text-white" ] [ text "Techniques à travailler" ]
            , p [ class "text-sm text-gray-600 dark:text-gray-400" ]
                [ text "Choisis jusqu'à 3 techniques clés. Elles seront ajoutées à Today Goal et suivies pendant ta session." ]
            ]
        , case maybeHero of
            Nothing ->
                viewEmptyCard "Sélection requise" "Choisis d'abord un champion pour afficher ses techniques signature." "📚"

            Just _ ->
                if List.isEmpty availableTechniques then
                    viewEmptyCard "Aucune technique" "Ce champion n'a pas encore de techniques associées." "🧩"

                else
                    div [ class "space-y-6" ]
                        [ div [ class "grid gap-4 md:grid-cols-2" ]
                            (List.map (viewTechniqueCard model.plannedTechniques) availableTechniques)
                        , p [ class "text-xs text-gray-500 dark:text-gray-400" ]
                            [ text ("Sélection : " ++ String.fromInt (List.length model.plannedTechniques) ++ "/3 techniques actives.") ]
                        ]
        ]


viewTechniqueCard : List String -> Technique -> Html FrontendMsg
viewTechniqueCard planned technique =
    let
        isSelected =
            List.member technique.id planned

        baseClass =
            if isSelected then
                "border-blue-500 bg-blue-50 dark:border-blue-400 dark:bg-blue-900/30"

            else
                "border-gray-200 dark:border-gray-700 hover:border-blue-400"
    in
    button
        [ onClick (TogglePlannedTechnique technique.id)
        , class ("w-full text-left p-4 rounded-2xl border transition-colors " ++ baseClass)
        , type_ "button"
        ]
        [ div [ class "flex items-center justify-between" ]
            [ h4 [ class "font-semibold text-gray-900 dark:text-white" ] [ text technique.name ]
            , span [ class "text-sm font-semibold text-green-600 dark:text-green-400" ] [ text ("+" ++ String.fromInt technique.xpValue ++ " XP") ]
            ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400 mt-1" ]
            [ text (techniqueCategoryLabel technique.category ++ " • " ++ difficultyLabel technique.difficulty) ]
        , if String.isEmpty technique.description then
            text ""

          else
            p [ class "text-xs text-gray-500 dark:text-gray-400 mt-2 line-clamp-2" ] [ text technique.description ]
        ]


viewActionTracker : FrontendModel -> Html FrontendMsg
viewActionTracker model =
    let
        completedXp =
            model.trainingActions
                |> List.filter (\action -> action.status == ActionCompleted)
                |> List.map .xp
                |> List.sum

        columns =
            [ ActionBacklog, ActionInProgress, ActionCompleted ]
    in
    div [ class "bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800 p-6" ]
        [ div [ class "flex items-center justify-between mb-4" ]
            [ h3 [ class "text-xl font-semibold text-gray-900 dark:text-white" ] [ text "Action tracker façon Notion" ]
            , span [ class "text-sm font-semibold text-green-600 dark:text-green-400" ]
                [ text ("+" ++ String.fromInt completedXp ++ " XP validés") ]
            ]
        , div [ class "grid gap-4 lg:grid-cols-3" ]
            (List.map (\status -> viewActionColumn status model.trainingActions) columns)
        ]


viewActionColumn : ActionStatus -> List TrainingAction -> Html FrontendMsg
viewActionColumn status actions =
    let
        columnActions =
            List.filter (\action -> action.status == status) actions
    in
    div [ class "rounded-2xl border border-gray-100 dark:border-gray-700 p-4 bg-gray-50 dark:bg-gray-900/40" ]
        [ div [ class "flex items-center justify-between mb-3" ]
            [ div [ class "flex items-center gap-2" ]
                [ span [ class "text-lg" ] [ text (actionStatusEmoji status) ]
                , span [ class "text-sm font-semibold text-gray-900 dark:text-white" ] [ text (actionStatusLabel status) ]
                ]
            , span [ class ("text-xs font-semibold " ++ actionStatusAccent status) ]
                [ text (String.fromInt (List.length columnActions) ++ " cartes") ]
            ]
        , if List.isEmpty columnActions then
            p [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text "Glisse tes actions ici." ]

          else
            div [ class "space-y-3" ] (List.map viewActionCard columnActions)
        ]


viewActionCard : TrainingAction -> Html FrontendMsg
viewActionCard action =
    div [ class "p-4 rounded-2xl bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 shadow-sm space-y-2" ]
        [ div [ class "flex items-center justify-between" ]
            [ span [ class "text-2xl" ] [ text action.icon ]
            , span [ class "text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase" ]
                [ text ("+" ++ String.fromInt action.xp ++ " XP") ]
            ]
        , h4 [ class "text-base font-semibold text-gray-900 dark:text-white" ] [ text action.title ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text action.description ]
        , button
            [ onClick (CycleTrainingActionStatus action.id)
            , class "text-sm font-semibold text-blue-600 dark:text-blue-400 hover:underline"
            ]
            [ text (actionStatusCta action.status) ]
        ]


actionStatusLabel : ActionStatus -> String
actionStatusLabel status =
    case status of
        ActionBacklog ->
            "Backlog"

        ActionInProgress ->
            "En cours"

        ActionCompleted ->
            "Terminé"


actionStatusAccent : ActionStatus -> String
actionStatusAccent status =
    case status of
        ActionBacklog ->
            "text-gray-500 dark:text-gray-400"

        ActionInProgress ->
            "text-orange-500"

        ActionCompleted ->
            "text-green-600 dark:text-green-400"


actionStatusCta : ActionStatus -> String
actionStatusCta status =
    case status of
        ActionBacklog ->
            "Commencer"

        ActionInProgress ->
            "Valider et gagner l'XP"

        ActionCompleted ->
            "Rejouer"


actionStatusEmoji : ActionStatus -> String
actionStatusEmoji status =
    case status of
        ActionBacklog ->
            "📋"

        ActionInProgress ->
            "⚙️"

        ActionCompleted ->
            "✅"


viewEmptyCard : String -> String -> String -> Html msg
viewEmptyCard title message icon =
    div [ class "text-center p-8 rounded-2xl border-2 border-dashed border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800" ]
        [ span [ class "text-3xl" ] [ text icon ]
        , h4 [ class "text-lg font-semibold text-gray-900 dark:text-white mt-2" ] [ text title ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400 mt-2" ] [ text message ]
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
            [ div [ class "flex flex-wrap gap-2" ]
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


styleLabel : FightingStyle -> String
styleLabel style =
    case style of
        Guard ->
            "Garde"

        Passing ->
            "Passage"

        LegLocks ->
            "Attaques de jambes"

        Wrestling ->
            "Lutte"

        Balanced ->
            "Équilibré"

        Submission ->
            "Soumissions"

        Pressure ->
            "Pression"


weightLabel : WeightClass -> String
weightLabel weight =
    case weight of
        Rooster ->
            "Poids coq"

        LightFeather ->
            "Plume léger"

        Feather ->
            "Plume"

        Light ->
            "Léger"

        Middle ->
            "Moyen"

        MediumHeavy ->
            "Moyen-lourd"

        Heavy ->
            "Lourd"

        SuperHeavy ->
            "Super-lourd"

        UltraHeavy ->
            "Ultra-lourd"


techniqueCategoryLabel : TechniqueCategory -> String
techniqueCategoryLabel category =
    case category of
        GuardTechnique ->
            "Progression de garde"

        PassingTechnique ->
            "Systèmes de passage"

        TakedownTechnique ->
            "Entrées debout"

        SubmissionTechnique ->
            "Chaînes de soumissions"

        EscapeTechnique ->
            "Sorties et défenses"

        SweepTechnique ->
            "Balayages & renversements"


difficultyLabel : Difficulty -> String
difficultyLabel difficulty =
    case difficulty of
        Beginner ->
            "Débutant"

        Intermediate ->
            "Intermédiaire"

        DifficultyAdvanced ->
            "Avancé"

        Expert ->
            "Expert"
