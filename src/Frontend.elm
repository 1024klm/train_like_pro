module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Dict exposing (Dict)
import Effect.Browser.Dom as Dom exposing (HtmlId)
import Effect.Browser.Events as Events
import Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Lamdera
import Effect.Subscription as Subscription exposing (Subscription)
import Task
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import I18n
import LocalStorage
import Theme
import Types exposing (..)
import Progress
import Url


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


init : Url.Url -> Browser.Navigation.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , localStorage = LocalStorage.defaultLocalStorage
      , clientId = ""
      , selectedHero = Nothing
      , activeTab = Overview
      , heroes = initHeroes
      , learningPhases = initLearningPhases
      , trainingSessions = []
      , techniqueProgress = []
      , achievements = Progress.getAchievements
      , showAddSessionModal = False
      , newSessionForm = emptySessionForm
      }
    , Cmd.batch
        [ Task.perform (\_ -> NoOpFrontendMsg) (Task.succeed ())
        , Lamdera.sendToBackend GetUserSession
        ]
    )


emptySessionForm : NewSessionForm
emptySessionForm =
    { heroId = Nothing
    , duration = ""
    , sessionType = Technique
    , techniques = ""
    , notes = ""
    , date = ""
    }


initHeroes : Dict String Hero
initHeroes =
    Dict.fromList
        [ ( "gordon"
          , { name = "Gordon Ryan"
            , nickname = "The King"
            , color = "bg-red-500"
            , lightColor = "bg-red-100"
            , specialties = [ "Leg Locks", "Back Control", "Mental Game" ]
            , philosophy = "Perfectionnement technique obsessionnel + confiance absolue"
            , keyPrinciples =
                [ "Maîtriser les détails avant la vitesse"
                , "Développer un jeu complet (gi/no-gi)"
                , "Confiance mentale = arme secrète"
                , "Étudier constamment les adversaires"
                ]
            , trainingApproach =
                { technique = "2-3h/jour de technique pure"
                , drilling = "Répétition jusqu'à l'automatisme"
                , sparring = "Rounds ciblés sur positions spécifiques"
                , study = "Analyse vidéo quotidienne"
                }
            , weeklyPlan =
                [ "Lundi: Leg locks + back attacks"
                , "Mardi: Passing + top control"
                , "Mercredi: Guard + sweeps"
                , "Jeudi: Submissions + transitions"
                , "Vendredi: Sparring libre"
                , "Samedi: Drilling intensif"
                , "Dimanche: Récupération + étude"
                ]
            }
          )
        , ( "buchecha"
          , { name = "Marcus Buchecha Almeida"
            , nickname = "The Phenom"
            , color = "bg-blue-600"
            , lightColor = "bg-blue-100"
            , specialties = [ "Pressure Passing", "Top Control", "Athleticism" ]
            , philosophy = "Pression constante + cardio surhumain + technique solide"
            , keyPrinciples =
                [ "La pression brise la technique"
                , "Cardio = base de tout"
                , "Simplicité > complexité"
                , "Toujours avancer, jamais reculer"
                ]
            , trainingApproach =
                { technique = "Focus sur les fondamentaux"
                , drilling = "Haute intensité + répétition"
                , sparring = "Rounds longs (10-15min)"
                , study = "Analyse de ses propres erreurs"
                }
            , weeklyPlan =
                [ "Lundi: Cardio + passes de garde"
                , "Mardi: Top control + submissions"
                , "Mercredi: Défense + escapes"
                , "Jeudi: Sparring intensif"
                , "Vendredi: Technique + drilling"
                , "Samedi: Compétition simulation"
                , "Dimanche: Récupération active"
                ]
            }
          )
        , ( "rafael"
          , { name = "Rafael Mendes"
            , nickname = "The Wizard"
            , color = "bg-green-600"
            , lightColor = "bg-green-100"
            , specialties = [ "Berimbolo", "Lapel Guards", "Movement" ]
            , philosophy = "Innovation technique + fluidité parfaite"
            , keyPrinciples =
                [ "Créer de nouveaux mouvements"
                , "Fluidité > force"
                , "Chaque position a une solution"
                , "Enseigner pour mieux comprendre"
                ]
            , trainingApproach =
                { technique = "Expérimentation constante"
                , drilling = "Mouvements fluides et enchaînements"
                , sparring = "Jeu créatif et positions nouvelles"
                , study = "Développement technique personnel"
                }
            , weeklyPlan =
                [ "Lundi: Berimbolo + transitions"
                , "Mardi: Lapel guards + sweeps"
                , "Mercredi: Leg drags + back takes"
                , "Jeudi: Sparring créatif"
                , "Vendredi: Nouveaux mouvements"
                , "Samedi: Teaching + drilling"
                , "Dimanche: Flow training"
                ]
            }
          )
        , ( "leandro"
          , { name = "Leandro Lo"
            , nickname = "The Passer"
            , color = "bg-purple-600"
            , lightColor = "bg-purple-100"
            , specialties = [ "Guard Passing", "Takedowns", "Competition" ]
            , philosophy = "Technique parfaite + timing impeccable"
            , keyPrinciples =
                [ "Le timing bat la force"
                , "Bases solides = victoire"
                , "Patience tactique"
                , "Adaptation constante"
                ]
            , trainingApproach =
                { technique = "Perfectionnement des bases"
                , drilling = "Timing et précision"
                , sparring = "Simulation de compétition"
                , study = "Stratégie et game planning"
                }
            , weeklyPlan =
                [ "Lundi: Takedowns + top position"
                , "Mardi: Guard passing drills"
                , "Mercredi: Submissions + control"
                , "Jeudi: Competition sparring"
                , "Vendredi: Technical refinement"
                , "Samedi: Open mat"
                , "Dimanche: Recovery + analysis"
                ]
            }
          )
        , ( "galvao"
          , { name = "André Galvão"
            , nickname = "The General"
            , color = "bg-orange-600"
            , lightColor = "bg-orange-100"
            , specialties = [ "Leadership", "Teaching", "Well-rounded" ]
            , philosophy = "Excellence dans tous les domaines + leadership"
            , keyPrinciples =
                [ "Enseigner = apprendre"
                , "Leadership par l'exemple"
                , "Jeu complet nécessaire"
                , "Mentalité d'équipe"
                ]
            , trainingApproach =
                { technique = "Approche systématique"
                , drilling = "Variété et adaptation"
                , sparring = "Tous niveaux et styles"
                , study = "Développement d'équipe"
                }
            , weeklyPlan =
                [ "Lundi: Gi technique + teaching"
                , "Mardi: No-gi + competition prep"
                , "Mercredi: Fundamentals + drilling"
                , "Jeudi: Advanced sparring"
                , "Vendredi: Team training"
                , "Samedi: Seminars + learning"
                , "Dimanche: Planning + recovery"
                ]
            }
          )
        ]


initLearningPhases : List LearningPhase
initLearningPhases =
    [ { phase = "Phase 1: Fondations (0-6 mois)"
      , icon = "🎯"
      , focus = "Bases solides comme Buchecha"
      , goals = [ "Escapes de base", "Positions fondamentales", "Cardio de base" ]
      }
    , { phase = "Phase 2: Développement (6-18 mois)"
      , icon = "🧠"
      , focus = "Créativité comme Rafael Mendes"
      , goals = [ "Premier jeu de garde", "Passes basiques", "Flow et timing" ]
      }
    , { phase = "Phase 3: Spécialisation (18+ mois)"
      , icon = "🏆"
      , focus = "Excellence comme Gordon Ryan"
      , goals = [ "Spécialités personnelles", "Game planning", "Mentalité de compétition" ]
      }
    ]


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        ReceivedLocalStorage value ->
            ( { model | localStorage = value }, Cmd.none )

        ChangeLanguage language ->
            ( model
            , Cmd.none
            )

        ChangeTheme theme ->
            ( model
            , Cmd.none
            )

        SelectHero maybeHeroId ->
            ( { model | selectedHero = maybeHeroId }
            , Lamdera.sendToBackend (TrackHeroSelection maybeHeroId)
            )

        SetActiveTab tab ->
            ( { model | activeTab = tab }, Cmd.none )

        ToggleAddSessionModal ->
            ( { model | showAddSessionModal = not model.showAddSessionModal }, Cmd.none )

        UpdateNewSessionForm newForm ->
            ( { model | newSessionForm = newForm }, Cmd.none )

        SaveTrainingSession ->
            case (model.newSessionForm.heroId, String.toInt model.newSessionForm.duration) of
                (Just heroId, Just duration) ->
                    let
                        newSession =
                            { id = String.fromInt (List.length model.trainingSessions + 1)
                            , date = model.newSessionForm.date
                            , heroId = heroId
                            , duration = duration
                            , techniques = String.split "," model.newSessionForm.techniques |> List.map String.trim
                            , notes = model.newSessionForm.notes
                            , sessionType = model.newSessionForm.sessionType
                            }
                    in
                    ( { model 
                        | showAddSessionModal = False
                        , newSessionForm = emptySessionForm 
                      }
                    , Lamdera.sendToBackend (SaveSession newSession)
                    )
                
                _ ->
                    ( model, Cmd.none )

        DeleteTrainingSession sessionId ->
            ( model, Lamdera.sendToBackend (DeleteSession sessionId) )

        UpdateTechniqueStatus techniqueId status ->
            ( model, Lamdera.sendToBackend (UpdateTechnique techniqueId status) )

        AddTechniqueNote techniqueId note ->
            ( model, Lamdera.sendToBackend (SaveTechniqueNote techniqueId note) )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        SessionData session ->
            let
                techniques = 
                    case session.selectedHero of
                        Just heroId ->
                            if List.isEmpty session.techniqueProgress then
                                Progress.getTechniquesForHero heroId
                            else
                                session.techniqueProgress
                        Nothing ->
                            session.techniqueProgress
            in
            ( { model
                | clientId = session.clientId
                , selectedHero = session.selectedHero
                , trainingSessions = session.trainingSessions
                , techniqueProgress = techniques
                , achievements = 
                    if List.isEmpty session.achievements then
                        model.achievements
                    else
                        session.achievements
              }
            , Cmd.none
            )

        SessionSaved newSession ->
            ( { model | trainingSessions = newSession :: model.trainingSessions }
            , Cmd.none
            )

        SessionDeleted sessionId ->
            ( { model | trainingSessions = List.filter (\s -> s.id /= sessionId) model.trainingSessions }
            , Cmd.none
            )

        TechniqueUpdated techniqueId newStatus ->
            let
                updateTechnique tech =
                    if tech.techniqueId == techniqueId then
                        { tech | status = newStatus, lastPracticed = Just "today" }
                    else
                        tech
            in
            ( { model | techniqueProgress = List.map updateTechnique model.techniqueProgress }
            , Cmd.none
            )

        AchievementUnlocked achievement ->
            let
                updateAchievement ach =
                    if ach.id == achievement.id then
                        achievement
                    else
                        ach
            in
            ( { model | achievements = List.map updateAchievement model.achievements }
            , Cmd.none
            )


subscriptions : Model -> Sub FrontendMsg
subscriptions model =
    Sub.none


view : Model -> Browser.Document FrontendMsg
view model =
    let
        userConfig =
            { t = I18n.translations
            , isDark = Theme.getMode model.localStorage.userPreference model.localStorage.systemMode == Theme.Dark
            }
    in
    { title = "Train Like Pro - BJJ Heroes Framework"
    , body =
        [ div [ class "max-w-6xl mx-auto p-6 bg-gray-50 dark:bg-gray-900 min-h-screen" ]
            [ viewHeader
            , viewNavigation model.activeTab
            , case model.activeTab of
                Overview ->
                    viewOverview model

                Heroes ->
                    viewHeroes model

                Plan ->
                    viewPlan model

                Progress ->
                    viewProgress model
            ]
        ]
    }


viewHeader : Html FrontendMsg
viewHeader =
    div [ class "text-center mb-8" ]
        [ h1 [ class "text-4xl font-bold text-gray-900 dark:text-white mb-2" ]
            [ text "Ton Cadre d'Apprentissage JJB" ]
        , p [ class "text-xl text-gray-600 dark:text-gray-300" ]
            [ text "Apprends des légendes du grappling" ]
        ]


viewNavigation : Tab -> Html FrontendMsg
viewNavigation activeTab =
    div [ class "flex justify-center mb-8" ]
        [ div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-1 flex space-x-1" ]
            [ viewTabButton Overview "Vue d'ensemble" activeTab
            , viewTabButton Heroes "Tes Héros" activeTab
            , viewTabButton Plan "Plan d'Action" activeTab
            , viewTabButton Progress "Progression" activeTab
            ]
        ]


viewTabButton : Tab -> String -> Tab -> Html FrontendMsg
viewTabButton tab label activeTab =
    button
        [ onClick (SetActiveTab tab)
        , class <|
            "px-6 py-2 rounded-md font-medium transition-colors "
                ++ (if activeTab == tab then
                        "bg-blue-600 text-white"

                    else
                        "text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                   )
        ]
        [ text label ]


viewOverview : Model -> Html FrontendMsg
viewOverview model =
    div [ class "space-y-8" ]
        [ viewLearningPhases model.learningPhases
        , viewUniversalPrinciples
        ]


viewLearningPhases : List LearningPhase -> Html FrontendMsg
viewLearningPhases phases =
    div [ class "grid md:grid-cols-3 gap-6" ]
        (List.map viewLearningPhase phases)


viewLearningPhase : LearningPhase -> Html FrontendMsg
viewLearningPhase phase =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ div [ class "flex items-center mb-4" ]
            [ div [ class "bg-blue-100 dark:bg-blue-900 p-2 rounded-lg mr-3 text-2xl" ]
                [ text phase.icon ]
            , h3 [ class "font-bold text-lg dark:text-white" ]
                [ text phase.phase ]
            ]
        , p [ class "text-blue-600 dark:text-blue-400 font-medium mb-3" ]
            [ text phase.focus ]
        , ul [ class "space-y-2" ]
            (List.map
                (\goal ->
                    li [ class "flex items-center text-sm dark:text-gray-300" ]
                        [ span [ class "text-green-500 mr-2" ] [ text "→" ]
                        , text goal
                        ]
                )
                phase.goals
            )
        ]


viewUniversalPrinciples : Html FrontendMsg
viewUniversalPrinciples =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ h3 [ class "text-2xl font-bold mb-4 dark:text-white" ]
            [ text "Principes Universels de tes Héros" ]
        , div [ class "grid md:grid-cols-2 gap-6" ]
            [ div []
                [ h4 [ class "font-semibold text-lg mb-3 flex items-center dark:text-white" ]
                    [ span [ class "mr-2" ] [ text "🧠" ]
                    , text "Mental & Mindset"
                    ]
                , ul [ class "space-y-2 text-sm dark:text-gray-300" ]
                    [ li [] [ text "• Confiance absolue (Gordon Ryan)" ]
                    , li [] [ text "• Pression constante (Buchecha)" ]
                    , li [] [ text "• Créativité (Rafael Mendes)" ]
                    , li [] [ text "• Patience tactique (Leandro Lo)" ]
                    , li [] [ text "• Leadership (André Galvão)" ]
                    ]
                ]
            , div []
                [ h4 [ class "font-semibold text-lg mb-3 flex items-center dark:text-white" ]
                    [ span [ class "mr-2" ] [ text "💪" ]
                    , text "Entraînement"
                    ]
                , ul [ class "space-y-2 text-sm dark:text-gray-300" ]
                    [ li [] [ text "• Technique avant tout" ]
                    , li [] [ text "• Drilling jusqu'à l'automatisme" ]
                    , li [] [ text "• Cardio comme base" ]
                    , li [] [ text "• Étude vidéo régulière" ]
                    , li [] [ text "• Sparring intelligent" ]
                    ]
                ]
            ]
        ]


viewHeroes : Model -> Html FrontendMsg
viewHeroes model =
    div [ class "space-y-6" ]
        [ viewHeroGrid model
        , case model.selectedHero of
            Just heroId ->
                viewSelectedHero heroId model.heroes

            Nothing ->
                text ""
        ]


viewHeroGrid : Model -> Html FrontendMsg
viewHeroGrid model =
    div [ class "grid md:grid-cols-2 lg:grid-cols-3 gap-4" ]
        [ viewHeroCard Gordon "gordon" model
        , viewHeroCard Buchecha "buchecha" model
        , viewHeroCard Rafael "rafael" model
        , viewHeroCard Leandro "leandro" model
        , viewHeroCard Galvao "galvao" model
        ]


viewHeroCard : HeroId -> String -> Model -> Html FrontendMsg
viewHeroCard heroId heroKey model =
    case Dict.get heroKey model.heroes of
        Just hero ->
            div
                [ onClick (SelectHero (if model.selectedHero == Just heroId then Nothing else Just heroId))
                , class <|
                    hero.color
                        ++ " text-white rounded-lg p-4 cursor-pointer transition-transform hover:scale-105"
                        ++ (if model.selectedHero == Just heroId then
                                " ring-4 ring-white"

                            else
                                ""
                           )
                ]
                [ h3 [ class "font-bold text-lg" ] [ text hero.name ]
                , p [ class "text-sm opacity-90" ] [ text ("\"" ++ hero.nickname ++ "\"") ]
                , p [ class "text-xs mt-2 opacity-80" ] [ text hero.philosophy ]
                ]

        Nothing ->
            text ""


viewSelectedHero : HeroId -> Dict String Hero -> Html FrontendMsg
viewSelectedHero heroId heroes =
    let
        heroKey =
            case heroId of
                Gordon ->
                    "gordon"

                Buchecha ->
                    "buchecha"

                Rafael ->
                    "rafael"

                Leandro ->
                    "leandro"

                Galvao ->
                    "galvao"
    in
    case Dict.get heroKey heroes of
        Just hero ->
            div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6" ]
                [ div [ class "flex items-center mb-6" ]
                    [ div [ class (hero.color ++ " w-4 h-4 rounded-full mr-3") ] []
                    , h2 [ class "text-2xl font-bold dark:text-white" ] [ text hero.name ]
                    , span [ class "ml-3 text-gray-500 dark:text-gray-400" ]
                        [ text ("\"" ++ hero.nickname ++ "\"") ]
                    ]
                , div [ class "grid md:grid-cols-2 gap-6" ]
                    [ div []
                        [ h4 [ class "font-semibold text-lg mb-3 dark:text-white" ] [ text "Spécialités" ]
                        , div [ class "flex flex-wrap gap-2 mb-4" ]
                            (List.map
                                (\spec ->
                                    span [ class (hero.lightColor ++ " px-3 py-1 rounded-full text-sm text-gray-800") ]
                                        [ text spec ]
                                )
                                hero.specialties
                            )
                        , h4 [ class "font-semibold text-lg mb-3 dark:text-white" ] [ text "Principes Clés" ]
                        , ul [ class "space-y-2" ]
                            (List.map
                                (\principle ->
                                    li [ class "flex items-start text-sm dark:text-gray-300" ]
                                        [ span [ class "text-green-500 mr-2 mt-0.5 flex-shrink-0" ] [ text "→" ]
                                        , text principle
                                        ]
                                )
                                hero.keyPrinciples
                            )
                        ]
                    , div []
                        [ h4 [ class "font-semibold text-lg mb-3 dark:text-white" ] [ text "Plan Hebdomadaire" ]
                        , div [ class "space-y-2" ]
                            (List.map
                                (\day ->
                                    div [ class "bg-gray-50 dark:bg-gray-700 p-2 rounded text-sm dark:text-gray-300" ]
                                        [ text day ]
                                )
                                hero.weeklyPlan
                            )
                        ]
                    ]
                ]

        Nothing ->
            text ""


viewPlan : Model -> Html FrontendMsg
viewPlan model =
    div [ class "space-y-6" ]
        [ viewActionPlan
        , viewChampionMindset
        ]


viewActionPlan : Html FrontendMsg
viewActionPlan =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ h2 [ class "text-2xl font-bold mb-4 flex items-center dark:text-white" ]
            [ span [ class "mr-3" ] [ text "⏰" ]
            , text "Ton Plan d'Action Personnalisé"
            ]
        , div [ class "grid md:grid-cols-2 gap-6" ]
            [ div []
                [ h3 [ class "font-semibold text-lg mb-3 dark:text-white" ] [ text "Semaine Type (Débutant)" ]
                , div [ class "space-y-2 text-sm" ]
                    [ viewDayPlan "Lundi" "Cours gi + escapes (Buchecha style)" "bg-blue-50 dark:bg-blue-900"
                    , viewDayPlan "Mardi" "Open mat + flow (Rafael style)" "bg-green-50 dark:bg-green-900"
                    , viewDayPlan "Mercredi" "Techniques + drilling (Leandro style)" "bg-purple-50 dark:bg-purple-900"
                    , viewDayPlan "Jeudi" "Sparring + étude vidéo (Gordon style)" "bg-red-50 dark:bg-red-900"
                    , viewDayPlan "Vendredi" "Cours + questions (Galvão style)" "bg-orange-50 dark:bg-orange-900"
                    , viewDayPlan "Weekend" "Récupération + théorie" "bg-gray-50 dark:bg-gray-700"
                    ]
                ]
            , div []
                [ h3 [ class "font-semibold text-lg mb-3 dark:text-white" ] [ text "Objectifs Mensuels" ]
                , div [ class "space-y-3" ]
                    [ viewMonthlyGoal "Mois 1-2: Survie" "Ne pas se faire soumettre, positions de base" "border-blue-500"
                    , viewMonthlyGoal "Mois 3-4: Mouvement" "Fluidité, transitions, premiers sweeps" "border-green-500"
                    , viewMonthlyGoal "Mois 5-6: Attaque" "Premières soumissions, garde active" "border-purple-500"
                    ]
                ]
            ]
        ]


viewDayPlan : String -> String -> String -> Html FrontendMsg
viewDayPlan day description colorClass =
    div [ class (colorClass ++ " p-3 rounded dark:text-gray-200") ]
        [ strong [] [ text (day ++ ": ") ]
        , text description
        ]


viewMonthlyGoal : String -> String -> String -> Html FrontendMsg
viewMonthlyGoal title description borderColor =
    div [ class ("border-l-4 " ++ borderColor ++ " pl-4") ]
        [ h4 [ class "font-medium dark:text-white" ] [ text title ]
        , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text description ]
        ]


viewChampionMindset : Html FrontendMsg
viewChampionMindset =
    div [ class "bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg p-6" ]
        [ h3 [ class "text-xl font-bold mb-3 flex items-center" ]
            [ span [ class "mr-3" ] [ text "👥" ]
            , text "Mentalité de Champion"
            ]
        , div [ class "grid md:grid-cols-3 gap-4 text-sm" ]
            [ div []
                [ strong [] [ text "Comme Gordon: " ]
                , text "Étudie tes adversaires, visualise tes techniques"
                ]
            , div []
                [ strong [] [ text "Comme Buchecha: " ]
                , text "Pousse ton cardio, ne lâche jamais"
                ]
            , div []
                [ strong [] [ text "Comme Rafael: " ]
                , text "Sois créatif, expérimente constamment"
                ]
            ]
        ]


viewProgress : Model -> Html FrontendMsg
viewProgress model =
    div [ class "space-y-8" ]
        [ viewProgressHeader model
        , viewTrainingStats model
        , viewRecentSessions model
        , viewTechniqueChecklist model
        , viewAchievements model
        , if model.showAddSessionModal then
            viewAddSessionModal model
          else
            text ""
        ]


viewProgressHeader : Model -> Html FrontendMsg
viewProgressHeader model =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ div [ class "flex justify-between items-center mb-4" ]
            [ h2 [ class "text-2xl font-bold dark:text-white" ]
                [ text "Suivi de Progression" ]
            , button
                [ onClick ToggleAddSessionModal
                , class "bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
                ]
                [ span [ class "mr-2" ] [ text "+" ]
                , text "Nouvelle Session"
                ]
            ]
        , case model.selectedHero of
            Just heroId ->
                div [ class "text-lg text-gray-600 dark:text-gray-300" ]
                    [ text ("Héros actuel: " ++ heroIdToString heroId) ]
            
            Nothing ->
                div [ class "text-yellow-600 dark:text-yellow-400" ]
                    [ text "⚠️ Sélectionnez un héros dans l'onglet 'Tes Héros' pour commencer" ]
        ]


viewTrainingStats : Model -> Html FrontendMsg
viewTrainingStats model =
    let
        totalHours = Progress.getTotalTrainingHours model.trainingSessions
        totalSessions = List.length model.trainingSessions
        techniqueStats = Progress.calculateProgress model.techniqueProgress
        completedAchievements = List.filter (\a -> a.unlockedAt /= Nothing) model.achievements |> List.length
    in
    div [ class "grid grid-cols-2 md:grid-cols-4 gap-4" ]
        [ viewStatCard "🏋️" "Sessions Totales" (String.fromInt totalSessions) "bg-blue-50 dark:bg-blue-900"
        , viewStatCard "⏱️" "Heures d'Entraînement" (String.fromFloat (toFloat (round (totalHours * 10)) / 10)) "bg-green-50 dark:bg-green-900"
        , viewStatCard "🎯" "Techniques Maîtrisées" (String.fromInt techniqueStats.mastered ++ "/" ++ String.fromInt techniqueStats.total) "bg-purple-50 dark:bg-purple-900"
        , viewStatCard "🏆" "Achievements" (String.fromInt completedAchievements ++ "/" ++ String.fromInt (List.length model.achievements)) "bg-yellow-50 dark:bg-yellow-900"
        ]


viewStatCard : String -> String -> String -> String -> Html FrontendMsg
viewStatCard icon label value bgColor =
    div [ class (bgColor ++ " rounded-lg p-4 text-center") ]
        [ div [ class "text-3xl mb-2" ] [ text icon ]
        , div [ class "text-sm text-gray-600 dark:text-gray-300 mb-1" ] [ text label ]
        , div [ class "text-2xl font-bold dark:text-white" ] [ text value ]
        ]


viewRecentSessions : Model -> Html FrontendMsg
viewRecentSessions model =
    let
        recentSessions = Progress.getRecentSessions 5 model.trainingSessions
    in
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ h3 [ class "text-xl font-bold mb-4 dark:text-white" ] 
            [ text "Sessions Récentes" ]
        , if List.isEmpty recentSessions then
            div [ class "text-gray-500 dark:text-gray-400 text-center py-8" ]
                [ text "Aucune session enregistrée. Cliquez sur 'Nouvelle Session' pour commencer!" ]
          else
            div [ class "space-y-3" ]
                (List.map viewSessionCard recentSessions)
        ]


viewSessionCard : TrainingSession -> Html FrontendMsg
viewSessionCard session =
    div [ class "border dark:border-gray-700 rounded-lg p-4 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors" ]
        [ div [ class "flex justify-between items-start" ]
            [ div []
                [ div [ class "flex items-center gap-3 mb-2" ]
                    [ span [ class "font-semibold dark:text-white" ] 
                        [ text (session.date ++ " - " ++ heroIdToString session.heroId) ]
                    , span [ class "text-sm bg-blue-100 dark:bg-blue-800 text-blue-800 dark:text-blue-200 px-2 py-1 rounded" ]
                        [ text (Progress.sessionTypeToString session.sessionType) ]
                    ]
                , div [ class "text-sm text-gray-600 dark:text-gray-300" ]
                    [ text (String.fromInt session.duration ++ " minutes") ]
                , if not (String.isEmpty session.notes) then
                    div [ class "text-sm text-gray-500 dark:text-gray-400 mt-2 italic" ]
                        [ text session.notes ]
                  else
                    text ""
                ]
            , button
                [ onClick (DeleteTrainingSession session.id)
                , class "text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
                ]
                [ text "🗑️" ]
            ]
        ]


viewTechniqueChecklist : Model -> Html FrontendMsg
viewTechniqueChecklist model =
    case model.selectedHero of
        Just heroId ->
            let
                techniques = List.filter (\t -> t.heroId == heroId) model.techniqueProgress
            in
            div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
                [ h3 [ class "text-xl font-bold mb-4 dark:text-white" ] 
                    [ text "Checklist des Techniques" ]
                , if List.isEmpty techniques then
                    div [ class "text-gray-500 dark:text-gray-400" ]
                        [ text "Les techniques seront chargées après votre première connexion." ]
                  else
                    div [ class "space-y-2" ]
                        (List.map viewTechniqueItem techniques)
                ]

        Nothing ->
            text ""


viewTechniqueItem : TechniqueProgress -> Html FrontendMsg
viewTechniqueItem technique =
    div [ class "border dark:border-gray-700 rounded-lg p-3 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors" ]
        [ div [ class "flex items-center justify-between" ]
            [ div [ class "flex items-center gap-3" ]
                [ statusIcon technique.status
                , div []
                    [ div [ class "font-medium dark:text-white" ] [ text technique.name ]
                    , div [ class "text-sm text-gray-500 dark:text-gray-400" ] [ text technique.category ]
                    ]
                ]
            , select
                [ onInput (\value -> UpdateTechniqueStatus technique.techniqueId (stringToTechniqueStatus value))
                , class "text-sm border dark:border-gray-600 rounded px-2 py-1 dark:bg-gray-700 dark:text-white"
                , value (techniqueStatusToValue technique.status)
                ]
                [ option [ value "notstarted" ] [ text "Non commencé" ]
                , option [ value "learning" ] [ text "En apprentissage" ]
                , option [ value "drilling" ] [ text "En drill" ]
                , option [ value "mastered" ] [ text "Maîtrisé" ]
                ]
            ]
        ]


statusIcon : TechniqueStatus -> Html msg
statusIcon status =
    case status of
        NotStarted ->
            span [ class "text-gray-400 text-xl" ] [ text "○" ]
        
        Learning ->
            span [ class "text-yellow-500 text-xl" ] [ text "◐" ]
        
        InDrilling ->
            span [ class "text-blue-500 text-xl" ] [ text "◕" ]
        
        Mastered ->
            span [ class "text-green-500 text-xl" ] [ text "●" ]


techniqueStatusToValue : TechniqueStatus -> String
techniqueStatusToValue status =
    case status of
        NotStarted -> "notstarted"
        Learning -> "learning"
        InDrilling -> "drilling"
        Mastered -> "mastered"


stringToTechniqueStatus : String -> TechniqueStatus
stringToTechniqueStatus str =
    case str of
        "learning" -> Learning
        "drilling" -> InDrilling
        "mastered" -> Mastered
        _ -> NotStarted


viewAchievements : Model -> Html FrontendMsg
viewAchievements model =
    div [ class "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6" ]
        [ h3 [ class "text-xl font-bold mb-4 dark:text-white" ] 
            [ text "Achievements" ]
        , div [ class "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" ]
            (List.map viewAchievementCard model.achievements)
        ]


viewAchievementCard : Achievement -> Html FrontendMsg
viewAchievementCard achievement =
    let
        isUnlocked = achievement.unlockedAt /= Nothing
        opacity = if isUnlocked then "" else "opacity-50"
    in
    div [ class (opacity ++ " text-center p-4 rounded-lg " ++ 
                 if isUnlocked then "bg-yellow-50 dark:bg-yellow-900" else "bg-gray-100 dark:bg-gray-700") ]
        [ div [ class "text-4xl mb-2" ] [ text achievement.icon ]
        , div [ class "font-medium text-sm dark:text-white" ] [ text achievement.name ]
        , div [ class "text-xs text-gray-600 dark:text-gray-300 mt-1" ] [ text achievement.description ]
        ]


viewAddSessionModal : Model -> Html FrontendMsg
viewAddSessionModal model =
    div [ class "fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" ]
        [ div [ class "bg-white dark:bg-gray-800 rounded-lg p-6 max-w-md w-full mx-4" ]
            [ h3 [ class "text-xl font-bold mb-4 dark:text-white" ] 
                [ text "Nouvelle Session d'Entraînement" ]
            , div [ class "space-y-4" ]
                [ div []
                    [ label [ class "block text-sm font-medium mb-1 dark:text-gray-300" ] 
                        [ text "Date" ]
                    , input
                        [ type_ "date"
                        , value model.newSessionForm.date
                        , onInput (\v -> 
                            let
                                form = model.newSessionForm
                            in
                            UpdateNewSessionForm { form | date = v }
                          )
                        , class "w-full border dark:border-gray-600 rounded px-3 py-2 dark:bg-gray-700 dark:text-white"
                        ]
                        []
                    ]
                , div []
                    [ label [ class "block text-sm font-medium mb-1 dark:text-gray-300" ] 
                        [ text "Héros" ]
                    , select
                        [ onInput (\v -> 
                            let
                                form = model.newSessionForm
                            in
                            UpdateNewSessionForm { form | heroId = stringToHeroId v }
                          )
                        , class "w-full border dark:border-gray-600 rounded px-3 py-2 dark:bg-gray-700 dark:text-white"
                        ]
                        [ option [ value "" ] [ text "Sélectionner un héros" ]
                        , option [ value "gordon" ] [ text "Gordon Ryan" ]
                        , option [ value "buchecha" ] [ text "Buchecha" ]
                        , option [ value "rafael" ] [ text "Rafael Mendes" ]
                        , option [ value "leandro" ] [ text "Leandro Lo" ]
                        , option [ value "galvao" ] [ text "André Galvão" ]
                        ]
                    ]
                , div []
                    [ label [ class "block text-sm font-medium mb-1 dark:text-gray-300" ] 
                        [ text "Type de Session" ]
                    , select
                        [ onInput (\v -> 
                            let
                                form = model.newSessionForm
                            in
                            UpdateNewSessionForm { form | sessionType = stringToSessionType v }
                          )
                        , class "w-full border dark:border-gray-600 rounded px-3 py-2 dark:bg-gray-700 dark:text-white"
                        ]
                        [ option [ value "technique" ] [ text "Technique" ]
                        , option [ value "drilling" ] [ text "Drilling" ]
                        , option [ value "sparring" ] [ text "Sparring" ]
                        , option [ value "competition" ] [ text "Compétition" ]
                        , option [ value "openmat" ] [ text "Open Mat" ]
                        ]
                    ]
                , div []
                    [ label [ class "block text-sm font-medium mb-1 dark:text-gray-300" ] 
                        [ text "Durée (minutes)" ]
                    , input
                        [ type_ "number"
                        , value model.newSessionForm.duration
                        , onInput (\v -> 
                            let
                                form = model.newSessionForm
                            in
                            UpdateNewSessionForm { form | duration = v }
                          )
                        , class "w-full border dark:border-gray-600 rounded px-3 py-2 dark:bg-gray-700 dark:text-white"
                        ]
                        []
                    ]
                , div []
                    [ label [ class "block text-sm font-medium mb-1 dark:text-gray-300" ] 
                        [ text "Techniques pratiquées" ]
                    , textarea
                        [ value model.newSessionForm.techniques
                        , onInput (\v -> 
                            let
                                form = model.newSessionForm
                            in
                            UpdateNewSessionForm { form | techniques = v }
                          )
                        , class "w-full border dark:border-gray-600 rounded px-3 py-2 dark:bg-gray-700 dark:text-white"
                        , rows 3
                        , placeholder "Ex: Berimbolo, Triangle, Armbar..."
                        ]
                        []
                    ]
                , div []
                    [ label [ class "block text-sm font-medium mb-1 dark:text-gray-300" ] 
                        [ text "Notes" ]
                    , textarea
                        [ value model.newSessionForm.notes
                        , onInput (\v -> 
                            let
                                form = model.newSessionForm
                            in
                            UpdateNewSessionForm { form | notes = v }
                          )
                        , class "w-full border dark:border-gray-600 rounded px-3 py-2 dark:bg-gray-700 dark:text-white"
                        , rows 3
                        ]
                        []
                    ]
                ]
            , div [ class "flex justify-end gap-3 mt-6" ]
                [ button
                    [ onClick ToggleAddSessionModal
                    , class "px-4 py-2 text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded"
                    ]
                    [ text "Annuler" ]
                , button
                    [ onClick SaveTrainingSession
                    , class "px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                    ]
                    [ text "Enregistrer" ]
                ]
            ]
        ]


heroIdToString : HeroId -> String
heroIdToString heroId =
    case heroId of
        Gordon -> "Gordon Ryan"
        Buchecha -> "Buchecha"
        Rafael -> "Rafael Mendes"
        Leandro -> "Leandro Lo"
        Galvao -> "André Galvão"


stringToHeroId : String -> Maybe HeroId
stringToHeroId str =
    case str of
        "gordon" -> Just Gordon
        "buchecha" -> Just Buchecha
        "rafael" -> Just Rafael
        "leandro" -> Just Leandro
        "galvao" -> Just Galvao
        _ -> Nothing


stringToSessionType : String -> SessionType
stringToSessionType str =
    case str of
        "drilling" -> Drilling
        "sparring" -> Sparring
        "competition" -> Competition
        "openmat" -> OpenMat
        _ -> Technique