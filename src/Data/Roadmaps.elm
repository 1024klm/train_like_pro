module Data.Roadmaps exposing 
    ( butterflyGuardRoadmap
    , getAllRoadmaps
    , getRoadmapById
    , getNodeById
    , calculateRoadmapProgress
    )

import Dict exposing (Dict)
import Set exposing (Set)
import Types exposing (..)


-- BUTTERFLY GUARD COMPLETE ROADMAP

butterflyGuardRoadmap : TechniqueRoadmap
butterflyGuardRoadmap =
    { id = "butterfly-guard-complete"
    , name = "Butterfly Guard Mastery Path"
    , slug = "butterfly-guard"
    , description = "From zero to Marcelo Garcia level butterfly guard. Master distance management, sweeps, submissions, and transitions."
    , hero = "marcelo-garcia"
    , difficulty = Intermediate
    , estimatedWeeks = 12
    , prerequisites = []
    , nodes = butterflyNodes
    , connections = butterflyConnections
    }


butterflyNodes : List RoadmapNode
butterflyNodes =
    [ -- Phase 1: Fundamentals (Semaines 1-3)
      { id = "bf-1"
      , type_ = ConceptNode
      , position = { x = 100, y = 250 }
      , content = 
          { title = "Butterfly Principles"
          , description = "Core concepts: hip mobility, distance control, hand fighting, and weight distribution"
          , videoUrl = Just "https://youtube.com/watch?v=butterfly-basics"
          , estimatedTime = 30
          , xpReward = 100
          , tips = 
              [ "Keep your spine straight - never lean back"
              , "Elbows tight to your ribs for structure"
              , "Active toes - hooks ready to elevate"
              , "Control the inside space with your arms"
              ]
          , commonMistakes = 
              [ "Leaning back too far - loses power"
              , "Hooks too deep - easy to smash"
              , "Passive arms - no frame/control"
              , "Static position - must be dynamic"
              ]
          }
      , status = NodeAvailable
      , requiredForNext = ["bf-2", "bf-3"]
      }
      
    , { id = "bf-2"
      , type_ = TechniqueNode
      , position = { x = 250, y = 200 }
      , content = 
          { title = "Basic Butterfly Sweep"
          , description = "The fundamental sweep to both sides using underhook and overhook grips"
          , videoUrl = Just "https://youtube.com/watch?v=basic-sweep"
          , estimatedTime = 45
          , xpReward = 150
          , tips = 
              [ "Load opponent's weight onto one hip"
              , "Kick with opposite hook while falling to side"
              , "Use your grips to guide their momentum"
              , "Follow through to mount or side control"
              ]
          , commonMistakes = 
              [ "No weight loading before sweep"
              , "Sweeping without proper grips"
              , "Not following opponent to top"
              , "Wrong timing - too early or late"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-4", "bf-5"]
      }
      
    , { id = "bf-3"
      , type_ = DrillNode
      , position = { x = 250, y = 300 }
      , content = 
          { title = "Hip Mobility Drills"
          , description = "Essential solo and partner drills for butterfly guard movement"
          , videoUrl = Just "https://youtube.com/watch?v=hip-drills"
          , estimatedTime = 30
          , xpReward = 75
          , tips = 
              [ "Practice hip scoots in all directions"
              , "Technical stand-ups from butterfly"
              , "Butterfly stretches for flexibility"
              , "Partner weight distribution drills"
              ]
          , commonMistakes = 
              [ "Rushing through movements"
              , "Not maintaining proper posture"
              , "Ignoring flexibility work"
              , "No resistance progression"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-4"]
      }
      
    -- Phase 2: Core Techniques (Semaines 4-6)
    , { id = "bf-4"
      , type_ = TechniqueNode
      , position = { x = 400, y = 250 }
      , content = 
          { title = "Hook Sweep"
          , description = "Advanced sweep using just the butterfly hooks without upper body grips"
          , videoUrl = Just "https://youtube.com/watch?v=hook-sweep"
          , estimatedTime = 45
          , xpReward = 175
          , tips = 
              [ "Create angle with hip movement"
              , "Time it when opponent posts hand"
              , "Explosive hip extension"
              , "Can chain with arm drag"
              ]
          , commonMistakes = 
              [ "No angle creation"
              , "Telegraphing the sweep"
              , "Weak hook pressure"
              , "Not capitalizing on reaction"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-7", "bf-8"]
      }
      
    , { id = "bf-5"
      , type_ = TechniqueNode
      , position = { x = 400, y = 150 }
      , content = 
          { title = "Arm Drag to Back"
          , description = "Transition from butterfly guard to back control using arm drag"
          , videoUrl = Just "https://youtube.com/watch?v=arm-drag"
          , estimatedTime = 40
          , xpReward = 200
          , tips = 
              [ "Control wrist and tricep"
              , "Pull across your body"
              , "Hip escape to create angle"
              , "Immediate seat belt grip"
              ]
          , commonMistakes = 
              [ "Pulling straight back"
              , "No hip movement"
              , "Losing grip during transition"
              , "Slow to secure back hooks"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-9"]
      }
      
    , { id = "bf-6"
      , type_ = TechniqueNode
      , position = { x = 400, y = 350 }
      , content = 
          { title = "Guillotine from Butterfly"
          , description = "High percentage submission when opponent pressure passes"
          , videoUrl = Just "https://youtube.com/watch?v=guillotine"
          , estimatedTime = 35
          , xpReward = 180
          , tips = 
              [ "Snap head down as they drive"
              , "High elbow for leverage"
              , "Use butterfly hook to elevate"
              , "Can transition to mounted guillotine"
              ]
          , commonMistakes = 
              [ "Grip too shallow on neck"
              , "Not using legs to control"
              , "Letting opponent pass to side"
              , "Wrong angle for finish"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-10"]
      }
      
    -- Phase 3: Advanced Combinations (Semaines 7-9)
    , { id = "bf-7"
      , type_ = SparringNode
      , position = { x = 550, y = 200 }
      , content = 
          { title = "Butterfly Sweep Chains"
          , description = "Live drilling of sweep combinations and counters"
          , videoUrl = Nothing
          , estimatedTime = 60
          , xpReward = 250
          , tips = 
              [ "If basic sweep fails → hook sweep"
              , "If they base wide → arm drag"
              , "If they pressure → guillotine"
              , "Always have 2-3 options ready"
              ]
          , commonMistakes = 
              [ "One dimensional attacks"
              , "Not reading reactions"
              , "Forcing techniques"
              , "Poor transition timing"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-11"]
      }
      
    , { id = "bf-8"
      , type_ = TechniqueNode
      , position = { x = 550, y = 300 }
      , content = 
          { title = "X-Guard Transition"
          , description = "Moving from butterfly to X-guard when opponent stands"
          , videoUrl = Just "https://youtube.com/watch?v=x-guard"
          , estimatedTime = 50
          , xpReward = 200
          , tips = 
              [ "Shoot one leg deep between theirs"
              , "Other leg hooks behind knee"
              , "Control ankle and collar/belt"
              , "Multiple sweep options from here"
              ]
          , commonMistakes = 
              [ "Not deep enough with leg"
              , "Poor ankle control"
              , "Static X-guard position"
              , "No contingency if they hop out"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-11"]
      }
      
    -- Phase 4: Competition Application (Semaines 10-12)
    , { id = "bf-9"
      , type_ = TechniqueNode
      , position = { x = 700, y = 150 }
      , content = 
          { title = "Butterfly Half Guard"
          , description = "Hybrid position combining butterfly and half guard concepts"
          , videoUrl = Just "https://youtube.com/watch?v=butterfly-half"
          , estimatedTime = 45
          , xpReward = 225
          , tips = 
              [ "Use when one leg gets trapped"
              , "Maintain underhook at all costs"
              , "Butterfly hook creates space"
              , "Can sweep or take back"
              ]
          , commonMistakes = 
              [ "Flat on back"
              , "Losing underhook battle"
              , "Passive butterfly hook"
              , "Not using proper frames"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-12"]
      }
      
    , { id = "bf-10"
      , type_ = DrillNode
      , position = { x = 700, y = 350 }
      , content = 
          { title = "Reaction Time Drills"
          , description = "Partner drills to improve timing and feel for sweeps"
          , videoUrl = Just "https://youtube.com/watch?v=reaction-drills"
          , estimatedTime = 40
          , xpReward = 150
          , tips = 
              [ "Partner randomly shifts weight"
              , "React with appropriate sweep"
              , "Start slow, increase speed"
              , "Focus on feeling, not seeing"
              ]
          , commonMistakes = 
              [ "Muscling instead of timing"
              , "Not reading weight shifts"
              , "Too fast too soon"
              , "No progressive resistance"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-12"]
      }
      
    , { id = "bf-11"
      , type_ = SparringNode
      , position = { x = 700, y = 250 }
      , content = 
          { title = "Positional Sparring"
          , description = "Start in butterfly, reset if passed or swept successfully"
          , videoUrl = Nothing
          , estimatedTime = 60
          , xpReward = 300
          , tips = 
              [ "3-minute rounds from butterfly"
              , "Goal: sweep or submit"
              , "Reset if guard passed"
              , "Track success rate"
              ]
          , commonMistakes = 
              [ "Giving up position easily"
              , "Not attempting techniques"
              , "Same attacks repeatedly"
              , "Not analyzing failures"
              ]
          }
      , status = NodeLocked
      , requiredForNext = ["bf-12"]
      }
      
    -- Final Test
    , { id = "bf-12"
      , type_ = TestNode
      , position = { x = 850, y = 250 }
      , content = 
          { title = "Butterfly Mastery Test"
          , description = "Complete evaluation: demonstrate all techniques in live rolling"
          , videoUrl = Nothing
          , estimatedTime = 90
          , xpReward = 500
          , tips = 
              [ "Film yourself rolling"
              , "Must hit 3 different sweeps"
              , "Show transitions and submissions"
              , "Self-assess and get feedback"
              ]
          , commonMistakes = 
              [ "Forcing techniques for test"
              , "Not flowing naturally"
              , "Ignoring fundamentals"
              , "No reflection on performance"
              ]
          }
      , status = NodeLocked
      , requiredForNext = []
      }
    ]


butterflyConnections : List NodeConnection
butterflyConnections =
    [ { from = "bf-1", to = "bf-2" }
    , { from = "bf-1", to = "bf-3" }
    , { from = "bf-2", to = "bf-4" }
    , { from = "bf-2", to = "bf-5" }
    , { from = "bf-3", to = "bf-4" }
    , { from = "bf-2", to = "bf-6" }
    , { from = "bf-4", to = "bf-7" }
    , { from = "bf-4", to = "bf-8" }
    , { from = "bf-5", to = "bf-9" }
    , { from = "bf-6", to = "bf-10" }
    , { from = "bf-7", to = "bf-11" }
    , { from = "bf-8", to = "bf-11" }
    , { from = "bf-9", to = "bf-12" }
    , { from = "bf-10", to = "bf-12" }
    , { from = "bf-11", to = "bf-12" }
    ]


-- HELPER FUNCTIONS

getAllRoadmaps : Dict String TechniqueRoadmap
getAllRoadmaps =
    Dict.fromList
        [ (butterflyGuardRoadmap.id, butterflyGuardRoadmap)
        -- Future roadmaps:
        -- , (deLaRivaRoadmap.id, deLaRivaRoadmap)
        -- , (legLocksRoadmap.id, legLocksRoadmap)
        -- , (passingSystemRoadmap.id, passingSystemRoadmap)
        -- , (wrestlingForBJJ.id, wrestlingForBJJ)
        -- , (mountSystemRoadmap.id, mountSystemRoadmap)
        ]


getRoadmapById : String -> Maybe TechniqueRoadmap
getRoadmapById id =
    Dict.get id getAllRoadmaps


getNodeById : String -> TechniqueRoadmap -> Maybe RoadmapNode
getNodeById nodeId roadmap =
    List.filter (\n -> n.id == nodeId) roadmap.nodes
        |> List.head


calculateRoadmapProgress : RoadmapProgress -> TechniqueRoadmap -> Float
calculateRoadmapProgress progress roadmap =
    let
        totalNodes = List.length roadmap.nodes
        completedCount = Set.size progress.completedNodes
    in
    if totalNodes > 0 then
        toFloat completedCount / toFloat totalNodes * 100
    else
        0