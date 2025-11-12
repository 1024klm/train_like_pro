module Data exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import Types
import Time
import Data.CFJJBEvents exposing (cfjjbEvents)


initHeroes : Dict String Types.Hero
initHeroes =
    Dict.fromList
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
            , bio = "ADCC multi-champion and CJI star mastering back control and half-butterfly transitions."
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
                , favoritePosition = "Back control / half-butterfly"
                , favoriteSubmission = "Inside heel hook / RNC"
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
            , bio = "6x World Champion Rafael Mendes revolutionized the modern guard game with his berimbolo and incredible movement. Co-founder of Art of Jiu Jitsu academy."
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
                , favoritePosition = "De La Riva Guard"
                , favoriteSubmission = "Triangle Choke"
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
            ++ championSeedEntries
        )


type alias ChampionSeed =
    { id : String
    , name : String
    , nickname : String
    , nationality : String
    , team : String
    , weight : Types.WeightClass
    , style : Types.FightingStyle
    , bio : String
    , titles : List String
    , favoritePosition : String
    , favoriteSubmission : String
    }


championSeedEntries : List ( String, Types.Hero )
championSeedEntries =
    championSeeds
        |> List.map (\seed -> let hero = championSeedToHero seed in ( hero.id, hero ))


championSeeds : List ChampionSeed
championSeeds =
    menChampionSeeds ++ womenChampionSeeds


womenChampionIds : Set String
womenChampionIds =
    womenChampionSeeds |> List.map .id |> Set.fromList


championSeedToHero : ChampionSeed -> Types.Hero
championSeedToHero seed =
    { id = seed.id
    , name = seed.name
    , nickname = seed.nickname
    , nationality = seed.nationality
    , team = seed.team
    , gender =
        if Set.member seed.id womenChampionIds then
            Types.Female
        else
            Types.Male
    , weight = seed.weight
    , style = seed.style
    , achievements = []
    , imageUrl = "/images/heroes/" ++ seed.id ++ ".jpg"
    , coverImageUrl = "/images/heroes/" ++ seed.id ++ "-cover.jpg"
    , bio = seed.bio
    , record =
        { wins = 0
        , losses = 0
        , draws = 0
        , submissions = 0
        , points = 0
        , advantages = 0
        , titles = seed.titles
        }
    , techniques = []
    , socialMedia = emptySocialMedia
    , videos = []
    , stats =
        { winRate = 0
        , submissionRate = 0
        , averageMatchTime = 0
        , favoritePosition = seed.favoritePosition
        , favoriteSubmission = seed.favoriteSubmission
        }
    }


emptySocialMedia : Types.SocialMedia
emptySocialMedia =
    { instagram = Nothing
    , youtube = Nothing
    , twitter = Nothing
    , website = Nothing
    }


menChampionSeeds : List ChampionSeed
menChampionSeeds =
    [ { id = "craig-jones"
      , name = "Craig Jones"
      , nickname = "Aussie Subs"
      , nationality = "Australia"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.LegLocks
      , bio = "Z-guard and half-butterfly menace, ADCC medalist, and CJI co-founder who steers B-Team."
      , titles = [ "ADCC medalist", "CJI co-founder" ]
      , favoritePosition = "Z-guard / half-butterfly"
      , favoriteSubmission = "Outside heel hook"
      }
    , { id = "kade-ruotolo"
      , name = "Kade Ruotolo"
      , nickname = "Kade"
      , nationality = "USA"
      , team = "Ruotolo Brothers / Atos"
      , weight = Types.Light
      , style = Types.Submission
      , bio = "Front headlock machine who wrestle-ups nonstop toward Darce chains; ADCC champ and CJI -80 kg star."
      , titles = [ "ADCC champion", "CJI -80 kg champion" ]
      , favoritePosition = "Front headlock / wrestle-up"
      , favoriteSubmission = "Darce choke"
      }
    , { id = "tye-ruotolo"
      , name = "Tye Ruotolo"
      , nickname = "Tye"
      , nationality = "USA"
      , team = "Ruotolo Brothers / Atos"
      , weight = Types.Middle
      , style = Types.Balanced
      , bio = "Top-pressure twin famous for relentless back takes, ONE title runs, and ADCC podium scrambles."
      , titles = [ "ADCC medalist", "ONE submission grappling champion" ]
      , favoritePosition = "Top pressure / back takes"
      , favoriteSubmission = "Brabo / Darce choke"
      }
    , { id = "nick-rodriguez"
      , name = "Nick Rodriguez"
      , nickname = "Nicky Rod"
      , nationality = "USA"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.SuperHeavy
      , style = Types.Wrestling
      , bio = "Explosive wrestler with body-lock pressure, double ADCC silver runs, and CJI +80 kg gold."
      , titles = [ "2x ADCC silver medalist", "CJI +80 kg champion" ]
      , favoritePosition = "Body-lock passing / top pressure"
      , favoriteSubmission = "Rear naked choke"
      }
    , { id = "victor-hugo"
      , name = "Victor Hugo"
      , nickname = "Victor"
      , nationality = "Brazil"
      , team = "Six Blades Jiu-Jitsu"
      , weight = Types.UltraHeavy
      , style = Types.Submission
      , bio = "Six Blades heavyweight who mixes modern lapel guard with crushing top control; IBJJF and CJI standout."
      , titles = [ "Multiple IBJJF world titles", "CJI team winner" ]
      , favoritePosition = "Top game / gi-no-gi hybrid guard"
      , favoriteSubmission = "Straight ankle lock / footlocks"
      }
    , { id = "felipe-pena"
      , name = "Felipe Pena"
      , nickname = "Preguiça"
      , nationality = "Brazil"
      , team = "Gracie Barra"
      , weight = Types.Heavy
      , style = Types.Balanced
      , bio = "Back-control specialist and gi passer who owns ADCC 2017 gold plus multiple IBJJF world titles."
      , titles = [ "ADCC 2017 champion", "IBJJF world champion" ]
      , favoritePosition = "Back control / gi passing pressure"
      , favoriteSubmission = "Bow-and-arrow choke / RNC"
      }
    , { id = "roger-gracie"
      , name = "Roger Gracie"
      , nickname = "Roger"
      , nationality = "United Kingdom"
      , team = "Gracie Barra"
      , weight = Types.Heavy
      , style = Types.Pressure
      , bio = "Mount-and-cross-choke icon with unmatched fundamental dominance across gi eras."
      , titles = [ "10x IBJJF world champion", "ADCC absolute champion" ]
      , favoritePosition = "Mount / cross-choke control"
      , favoriteSubmission = "Cross-collar choke"
      }
    , { id = "lucas-lepri"
      , name = "Lucas Lepri"
      , nickname = "Lepri"
      , nationality = "Brazil"
      , team = "Alliance"
      , weight = Types.Light
      , style = Types.Passing
      , bio = "Slim-pass genius controlling gi exchanges with surgical knee cuts and back takes."
      , titles = [ "Multiple IBJJF lightweight world titles" ]
      , favoritePosition = "Slim passing lanes / gi control"
      , favoriteSubmission = "Back takes / collar chokes"
      }
    , { id = "mica-galvao"
      , name = "Mica Galvão"
      , nickname = "Mica"
      , nationality = "Brazil"
      , team = "Melqui Galvão Jiu-Jitsu"
      , weight = Types.Feather
      , style = Types.Submission
      , bio = "All-terrain phenom blending aggression, wrestling, and submission chains."
      , titles = [ "IBJJF world champion", "ADCC medalist" ]
      , favoritePosition = "All-terrain aggression"
      , favoriteSubmission = "Armbar / RNC / ankle attacks"
      }
    , { id = "jt-torres"
      , name = "JT Torres"
      , nickname = "JT"
      , nationality = "USA"
      , team = "Essential BJJ / Atos"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "Back-take tactician and two-time ADCC -77 kg champion with no-gi control systems."
      , titles = [ "ADCC -77 kg champion (x2)" ]
      , favoritePosition = "Back-takes / no-gi control"
      , favoriteSubmission = "Rear naked choke"
      }
    , { id = "mikey-musumeci"
      , name = "Mikey Musumeci"
      , nickname = "Darth Rigatoni"
      , nationality = "USA"
      , team = "Evolve / ONE"
      , weight = Types.LightFeather
      , style = Types.Guard
      , bio = "Guard and entanglement prodigy, 5x IBJJF world champ and ONE title holder."
      , titles = [ "5x IBJJF world champion", "ONE submission grappling champion" ]
      , favoritePosition = "Guard / leg entanglements"
      , favoriteSubmission = "Straight ankle lock (Mikey lock)"
      }
    , { id = "roberto-cyborg-abreu"
      , name = "Roberto \"Cyborg\" Abreu"
      , nickname = "Cyborg"
      , nationality = "Brazil"
      , team = "Fight Sports"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "Tornado-half innovator with HW top pressure, ADCC gold, and IBJJF no-gi dominance."
      , titles = [ "ADCC champion", "IBJJF No-Gi champion" ]
      , favoritePosition = "Tornado half / top pressure"
      , favoriteSubmission = "Kneebar / armbar"
      }
    , { id = "nicholas-meregali"
      , name = "Nicholas Meregali"
      , nickname = "Meregali"
      , nationality = "Brazil"
      , team = "New Wave Jiu Jitsu"
      , weight = Types.SuperHeavy
      , style = Types.Pressure
      , bio = "Gi passer turned no-gi threat, blending collar pressure with back-take chains."
      , titles = [ "IBJJF heavyweight world champion", "ADCC 2022 podium" ]
      , favoritePosition = "Gi passing / back-take hubs"
      , favoriteSubmission = "Bow-and-arrow / RNC"
      }
    , { id = "yuri-simoes"
      , name = "Yuri Simões"
      , nickname = "Yuri"
      , nationality = "Brazil"
      , team = "CTA"
      , weight = Types.MediumHeavy
      , style = Types.Balanced
      , bio = "Wrestling-fueled pressure player, double ADCC champ in -88/-99 divisions."
      , titles = [ "2x ADCC champion (-88 / -99)" ]
      , favoritePosition = "Wrestling pressure chains"
      , favoriteSubmission = "Guillotine / kneebar"
      }
    , { id = "joao-gabriel-rocha"
      , name = "João Gabriel Rocha"
      , nickname = "João Gabriel"
      , nationality = "Brazil"
      , team = "Double Five"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "Heavyweight pressure player with IBJJF podiums and ADCC finals experience."
      , titles = [ "IBJJF podium mainstay", "ADCC finalist" ]
      , favoritePosition = "Pressure HW top game"
      , favoriteSubmission = "Collar chokes"
      }
    , { id = "kaynan-duarte"
      , name = "Kaynan Duarte"
      , nickname = "Kaynan"
      , nationality = "Brazil"
      , team = "Atos Jiu-Jitsu"
      , weight = Types.Heavy
      , style = Types.Balanced
      , bio = "Dynamic top player with leg entanglements, double ADCC champ plus IBJJF titles."
      , titles = [ "ADCC 2019 champion", "ADCC 2022 champion", "IBJJF world champion" ]
      , favoritePosition = "Dynamic top / leg entanglements"
      , favoriteSubmission = "Outside heel hook / armbar"
      }
    , { id = "isaac-doederlein"
      , name = "Isaac Doederlein"
      , nickname = "Isaac"
      , nationality = "USA"
      , team = "Alliance / Dream Art"
      , weight = Types.Feather
      , style = Types.Guard
      , bio = "Berimbolo-savvy guard player and IBJJF featherweight world champ."
      , titles = [ "IBJJF featherweight world champion" ]
      , favoritePosition = "Berimbolo / guard work"
      , favoriteSubmission = "Triangle / armbar"
      }
    , { id = "lachlan-giles"
      , name = "Lachlan Giles"
      , nickname = "Lachlan"
      , nationality = "Australia"
      , team = "Absolute MMA"
      , weight = Types.Middle
      , style = Types.LegLocks
      , bio = "ADCC giant-killer mixing half guard traps with analytical leg locks."
      , titles = [ "ADCC 2019 absolute bronze" ]
      , favoritePosition = "Half-guard / leg locks"
      , favoriteSubmission = "Inside heel hook"
      }
    , { id = "rafael-lovato-jr"
      , name = "Rafael Lovato Jr"
      , nickname = "Lovato Jr"
      , nationality = "USA"
      , team = "Lovato Jiu-Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "Mount-and-collar-choke artisan, IBJJF world champ and Bellator MMA titleholder."
      , titles = [ "IBJJF world champion", "Bellator middleweight champion" ]
      , favoritePosition = "Mount / collar-choke setups"
      , favoriteSubmission = "Armbar / triangle"
      }
    , { id = "ronaldo-junior"
      , name = "Ronaldo Junior"
      , nickname = "Jacare Jr"
      , nationality = "Brazil"
      , team = "Atos Jiu-Jitsu"
      , weight = Types.Middle
      , style = Types.Passing
      , bio = "Explosive passer delivering toreando blitzes, IBJJF titles, and ADCC trials wins."
      , titles = [ "IBJJF champion", "ADCC trials winner" ]
      , favoritePosition = "Explosive passing sequences"
      , favoriteSubmission = "Collar chokes"
      }
    , { id = "tainan-dalpra"
      , name = "Tainan Dalpra"
      , nickname = "Tainan"
      , nationality = "Brazil"
      , team = "Art of Jiu Jitsu"
      , weight = Types.Middle
      , style = Types.Passing
      , bio = "Mount-and-back-on-top artist with multiple IBJJF middleweight crowns."
      , titles = [ "Multiple IBJJF middleweight world titles" ]
      , favoritePosition = "Mount / back from guard"
      , favoriteSubmission = "Cross-collar choke"
      }
    , { id = "diogo-reis"
      , name = "Diogo \"Baby Shark\" Reis"
      , nickname = "Baby Shark"
      , nationality = "Brazil"
      , team = "Melqui Galvão Jiu-Jitsu"
      , weight = Types.Feather
      , style = Types.Wrestling
      , bio = "Scramble-heavy ADCC -66 kg champion who chains wrestling into back takes."
      , titles = [ "ADCC 2022 -66 kg champion" ]
      , favoritePosition = "Scramble pace / wrestling"
      , favoriteSubmission = "Guillotine / RNC"
      }
    , { id = "ethan-crelinsten"
      , name = "Ethan Crelinsten"
      , nickname = "Ethan"
      , nationality = "Canada"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.Light
      , style = Types.LegLocks
      , bio = "Front headlock hunter, ADCC vet, and EBI/WNO threat with guillotine traps."
      , titles = [ "ADCC veteran", "EBI & WNO standout" ]
      , favoritePosition = "Front headlock systems"
      , favoriteSubmission = "Guillotine"
      }
    , { id = "nicky-ryan"
      , name = "Nicky Ryan"
      , nickname = "Nicky"
      , nationality = "USA"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.Light
      , style = Types.Guard
      , bio = "Leg-lock system prodigy with WNO wins and recurring ADCC appearances."
      , titles = [ "ADCC veteran", "WNO winner" ]
      , favoritePosition = "Leg-lock system control"
      , favoriteSubmission = "Inside heel hook"
      }
    , { id = "jozef-chen"
      , name = "Jozef Chen"
      , nickname = "Jozef"
      , nationality = "USA"
      , team = "New Wave Jiu Jitsu"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "Systematic leg-locker who emerged at ADCC 2024 and shines at CJI."
      , titles = [ "ADCC 2024 breakout", "CJI finalist" ]
      , favoritePosition = "Systematic leg locks / top"
      , favoriteSubmission = "Heel hook"
      }
    , { id = "haisam-rida"
      , name = "Haisam Rida"
      , nickname = "Giraffe"
      , nationality = "Ghana"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.Heavy
      , style = Types.Submission
      , bio = "Long-limbed thrower famed for the ADCC flying armbar on Cyborg."
      , titles = [ "ADCC 2022 highlight maker" ]
      , favoritePosition = "Long-limb top / throws"
      , favoriteSubmission = "Flying armbar / armbar"
      }
    , { id = "giancarlo-bodoni"
      , name = "Giancarlo Bodoni"
      , nickname = "Giancarlo"
      , nationality = "USA"
      , team = "New Wave Jiu Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "Back-control and wrestling-up ace, ADCC 2022 -88 kg gold medalist."
      , titles = [ "ADCC 2022 -88 kg champion" ]
      , favoritePosition = "Back control / wrestling-up"
      , favoriteSubmission = "Rear naked choke"
      }
    ]


womenChampionSeeds : List ChampionSeed
womenChampionSeeds =
    [ { id = "ffion-davies"
      , name = "Ffion Davies"
      , nickname = "Ffion"
      , nationality = "Wales"
      , team = "Essential BJJ"
      , weight = Types.Light
      , style = Types.Guard
      , bio = "Takedown-to-back specialist, ADCC 2022 champ and IBJJF world queen."
      , titles = [ "ADCC 2022 champion", "IBJJF world champion" ]
      , favoritePosition = "Takedown to back control"
      , favoriteSubmission = "Rear naked / bow-and-arrow choke"
      }
    , { id = "helena-crevar"
      , name = "Helena Crevar"
      , nickname = "Helena"
      , nationality = "USA"
      , team = "B-Team / New Wave"
      , weight = Types.Middle
      , style = Types.Wrestling
      , bio = "Leg-entanglement teen phenom with heel-hook finishes and CJI/ADCC trials runs."
      , titles = [ "CJI open champion", "ADCC trials standout" ]
      , favoritePosition = "Leg entanglements / top pressure"
      , favoriteSubmission = "Heel hook"
      }
    , { id = "adele-fornarino"
      , name = "Adele Fornarino"
      , nickname = "Adele"
      , nationality = "Australia"
      , team = "Absolute MMA"
      , weight = Types.Feather
      , style = Types.Guard
      , bio = "Front-headlock and leg-entry threat from Oceania with repeated ADCC trials wins."
      , titles = [ "ADCC trials champion", "CJI contender" ]
      , favoritePosition = "Front headlock / leg entries"
      , favoriteSubmission = "Heel hook / guillotine"
      }
    , { id = "ana-carolina-vieira"
      , name = "Ana Carolina Vieira"
      , nickname = "Baby"
      , nationality = "Brazil"
      , team = "GFTeam"
      , weight = Types.Middle
      , style = Types.Balanced
      , bio = "Gi passageuse patient with devastating back control and bow-and-arrow finishes."
      , titles = [ "IBJJF world champion", "ADCC medalist" ]
      , favoritePosition = "Gi passing / back control"
      , favoriteSubmission = "Bow-and-arrow choke"
      }
    , { id = "beatriz-mesquita"
      , name = "Beatriz Mesquita"
      , nickname = "Bia"
      , nationality = "Brazil"
      , team = "Gracie Humaitá"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "All-rounder legend mixing guard, passing, and finishing instincts."
      , titles = [ "10x+ IBJJF world champion", "ADCC 2019 champion" ]
      , favoritePosition = "Complete guard / passer blend"
      , favoriteSubmission = "Armbar"
      }
    , { id = "gabrieli-pessanha"
      , name = "Gabrieli Pessanha"
      , nickname = "Gabi"
      , nationality = "Brazil"
      , team = "Infight"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "HW powerhouse dominating IBJJF opens with mount pressure and collar chokes."
      , titles = [ "IBJJF open-class dominator" ]
      , favoritePosition = "HW pressure / mount"
      , favoriteSubmission = "Cross-collar choke"
      }
    , { id = "mayssa-bastos"
      , name = "Mayssa Bastos"
      , nickname = "Mayssa"
      , nationality = "Brazil"
      , team = "Art of Jiu-Jitsu"
      , weight = Types.LightFeather
      , style = Types.Guard
      , bio = "Roosterweight guard prodigy famed for berimbolos and straight ankle finishes."
      , titles = [ "IBJJF roosterweight world champion", "ADCC medalist" ]
      , favoritePosition = "Light guard / berimbolo"
      , favoriteSubmission = "Straight ankle lock"
      }
    , { id = "elisabeth-clay"
      , name = "Elisabeth Clay"
      , nickname = "Liz Clay"
      , nationality = "USA"
      , team = "Ares BJJ"
      , weight = Types.Middle
      , style = Types.Guard
      , bio = "Leg-lock specialist with ruthless ashi garami chains."
      , titles = [ "IBJJF No-Gi world champion", "ADCC podium" ]
      , favoritePosition = "Leg locks / ashi systems"
      , favoriteSubmission = "Heel hook / toe hold"
      }
    , { id = "bianca-basilio"
      , name = "Bianca Basilio"
      , nickname = "Bia Basilio"
      , nationality = "Brazil"
      , team = "Almeida JJ"
      , weight = Types.Feather
      , style = Types.Submission
      , bio = "Aggressive passer known for toe holds, ankle locks, and ADCC 2019 gold."
      , titles = [ "ADCC 2019 champion", "IBJJF world medalist" ]
      , favoritePosition = "Aggressive guard passing"
      , favoriteSubmission = "Toe hold / ankle lock"
      }
    , { id = "tayane-porfirio"
      , name = "Tayane Porfirio"
      , nickname = "Tayane"
      , nationality = "Brazil"
      , team = "Alliance"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "Power passer with unstoppable mount dominance across IBJJF absolutes."
      , titles = [ "IBJJF absolute champion" ]
      , favoritePosition = "Power passing / HW mount"
      , favoriteSubmission = "Mount chokes"
      }
    , { id = "luiza-monteiro"
      , name = "Luiza Monteiro"
      , nickname = "Luiza"
      , nationality = "Brazil"
      , team = "Atos Jiu-Jitsu"
      , weight = Types.Light
      , style = Types.Passing
      , bio = "Gi passer blending sweeps, torreando chains, and armbar threats."
      , titles = [ "Multi-time IBJJF world champion" ]
      , favoritePosition = "Gi passer / sweep chains"
      , favoriteSubmission = "Armbar / kimura"
      }
    , { id = "nathalie-ribeiro"
      , name = "Nathalie Ribeiro"
      , nickname = "Tuco"
      , nationality = "Brazil"
      , team = "Checkmat"
      , weight = Types.Feather
      , style = Types.Guard
      , bio = "Triangle-focused guard player with IBJJF and no-gi accolades."
      , titles = [ "IBJJF world champion", "IBJJF no-gi champion" ]
      , favoritePosition = "Triangle-heavy guard"
      , favoriteSubmission = "Triangle / loop choke"
      }
    , { id = "brianna-ste-marie"
      , name = "Brianna Ste-Marie"
      , nickname = "Brianna"
      , nationality = "Canada"
      , team = "BTT Canada"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "Front-headlock and back-taking terror, ADCC 2022 silver medalist."
      , titles = [ "ADCC 2022 silver medalist" ]
      , favoritePosition = "Front headlock / back takes"
      , favoriteSubmission = "Rear naked choke / guillotine"
      }
    , { id = "julia-maele"
      , name = "Julia Maele"
      , nickname = "Julia"
      , nationality = "Norway"
      , team = "Kimura Nova União"
      , weight = Types.Middle
      , style = Types.Wrestling
      , bio = "Pressure-and-wrestling specialist with ADCC experience and European titles."
      , titles = [ "ADCC veteran", "IBJJF European champion" ]
      , favoritePosition = "Pressure wrestling entries"
      , favoriteSubmission = "Rear naked choke"
      }
    , { id = "amy-campo"
      , name = "Amy Campo"
      , nickname = "Amy"
      , nationality = "USA"
      , team = "Zenith Jiu-Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "Back-control heavy ADCC 2022 champion with fearless scrambles."
      , titles = [ "ADCC 2022 champion" ]
      , favoritePosition = "Back control / top pressure"
      , favoriteSubmission = "Rear naked choke"
      }
    , { id = "kendall-reusing"
      , name = "Kendall Reusing"
      , nickname = "Kendall"
      , nationality = "USA"
      , team = "Gracie Barra"
      , weight = Types.UltraHeavy
      , style = Types.Wrestling
      , bio = "Wrestler turned grappler using body locks, ADCC bronzes, and no-gi titles."
      , titles = [ "ADCC bronze medalist", "IBJJF No-Gi champion" ]
      , favoritePosition = "Wrestling / top control"
      , favoriteSubmission = "Head-arm choke"
      }
    , { id = "danielle-kelly"
      , name = "Danielle Kelly"
      , nickname = "Danielle"
      , nationality = "USA"
      , team = "Silver Fox BJJ"
      , weight = Types.Light
      , style = Types.Submission
      , bio = "ONE submission grappling champion blending back takes and heel hooks."
      , titles = [ "ONE atomweight submission champion" ]
      , favoritePosition = "Back & leg entries"
      , favoriteSubmission = "Rear naked choke / heel hook"
      }
    , { id = "tammi-musumeci"
      , name = "Tammi Musumeci"
      , nickname = "Tammi"
      , nationality = "USA"
      , team = "Evolve / PSF"
      , weight = Types.Light
      , style = Types.Guard
      , bio = "Guard ace with multiple IBJJF world titles and trademark armbars."
      , titles = [ "IBJJF world champion", "ONE athlete" ]
      , favoritePosition = "Guard / armbar setups"
      , favoriteSubmission = "Armbar"
      }
    , { id = "maggie-grindatti"
      , name = "Maggie Grindatti"
      , nickname = "Maggie"
      , nationality = "USA"
      , team = "Fight Sports"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "Top-pressure heavyweight collecting IBJJF and no-gi podiums."
      , titles = [ "IBJJF / No-Gi podium finisher" ]
      , favoritePosition = "Top pressure / HW control"
      , favoriteSubmission = "Chokes / armbar"
      }
    ]

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


guardEntry : String -> LocalizedString -> LocalizedString -> List LocalizedString -> TechniqueEntry
guardEntry =
    techniqueEntry


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
