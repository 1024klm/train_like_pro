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
      }
    , Cmd.batch
        [ Task.perform (\_ -> NoOpFrontendMsg) (Task.succeed ())
        , Lamdera.sendToBackend GetUserSession
        ]
    )


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


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        SessionData session ->
            ( { model
                | clientId = session.clientId
                , selectedHero = session.selectedHero
              }
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