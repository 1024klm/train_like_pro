module GameMechanics.XP exposing 
    ( calculateXP
    , levelFromXP
    , xpToNextLevel
    , calculateSessionXP
    , calculateStreakBonus
    , calculateComboMultiplier
    , getTitleForLevel
    , getBeltProgress
    )

import Types exposing (..)
import Time


-- XP CALCULATIONS

calculateXP : Activity -> TechniqueContext -> Int
calculateXP activity context =
    let
        baseXP = 
            case activity of
                WatchedVideo duration -> 
                    min (duration // 2) 50 -- Max 50 XP pour vid\u00e9o
                    
                CompletedDrill reps -> 
                    min (reps * 2) 100 -- 2 XP par rep, max 100
                    
                PracticedTechnique time quality ->
                    let
                        timeXP = min (time * 3) 150
                        qualityBonus = toFloat quality * 0.2
                    in
                    round (toFloat timeXP * (1.0 + qualityBonus))
                    
                SuccessfulSparring intensity ->
                    case intensity of
                        Light -> 30
                        Medium -> 50
                        Hard -> 80
                        Competition -> 150
                        
                TaughtTechnique -> 
                    100 -- Enseigner = ma\u00eetriser
                    
                CompletedNode nodeType ->
                    case nodeType of
                        ConceptNode -> 50
                        TechniqueNode -> 100
                        DrillNode -> 75
                        SparringNode -> 125
                        TestNode -> 200
                
        difficultyMultiplier =
            case context.difficulty of
                Beginner -> 1.0
                Intermediate -> 1.5
                DifficultyAdvanced -> 2.0
                Expert -> 2.5
                
        streakBonus = calculateStreakBonus context.streak
        
        masteryPenalty =
            case context.currentMastery of
                Mastered -> 0.5  -- Moins d'XP sur techniques ma\u00eetris\u00e9es
                Advanced -> 0.75
                Proficient -> 0.9
                _ -> 1.0
                
        comboMultiplier = 
            if context.comboCount > 0 then
                1.0 + (toFloat context.comboCount * 0.1) -- +10% par combo
            else
                1.0
    in
    round (toFloat baseXP * difficultyMultiplier * streakBonus * masteryPenalty * comboMultiplier)


type Activity
    = WatchedVideo Int -- duration in minutes
    | CompletedDrill Int -- repetitions
    | PracticedTechnique Int Int -- time in minutes, quality 1-5
    | SuccessfulSparring SparringIntensity
    | TaughtTechnique
    | CompletedNode NodeType


type SparringIntensity
    = Light
    | Medium
    | Hard
    | Competition


type alias TechniqueContext =
    { difficulty : Difficulty
    , currentMastery : MasteryLevel
    , streak : Int
    , comboCount : Int
    }


-- LEVEL CALCULATIONS

levelFromXP : Int -> (Int, Float)
levelFromXP totalXP =
    let
        -- Progression exponentielle douce
        -- Niveau 1: 0-100 XP
        -- Niveau 2: 100-250 XP (+150)
        -- Niveau 3: 250-450 XP (+200)
        -- etc.
        level = calculateLevel totalXP 1 0 100
        currentLevelXP = xpForLevel (level - 1)
        nextLevelXP = xpForLevel level
        progressXP = totalXP - currentLevelXP
        totalNeeded = nextLevelXP - currentLevelXP
        progress = toFloat progressXP / toFloat totalNeeded
    in
    (level, progress)


calculateLevel : Int -> Int -> Int -> Int -> Int
calculateLevel totalXP level accumXP nextRequired =
    if totalXP < accumXP + nextRequired then
        level
    else
        calculateLevel totalXP (level + 1) (accumXP + nextRequired) (nextRequired + 50 * level)


xpForLevel : Int -> Int
xpForLevel level =
    if level <= 0 then
        0
    else if level == 1 then
        100
    else
        xpForLevel (level - 1) + (50 * (level - 1) + 100)


xpToNextLevel : Int -> Int
xpToNextLevel totalXP =
    let
        (currentLevel, _) = levelFromXP totalXP
        nextLevelXP = xpForLevel currentLevel
    in
    nextLevelXP - totalXP


-- SESSION XP CALCULATION

calculateSessionXP : TrainingSession -> Int
calculateSessionXP session =
    let
        techniqueXP = 
            List.foldl (+) 0 (List.map .xpEarned session.techniques)
            
        durationBonus =
            if session.duration >= 120 then
                100 -- 2h+ session bonus
            else if session.duration >= 90 then
                50 -- 1h30+ bonus
            else if session.duration >= 60 then
                25 -- 1h+ bonus
            else
                0
                
        moodMultiplier =
            case session.mood of
                FlowState -> 2.0
                Excellent -> 1.5
                Good -> 1.2
                Neutral -> 1.0
                Frustrated -> 0.8
                
        completionBonus =
            if session.completed then 50 else 0
    in
    round (toFloat (techniqueXP + durationBonus + completionBonus) * moodMultiplier)


-- STREAK CALCULATIONS

calculateStreakBonus : Int -> Float
calculateStreakBonus streak =
    if streak >= 30 then
        2.0 -- Double XP!
    else if streak >= 14 then
        1.75
    else if streak >= 7 then
        1.5
    else if streak >= 3 then
        1.25
    else
        1.0


-- COMBO MULTIPLIER

calculateComboMultiplier : List TechniqueLog -> Float
calculateComboMultiplier techniques =
    let
        highQualityCount =
            techniques
                |> List.filter (\t -> t.quality >= 4)
                |> List.length
                
        comboMultiplier =
            if highQualityCount >= 5 then
                1.5 -- 5+ techniques parfaites
            else if highQualityCount >= 3 then
                1.25
            else
                1.0
    in
    comboMultiplier


-- TITLES & PROGRESSION

getTitleForLevel : Int -> PlayerTitle
getTitleForLevel level =
    if level >= 90 then
        { id = "master"
        , name = "Master"
        , description = "You've reached the pinnacle of BJJ mastery"
        , icon = "🥋"
        , rarity = Legendary
        , equipped = True
        }
    else if level >= 70 then
        { id = "professor"
        , name = "Professor"
        , description = "Your knowledge runs deep"
        , icon = "👨‍🏫"
        , rarity = Epic
        , equipped = True
        }
    else if level >= 50 then
        { id = "veteran"
        , name = "Veteran"
        , description = "Battle-tested and experienced"
        , icon = "⚔️"
        , rarity = Rare
        , equipped = True
        }
    else if level >= 30 then
        { id = "practitioner"
        , name = "Practitioner"
        , description = "Dedicated to the art"
        , icon = "🎯"
        , rarity = Common
        , equipped = True
        }
    else if level >= 10 then
        { id = "student"
        , name = "Student"
        , description = "Eager to learn"
        , icon = "📚"
        , rarity = Common
        , equipped = True
        }
    else
        { id = "beginner"
        , name = "White Belt Warrior"
        , description = "Everyone starts somewhere"
        , icon = "🤍"
        , rarity = Common
        , equipped = True
        }


-- BELT PROGRESSION

getBeltProgress : Int -> BeltLevel -> (BeltLevel, Float)
getBeltProgress totalXP currentBelt =
    let
        beltThresholds =
            [ (White, 0)
            , (Blue, 5000)      -- ~Level 20
            , (Purple, 15000)   -- ~Level 40
            , (Brown, 30000)    -- ~Level 60
            , (Black, 50000)    -- ~Level 80
            ]
            
        nextBelt =
            case currentBelt of
                White -> Blue
                Blue -> Purple
                Purple -> Brown
                Brown -> Black
                Black -> Black
                
        currentThreshold =
            beltThresholds
                |> List.filter (\(belt, _) -> belt == currentBelt)
                |> List.head
                |> Maybe.map Tuple.second
                |> Maybe.withDefault 0
                
        nextThreshold =
            beltThresholds
                |> List.filter (\(belt, _) -> belt == nextBelt)
                |> List.head
                |> Maybe.map Tuple.second
                |> Maybe.withDefault 999999
                
        progress =
            if currentBelt == Black then
                1.0
            else
                toFloat (totalXP - currentThreshold) / toFloat (nextThreshold - currentThreshold)
                
        actualBelt =
            if totalXP >= 50000 then Black
            else if totalXP >= 30000 then Brown
            else if totalXP >= 15000 then Purple
            else if totalXP >= 5000 then Blue
            else White
    in
    (actualBelt, min 1.0 progress)