module Data exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import Types
import Time
import Data.CFJJBEvents exposing (cfjjbEvents)


initHeroes : Dict String Types.Hero
initHeroes =
    (    [ ( "gordon-ryan"
          , { id = "gordon-ryan"
            , name = "Gordon Ryan"
            , nickname = "The King"
            , nationality = "USA"
            , team = "New Wave Jiu Jitsu"
            , gender = Types.Male
            , weight = Types.SuperHeavy
            , style = Types.LegLocks
            , achievements = gordonAchievements
            , imageUrl = "/images/heroes/gordon-ryan.jpg"
            , coverImageUrl = "/images/heroes/gordon-ryan-cover.jpg"
            , bio = "ADCC multi-champion and CJI star blending heavyweight wrestling, butterfly sumi-gaeshi sweeps and the New Wave Straitjacket back system with ruthless leg locks."
            , record = 
                { wins = 153
                , losses = 7
                , draws = 2
                , submissions = 102
                , points = 32
                , advantages = 19
                , titles = [ "4x ADCC Champion", "3x ADCC Superfight Champion", "EBI Champion", "IBJJF No-Gi World Champion" ]
                }
            , techniques = gordonTechniques
            , socialMedia =
                { instagram = Just "@gordonlovesjiujitsu"
                , youtube = Just "Gordon Ryan BJJ Fanatics"
                , twitter = Just "@GordonRyanBJJ"
                , website = Just "www.bjjfanatics.com/gordon-ryan"
                }
            , videos = gordonVideos
            , stats =
                { winRate = 95.6
                , submissionRate = 66.7
                , averageMatchTime = 8.5
                , favoritePosition = "Butterfly sumi-gaeshi ➜ Straitjacket back control"
                , favoriteSubmission = "Rear naked choke / inside heel hook"
                }
            }
          )
        , ( "marcus-buchecha"
          , { id = "marcus-buchecha"
            , name = "Marcus Almeida"
            , nickname = "Buchecha"
            , nationality = "Brazil"
            , team = "Checkmat"
            , gender = Types.Male
            , weight = Types.UltraHeavy
            , style = Types.Pressure
            , achievements = buchechaAchievements
            , imageUrl = "/images/heroes/buchecha.jpg"
            , coverImageUrl = "/images/heroes/buchecha-cover.jpg"
            , bio = "13x+ IBJJF world champion and ADCC legend with explosive over-under pressure."
            , record =
                { wins = 128
                , losses = 14
                , draws = 0
                , submissions = 57
                , points = 52
                , advantages = 19
                , titles = [ "13x IBJJF World Champion", "2x ADCC Champion", "7x IBJJF Pro League Champion" ]
                }
            , techniques = buchechaTechniques
            , socialMedia =
                { instagram = Just "@marcusbuchecha"
                , youtube = Nothing
                , twitter = Just "@Buchecha"
                , website = Nothing
                }
            , videos = buchechaVideos
            , stats =
                { winRate = 90.1
                , submissionRate = 44.5
                , averageMatchTime = 7.2
                , favoritePosition = "Explosive top / over-under"
                , favoriteSubmission = "Toe hold / armbar"
                }
            }
          )
        , ( "rafael-mendes"
          , { id = "rafael-mendes"
            , name = "Rafael Mendes"
            , nickname = "Rafa"
            , nationality = "Brazil"
            , team = "Art of Jiu Jitsu"
            , gender = Types.Male
            , weight = Types.Feather
            , style = Types.Guard
            , achievements = rafaAchievements
            , imageUrl = "/images/heroes/rafael-mendes.jpg"
            , coverImageUrl = "/images/heroes/rafael-mendes-cover.jpg"
            , bio = "6x world champ who perfected berimbolo, 50/50 traps and leg-drag chains that defined the Mendes Bros style at AOJ."
            , record =
                { wins = 124
                , losses = 18
                , draws = 2
                , submissions = 48
                , points = 62
                , advantages = 14
                , titles = [ "6x IBJJF World Champion", "2x ADCC Champion", "2x World Cup Champion" ]
                }
            , techniques = rafaTechniques
            , socialMedia =
                { instagram = Just "@mendesbros"
                , youtube = Just "Art of Jiu Jitsu"
                , twitter = Nothing
                , website = Just "www.artofjiujitsu.com"
                }
            , videos = rafaVideos
            , stats =
                { winRate = 87.3
                , submissionRate = 38.7
                , averageMatchTime = 6.8
                , favoritePosition = "De La Riva ➜ berimbolo / 50-50 control"
                , favoriteSubmission = "Rear naked choke / leg-drag choke chains"
                }
            }
          )
        , ( "andre-galvao"
          , { id = "andre-galvao"
            , name = "André Galvão"
            , nickname = "Deco"
            , nationality = "Brazil"
            , team = "Atos Jiu-Jitsu"
            , gender = Types.Male
            , weight = Types.MediumHeavy
            , style = Types.Balanced
            , achievements = galvaoAchievements
            , imageUrl = "/images/heroes/andre-galvao.jpg"
            , coverImageUrl = "/images/heroes/andre-galvao-cover.jpg"
            , bio = "Pressure-passing Atos founder, multi-time ADCC superfight king with lethal mount attacks."
            , record =
                { wins = 142
                , losses = 23
                , draws = 3
                , submissions = 63
                , points = 58
                , advantages = 21
                , titles = [ "6x ADCC Champion", "2x IBJJF World Champion", "ADCC Superfight Champion" ]
                }
            , techniques = galvaoTechniques
            , socialMedia =
                { instagram = Just "@galvaobjj"
                , youtube = Just "Atos Jiu-Jitsu"
                , twitter = Just "@GalvaoBJJ"
                , website = Just "www.atosjiujitsuhq.com"
                }
            , videos = galvaoVideos
            , stats =
                { winRate = 86.1
                , submissionRate = 44.4
                , averageMatchTime = 7.5
                , favoritePosition = "Pressure passing / mount"
                , favoriteSubmission = "Armbar / katagatame"
                }
            }
          )
        , ( "leandro-lo"
          , { id = "leandro-lo"
            , name = "Leandro Lo"
            , nickname = "Lo"
            , nationality = "Brazil"
            , team = "NS Brotherhood"
            , gender = Types.Male
            , weight = Types.Middle
            , style = Types.Passing
            , achievements = loAchievements
            , imageUrl = "/images/heroes/leandro-lo.jpg"
            , coverImageUrl = "/images/heroes/leandro-lo-cover.jpg"
            , bio = "8x IBJJF world legend remembered for toreando blitz passing and fearless scrambles."
            , record =
                { wins = 156
                , losses = 21
                , draws = 1
                , submissions = 54
                , points = 78
                , advantages = 24
                , titles = [ "8x IBJJF World Champion", "7x Pan American Champion", "2x ADCC Champion" ]
                }
            , techniques = loTechniques
            , socialMedia =
                { instagram = Just "@leandrolojj"
                , youtube = Nothing
                , twitter = Nothing
                , website = Nothing
                }
            , videos = loVideos
            , stats =
                { winRate = 88.1
                , submissionRate = 34.6
                , averageMatchTime = 6.5
                , favoritePosition = "Toriando / guard passing blitz"
                , favoriteSubmission = "Loop choke"
                }
            }
          )
        ]
    )
        |> List.filter
            (\(_, hero) ->
                not (List.isEmpty hero.techniques)
            )
        |> Dict.fromList



gordonAchievements : List Types.Achievement
gordonAchievements =
    [ { id = "adcc-2019"
      , name = "ADCC 2019 Double Gold"
      , description = "Won both weight and absolute divisions"
      , icon = "🏆"
      , unlockedAt = Just "2019-09-29"
      , category = Types.MilestoneAchievement
      , points = 1000
      }
    , { id = "adcc-2022"
      , name = "ADCC 2022 Superfight"
      , description = "Defeated André Galvão in superfight"
      , icon = "👑"
      , unlockedAt = Just "2022-09-18"
      , category = Types.MilestoneAchievement
      , points = 1000
      }
    ]


buchechaAchievements : List Types.Achievement
buchechaAchievements =
    [ { id = "worlds-13x"
      , name = "13x World Champion"
      , description = "Most decorated IBJJF World Champion"
      , icon = "🥇"
      , unlockedAt = Just "2019-06-02"
      , category = Types.MilestoneAchievement
      , points = 1500
      }
    ]


rafaAchievements : List Types.Achievement
rafaAchievements =
    [ { id = "berimbolo-pioneer"
      , name = "Berimbolo Pioneer"
      , description = "Revolutionized the modern guard game"
      , icon = "🔄"
      , unlockedAt = Just "2013-06-02"
      , category = Types.TechniqueAchievement
      , points = 800
      }
    ]


galvaoAchievements : List Types.Achievement
galvaoAchievements =
    [ { id = "atos-founder"
      , name = "Atos Founder"
      , description = "Created one of the most successful teams"
      , icon = "🏛️"
      , unlockedAt = Just "2008-01-01"
      , category = Types.MilestoneAchievement
      , points = 1200
      }
    ]


loAchievements : List Types.Achievement
loAchievements =
    [ { id = "passing-master"
      , name = "Passing Master"
      , description = "Dominated with explosive guard passing"
      , icon = "⚡"
      , unlockedAt = Just "2018-06-03"
      , category = Types.TechniqueAchievement
      , points = 900
      }
    ]


gordonTechniques : List Types.Technique
gordonTechniques =
    [ { id = "gordon-back-system"
      , name = "Back Attack System"
      , category = Types.SubmissionTechnique
      , difficulty = Types.Expert
      , description = "Gordon's systematic approach to controlling and finishing from the back"
      , keyDetails = [ "Hand fighting concepts", "Body triangle variations", "RNC mechanics" ]
      , videoUrl = Just "https://example.com/gordon-back"
      , xpValue = 200
      , prerequisites = []
      , masteryLevel = Types.NotStarted
      , relatedFighters = [ "gordon-ryan" ]
      }
    , { id = "gordon-leg-system"
      , name = "Leg Lock System"
      , category = Types.SubmissionTechnique
      , difficulty = Types.Expert
      , description = "Complete leg entanglement system"
      , keyDetails = [ "Ashi Garami entries", "Breaking mechanics", "Heel exposure" ]
      , videoUrl = Just "https://example.com/gordon-legs"
      , xpValue = 250
      , prerequisites = []
      , masteryLevel = Types.NotStarted
      , relatedFighters = [ "gordon-ryan", "craig-jones" ]
      }
    ]


buchechaTechniques : List Types.Technique
buchechaTechniques =
    [ { id = "buchecha-pressure"
      , name = "Pressure Passing"
      , category = Types.PassingTechnique
      , difficulty = Types.DifficultyAdvanced
      , description = "Heavy pressure passing system"
      , keyDetails = [ "Weight distribution", "Hip pressure", "Shoulder control" ]
      , videoUrl = Nothing
      , xpValue = 150
      , prerequisites = []
      , masteryLevel = Types.NotStarted
      , relatedFighters = [ "marcus-buchecha" ]
      }
    ]


rafaTechniques : List Types.Technique
rafaTechniques =
    [ { id = "rafa-berimbolo"
      , name = "Berimbolo"
      , category = Types.SweepTechnique
      , difficulty = Types.Expert
      , description = "The signature berimbolo sweep"
      , keyDetails = [ "De La Riva entry", "Inversion mechanics", "Back take finish" ]
      , videoUrl = Just "https://example.com/rafa-berimbolo"
      , xpValue = 300
      , prerequisites = []
      , masteryLevel = Types.NotStarted
      , relatedFighters = [ "rafael-mendes", "mikey-galvao" ]
      }
    ]


galvaoTechniques : List Types.Technique
galvaoTechniques =
    [ { id = "galvao-guillotine"
      , name = "High Elbow Guillotine"
      , category = Types.SubmissionTechnique
      , difficulty = Types.DifficultyAdvanced
      , description = "Galvão's famous guillotine system"
      , keyDetails = [ "Arm positioning", "Hip movement", "Finishing mechanics" ]
      , videoUrl = Nothing
      , xpValue = 150
      , prerequisites = []
      , masteryLevel = Types.NotStarted
      , relatedFighters = [ "andre-galvao" ]
      }
    ]


loTechniques : List Types.Technique
loTechniques =
    [ { id = "lo-knee-cut"
      , name = "Knee Cut Pass"
      , category = Types.PassingTechnique
      , difficulty = Types.Intermediate
      , description = "Lo's explosive knee cut passing"
      , keyDetails = [ "Grips", "Angle", "Hip pressure" ]
      , videoUrl = Just "https://example.com/lo-knee-cut"
      , xpValue = 150
      , prerequisites = []
      , masteryLevel = Types.NotStarted
      , relatedFighters = [ "leandro-lo" ]
      }
    ]

type alias LocalizedString =
    { en : String
    , fr : String
    }


localized : String -> String -> LocalizedString
localized en fr =
    { en = en, fr = fr }


type alias TechniqueEntry =
    { id : String
    , name : LocalizedString
    , description : LocalizedString
    , details : List LocalizedString
    }


type alias TechniqueGroup =
    { id : String
    , icon : String
    , title : LocalizedString
    , subtitle : LocalizedString
    , entries : List TechniqueEntry
    }


finishingTechniqueGroups : List TechniqueGroup
finishingTechniqueGroups =
    [ chokersGroup
    , armlockGroup
    , leglockGroup
    , hybridGroup
    ]


guardTechniqueGroups : List TechniqueGroup
guardTechniqueGroups =
    [ basicsGuardGroup
    , seatedGuardGroup
    , entanglementGuardGroup
    , lapelGuardGroup
    , invertedGuardGroup
    , topControlGuardGroup
    , hybridGuardPositions
    , specialtyGuardGroup
    ]


sweepTechniqueGroups : List TechniqueGroup
sweepTechniqueGroups =
    [ closedGuardSweepGroup
    , butterflySweepGroup
    , halfGuardSweepGroup
    , deLaRivaSweepGroup
    , spiderLassoSweepGroup
    , modernGuardSweepGroup
    , seatedOpenSweepGroup
    , inversionSweepGroup
    , rubberGuardSweepGroup
    ]


guardTechniqueNotes : List LocalizedString
guardTechniqueNotes =
    [ localized
        "Many guards connect together: e.g. De La Riva ➜ berimbolo ➜ back take."
        "De nombreuses gardes se connectent entre elles : par exemple De La Riva mène souvent au berimbolo puis au dos."
    , localized
        "Some guards are gi-centric (Spider, Lasso, Worm) while others stay no-gi friendly (X-guard, SLX, Truck)."
        "Certaines gardes sont surtout en kimono (Spider, Lasso, Worm) alors que d'autres restent no-gi friendly (X-guard, SLX, Truck)."
    , localized
        "Master 3–5 core guards (closed, half/deep half, butterfly, De La Riva, X-guard) to cover most scenarios."
        "Maîtriser 3 à 5 gardes solides (fermée, demi/deep half, papillon, De La Riva, X-guard) couvre l’essentiel des options compétitives."
    , localized
        "Modern guards mix sweeps + leg entanglements + berimbolos; understanding transitions matters more than memorizing names."
        "Les gardes modernes mixent balayages + entanglements de jambes + berimbolos : comprendre les transitions vaut plus que mémoriser chaque nom."
    ]


sweepTechniqueNotes : List LocalizedString
sweepTechniqueNotes =
    [ localized
        "Pair each sweep with an opposite-direction follow-up (e.g. hip bump ↔️ kimura pendulum) to punish reactions."
        "Associe chaque renversement à un suivi en sens inverse (ex : hip bump ↔️ kimura/pendule) pour punir les réactions."
    , localized
        "Think in mechanics: kuzushi (off-balancing), elevation, leg traps, or spin unders—label the trigger before you drill."
        "Raisonne en mécaniques : kuzushi, élévation, piège de jambe ou inversion — nomme le déclencheur avant de répéter."
    , localized
        "Control the posting arm or ankle first; 80% of failed sweeps come from letting the opponent post freely."
        "Contrôle toujours le bras ou la cheville d’appui : 80 % des sweeps ratés viennent d’un appui libre."
    , localized
        "Standing opponents require grip switches: swap sleeves for ankles and be ready to technical stand up."
        "Face à un adversaire debout, change rapidement de grips : manches → chevilles et prépare le relevé technique."
    ]


chokersGroup : TechniqueGroup
chokersGroup =
    { id = "chokes"
    , icon = "🔒"
    , title = localized "Chokes" "Étranglements (Chokes)"
    , subtitle = localized "From guard, back, or top control." "Depuis la garde, le dos ou le dessus"
    , entries =
        [ choke "rear-naked"
            (localized "Rear Naked Choke (Mata Leão)" "Rear Naked Choke (Mata Leão)")
            (localized "Classic back-control choke that seals both carotids without a collar grip."
                "L’étranglement arrière classique qui coupe les carotides sans utiliser le col.")
            [ localized "Fight for hand control before sliding under the chin." "Contrôle les mains avant de glisser sous le menton."
            , localized "Use body-triangle variations to stay glued to the back." "Verrouille un body triangle pour rester collé au dos."
            ]
        , choke "bow-arrow"
            (localized "Bow and Arrow Choke" "Bow and Arrow Choke")
            (localized "Gi choke that finishes by pulling the lapel across like an archer’s bow."
                "Étranglement en gi qui se termine en tirant le col comme un arc.")
            [ localized "Control the far hip to prevent the opponent from rolling." "Contrôle la hanche opposée pour empêcher la roulade."
            , localized "Extend the torso to generate cutting power." "Allonge ton tronc pour créer la pression de coupe."
            ]
        , choke "cross-collar"
            (localized "Cross Collar Choke" "Étranglement croisé au col")
            (localized "Fundamental gi choke using opposite lapels from closed or mount."
                "Étranglement fondamental en gi utilisant les revers opposés.")
            [ localized "Feed deep grips before crossing the wrists." "Place tes poignets profondément avant de croiser les mains."
            , localized "Draw the elbows toward your hips to finish." "Ramène les coudes vers tes hanches pour finaliser."
            ]
        , choke "ezekiel"
            (localized "Ezekiel Choke" "Ezekiel")
            (localized "Forearm choke that works from mount or inside closed guard."
                "Étranglement à l’avant-bras depuis la monture ou la garde fermée.")
            [ localized "Slide one hand into your sleeve to hide the grip." "Glisse une main dans ta manche pour masquer ta prise."
            , localized "Use the blade of the forearm across the trachea." "Utilise le tranchant de l’avant-bras sur la trachée."
            ]
        , choke "loop"
            (localized "Loop Choke" "Loop Choke")
            (localized "Fast collar choke that spins around the opponent’s head."
                "Étranglement rapide qui tourne autour de la tête grâce au col.")
            [ localized "Thread the choking arm under the neck like a guillotine." "Passe ton bras sous la nuque comme pour une guillotine."
            , localized "Rotate your body to tighten the loop." "Tourne ton corps pour serrer la boucle."
            ]
        , choke "guillotine"
            (localized "Guillotine" "Guillotine")
            (localized "Front headlock choke, perfect against level-change takedowns."
                "Étranglement frontal idéal contre les projections basses.")
            [ localized "Connect your hands palm-to-palm or high-elbow." "Verrouille main sur main ou en high elbow."
            , localized "Drive the hips forward to compress the airway." "Pousse tes hanches vers l’avant pour couper l’air."
            ]
        , choke "arm-triangle"
            (localized "Arm Triangle (Katagatame)" "Arm Triangle (Katagatame)")
            (localized "Uses your arm and the opponent’s trapped arm to seal the neck."
                "Utilise ton bras et celui de l’adversaire pour enfermer le cou.")
            [ localized "Keep your head low and walk toward the trapped arm." "Garde la tête basse et marche vers le bras piégé."
            , localized "Aim for a 90° angle with shoulders parallel to the mat." "Cherche un angle de 90° avec les épaules parallèles au tapis."
            ]
        , choke "darce"
            (localized "D’Arce Choke" "D’Arce Choke")
            (localized "Wraps around neck and arm from front-headlock style control."
                "Étranglement qui enroule le cou et le bras depuis un front-headlock.")
            [ localized "Thread the arm deep under the armpit toward the neck." "Passe ton bras profondément sous l’aisselle vers le cou."
            , localized "Lock palm-to-bicep and sprawl to finish." "Verrouille main-biceps puis sprawl pour finaliser."
            ]
        , choke "anaconda"
            (localized "Anaconda Choke" "Anaconda Choke")
            (localized "Inverted d’Arce variation that finishes after a roll."
                "Variante inversée du d’Arce qui se termine après une roulade.")
            [ localized "Connect your hands first, then roll toward the trapped arm." "Connecte tes mains puis roule vers le bras enfermé."
            , localized "Squeeze the elbows toward the ribcage." "Resserre les coudes vers tes côtes."
            ]
        , choke "north-south"
            (localized "North-South Choke" "North-South Choke")
            (localized "Hand-to-hand choke while sitting north-south above the head."
                "Étranglement main-à-main en position north-south.")
            [ localized "Drop your chest onto the jawline." "Pose ta poitrine sur la mâchoire adverse."
            , localized "Walk the hips around to block the escape path." "Marche autour pour bloquer les sorties."
            ]
        , choke "clock"
            (localized "Clock Choke" "Clock Choke")
            (localized "Turtle choke where you walk around like a pendulum."
                "Étranglement depuis la turtle en marchant comme une pendule.")
            [ localized "Drive a deep lapel grip behind the neck." "Plante un revers profond derrière la nuque."
            , localized "Walk around the body to tighten the choke." "Marche autour du corps pour serrer."
            ]
        , choke "paper-cutter"
            (localized "Paper Cutter Choke" "Paper Cutter Choke")
            (localized "Uses a deep collar grip and a slicing forearm motion."
                "Utilise une prise profonde au col et un mouvement de coupe.")
            [ localized "Feed the far lapel palm-up." "Passe le revers opposé paume vers le haut."
            , localized "Drop your far elbow toward the mat." "Laisse tomber ton coude opposé vers le tapis."
            ]
        , choke "baseball-bat"
            (localized "Baseball Bat Choke" "Baseball Bat Choke")
            (localized "Rotational collar choke often hit from inverted guard."
                "Étranglement par rotation souvent depuis une garde inversée.")
            [ localized "Set opposite grips like holding a bat." "Place tes mains comme si tu tenais une batte."
            , localized "Spin under the opponent to apply the choke." "Tourne-toi sous l’adversaire pour terminer."
            ]
        , choke "triangle"
            (localized "Triangle Choke" "Triangle Choke (Sankaku)")
            (localized "Classic legs-around-the-neck choke from guard or mount."
                "Étranglement classique en triangle depuis la garde ou la monture.")
            [ localized "Lock the ankle under the opposite knee." "Verrouille la cheville sous le genou opposé."
            , localized "Angle your hips off to the side." "Oriente tes hanches de côté."
            ]
        , choke "reverse-triangle"
            (localized "Reverse Triangle" "Triangle inversé")
            (localized "Back or mount variation that squeezes from behind."
                "Variation depuis le dos ou la monture qui serre par l’arrière.")
            [ localized "Use seat-belt style control to trap the shoulder." "Utilise un contrôle seat-belt pour piéger l’épaule."
            , localized "Drive the hips forward to finish." "Pousse les hanches vers l’avant pour finir."
            ]
        , choke "gogoplata"
            (localized "Gogoplata" "Gogoplata")
            (localized "High guard choke using the shin across the trachea."
                "Étranglement de garde haute avec le tibia sur la trachée.")
            [ localized "Bring your shin over the opponent’s shoulder." "Place ton tibia par-dessus l’épaule adverse."
            , localized "Grab behind the head to add pressure." "Saisis l’arrière de la tête pour ajouter de la pression."
            ]
        , choke "omoplata-choke"
            (localized "Omoplata Choke" "Omoplata Choke")
            (localized "Strangulation that transitions directly out of the omoplata finish."
                "Étranglement qui naît directement de l’omoplata.")
            [ localized "Thread the foot behind the neck." "Passe ton pied derrière la nuque."
            , localized "Pull the collar downward while extending the hips." "Tire sur le col tout en levant les hanches."
            ]
        ]
    }


armlockGroup : TechniqueGroup
armlockGroup =
    { id = "armlocks"
    , icon = "💪"
    , title = localized "Arm Locks" "Clés de bras (Armlocks)"
    , subtitle = localized "Hyperextensions that attack the elbow or shoulder." "Hyperextensions sur le coude ou l’épaule."
    , entries =
        [ armlock "armbar"
            (localized "Armbar (Juji Gatame)" "Armbar (Juji Gatame)")
            (localized "Direct elbow hyperextension from guard, mount, or back."
                "Hyperextension directe du coude depuis la garde, la monture ou le dos.")
            [ localized "Pinch the knees together before finishing." "Pince tes genoux avant de finaliser."
            , localized "Point the opponent’s thumb to the ceiling." "Garde le pouce de l’adversaire dirigé vers le plafond."
            ]
        , armlock "kimura"
            (localized "Kimura" "Kimura")
            (localized "Figure-four grip that rotates the shoulder outward."
                "Clé en double saisie qui fait pivoter l’épaule vers l’extérieur.")
            [ localized "Trap the wrist to the mat first." "Plaque le poignet au tapis avant tout."
            , localized "Move your torso to a 90° angle." "Écarte ton torse à 90° pour le levier."
            ]
        , armlock "americana"
            (localized "Americana" "Americana")
            (localized "Shoulder lock in internal rotation, often from mount."
                "Clé d’épaule en rotation interne, souvent depuis la monture.")
            [ localized "Keep their elbow at a right angle." "Maintiens leur coude à angle droit."
            , localized "Slide the trapped hand along the mat." "Fais glisser leur poignet le long du tapis."
            ]
        , armlock "straight-arm"
            (localized "Straight Arm Lock" "Clé de bras droite")
            (localized "Direct elbow lock by pinching their arm between your arms."
                "Hyperextension directe en serrant leur bras entre les tiens.")
            [ localized "Apply pressure through your hips." "Applique la pression avec tes hanches."
            , localized "Use your forearm as a fulcrum on the joint." "Utilise ton avant-bras comme point d’appui."
            ]
        , armlock "bicep-slicer"
            (localized "Bicep Slicer" "Écrasement du biceps")
            (localized "Compression lock that crushes the biceps against a hard wedge."
                "Écrasement qui bloque le biceps contre un point dur.")
            [ localized "Create a sharp wedge with shin or forearm." "Crée un levier dur avec ton tibia ou avant-bras."
            , localized "Pull their forearm toward you to apply pressure." "Ramène leur avant-bras vers toi pour comprimer."
            ]
        , armlock "wrist-lock"
            (localized "Wrist Lock" "Clé de poignet")
            (localized "Flexes or extends the wrist to force a quick tap."
                "Met en flexion ou extension le poignet pour provoquer l’abandon.")
            [ localized "Control the elbow so the opponent can’t spin out." "Contrôle le coude pour empêcher la rotation."
            , localized "Finish with a small circular motion." "Finalise avec un petit mouvement circulaire."
            ]
        ]
    }


leglockGroup : TechniqueGroup
leglockGroup =
    { id = "leglocks"
    , icon = "🦵"
    , title = localized "Leg Locks" "Attaques de jambes (Leg Locks)"
    , subtitle = localized "Ankle, knee, and entanglement-based finishes." "Clés de cheville, genou et positions d’entanglement."
    , entries =
        [ leglock "straight-ankle"
            (localized "Straight Ankle Lock" "Straight Ankle Lock")
            (localized "Fundamental ankle lock that hinges the foot backward."
                "Clé basique qui fléchit la cheville vers l’arrière.")
            [ localized "Keep your outside foot on the hip to push away." "Garde ton pied extérieur sur la hanche pour repousser."
            , localized "Lift your hips to add pressure to the Achilles." "Soulève les hanches pour écraser le tendon."
            ]
        , leglock "heel-hook"
            (localized "Heel Hook (Inside/Outside)" "Heel Hook (inside/outside)")
            (localized "Rotational submission twisting the knee via the heel."
                "Soumission rotationnelle qui tord le genou via le talon.")
            [ localized "Control the knee line before twisting." "Contrôle la ligne du genou avant de tourner."
            , localized "Rotate slowly and keep the opponent’s hips trapped." "Tourne lentement tout en piégeant les hanches."
            ]
        , leglock "toe-hold"
            (localized "Toe Hold" "Toe Hold")
            (localized "Figure-four grip folding the foot toward the glutes."
                "Prise en croissant qui replie le pied vers les fessiers.")
            [ localized "Align both wrists before pulling." "Aligne tes poignets avant de tirer."
            , localized "Pin their elbow to your ribs to keep control." "Colle leur coude à ton buste pour garder le contrôle."
            ]
        , leglock "kneebar"
            (localized "Kneebar" "Kneebar")
            (localized "Armbar mechanics applied to the knee joint."
                "Armbar appliqué à l’articulation du genou.")
            [ localized "Glue your hips to the femur." "Colle tes hanches au fémur."
            , localized "Trap their foot under your armpit." "Coince leur pied sous ton aisselle."
            ]
        , leglock "calf-slicer"
            (localized "Calf Slicer" "Écrasement du mollet")
            (localized "Compression lock crushing the calf against a wedge."
                "Écrasement du mollet contre un point d’appui rigide.")
            [ localized "Thread your shin behind their knee." "Passe ton tibia derrière leur genou."
            , localized "Lock your legs tightly before pulling." "Verrouille fortement tes jambes avant de tirer."
            ]
        , leglock "estima-lock"
            (localized "Estima Lock" "Estima Lock")
            (localized "Explosive ankle lock timed during guard passing."
                "Clé de cheville explosive déclenchée pendant le passage de garde.")
            [ localized "Clamp the wrists together quickly." "Serre tes poignets rapidement."
            , localized "Rotate outward to finish instantly." "Tourne vers l’extérieur pour finir immédiatement."
            ]
        , leglock "5050-heel-hook"
            (localized "50/50 Heel Hook" "50/50 Heel Hook")
            (localized "Heel hook variation built directly from 50/50 guard."
                "Variation de heel hook directement depuis la 50/50 guard.")
            [ localized "Cross your feet to stop their escape path." "Croise tes pieds pour bloquer leurs sorties."
            , localized "Control their hips before addressing the heel." "Contrôle leurs hanches avant de chercher le talon."
            ]
        , leglock "outside-ashi"
            (localized "Outside Ashi Garami" "Outside Ashi Garami")
            (localized "Single-leg entanglement leading to outside heel hooks."
                "Enchevêtrement sur une jambe menant aux heel hooks extérieurs.")
            [ localized "Align their knee with your hips." "Aligne leur genou avec tes hanches."
            , localized "Use your free foot as a hook for retention." "Utilise ton pied libre comme crochet de rétention."
            ]
        , leglock "inside-ashi"
            (localized "Inside Ashi Garami" "Inside Ashi Garami")
            (localized "Mirror position attacking the near leg for inside heel hooks."
                "Position miroir pour attaquer la jambe proche en inside heel hook.")
            [ localized "Clamp their knee between your thighs." "Coince leur genou entre tes cuisses."
            , localized "Angle off to the side before finishing." "Décale-toi sur le côté avant de finir."
            ]
        ]
    }


hybridGroup : TechniqueGroup
hybridGroup =
    { id = "hybrids"
    , icon = "⚙️"
    , title = localized "Hybrid submissions & transitions" "Soumissions hybrides & transitions"
    , subtitle = localized "Mix of chokes, locks, and positional changes." "Mélange de strangulations, de clés et de transitions."
    , entries =
        [ hybrid "omoplata"
            (localized "Omoplata" "Omoplata")
            (localized "Shoulder lock using the legs that can flow into chokes."
                "Clé d’épaule via les jambes pouvant évoluer vers un étranglement.")
            [ localized "Turn your chest toward their hips." "Tourne ton buste vers leurs hanches."
            , localized "Lift your hips while controlling the waist." "Soulève les hanches en contrôlant la taille."
            ]
        , hybrid "triangle-armbar"
            (localized "Triangle / Armbar combos" "Combinaisons triangle-armbar")
            (localized "Fluid transitions between triangle choke and armbar."
                "Transitions fluides entre triangle et armbar.")
            [ localized "Break posture before switching." "Casse la posture avant de changer."
            , localized "Re-anchor the foot under your knee each time." "Replace ton pied sous ton genou à chaque rotation."
            ]
        , hybrid "mounted-triangle"
            (localized "Mounted Triangle" "Triangle monté")
            (localized "Mounted setup that offers both choke and armbar finishes."
                "Triangle monté ouvrant sur étranglement ou armbar.")
            [ localized "Slide the knee under the armpit." "Glisse ton genou sous l’aisselle."
            , localized "Pour weight forward to stop bridging." "Projette ton poids vers l’avant pour bloquer les ponts."
            ]
        , hybrid "armbar-back"
            (localized "Armbar from the back" "Armbar depuis le dos")
            (localized "Rotate off the hip while keeping the back secured."
                "Rotation sur la hanche en conservant le contrôle du dos.")
            [ localized "Keep at least one hook in during the spin." "Garde au moins un crochet durant la rotation."
            , localized "Control the thumb orientation before extending." "Contrôle l’orientation du pouce avant d’étendre."
            ]
        , hybrid "crucifix"
            (localized "Crucifix Choke" "Crucifix Choke")
            (localized "Crucifix control that opens up both chokes and locks."
                "Contrôle en croix qui ouvre étrangle­ments et clés.")
            [ localized "Trap their far arm with your legs." "Coince leur bras éloigné avec tes jambes."
            , localized "Pull the lapel or head backward to finish." "Tire sur le col ou la tête vers l’arrière."
            ]
        , hybrid "twister"
            (localized "Truck / Twister" "Truck / Twister")
            (localized "10th Planet chain combining truck hooks and spinal locks."
                "Chaîne 10th Planet combinant hooks truck et torsions vertébrales.")
            [ localized "Keep the truck hook glued to the thigh." "Garde le hook du truck collé à la cuisse."
            , localized "Lock behind the head for the twister finish." "Verrouille derrière la tête pour twister."
            ]
        , hybrid "peruvian"
            (localized "Peruvian Necktie" "Peruvian Necktie")
            (localized "Hybrid choke from the front headlock that mimics a guillotine."
                "Étranglement hybride depuis le front headlock à mi-chemin entre guillotine et crank.")
            [ localized "Thread the choking arm deep under the neck." "Passe ton bras profondément sous la nuque."
            , localized "Sit onto the back of the head." "Assieds-toi sur l’arrière de la tête."
            ]
        , hybrid "banana-split"
            (localized "Banana Split" "Banana Split")
            (localized "Grappling-only leg splitter from truck or back control."
                "Écartèlement des jambes depuis le truck ou le dos.")
            [ localized "Hook both legs in opposite directions." "Accroche leurs jambes dans des directions opposées."
            , localized "Pull their hips toward your chest." "Ramène leurs hanches vers ta poitrine."
            ]
        ]
    }


choke : String -> LocalizedString -> LocalizedString -> List LocalizedString -> TechniqueEntry
choke =
    techniqueEntry


armlock : String -> LocalizedString -> LocalizedString -> List LocalizedString -> TechniqueEntry
armlock =
    techniqueEntry


leglock : String -> LocalizedString -> LocalizedString -> List LocalizedString -> TechniqueEntry
leglock =
    techniqueEntry


hybrid : String -> LocalizedString -> LocalizedString -> List LocalizedString -> TechniqueEntry
hybrid =
    techniqueEntry


techniqueEntry : String -> LocalizedString -> LocalizedString -> List LocalizedString -> TechniqueEntry
techniqueEntry id name description details =
    { id = id
    , name = name
    , description = description
    , details = details
    }


basicsGuardGroup : TechniqueGroup
basicsGuardGroup =
    { id = "guards-basics"
    , icon = "🛡️"
    , title = localized "Foundational guards" "Gardes fermées & basiques"
    , subtitle = localized "Fundamental controls to slow or attack." "Contrôles fondamentaux pour ralentir ou attaquer."
    , entries =
        [ guardEntry "closed-guard"
            (localized "Closed Guard" "Garde fermée")
            (localized "Legs locked around the torso to control posture and distance."
                "Jambes croisées autour du torse pour contrôler posture et distance.")
            [ localized "Threaten armbar, triangle, kimura." "Menaces armbar, triangle, kimura."
            , localized "Use hip-bump or pendulum sweeps." "Balayages hip bump et pendule."
            ]
        , guardEntry "open-guard"
            (localized "Open Guard" "Garde ouverte")
            (localized "Feet uncrossed; base position that leads to modern guards."
                "Pieds non croisés, base pour transiter vers d’autres gardes.")
            [ localized "Attack basic sweeps and triangles." "Balayages basiques, triangles."
            , localized "Enter De La Riva or X-guard." "Entrées vers De La Riva, X."
            ]
        , guardEntry "half-guard"
            (localized "Half Guard" "Demi-garde")
            (localized "One leg trapped between the opponent’s legs."
                "Une jambe entre les jambes de l’adversaire, versions gi/no-gi.")
            [ localized "Set up kimura and back takes." "Prépare kimura et prises de dos."
            , localized "Transition to deep half for sweeps." "Transition vers deep half pour balayer."
            ]
        , guardEntry "deep-half"
            (localized "Deep Half Guard" "Deep Half Guard")
            (localized "Sit deep underneath to tilt and sweep effortlessly."
                "Variation enfouie sous l’adversaire pour renverser facilement.")
            [ localized "Use explosive tilt sweeps." "Balayages explosifs en bascule."
            , localized "Chain into X-guard entries." "Enchaîne vers les entrées X-guard."
            ]
        ]
    }


seatedGuardGroup : TechniqueGroup
seatedGuardGroup =
    { id = "guards-seated"
    , icon = "🧘"
    , title = localized "Seated & butterfly guards" "Gardes assises & papillon"
    , subtitle = localized "High-pace options ideal for modern gi/no-gi play." "Options rapides idéales en gi comme en no-gi."
    , entries =
        [ guardEntry "butterfly"
            (localized "Butterfly Guard" "Garde papillon")
            (localized "Hooks under the thighs to off-balance from seated."
                "Crochets sous les cuisses pour déséquilibrer en position assise.")
            [ localized "Hit classic butterfly sweeps." "Balayages papillon classiques."
            , localized "Threaten guillotines and back takes." "Guillotines et prises de dos."
            ]
        , guardEntry "seated-open"
            (localized "Seated Open Guard" "Garde assise ouverte")
            (localized "Stay seated with sleeve/pant or collar grips."
                "Position assise avec contrôles manches/pantalon ou col.")
            [ localized "Launch quick sit-up sweeps." "Balayages rapides en sit-up."
            , localized "Enter X-guard or leg locks." "Entrées vers X ou leg locks."
            ]
        , guardEntry "single-leg-x"
            (localized "Single Leg X (SLX)" "Single Leg X (SLX)")
            (localized "Inside control of one leg while seated or supine."
                "Contrôle d’une jambe depuis la position assise ou sur le dos.")
            [ localized "Sweep to technical stand-up." "Balaye vers le relevé technique."
            , localized "Transition to leg lock finishes." "Transitions vers leg locks."
            ]
        , guardEntry "shin-to-shin"
            (localized "Shin-to-Shin Guard" "Shin-to-Shin Guard")
            (localized "Shin against shin entry that launches SLX or 50/50."
                "Tibia contre tibia pour déclencher SLX ou 50/50.")
            [ localized "Use against standing opponents." "À utiliser contre un adversaire debout."
            , localized "Flow directly into leg entanglements." "Permet d’aller directement vers les entanglements."
            ]
        ]
    }


entanglementGuardGroup : TechniqueGroup
entanglementGuardGroup =
    { id = "guards-entanglements"
    , icon = "🦾"
    , title = localized "Leg entanglement guards" "Gardes d’enchevêtrement de jambes"
    , subtitle = localized "Platforms for sweeps and relentless leg attacks." "Plateformes pour balayages et attaques de jambes."
    , entries =
        [ guardEntry "x-guard"
            (localized "X-Guard" "X-Guard")
            (localized "Low guard with crossed hooks under the opponent."
                "Garde basse avec crochets croisés sous l’adversaire.")
            [ localized "Load their weight onto your hooks then tilt." "Charge leur poids sur tes crochets puis bascule."
            , localized "Transition immediately into leg attacks." "Transitionne directement vers les attaques de jambe."
            ]
        , guardEntry "5050"
            (localized "50/50 Guard" "50/50 Guard")
            (localized "Symmetrical entanglement great for sweeps and heel hooks."
                "Enchevêtrement symétrique idéal pour sweeps et heel hooks.")
            [ localized "Control both knees to slow counters." "Contrôle les deux genoux pour freiner les contres."
            , localized "Alternate between off-balancing and submissions." "Alterne déséquilibres et soumissions."
            ]
        , guardEntry "outside-ashi"
            (localized "Outside / Inside Ashi" "Outside / Inside Ashi")
            (localized "Ashi Garami families that isolate one leg."
                "Familles Ashi Garami pour isoler une jambe.")
            [ localized "Choose inside or outside heel hooks." "Choisis les heel hooks inside ou outside."
            , localized "Flow into kneebars and toe holds." "Enchaîne vers kneebars et toe holds."
            ]
        , guardEntry "saddle-truck"
            (localized "Saddle / Truck" "Saddle / Truck")
            (localized "Control similar to truck/twister entries for back takes."
                "Contrôle façon truck/twister pour ouvrir le dos.")
            [ localized "Threaten combined heel hooks." "Menace des heel hooks combinés."
            , localized "Use truck hooks to expose the back." "Utilise les hooks truck pour exposer le dos."
            ]
        ]
    }


lapelGuardGroup : TechniqueGroup
lapelGuardGroup =
    { id = "guards-lapel"
    , icon = "🪢"
    , title = localized "De La Riva & lapel guards" "Gardes De La Riva & lapels"
    , subtitle = localized "Use sleeves and lapels to immobilize and attack." "Utilise manches et revers pour piéger et attaquer."
    , entries =
        [ guardEntry "de-la-riva"
            (localized "De La Riva Guard" "De La Riva")
            (localized "Outside hook around the thigh, cornerstone of gi guard work."
                "Pied accroché autour de la cuisse extérieure, base en gi.")
            [ localized "Launch sweeps or berimbolo entries." "Balayages ou départs de berimbolo."
            , localized "Climb to the back when posture breaks." "Prends le dos quand la posture casse."
            ]
        , guardEntry "reverse-dlr"
            (localized "Reverse De La Riva" "Reverse De La Riva")
            (localized "Inverted hook that stuffs knee slices and creates reversals."
                "Crochet inversé qui casse la base et inverse le passage.")
            [ localized "Use against knee-slice attempts." "À utiliser contre les knee slices."
            , localized "Transition to leg drag style sweeps." "Transitions vers des balayages type leg drag."
            ]
        , guardEntry "spider"
            (localized "Spider Guard" "Spider Guard")
            (localized "Feet on biceps or hips while controlling both sleeves."
                "Pieds sur les biceps ou les hanches avec contrôle des manches.")
            [ localized "Chain triangles, omoplatas, lassos." "Enchaîne triangles, omoplatas, lasso."
            , localized "Use push-pull motion for directional sweeps." "Utilise le push-pull pour diriger les balayages."
            ]
        , guardEntry "lasso"
            (localized "Lasso Guard" "Lasso Guard")
            (localized "Wrap the foot around the arm to freeze the passer."
                "Pied enroulé autour du bras pour figer l’adversaire.")
            [ localized "Clamp the lasso knee to control posture." "Colle ton genou lasso pour contrôler la posture."
            , localized "Open angles for sweeps or back takes." "Ouvre des angles pour balayer ou prendre le dos."
            ]
        , guardEntry "lapel-guard"
            (localized "Lapel / Collar Guard" "Lapel / Collar Guard")
            (localized "Use wrapped lapels to multiply levers (lapeloplata, collar drags)."
                "Utilise les revers pour multiplier les leviers (lapeloplata, collar drag, etc.).")
            [ localized "Set up bow-and-arrow variations." "Prépare les variantes bow & arrow."
            , localized "Feed the lapel to unleash berimbolo-style attacks." "Passe le col pour lancer les berimbolos."
            ]
        , guardEntry "worm-guard"
            (localized "Worm Guard" "Worm Guard")
            (localized "Kenan-style lapel system that binds the hips."
                "Système Kenan basé sur le lapel pour immobiliser les hanches.")
            [ localized "Create gyro-style sweeps." "Créé des sweeps gyroscopiques."
            , localized "Pin the opponent’s hip while you move freely." "Bloque les hanches adverses pendant que tu bouges."
            ]
        ]
    }


invertedGuardGroup : TechniqueGroup
invertedGuardGroup =
    { id = "guards-inverted"
    , icon = "🌀"
    , title = localized "Inverted & modern guards" "Gardes inversées & modernes"
    , subtitle = localized "Aerial approaches for berimbolos and back takes." "Approches aériennes pour renversements et prises de dos."
    , entries =
        [ guardEntry "inverted"
            (localized "Inverted Guard" "Inverted Guard")
            (localized "Roll onto the shoulders to attack triangles or berimbolo."
                "Vie sur les épaules pour attaquer triangles et berimbolos.")
            [ localized "Go upside down to expose the back." "Retourne-toi pour exposer le dos."
            , localized "Chain directly into berimbolo finishes." "Enchaîne directement vers le berimbolo."
            ]
        , guardEntry "inverted-x"
            (localized "Inverted X / Butterfly Inverted" "Inverted X / Butterfly inversée")
            (localized "Modern mix of inverted butterfly hooks and X control."
                "Mélange moderne de crochets papillon inversés et de contrôle X.")
            [ localized "Look toward their feet to find balance." "Regarde vers leurs pieds pour te stabiliser."
            , localized "Return to the back once the hips are exposed." "Reviens sur le dos dès que les hanches sont exposées."
            ]
        , guardEntry "rubber-guard"
            (localized "Rubber Guard" "Rubber Guard")
            (localized "High guard wrapping the leg around the neck for control."
                "Garde haute avec la jambe enroulée autour du cou pour contrôler.")
            [ localized "Hunt gogoplata and omoplata finishes." "Cherche les gogoplata et omoplata."
            , localized "Clamp the posture with your free arm." "Verrouille la posture avec ton bras libre."
            ]
        , guardEntry "knee-shield"
            (localized "Knee Shield (Z-Guard)" "Knee Shield (Z-Guard)")
            (localized "Use a knee as a frame to maintain distance."
                "Genou en bouclier pour maintenir la distance.")
            [ localized "Combine shrimping with underhooks." "Combine le shrimp avec la prise d’underhook."
            , localized "Launch kimura, sweeps, or back takes." "Lance kimura, balayages ou prises de dos."
            ]
        , guardEntry "tornado"
            (localized "Tornado / Helicopter Guard" "Tornado / Helicopter Guard")
            (localized "Dynamic no-gi guard used for leg entanglements and trucks."
                "Garde dynamique orientée leg entanglements et truck.")
            [ localized "Roll under to attack the legs." "Roule dessous pour attaquer les jambes."
            , localized "Transition to truck entries for finishes." "Transitionne vers les entrées truck."
            ]
        ]
    }


topControlGuardGroup : TechniqueGroup
topControlGuardGroup =
    { id = "guards-top-control"
    , icon = "🧱"
    , title = localized "Top-control style guards" "Contrôles depuis le dessus"
    , subtitle = localized "Options that slow the opponent before passing." "Options pour immobiliser avant de passer."
    , entries =
        [ guardEntry "reverse-dlr-top"
            (localized "Reverse De La Riva (top)" "Reverse De La Riva (top)")
            (localized "Standing or kneeling control on the far leg."
                "Contrôle debout/à genoux sur la jambe opposée.")
            [ localized "Enter leg drag or X-pass variations." "Entrées leg drag ou X-pass."
            , localized "Stuff the guard player’s hip mobility." "Bloque la mobilité des hanches adverses."
            ]
        , guardEntry "top-x"
            (localized "Top X entries" "Top X entries")
            (localized "Lock the hips before stepping into mount."
                "Verrouille les hanches avant de monter.")
            [ localized "Break their base by cross-facing." "Casse leur base avec un crossface."
            , localized "Cut across to the far side for the pass." "Passe de l’autre côté pour finaliser."
            ]
        , guardEntry "mount-type-guards"
            (localized "Mount-type controls" "Gardes type monture")
            (localized "Closed-style shells on top before attacking."
                "Postures fermées en haut avant d’attaquer.")
            [ localized "Isolate an arm for armbars." "Isole un bras pour l’armbar."
            , localized "Switch to shoulder isolations." "Enchaîne sur les isolements d’épaule."
            ]
        , guardEntry "combat-base"
            (localized "Combat base / knee-slice setups" "Combat base / entrées knee slice")
            (localized "Kneeling stance that feeds into knee-slice passing."
                "Position à genoux préparant le knee slice.")
            [ localized "Apply shoulder pressure to the torso." "Applique la pression de l’épaule sur le torse."
            , localized "Cut across diagonally to finish the pass." "Coupe en diagonale pour terminer le passage."
            ]
        ]
    }


hybridGuardPositions : TechniqueGroup
hybridGuardPositions =
    { id = "guards-hybrid"
    , icon = "⚔️"
    , title = localized "Hybrid / competition guards" "Gardes hybrides & compétition"
    , subtitle = localized "Blend berimbolos, entanglements, and truck entries." "Mix berimbolo, leg entanglements et entrées truck."
    , entries =
        [ guardEntry "berimbolo"
            (localized "Berimbolo" "Berimbolo")
            (localized "De La Riva sequence taking you to the back or 50/50."
                "Séquence De La Riva menant au dos ou à la 50/50.")
            [ localized "Invert with control on the far hip." "Inverse-toi en contrôlant la hanche opposée."
            , localized "Finish with a secure seat-belt." "Termine avec un seatbelt sécurisé."
            ]
        , guardEntry "truck"
            (localized "Truck / Twister path" "Trajectoire Truck / Twister")
            (localized "10th Planet-inspired path mixing truck hooks and spinal locks."
                "Chemin inspiré 10th Planet mêlant hooks truck et torsions.")
            [ localized "Use truck hooks to expose the back." "Utilise les hooks truck pour exposer le dos."
            , localized "Switch to heel hooks or twister controls." "Alterne vers les heel hooks ou le twister."
            ]
        , guardEntry "single-leg-x-sweep"
            (localized "SLX / 50-50 transitions" "Transitions SLX / 50/50")
            (localized "Cycle between Single Leg X, 50/50, and saddle entries."
                "Bascule entre SLX, 50/50 et les entrées saddle.")
            [ localized "Sweep against standing bases." "Balaye les bases debout."
            , localized "Switch to saddle to finish the leg." "Bascule vers le saddle pour finir la jambe."
            ]
        ]
    }


specialtyGuardGroup : TechniqueGroup
specialtyGuardGroup =
    { id = "guards-specialty"
    , icon = "🧩"
    , title = localized "Specialty variations" "Variantes spécialisées"
    , subtitle = localized "Specific guards to slow or surprise." "Gardes spécifiques pour ralentir ou surprendre."
    , entries =
        [ guardEntry "quarter-guard"
            (localized "Quarter Guard" "Quarter Guard")
            (localized "Between half guard and open guard to break rhythm."
                "Entre demi-garde et open guard pour casser le rythme.")
            [ localized "Delay the pass while hunting underhooks." "Retarde le passage tout en cherchant l’underhook."
            , localized "Switch back to half guard safely." "Reviens en demi-garde en sécurité."
            ]
        , guardEntry "lockdown"
            (localized "Lockdown Half Guard" "Lockdown")
            (localized "Crossed-leg control from half guard to stretch the opponent."
                "Contrôle croisé des chevilles depuis la demi-garde.")
            [ localized "Set up electric-chair sweeps." "Prépare les balayages electric chair."
            , localized "Transition to truck or leg attacks." "Transitionne vers le truck ou les attaques de jambes."
            ]
        , guardEntry "situp-lockdown"
            (localized "Sit-up to Lockdown" "Sit-up to Lockdown")
            (localized "Modern combination to re-grip the leg and enter truck."
                "Combinaison moderne pour accrocher la jambe et entrer dans le truck.")
            [ localized "Use goon sweeps when opponents stand." "Utilise les goon sweeps quand ils se relèvent."
            , localized "Keep the knee shield ready to invert." "Garde un knee shield prêt à t’inverser."
            ]
        ]
    }


closedGuardSweepGroup : TechniqueGroup
closedGuardSweepGroup =
    { id = "sweeps-closed-guard"
    , icon = "🧭"
    , title = localized "Closed-Guard Sweeps" "Renversements garde fermée"
    , subtitle = localized "Sit-up, pendulum, kimura, and ankle-dump chains." "Sit-up, pendule, kimura et balayages de chevilles."
    , entries =
        [ sweepEntry "hip-bump-sweep"
            (localized "Hip Bump Sweep (Sit-up)" "Hip Bump Sweep (Sit-up)")
            (localized "Explosive sit-up that collapses posture into mount or side control."
                "Sit-up explosif qui casse la posture et amène directement en montée ou en side.")
            (localized "Closed guard seated" "Garde fermée assise")
            (localized "Pin the posting arm, post a hand, then bump hips diagonally."
                "Bloque le bras d’appui, poste une main puis projette tes hanches en diagonale.")
        , sweepEntry "scissor-sweep"
            (localized "Scissor Sweep" "Scissor Sweep")
            (localized "Collar-and-sleeve control with a chopping leg motion to topple kneeling opponents."
                "Contrôle col/manche et mouvement en ciseau pour faire chuter un adversaire à genoux.")
            (localized "Closed guard opening to an angle" "Garde fermée qui s’ouvre sur un angle")
            (localized "Bottom leg kicks low while the top leg shelves the torso."
                "La jambe du bas fouette bas alors que la jambe du haut soutient le torse.")
        , sweepEntry "flower-sweep"
            (localized "Flower / Pendulum Sweep" "Flower / Pendulum Sweep")
            (localized "Pendulum leg swing that loads their weight so you can roll into mount."
                "Balancement façon pendule qui charge le poids pour rouler en montée.")
            (localized "Closed guard underhook on far leg" "Garde fermée avec underhook sur la jambe opposée")
            (localized "Swing the free leg wide then lift with the knee trapped between your thighs."
                "Balance la jambe libre en grand arc puis soulève avec le genou coincé entre tes cuisses.")
        , sweepEntry "double-ankle-sweep"
            (localized "Double Ankle Sweep" "Double Ankle Sweep")
            (localized "When the opponent stands, grab both ankles and extend your hips to dump them backward."
                "Quand l’adversaire se lève, saisis les deux chevilles et tends les hanches pour le renverser en arrière.")
            (localized "Closed guard vs standing opponent" "Garde fermée face à un adversaire debout")
            (localized "Kick the hips up while pulling ankles to erase the base."
                "Projette les hanches vers le haut tout en tirant les chevilles pour enlever la base.")
        , sweepEntry "lumberjack-sweep"
            (localized "Lumberjack Sweep" "Lumberjack Sweep")
            (localized "Lift the ankles off the mat like a deadlift, then pull their hips over your shins."
                "Soulève les chevilles du sol comme un soulevé de terre puis attire les hanches au-dessus de tes tibias.")
            (localized "Closed or open guard vs standing base" "Garde fermée/ouverture face à un adversaire debout")
            (localized "Scoot underneath, flare knees, and yank the heels toward you."
                "Glisse-toi dessous, ouvre les genoux et ramène les talons vers toi.")
        , sweepEntry "kimura-sweep"
            (localized "Kimura Sweep" "Kimura Sweep")
            (localized "Use the kimura threat to glue their shoulder, then roll over the trapped arm."
                "Utilise la menace kimura pour coller l’épaule puis roule au-dessus du bras piégé.")
            (localized "Closed guard kimura grip" "Garde fermée avec prise kimura")
            (localized "Figure-four grips remove the post so your hips can swing hard."
                "Le grip en clé de bras empêche l’appui et libère le swing des hanches.")
        , sweepEntry "elevator-sweep"
            (localized "Elevator Sweep" "Elevator Sweep")
            (localized "Butterfly-style hook from closed guard that elevates the thigh and twists the hips."
                "Hook façon butterfly depuis la garde fermée qui élève la cuisse et vrille les hanches.")
            (localized "Closed guard to inside hook" "Garde fermée vers hook intérieur")
            (localized "Lift with the hook while pulling sleeve/collar to guide the landing."
                "Lève avec le hook en tirant manche/col pour guider la chute.")
        , sweepEntry "hip-heist-sweep"
            (localized "Hip Heist Sweep" "Hip Heist Sweep")
            (localized "Technical stand-up from closed guard that converts to a fast top position."
                "Relevé technique depuis la garde fermée qui se transforme en top rapide.")
            (localized "Closed guard breaking open" "Garde fermée qui s’ouvre")
            (localized "Plant hand and foot, swing hips outside, then drive into the opponent."
                "Plante main et pied, sors les hanches puis pousse dans l’adversaire.")
        ]
    }


butterflySweepGroup : TechniqueGroup
butterflySweepGroup =
    { id = "sweeps-butterfly"
    , icon = "🦋"
    , title = localized "Butterfly Sweeps" "Renversements butterfly"
    , subtitle = localized "Hook-based tilts, arm-drags, and forward dives." "Basculements sur hooks, arm drags et plongées avant."
    , entries =
        [ sweepEntry "butterfly-basic-sweep"
            (localized "Basic Butterfly Sweep" "Basic Butterfly Sweep")
            (localized "Centerline butterfly sweep using double underhooks or overhooks to tilt the base."
                "Balayage papillon central avec double underhook ou overhook pour basculer la base.")
            (localized "Seated butterfly guard" "Butterfly guard assise")
            (localized "Lift with the inside hook while driving your head past their shoulder."
                "Élève avec le crochet intérieur en passant la tête au-delà de leur épaule.")
        , sweepEntry "arm-drag-butterfly-sweep"
            (localized "Arm Drag to Sweep" "Arm Drag to Sweep")
            (localized "Arm drag exposes the back; if they post, continue the spin to land on top."
                "L’arm drag expose le dos ; s’ils postent, poursuis la rotation pour finir au-dessus.")
            (localized "Butterfly guard arm drag" "Arm drag depuis butterfly guard")
            (localized "Pull the arm across your waist, hook the far hip, and rotate."
                "Tire le bras en travers de la taille, accroche la hanche opposée puis pivote.")
        , sweepEntry "hook-sweep-butterfly"
            (localized "Hook Sweep" "Hook Sweep")
            (localized "Near-side hook loads their hip while the far hook guides them over your shoulder."
                "Le hook proche charge la hanche tandis que l’autre guide au-dessus de ton épaule.")
            (localized "Butterfly guard with double hooks" "Butterfly guard avec double hooks")
            (localized "Kick the hooking leg up as you fall onto your shoulder."
                "Frappe la jambe crochetée vers le haut en tombant sur l’épaule.")
        , sweepEntry "over-under-butterfly-sweep"
            (localized "Over-Under Sweep" "Over-Under Sweep")
            (localized "One underhook, one overhook, chest tight to drive a sideways tilt."
                "Un underhook, un overhook, poitrine collée pour créer une bascule latérale.")
            (localized "Butterfly clinch" "Clinch butterfly")
            (localized "Lift with the underhook knee while steering the head/arm you overhook."
                "Élève avec le genou de l’underhook tout en dirigeant la tête/le bras overhookés.")
        , sweepEntry "reverse-hook-sweep"
            (localized "Reverse Hook Sweep" "Reverse Hook Sweep")
            (localized "Switch the hook outside to sweep away from your normal side."
                "Inverse le hook à l’extérieur pour balayer à l’opposé de ton côté habituel.")
            (localized "Butterfly guard reverse hook" "Butterfly guard avec crochet inversé")
            (localized "Rotate hips, hook the outside thigh, and kick outward."
                "Tourne les hanches, croche la cuisse externe puis donne un coup vers l’extérieur.")
        , sweepEntry "x-guard-entry-sweep"
            (localized "X-Guard Entry Sweep" "X-Guard Entry Sweep")
            (localized "Slide under to X-guard, stretch both legs, and spin them over your head."
                "Glisse en X-guard, étire les deux jambes et fais-les passer au-dessus de toi.")
            (localized "Butterfly guard transitioning to X-guard" "Butterfly guard transition vers X-guard")
            (localized "Inside leg posts on the hip while the outside leg blocks the far knee."
                "La jambe intérieure pousse sur la hanche tandis que l’autre bloque le genou opposé.")
        , sweepEntry "shuck-shoulder-crunch"
            (localized "Shuck Sweep / Shoulder Crunch" "Shuck Sweep / Shoulder Crunch")
            (localized "Shuck the shoulder past your hip, crunch them forward, and topple into mount."
                "Pousse l’épaule au-delà de ta hanche, compresse en avant et bascule en montée.")
            (localized "Butterfly collar tie or overhook" "Butterfly avec collar tie ou overhook")
            (localized "Pull the shoulder to the mat then follow with a forward dive."
                "Amène l’épaule au sol puis poursuis par une plongée vers l’avant.")
        ]
    }


halfGuardSweepGroup : TechniqueGroup
halfGuardSweepGroup =
    { id = "sweeps-half-guard"
    , icon = "🪶"
    , title = localized "Half-Guard Sweeps" "Renversements demi-garde"
    , subtitle = localized "Old school, lockdown, deep-half, and knee-shield chains." "Old school, lockdown, deep half et enchaînements knee shield."
    , entries =
        [ sweepEntry "old-school-sweep"
            (localized "Old School Sweep" "Old School Sweep")
            (localized "Deep underhook plus trapped foot rolling them over their shoulder blades."
                "Underhook profond plus pied piégé qui les fait rouler sur les omoplates.")
            (localized "Half guard with underhook and far foot grip" "Demi-garde avec underhook et prise du pied opposé")
            (localized "Drive off your toes, pull the trapped foot to your hip, and roll."
                "Pousse sur tes appuis, ramène le pied piégé sur ta hanche puis roule.")
        , sweepEntry "electric-chair-sweep"
            (localized "Electric Chair Sweep (Lockdown)" "Electric Chair Sweep (Lockdown)")
            (localized "Lockdown stretch splits their base until they must fall."
                "Le lockdown étire leur base jusqu’à la chute.")
            (localized "Lockdown half guard" "Demi-garde lockdown")
            (localized "Extend the lockdown, scoop the far leg, and finish with a long roll."
                "Étire le lockdown, cueille la jambe opposée puis termine par un roulé long.")
        , sweepEntry "deep-half-guard-sweep"
            (localized "Deep Half Guard Sweep" "Deep Half Guard Sweep")
            (localized "Hide under the hips, connect to the far knee, and tilt them over you."
                "Cache-toi sous les hanches, accroche le genou opposé et renverse-les sur toi.")
            (localized "Deep half guard" "Deep half guard")
            (localized "Lift their ankle like a steering wheel as you roll toward your head."
                "Soulève leur cheville comme un volant en roulant vers ta tête.")
        , sweepEntry "plan-b-sweep"
            (localized "Plan B Sweep" "Plan B Sweep")
            (localized "When they retreat the knee, switch directions and roll away from the whizzer."
                "Quand ils retirent le genou, change de direction et roule à l’opposé du whizzer.")
            (localized "Half guard underhook vs knee retract" "Demi-garde underhook vs retrait du genou")
            (localized "Trap the far leg, turn to your back, and scissor-roll over your shoulders."
                "Piège la jambe opposée, tourne sur le dos puis roule sur les épaules.")
        , sweepEntry "waiter-sweep"
            (localized "Waiter Sweep" "Waiter Sweep")
            (localized "Deep-half variant where you elevate the leg as if serving a tray."
                "Variante deep half où tu élèves la jambe comme un plateau.")
            (localized "Deep half guard under the leg" "Deep half guard sous la jambe")
            (localized "Cup the ankle, drive your forehead into the thigh, and tip them backward."
                "Coupe la cheville, colle le front sur la cuisse et renverse en arrière.")
        , sweepEntry "shaolin-sweep"
            (localized "Shaolin Sweep" "Shaolin Sweep")
            (localized "Classic kneeling half guard that builds to the knee for a powerful tilt."
                "Demi-garde classique qui se relève sur un genou pour une bascule puissante.")
            (localized "Half guard with inside knee posted" "Demi-garde avec genou intérieur posté")
            (localized "Sit up, pinch the knees on the trapped leg, and drive with head pressure."
                "Redresse-toi, pince les genoux sur la jambe piégée et pousse avec la tête.")
        , sweepEntry "underhook-backtake-sweep"
            (localized "Underhook to Back Take / Sweep" "Underhook to Back Take / Sweep")
            (localized "Climb to the back; if they square up, continue the roll for the sweep."
                "Monte au dos ; s’ils se remettent face, poursuis la rotation pour le renversement.")
            (localized "Half guard deep-underhook path" "Trajectoire demi-garde avec underhook profond")
            (localized "Seat-belt or double-under grips collapse their post."
                "Un seatbelt ou double under effondre leurs appuis.")
        , sweepEntry "knee-shield-underhook-sweep"
            (localized "Knee Shield to Underhook Sweep" "Knee Shield to Underhook Sweep")
            (localized "Combine knee shield kuzushi with an underhook dive to tip them."
                "Combine le kuzushi du genou bouclier avec une plongée underhook pour les renverser.")
            (localized "Knee shield half guard" "Demi-garde knee shield")
            (localized "Pull with the shield, swim the underhook, then come up to your knees."
                "Tire avec le shield, nage l’underhook puis relève-toi sur les genoux.")
        ]
    }


deLaRivaSweepGroup : TechniqueGroup
deLaRivaSweepGroup =
    { id = "sweeps-dlr"
    , icon = "🌀"
    , title = localized "De La Riva / Reverse DLR" "Renversements De La Riva / Reverse"
    , subtitle = localized "Tripod, sickle, berimbolo, and balloon-style lifts." "Tripod, sickle, berimbolo et élévations type ballon."
    , entries =
        [ sweepEntry "tripod-sweep"
            (localized "Tripod Sweep" "Tripod Sweep")
            (localized "Foot on hip and ankle grips work together to dump standing opponents."
                "Pied sur la hanche et prise de cheville combinés pour faire tomber un adversaire debout.")
            (localized "De La Riva guard vs standing base" "Garde De La Riva contre une base debout")
            (localized "Push the hip, pull the collar or ankle, then kick the far leg out."
                "Pousse la hanche, tire le col ou la cheville puis fauche la jambe opposée.")
        , sweepEntry "sickle-sweep"
            (localized "Sickle Sweep" "Sickle Sweep")
            (localized "Tripod variation where the outside leg scythes behind the ankle."
                "Variante du tripod où la jambe extérieure fauche derrière la cheville.")
            (localized "De La Riva open guard" "Garde De La Riva ouverte")
            (localized "Switch hooks and swing the sickle leg low to the mat."
                "Change les hooks et fais passer la jambe faucheuse au ras du sol.")
        , sweepEntry "berimbolo-sweep"
            (localized "Berimbolo Sweep" "Berimbolo Sweep")
            (localized "Inverted roll from De La Riva that exposes the back or 50/50."
                "Roulade inversée depuis De La Riva qui expose le dos ou la 50/50.")
            (localized "De La Riva with belt or hip control" "De La Riva avec contrôle ceinture ou hanche")
            (localized "Invert under the far hip while stapling their leg."
                "Inverse-toi sous la hanche opposée en agrafant leur jambe.")
        , sweepEntry "dlr-hook-sweep"
            (localized "De La Riva Hook Sweep" "De La Riva Hook Sweep")
            (localized "Diagonal sweep using sleeve + ankle control with an active hook."
                "Balayage diagonal avec contrôle manche + cheville et hook actif.")
            (localized "Classic De La Riva guard" "De La Riva classique")
            (localized "Kick the hook outward while pulling the sleeve across."
                "Pousse le hook vers l’extérieur en tirant la manche en travers.")
        , sweepEntry "reverse-dlr-sweep"
            (localized "Reverse De La Riva Sweep" "Reverse De La Riva Sweep")
            (localized "Reverse hook wraps inside the thigh to launch forward or backward sweeps."
                "Le hook inversé entoure la cuisse pour lancer des renversements avant ou arrière.")
            (localized "Reverse De La Riva guard" "Reverse De La Riva")
            (localized "Thread the leg deep, control the far sleeve, and twist the hips."
                "Passe la jambe profondément, contrôle la manche opposée et vrille les hanches.")
        , sweepEntry "balloon-sweep"
            (localized "Balloon Sweep" "Balloon Sweep")
            (localized "Load them on top of your shins then catapult them like a balloon."
                "Charge-les sur tes tibias puis catapulte-les comme un ballon.")
            (localized "Open guard with double hooks" "Garde ouverte avec doubles hooks")
            (localized "Kick upward and guide with your grips to float them overhead."
                "Frappe vers le haut et guide avec tes grips pour les faire flotter.")
        ]
    }


spiderLassoSweepGroup : TechniqueGroup
spiderLassoSweepGroup =
    { id = "sweeps-spider-lasso"
    , icon = "🕸️"
    , title = localized "Spider / Lasso / Lapel" "Spider / Lasso / Lapel"
    , subtitle = localized "Gi-based kuzushi using sleeves, lapels, and biceps control." "Kuzushi en kimono avec manches, lapels et contrôle des biceps."
    , entries =
        [ sweepEntry "spider-lasso-sweep"
            (localized "Spider Lasso Sweep" "Spider Lasso Sweep")
            (localized "One foot on the biceps, the other lassoing the arm to pull them sideways."
                "Un pied dans le biceps, l’autre jambe en lasso pour tirer de côté.")
            (localized "Spider + lasso guard" "Garde spider + lasso")
            (localized "Push the biceps, yank the sleeve, and circle the hips for the dump."
                "Pousse le biceps, tire la manche et tourne les hanches pour la bascule.")
        , sweepEntry "double-biceps-sweep"
            (localized "Double Biceps Sweep" "Double Biceps Sweep")
            (localized "Both feet on the biceps stretch them so you can kick into the hips."
                "Les deux pieds sur les biceps les étirent avant de frapper dans les hanches.")
            (localized "Spider guard double sleeves" "Spider guard double manches")
            (localized "Extend both legs, then drop one to off-balance."
                "Étends les deux jambes puis relâche-en une pour déséquilibrer.")
        , sweepEntry "spider-to-x-sweep"
            (localized "Spider to X Sweep" "Spider to X Sweep")
            (localized "Slide under from spider to X-guard and finish with elevation."
                "Glisse de spider vers X-guard puis termine en élévation.")
            (localized "Spider guard transitioning to X-guard" "Spider guard en transition vers X-guard")
            (localized "Thread your shin under the thigh, catch the ankle, and extend."
                "Fais passer ton tibia sous la cuisse, attrape la cheville puis étire.")
        , sweepEntry "worm-guard-sweep"
            (localized "Worm Guard Sweep" "Worm Guard Sweep")
            (localized "Lapel-wrapped leg entanglement that locks their hip for sweeping."
                "Enchevêtrement de jambe avec lapel qui verrouille la hanche pour balayer.")
            (localized "Worm guard lapel wrap" "Worm guard avec lapel enroulé")
            (localized "Feed the lapel around the leg, off-balance, and spin underneath."
                "Passe le lapel autour de la jambe, déséquilibre puis tourne dessous.")
        , sweepEntry "lapel-lasso-sweep"
            (localized "Lapel Lasso Sweep" "Lapel Lasso Sweep")
            (localized "Combine lapel wrap with a lasso to yank diagonally."
                "Combine lapel enroulé et lasso pour tirer en diagonale.")
            (localized "Lapel lasso guard" "Garde lapel + lasso")
            (localized "Stretch the lapel across the back while chopping with the lasso leg."
                "Étire le lapel sur le dos tout en cisaillant avec la jambe lasso.")
        , sweepEntry "collar-sleeve-balloon"
            (localized "Collar Sleeve Balloon Sweep" "Collar Sleeve Balloon Sweep")
            (localized "Collar-sleeve grips lift them high for a floating balloon-style sweep."
                "Grips col/manche qui soulèvent haut pour un sweep type ballon.")
            (localized "Spider / collar-sleeve open guard" "Spider / collar-sleeve en garde ouverte")
            (localized "Kick both legs upward and guide with the collar grip to flip them."
                "Frappe les deux jambes vers le haut et guide avec le grip au col pour les retourner.")
        ]
    }


modernGuardSweepGroup : TechniqueGroup
modernGuardSweepGroup =
    { id = "sweeps-modern"
    , icon = "⚙️"
    , title = localized "Modern Guard Sweeps" "Renversements gardes modernes"
    , subtitle = localized "SLX, X, 50/50, matrix, crab ride, and leg-drag counters." "SLX, X, 50/50, matrix, crab ride et contres sur leg drag."
    , entries =
        [ sweepEntry "single-leg-x-sweep"
            (localized "Single Leg X Sweep" "Single Leg X Sweep")
            (localized "Clamp their leg between your knees, off-balance, and kick the hips."
                "Coince leur jambe entre tes genoux, déséquilibre puis pousse les hanches.")
            (localized "Single Leg X guard" "Single Leg X guard")
            (localized "Lift with the inside foot on the hip while controlling the far heel."
                "Soulève avec le pied intérieur sur la hanche en contrôlant le talon opposé.")
        , sweepEntry "x-guard-sweep"
            (localized "X-Guard Sweep" "X-Guard Sweep")
            (localized "Classic X-guard stretch using crossed hooks to spin upright opponents."
                "Étirement X-guard classique utilisant des hooks croisés pour faire tourner un adversaire debout.")
            (localized "X-guard under a standing base" "X-guard sous une base debout")
            (localized "Extend the bottom leg, drop the top leg to steer, and post on the hips."
                "Étends la jambe basse, relâche la jambe haute pour diriger puis pousse sur les hanches.")
        , sweepEntry "fifty-fifty-sweep"
            (localized "50/50 Sweep" "50/50 Sweep")
            (localized "Symmetrical leg entanglement letting you tip either way while hunting legs."
                "Enchevêtrement symétrique permettant de basculer des deux côtés tout en chassant les jambes.")
            (localized "50/50 guard" "Garde 50/50")
            (localized "Control the far ankle, sit up, and rotate their knee line."
                "Contrôle la cheville opposée, redresse-toi et tourne leur ligne de genou.")
        , sweepEntry "kiss-of-the-dragon"
            (localized "Kiss of the Dragon Sweep" "Kiss of the Dragon Sweep")
            (localized "Reverse De La Riva inversion spinning inside to expose the back."
                "Inversion reverse De La Riva qui tourne à l’intérieur pour exposer le dos.")
            (localized "Reverse De La Riva into matrix tunnel" "Reverse De La Riva vers l’entrée matrix")
            (localized "Thread your leg between theirs, grab the belt, and spin on your shoulders."
                "Glisse ta jambe entre les leurs, attrape la ceinture puis tourne sur tes épaules.")
        , sweepEntry "crab-ride-sweep"
            (localized "Crab Ride Sweep / Back Roll" "Crab Ride Sweep / Back Roll")
            (localized "Crab ride hooks load their hips so you can roll to the back or dump sideways."
                "Les hooks crab ride chargent leurs hanches pour rouler au dos ou basculer latéralement.")
            (localized "Crab ride entries" "Entrées crab ride")
            (localized "Use double hooks behind the knees then roll like a back take."
                "Place des doubles hooks derrière les genoux puis roule comme pour prendre le dos.")
        , sweepEntry "matrix-sweep"
            (localized "Matrix Sweep" "Matrix Sweep")
            (localized "Modern inversion that threads the leg high like a matrix entry."
                "Inversion moderne qui file la jambe en hauteur façon matrix.")
            (localized "Reverse De La Riva with lapel/belt control" "Reverse De La Riva avec contrôle lapel/ceinture")
            (localized "Kick long, grab the far hip, and climb to the back corner."
                "Frappe en longueur, attrape la hanche opposée et grimpe vers l’angle arrière.")
        , sweepEntry "overhead-tornado-sweep"
            (localized "Overhead Sweep (Tornado)" "Overhead Sweep (Tornado)")
            (localized "Load them on both shins then spin overhead Eddie-Bravo style."
                "Charge-les sur tes deux tibias puis fais-les passer au-dessus façon Eddie Bravo.")
            (localized "Half guard / inverted tornado setup" "Setup half guard / tornado inversé")
            (localized "Switch to inverted guard, kick skyward, and roll through."
                "Passe en garde inversée, donne un coup vers le ciel puis roule.")
        , sweepEntry "leg-drag-counter-sweep"
            (localized "Leg Drag Counter Sweep" "Leg Drag Counter Sweep")
            (localized "Time the leg drag attempt to elevate and spin them the other way."
                "Time le leg drag adverse pour les élever et les faire tourner à l’opposé.")
            (localized "Modern open guard vs leg drag" "Open guard moderne vs leg drag")
            (localized "Frame the shoulder, hook the dragged leg, and rotate underneath."
                "Cadre l’épaule, croche la jambe qu’ils tirent puis tourne dessous.")
        , sweepEntry "mantis-guard-sweep"
            (localized "Mantis Guard Sweep" "Mantis Guard Sweep")
            (localized "Sticky shin hooks both of their legs to topple them forward."
                "Le shin collant accroche leurs deux jambes pour les faire tomber vers l’avant.")
            (localized "Mantis guard" "Mantis guard")
            (localized "Clamp the knee line, lift with double inside hooks, and chase the angle."
                "Pince la ligne des genoux, élève avec les deux crochets intérieurs puis attaque l’angle.")
        ]
    }


seatedOpenSweepGroup : TechniqueGroup
seatedOpenSweepGroup =
    { id = "sweeps-seated-open"
    , icon = "💨"
    , title = localized "Seated / Open Guard (No-Gi)" "Garde assise / open guard (No-Gi)"
    , subtitle = localized "Technical stand-ups, tripod variations, and wrestling-style drags." "Relevés techniques, variantes tripod et drags façon lutte."
    , entries =
        [ sweepEntry "situp-technical-standup"
            (localized "Sit-up Sweep (Technical Stand-Up)" "Sit-up Sweep (Relevé technique)")
            (localized "Technical stand-up sweep that uses the inside leg to get back to your feet."
                "Balayage en relevé technique utilisant la jambe intérieure pour te remettre debout.")
            (localized "Seated open guard" "Garde assise ouverte")
            (localized "Post a hand, kick the back leg, and shove the opponent as you stand."
                "Poste une main, balance la jambe arrière puis pousse l’adversaire en te relevant.")
        , sweepEntry "tripod-sickle-nogi"
            (localized "Tripod / Sickle (No-Gi)" "Tripod / Sickle (No-Gi)")
            (localized "No-gi tripod and sickle variations relying on ankle and head control."
                "Variantes tripod et sickle no-gi basées sur le contrôle des chevilles et de la tête.")
            (localized "Seated guard vs standing opponent" "Garde assise contre adversaire debout")
            (localized "Control the ankle, hook behind the knee, and push/pull simultaneously."
                "Contrôle la cheville, croche derrière le genou puis pousse/tire simultanément.")
        , sweepEntry "ankle-pick-sweep"
            (localized "Ankle Pick Sweep" "Ankle Pick Sweep")
            (localized "Reach the ankle while posting on their head to dump them."
                "Attrape la cheville en postant sur leur tête pour les faire tomber.")
            (localized "Open guard wrestling tie" "Open guard avec saisie lutte")
            (localized "Pull the head, step up, and pick the ankle with your free hand."
                "Tire sur la tête, avance puis cueille la cheville avec la main libre.")
        , sweepEntry "collar-head-drag-sweep"
            (localized "Collar Drag / Head Drag" "Collar Drag / Head Drag")
            (localized "Drag pulls them into empty space for back takes or sweeps."
                "Le collar/head drag les entraîne dans le vide pour prendre le dos ou balayer.")
            (localized "Seated guard collar or head tie" "Garde assise avec saisie du col ou de la tête")
            (localized "Sit up, drag diagonally, and shoot your hips behind their leg."
                "Redresse-toi, tire en diagonale puis jette tes hanches derrière leur jambe.")
        , sweepEntry "shin-to-shin-sweep"
            (localized "Shin-to-Shin Sweep" "Shin-to-Shin Sweep")
            (localized "Shin-to-shin entry elevates their leg to tip them sideways."
                "L’entrée shin-to-shin élève leur jambe pour les basculer latéralement.")
            (localized "Shin-to-shin guard" "Garde shin-to-shin")
            (localized "Lift with the shin hook, control the ankle, and slide your hips under."
                "Soulève avec le hook du tibia, contrôle la cheville puis glisse les hanches dessous.")
        , sweepEntry "arm-drag-situp"
            (localized "Arm Drag Sit-Up Sweep" "Arm Drag Sit-Up Sweep")
            (localized "Arm drag connects to a forward-roll style sweep when they square up."
                "L’arm drag enchaîne sur un sweep en roulade avant lorsqu’ils se remettent face.")
            (localized "Seated guard arm drag" "Arm drag depuis garde assise")
            (localized "Drag the arm, plant your free hand, tuck the head, and roll through."
                "Tire le bras, pose la main libre, rentre la tête puis roule.")
        ]
    }


inversionSweepGroup : TechniqueGroup
inversionSweepGroup =
    { id = "sweeps-inverted"
    , icon = "🪜"
    , title = localized "Inverted Positions" "Positions inversées"
    , subtitle = localized "Inverted guard, granby rolls, babybolo, tornado, and truck hooks." "Garde inversée, Granby roll, babybolo, tornado et hooks truck."
    , entries =
        [ sweepEntry "inverted-guard-sweep"
            (localized "Inverted Guard Sweep" "Inverted Guard Sweep")
            (localized "Stay upside down under them to kick their hips over your shoulders."
                "Reste inversé sous eux pour basculer leurs hanches au-dessus de tes épaules.")
            (localized "Inverted guard" "Garde inversée")
            (localized "Frame on their leg, spin on your shoulders, and elevate."
                "Cadre sur leur jambe, tourne sur tes épaules puis élève.")
        , sweepEntry "granby-roll-sweep"
            (localized "Granby Roll Sweep" "Granby Roll Sweep")
            (localized "Granby roll clears grips and uses momentum to sweep."
                "Le Granby roll libère les grips et exploite le momentum pour balayer.")
            (localized "Inverted turtle / granby guard" "Tortue inversée / garde granby")
            (localized "Roll over your shoulders, hook the leg, and continue the spin."
                "Roule sur tes épaules, croche la jambe puis poursuis la rotation.")
        , sweepEntry "babybolo-sweep"
            (localized "Kiss of the Dragon / Babybolo" "Kiss of the Dragon / Babybolo")
            (localized "Babybolo spin from inverted De La Riva ending in a sweep or back take."
                "Spin babybolo depuis De La Riva inversée qui finit en sweep ou au dos.")
            (localized "Inverted De La Riva" "De La Riva inversée")
            (localized "Tuck the knee inside, grab the belt, and spin like a bolo."
                "Rentre le genou à l’intérieur, attrape la ceinture puis tourne comme un bolo.")
        , sweepEntry "tornado-sweep-inverted"
            (localized "Tornado Sweep" "Tornado Sweep")
            (localized "Invert from half guard, load them on your legs, and whip them overhead."
                "Inverse-toi depuis la demi-garde, charge-les sur tes jambes puis projette-les au-dessus.")
            (localized "Inverted half / tornado guard" "Demi-garde inversée / tornado guard")
            (localized "Kick the trapped leg skyward while spinning underneath."
                "Projette la jambe piégée vers le ciel tout en tournant dessous.")
        , sweepEntry "twister-hook-sweep"
            (localized "Twister Hook Sweep" "Twister Hook Sweep")
            (localized "10th Planet twister hook controls the outside leg for rolling sweeps."
                "Le twister hook façon 10th Planet contrôle la jambe externe pour rouler.")
            (localized "Truck / twister hook guard" "Garde truck / twister hook")
            (localized "Shoot the hook behind the knee, lock the hands, and roll through the truck."
                "Glisse le hook derrière le genou, verrouille les mains puis roule via le truck.")
        ]
    }


rubberGuardSweepGroup : TechniqueGroup
rubberGuardSweepGroup =
    { id = "sweeps-rubber-guard"
    , icon = "🧘"
    , title = localized "Rubber Guard Sweeps" "Renversements rubber guard"
    , subtitle = localized "Mission control, Carni, and Chill Dog style attacks." "Attaques Mission Control, Carni et Chill Dog."
    , entries =
        [ sweepEntry "mission-control-sweep"
            (localized "Mission Control Sweep" "Mission Control Sweep")
            (localized "Mission control clamps the head while you open the hip to knock them over."
                "Mission control verrouille la tête pendant que tu ouvres la hanche pour les renverser.")
            (localized "Rubber guard mission control" "Mission control en rubber guard")
            (localized "Release the leg to hook their far hip and sit up to finish."
                "Relâche la jambe pour accrocher la hanche opposée puis redresse-toi pour finir.")
        , sweepEntry "carni-sweep"
            (localized "Carni Sweep" "Carni Sweep")
            (localized "Omoplata-style roll that blends sweep plus submission threats."
                "Roulade type omoplata mêlant sweep et menaces de soumission.")
            (localized "Rubber guard Carni entry" "Entrée Carni en rubber guard")
            (localized "Hip out, thread the leg across the face, and roll for momentum."
                "Sors les hanches, passe la jambe devant le visage puis roule pour générer du momentum.")
        , sweepEntry "new-york-sweep"
            (localized "New York / Chill Dog Sweep" "New York / Chill Dog Sweep")
            (localized "New York/Chill Dog clamps the arm so you can roll onto a flank."
                "New York/Chill Dog pince le bras pour pouvoir rouler sur un flanc.")
            (localized "Rubber guard New York" "Rubber guard New York")
            (localized "Control the elbow, stomp the hips down, and rotate to the top."
                "Contrôle le coude, écrase les hanches puis pivote pour finir au-dessus.")
        ]
    }


guardEntry : String -> LocalizedString -> LocalizedString -> List LocalizedString -> TechniqueEntry
guardEntry =
    techniqueEntry


sweepEntry :
    String
    -> LocalizedString
    -> LocalizedString
    -> LocalizedString
    -> LocalizedString
    -> TechniqueEntry
sweepEntry id name description origin mechanic =
    techniqueEntry id name description
        [ originDetail origin
        , mechanicDetail mechanic
        ]


originDetail : LocalizedString -> LocalizedString
originDetail detail =
    localized ("Origin: " ++ detail.en) ("Origine : " ++ detail.fr)


mechanicDetail : LocalizedString -> LocalizedString
mechanicDetail detail =
    localized ("Mechanic: " ++ detail.en) ("Mécanique : " ++ detail.fr)


gordonVideos : List Types.Video
gordonVideos =
    [ { id = "gordon-adcc-2022"
      , title = "Gordon Ryan vs André Galvão - ADCC 2022 Superfight"
      , url = "https://example.com/video1"
      , type_ = Types.Match
      , date = "2022-09-18"
      , thumbnail = "/images/thumbnails/gordon-adcc-2022.jpg"
      }
    ]


buchechaVideos : List Types.Video
buchechaVideos =
    [ { id = "buchecha-worlds-2019"
      , title = "Buchecha Wins 13th World Title"
      , url = "https://example.com/video2"
      , type_ = Types.Match
      , date = "2019-06-02"
      , thumbnail = "/images/thumbnails/buchecha-worlds.jpg"
      }
    ]


rafaVideos : List Types.Video
rafaVideos =
    [ { id = "rafa-highlight"
      , title = "Rafael Mendes Career Highlights"
      , url = "https://example.com/video3"
      , type_ = Types.Highlight
      , date = "2020-01-15"
      , thumbnail = "/images/thumbnails/rafa-highlight.jpg"
      }
    ]


galvaoVideos : List Types.Video
galvaoVideos =
    [ { id = "galvao-instructional"
      , title = "André Galvão - Passing Concepts"
      , url = "https://example.com/video4"
      , type_ = Types.Instructional
      , date = "2021-03-20"
      , thumbnail = "/images/thumbnails/galvao-instructional.jpg"
      }
    ]


loVideos : List Types.Video
loVideos =
    [ { id = "lo-passing"
      , title = "Leandro Lo Passing Study"
      , url = "https://example.com/video5"
      , type_ = Types.Instructional
      , date = "2021-08-10"
      , thumbnail = "/images/thumbnails/lo-passing.jpg"
      }
    ]


initEvents : Dict String Types.Event
initEvents =
    Dict.union internationalEvents cfjjbEvents


internationalEvents : Dict String Types.Event
internationalEvents =
    Dict.fromList
        [ ( "adcc-2024"
          , { id = "adcc-2024"
            , name = "ADCC World Championship 2024"
            , date = "2024-08-17"
            , location =
                { city = "Las Vegas"
                , state = "Nevada"
                , country = "USA"
                , address = "T-Mobile Arena"
                , coordinates = Just { latitude = 36.1699, longitude = -115.1398 }
                }
            , organization = "ADCC"
            , type_ = Types.Tournament
            , imageUrl = "/images/events/adcc-2024.jpg"
            , description = "The most prestigious no-gi grappling tournament in the world"
            , registrationUrl = Just "https://adcc.com/register"
            , streamUrl = Just "https://flograppling.com"
            , results = Nothing
            , brackets = adccBrackets
            , status = Types.EventUpcoming
            }
          )
        , ( "worlds-2024"
          , { id = "worlds-2024"
            , name = "IBJJF World Championship 2024"
            , date = "2024-06-01"
            , location =
                { city = "Long Beach"
                , state = "California"
                , country = "USA"
                , address = "Walter Pyramid"
                , coordinates = Just { latitude = 33.7866, longitude = -118.1148 }
                }
            , organization = "IBJJF"
            , type_ = Types.Tournament
            , imageUrl = "/images/events/worlds-2024.jpg"
            , description = "The most prestigious gi tournament in Brazilian Jiu-Jitsu"
            , registrationUrl = Just "https://ibjjf.com/register"
            , streamUrl = Just "https://flograppling.com"
            , results = Nothing
            , brackets = worldsBrackets
            , status = Types.EventUpcoming
            }
          )
        ]


adccBrackets : List Types.Bracket
adccBrackets =
    [ { division = "Male"
      , weightClass = Types.SuperHeavy
      , belt = Types.Black
      , competitors = [ "Gordon Ryan", "Felipe Pena", "Nick Rodriguez" ]
      }
    , { division = "Female"
      , weightClass = Types.Feather
      , belt = Types.Black
      , competitors = [ "Ffion Davies", "Beatriz Mesquita" ]
      }
    ]


worldsBrackets : List Types.Bracket
worldsBrackets =
    [ { division = "Male Adult"
      , weightClass = Types.Middle
      , belt = Types.Black
      , competitors = [ "Isaque Bahiense", "Jansen Gomes", "Otavio Sousa" ]
      }
    , { division = "Female Adult"
      , weightClass = Types.Light
      , belt = Types.Black
      , competitors = [ "Tayane Porfirio", "Ana Vieira" ]
      }
    ]


emptyFavorites : Types.Favorites
emptyFavorites =
    { heroes = Set.empty
    , events = Set.empty
    }


defaultUserProfile : String -> Types.UserProfile
defaultUserProfile userId =
    { id = userId
    , username = "Guest"
    , email = ""
    , avatar = Nothing
    , beltLevel = Types.White
    , academy = Nothing
    , startedTraining = "2024-01-01"
    , favoriteHeroes = Set.empty
    , savedEvents = Set.empty
    , trainingGoals = []
    , achievements = []
    , stats =
        { totalSessions = 0
        , totalHours = 0
        , currentStreak = 0
        , longestStreak = 0
        , techniquesLearned = 0
        , favoritePosition = Nothing
        }
    , progress = defaultUserProgress
    }


defaultUserProgress : Types.UserProgress
defaultUserProgress =
    { totalXP = 0
    , currentLevel = 1
    , levelProgress = 0.0
    , beltProgress = 0.0
    , skillTree = Dict.empty
    , techniqueMastery = Dict.empty
    , roadmapProgress = Dict.empty
    , unlockedAchievements = []
    , titles = []
    , badges = []
    , dailyQuests = []
    , weeklyGoals = 
        { goals = []
        , weekStart = Time.millisToPosix 0
        , totalXPTarget = 500
        , currentXP = 0
        }
    , lastActive = Time.millisToPosix 0
    , currentStreak = 0
    , longestStreak = 0
    }


defaultTrainingActions : List Types.TrainingAction
defaultTrainingActions =
    [ { id = "plan-session"
      , title = "Planifie ta session"
      , description = "Choisis un champion et définis tes techniques prioritaires."
      , xp = 50
      , icon = "🧠"
      , status = Types.ActionBacklog
      }
    , { id = "drill-technique"
      , title = "Drill technique"
      , description = "Réalise 3 séries de répétitions contrôlées."
      , xp = 75
      , icon = "🎯"
      , status = Types.ActionBacklog
      }
    , { id = "sparring-focus"
      , title = "Sparring situationnel"
      , description = "Teste la technique contre résistance légère."
      , xp = 100
      , icon = "🤼"
      , status = Types.ActionBacklog
      }
    , { id = "note-feedback"
      , title = "Note insights"
      , description = "Capture l'apprentissage clé dans ton journal."
      , xp = 40
      , icon = "📝"
      , status = Types.ActionBacklog
      }
    , { id = "recover"
      , title = "Récup active"
      , description = "5 minutes de respiration / mobilité pour intégrer."
      , xp = 30
      , icon = "💤"
      , status = Types.ActionBacklog
      }
    ]
