module Progress exposing (..)

import Types exposing (..)


getTechniquesForHero : HeroId -> List TechniqueProgress
getTechniquesForHero heroId =
    case heroId of
        Gordon ->
            [ { techniqueId = "gordon-leg-entanglement"
              , name = "Système d'emmêlement de jambes"
              , heroId = Gordon
              , category = "Leg Locks"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "gordon-heel-hook"
              , name = "Heel Hook (Inside & Outside)"
              , heroId = Gordon
              , category = "Leg Locks"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "gordon-back-control"
              , name = "Système de contrôle du dos"
              , heroId = Gordon
              , category = "Back Control"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "gordon-mount-system"
              , name = "Système de montée"
              , heroId = Gordon
              , category = "Mount"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "gordon-guard-passing"
              , name = "Passage de garde systématique"
              , heroId = Gordon
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            ]

        Buchecha ->
            [ { techniqueId = "buchecha-pressure-passing"
              , name = "Passage par pression"
              , heroId = Buchecha
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "buchecha-over-under"
              , name = "Over-Under Pass"
              , heroId = Buchecha
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "buchecha-double-leg"
              , name = "Double Leg Takedown"
              , heroId = Buchecha
              , category = "Takedowns"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "buchecha-side-control"
              , name = "Contrôle latéral lourd"
              , heroId = Buchecha
              , category = "Top Control"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "buchecha-armbar"
              , name = "Armbar depuis le dessus"
              , heroId = Buchecha
              , category = "Submissions"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            ]

        Rafael ->
            [ { techniqueId = "rafael-berimbolo"
              , name = "Berimbolo"
              , heroId = Rafael
              , category = "Guard"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "rafael-dlr"
              , name = "De La Riva Guard"
              , heroId = Rafael
              , category = "Guard"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "rafael-lapel-guard"
              , name = "Système de garde au revers"
              , heroId = Rafael
              , category = "Guard"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "rafael-back-take"
              , name = "Prise de dos depuis la garde"
              , heroId = Rafael
              , category = "Transitions"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "rafael-leg-drag"
              , name = "Leg Drag Pass"
              , heroId = Rafael
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            ]

        Leandro ->
            [ { techniqueId = "leandro-torreando"
              , name = "Torreando Pass"
              , heroId = Leandro
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "leandro-knee-cut"
              , name = "Knee Cut Pass"
              , heroId = Leandro
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "leandro-single-leg"
              , name = "Single Leg Takedown"
              , heroId = Leandro
              , category = "Takedowns"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "leandro-spider-guard"
              , name = "Défense contre Spider Guard"
              , heroId = Leandro
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "leandro-stack-pass"
              , name = "Stack Pass"
              , heroId = Leandro
              , category = "Guard Passing"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            ]

        Galvao ->
            [ { techniqueId = "galvao-butterfly"
              , name = "Butterfly Guard System"
              , heroId = Galvao
              , category = "Guard"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "galvao-x-guard"
              , name = "X-Guard"
              , heroId = Galvao
              , category = "Guard"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "galvao-kimura"
              , name = "Kimura Trap System"
              , heroId = Galvao
              , category = "Submissions"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "galvao-half-guard"
              , name = "Half Guard (Top & Bottom)"
              , heroId = Galvao
              , category = "Guard"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            , { techniqueId = "galvao-guillotine"
              , name = "Guillotine System"
              , heroId = Galvao
              , category = "Submissions"
              , status = NotStarted
              , lastPracticed = Nothing
              , notes = ""
              }
            ]


getAchievements : List Achievement
getAchievements =
    [ { id = "first-session"
      , name = "Première Session"
      , description = "Complétez votre première session d'entraînement"
      , icon = "🥋"
      , unlockedAt = Nothing
      , category = Milestone
      }
    , { id = "week-warrior"
      , name = "Guerrier de la Semaine"
      , description = "Entraînez-vous 3 fois dans une semaine"
      , icon = "💪"
      , unlockedAt = Nothing
      , category = Consistency
      }
    , { id = "month-dedication"
      , name = "Dédication Mensuelle"
      , description = "Entraînez-vous 12 fois dans un mois"
      , icon = "🏆"
      , unlockedAt = Nothing
      , category = Consistency
      }
    , { id = "technique-explorer"
      , name = "Explorateur de Techniques"
      , description = "Pratiquez 10 techniques différentes"
      , icon = "🔍"
      , unlockedAt = Nothing
      , category = TechniqueCategory
      }
    , { id = "technique-master"
      , name = "Maître Technique"
      , description = "Maîtrisez votre première technique"
      , icon = "⭐"
      , unlockedAt = Nothing
      , category = TechniqueCategory
      }
    , { id = "hero-dedication"
      , name = "Dédication au Héros"
      , description = "Complétez 20 sessions avec le même héros"
      , icon = "🎯"
      , unlockedAt = Nothing
      , category = HeroCategory
      }
    , { id = "all-heroes"
      , name = "Étudiant Universel"
      , description = "Entraînez-vous avec tous les héros"
      , icon = "🌟"
      , unlockedAt = Nothing
      , category = HeroCategory
      }
    , { id = "competition-ready"
      , name = "Prêt pour la Compétition"
      , description = "Complétez 5 sessions de type Compétition"
      , icon = "🥇"
      , unlockedAt = Nothing
      , category = Milestone
      }
    , { id = "100-hours"
      , name = "Centurion"
      , description = "Accumulez 100 heures d'entraînement"
      , icon = "💯"
      , unlockedAt = Nothing
      , category = Milestone
      }
    , { id = "consistency-king"
      , name = "Roi de la Constance"
      , description = "Entraînez-vous 30 jours consécutifs"
      , icon = "👑"
      , unlockedAt = Nothing
      , category = Consistency
      }
    ]


calculateProgress : List TechniqueProgress -> { total : Int, notStarted : Int, learning : Int, drilling : Int, mastered : Int }
calculateProgress techniques =
    let
        countStatus status =
            List.filter (\t -> t.status == status) techniques |> List.length
    in
    { total = List.length techniques
    , notStarted = countStatus NotStarted
    , learning = countStatus Learning
    , drilling = countStatus InDrilling
    , mastered = countStatus Mastered
    }


getTotalTrainingHours : List TrainingSession -> Float
getTotalTrainingHours sessions =
    sessions
        |> List.map .duration
        |> List.sum
        |> toFloat
        |> (\minutes -> minutes / 60)


getSessionsByHero : HeroId -> List TrainingSession -> List TrainingSession
getSessionsByHero heroId sessions =
    List.filter (\s -> s.heroId == heroId) sessions


getRecentSessions : Int -> List TrainingSession -> List TrainingSession
getRecentSessions count sessions =
    sessions
        |> List.sortBy .date
        |> List.reverse
        |> List.take count


techniqueStatusToString : TechniqueStatus -> String
techniqueStatusToString status =
    case status of
        NotStarted ->
            "Non commencé"

        Learning ->
            "En apprentissage"

        InDrilling ->
            "En drill"

        Mastered ->
            "Maîtrisé"


sessionTypeToString : SessionType -> String
sessionTypeToString sessionType =
    case sessionType of
        Technique ->
            "Technique"

        Drilling ->
            "Drilling"

        Sparring ->
            "Sparring"

        Competition ->
            "Compétition"

        OpenMat ->
            "Open Mat"