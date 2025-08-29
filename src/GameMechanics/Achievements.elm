module GameMechanics.Achievements exposing 
    ( checkAchievements
    , unlockAchievement
    , getAchievementProgress
    , getAllAchievements
    , getUnlockedAchievements
    )

import Types exposing (..)
import Dict exposing (Dict)
import Set exposing (Set)
import Time


-- ACHIEVEMENT DEFINITIONS

getAllAchievements : List Achievement
getAllAchievements =
    [ -- Première fois
      { id = "first-blood"
      , name = "First Blood"
      , description = "Complete your first training session"
      , icon = "🩸"
      , category = TechniqueBadge
      , unlockedAt = Nothing
      }
      
      -- Streaks
    , { id = "week-warrior"
      , name = "Week Warrior"
      , description = "Train 7 days in a row"
      , icon = "🔥"
      , category = ConsistencyBadge
      , unlockedAt = Nothing
      }
      
    , { id = "iron-will"
      , name = "Iron Will"
      , description = "Maintain a 30-day training streak"
      , icon = "💪"
      , category = ConsistencyBadge
      , unlockedAt = Nothing
      }
      
      -- Techniques
    , { id = "technique-collector"
      , name = "Technique Collector"
      , description = "Learn 10 different techniques"
      , icon = "📚"
      , category = TechniqueBadge
      , unlockedAt = Nothing
      }
      
    , { id = "submission-specialist"
      , name = "Submission Specialist"
      , description = "Master 5 submission techniques"
      , icon = "🎯"
      , category = TechniqueBadge
      , unlockedAt = Nothing
      }
      
    , { id = "sweep-master"
      , name = "Sweep Master"
      , description = "Successfully hit 100 sweeps in sparring"
      , icon = "🌊"
      , category = TechniqueBadge
      , unlockedAt = Nothing
      }
      
      -- Competition
    , { id = "competitor"
      , name = "Competitor"
      , description = "Log your first competition"
      , icon = "🏆"
      , category = CompetitionBadge
      , unlockedAt = Nothing
      }
      
    , { id = "podium-finisher"
      , name = "Podium Finisher"
      , description = "Place in top 3 at a competition"
      , icon = "🥇"
      , category = CompetitionBadge
      , unlockedAt = Nothing
      }
      
      -- Social
    , { id = "training-partner"
      , name = "Great Training Partner"
      , description = "Train with 10 different partners"
      , icon = "🤝"
      , category = SocialBadge
      , unlockedAt = Nothing
      }
      
    , { id = "teacher"
      , name = "Teacher"
      , description = "Help teach a technique to someone"
      , icon = "👨‍🏫"
      , category = SocialBadge
      , unlockedAt = Nothing
      }
      
      -- Special
    , { id = "night-owl"
      , name = "Night Owl"
      , description = "Complete a training session after 10 PM"
      , icon = "🦉"
      , category = SpecialBadge
      , unlockedAt = Nothing
      }
      
    , { id = "early-bird"
      , name = "Early Bird"
      , description = "Complete a training session before 6 AM"
      , icon = "🐦"
      , category = SpecialBadge
      , unlockedAt = Nothing
      }
      
    , { id = "roadmap-pioneer"
      , name = "Roadmap Pioneer"
      , description = "Complete your first technique roadmap"
      , icon = "🗺️"
      , category = SpecialBadge
      , unlockedAt = Nothing
      }
      
    , { id = "xp-hunter"
      , name = "XP Hunter"
      , description = "Earn 10,000 total XP"
      , icon = "⚡"
      , category = SpecialBadge
      , unlockedAt = Nothing
      }
      
    , { id = "black-belt-mindset"
      , name = "Black Belt Mindset"
      , description = "Reach level 50"
      , icon = "🥋"
      , category = SpecialBadge
      , unlockedAt = Nothing
      }
    ]


-- ACHIEVEMENT CHECKING

checkAchievements : UserProgress -> List TrainingSession -> List String
checkAchievements progress sessions =
    let
        unlockedIds = Set.fromList progress.unlockedAchievements
        allChecks = 
            [ checkFirstBlood sessions
            , checkStreakAchievements progress.currentStreak
            , checkTechniqueAchievements progress.techniqueMastery
            , checkXPAchievements progress.totalXP
            , checkLevelAchievements progress.currentLevel
            , checkRoadmapAchievements progress.roadmapProgress
            , checkSessionAchievements sessions
            ]
            |> List.concat
            |> List.filter (\id -> not (Set.member id unlockedIds))
    in
    allChecks


checkFirstBlood : List TrainingSession -> List String
checkFirstBlood sessions =
    if List.length sessions > 0 then
        ["first-blood"]
    else
        []


checkStreakAchievements : Int -> List String
checkStreakAchievements streak =
    List.filterMap
        (\(threshold, achievementId) ->
            if streak >= threshold then
                Just achievementId
            else
                Nothing
        )
        [ (7, "week-warrior")
        , (30, "iron-will")
        ]


checkTechniqueAchievements : Dict String TechniqueMastery -> List String
checkTechniqueAchievements techniques =
    let
        totalTechniques = Dict.size techniques
        masteredCount = 
            techniques
                |> Dict.values
                |> List.filter (\t -> t.mastery == MasteryComplete)
                |> List.length
                
        submissionMastered =
            techniques
                |> Dict.values
                |> List.filter (\t -> 
                    t.mastery == MasteryComplete && 
                    String.contains "submission" t.name
                )
                |> List.length
    in
    List.concat
        [ if totalTechniques >= 10 then ["technique-collector"] else []
        , if submissionMastered >= 5 then ["submission-specialist"] else []
        ]


checkXPAchievements : Int -> List String
checkXPAchievements totalXP =
    if totalXP >= 10000 then
        ["xp-hunter"]
    else
        []


checkLevelAchievements : Int -> List String
checkLevelAchievements level =
    if level >= 50 then
        ["black-belt-mindset"]
    else
        []


checkRoadmapAchievements : Dict String RoadmapProgress -> List String
checkRoadmapAchievements roadmaps =
    let
        completedCount =
            roadmaps
                |> Dict.values
                |> List.filter (\r -> r.completionPercentage >= 100)
                |> List.length
    in
    if completedCount > 0 then
        ["roadmap-pioneer"]
    else
        []


checkSessionAchievements : List TrainingSession -> List String
checkSessionAchievements sessions =
    let
        hasEarlySession =
            sessions
                |> List.any (\s -> 
                    let
                        hour = Time.toHour Time.utc s.date
                    in
                    hour < 6
                )
                
        hasLateSession =
            sessions
                |> List.any (\s ->
                    let
                        hour = Time.toHour Time.utc s.date
                    in
                    hour >= 22
                )
                
        uniquePartners =
            sessions
                |> List.concatMap .techniques
                |> List.filterMap .partner
                |> Set.fromList
                |> Set.size
    in
    List.concat
        [ if hasEarlySession then ["early-bird"] else []
        , if hasLateSession then ["night-owl"] else []
        , if uniquePartners >= 10 then ["training-partner"] else []
        ]


-- ACHIEVEMENT UNLOCKING

unlockAchievement : String -> Time.Posix -> UserProgress -> UserProgress
unlockAchievement achievementId currentTime progress =
    let
        newBadge =
            getAllAchievements
                |> List.filter (\a -> a.id == achievementId)
                |> List.head
                |> Maybe.map (\a -> 
                    { a | unlockedAt = Just currentTime }
                )
    in
    case newBadge of
        Just badge ->
            { progress
            | unlockedAchievements = achievementId :: progress.unlockedAchievements
            , badges = badge :: progress.badges
            , totalXP = progress.totalXP + getAchievementXP badge.category
            }
            
        Nothing ->
            progress


getAchievementXP : BadgeCategory -> Int
getAchievementXP category =
    case category of
        TechniqueBadge -> 100
        ConsistencyBadge -> 150
        CompetitionBadge -> 200
        SocialBadge -> 75
        SpecialBadge -> 250


-- ACHIEVEMENT PROGRESS

getAchievementProgress : String -> UserProgress -> List TrainingSession -> Float
getAchievementProgress achievementId progress sessions =
    case achievementId of
        "week-warrior" ->
            toFloat progress.currentStreak / 7
            
        "iron-will" ->
            toFloat progress.currentStreak / 30
            
        "technique-collector" ->
            toFloat (Dict.size progress.techniqueMastery) / 10
            
        "xp-hunter" ->
            toFloat progress.totalXP / 10000
            
        "black-belt-mindset" ->
            toFloat progress.currentLevel / 50
            
        _ ->
            0


-- ACHIEVEMENT QUERIES

getUnlockedAchievements : UserProgress -> List Badge
getUnlockedAchievements progress =
    progress.badges
        |> List.sortBy (\b -> 
            case b.unlockedAt of
                Just time -> Time.posixToMillis time
                Nothing -> 0
        )
        |> List.reverse