module GameMechanics.Quests exposing 
    ( generateDailyQuests
    , checkQuestProgress
    , completeQuest
    , getQuestXP
    , questToString
    )

import Types exposing (..)
import Time
import Random


-- DAILY QUEST GENERATION

generateDailyQuests : Time.Posix -> Int -> List Quest
generateDailyQuests currentTime userLevel =
    let
        seed = Time.posixToMillis currentTime
        baseQuests = getBaseQuests userLevel
    in
    baseQuests
        |> List.take 3 -- 3 quêtes par jour
        |> List.indexedMap (\i quest ->
            { quest 
            | id = "daily-" ++ String.fromInt seed ++ "-" ++ String.fromInt i
            , expiresAt = addHours 24 currentTime
            }
        )


getBaseQuests : Int -> List Quest
getBaseQuests userLevel =
    let
        difficulty = 
            if userLevel >= 50 then
                3 -- Hard
            else if userLevel >= 20 then
                2 -- Medium
            else
                1 -- Easy
    in
    [ -- Quêtes de répétitions
      { id = ""
      , title = "Drill Master"
      , description = getDrillDescription difficulty
      , type_ = DailyDrill (getDrillTarget difficulty)
      , progress = 0
      , target = getDrillTarget difficulty
      , xpReward = 50 * difficulty
      , completed = False
      , expiresAt = Time.millisToPosix 0
      }
      
      -- Quêtes de techniques
    , { id = ""
      , title = "Technique Explorer"
      , description = "Practice " ++ String.fromInt (3 * difficulty) ++ " different techniques"
      , type_ = TechniqueQuest ""
      , progress = 0
      , target = 3 * difficulty
      , xpReward = 75 * difficulty
      , completed = False
      , expiresAt = Time.millisToPosix 0
      }
      
      -- Quêtes de sparring
    , { id = ""
      , title = "Rolling Warrior"
      , description = "Complete " ++ String.fromInt (2 * difficulty) ++ " sparring rounds"
      , type_ = SparringQuest
      , progress = 0
      , target = 2 * difficulty
      , xpReward = 100 * difficulty
      , completed = False
      , expiresAt = Time.millisToPosix 0
      }
      
      -- Quête de consistency
    , { id = ""
      , title = "Consistency is Key"
      , description = "Train for at least " ++ String.fromInt (30 * difficulty) ++ " minutes"
      , type_ = ConsistencyQuest
      , progress = 0
      , target = 30 * difficulty
      , xpReward = 60 * difficulty
      , completed = False
      , expiresAt = Time.millisToPosix 0
      }
      
      -- Quête d'étude
    , { id = ""
      , title = "Student of the Game"
      , description = "Watch " ++ String.fromInt difficulty ++ " technique videos"
      , type_ = StudyQuest
      , progress = 0
      , target = difficulty
      , xpReward = 40 * difficulty
      , completed = False
      , expiresAt = Time.millisToPosix 0
      }
    ]


getDrillDescription : Int -> String
getDrillDescription difficulty =
    case difficulty of
        1 -> "Complete 50 repetitions of any technique"
        2 -> "Complete 100 repetitions across 3 techniques"
        3 -> "Complete 200 repetitions with 80% quality"
        _ -> "Complete 50 repetitions"


getDrillTarget : Int -> Int
getDrillTarget difficulty =
    case difficulty of
        1 -> 50
        2 -> 100
        3 -> 200
        _ -> 50


-- QUEST PROGRESS TRACKING

checkQuestProgress : Quest -> Activity -> Quest
checkQuestProgress quest activity =
    case (quest.type_, activity) of
        (DailyDrill targetTechnique, DrillCompleted techniqueId reps) ->
            if String.isEmpty targetTechnique || targetTechnique == techniqueId then
                updateQuestProgress quest (toFloat reps)
            else
                quest
                
        (TechniqueQuest _, TechniquePracticed _ _) ->
            updateQuestProgress quest 1
            
        (SparringQuest, SparringCompleted _) ->
            updateQuestProgress quest 1
            
        (ConsistencyQuest, SessionTime minutes) ->
            updateQuestProgress quest (toFloat minutes)
            
        (StudyQuest, VideoWatched _) ->
            updateQuestProgress quest 1
            
        _ ->
            quest


updateQuestProgress : Quest -> Float -> Quest
updateQuestProgress quest amount =
    let
        newProgress = min (quest.progress + amount) (toFloat quest.target)
        isCompleted = newProgress >= toFloat quest.target
    in
    { quest 
    | progress = newProgress
    , completed = isCompleted
    }


-- QUEST COMPLETION

completeQuest : Quest -> UserProgress -> UserProgress
completeQuest quest progress =
    if quest.completed then
        { progress 
        | totalXP = progress.totalXP + quest.xpReward
        , dailyQuests = 
            progress.dailyQuests
                |> List.map (\q -> 
                    if q.id == quest.id then 
                        { q | completed = True }
                    else 
                        q
                )
        }
    else
        progress


getQuestXP : Quest -> Int
getQuestXP quest =
    if quest.completed then
        quest.xpReward
    else
        -- XP partiel basé sur la progression
        round (toFloat quest.xpReward * (quest.progress / toFloat quest.target) * 0.5)


-- QUEST DISPLAY

questToString : Quest -> String
questToString quest =
    let
        progressText = 
            String.fromInt (round quest.progress) ++ "/" ++ String.fromInt quest.target
    in
    quest.title ++ " (" ++ progressText ++ ")"


-- HELPER TYPES FOR ACTIVITIES

type Activity
    = DrillCompleted String Int -- techniqueId, reps
    | TechniquePracticed String Int -- techniqueId, quality
    | SparringCompleted Int -- rounds
    | SessionTime Int -- minutes
    | VideoWatched String -- videoId


-- TIME HELPERS

addHours : Int -> Time.Posix -> Time.Posix
addHours hours time =
    Time.millisToPosix (Time.posixToMillis time + (hours * 60 * 60 * 1000))