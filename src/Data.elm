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
            , bio = "Gordon Ryan is widely considered the greatest no-gi grappler of all time. Known for his systematic approach and mental warfare, he has dominated ADCC and every major no-gi competition."
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
                , favoritePosition = "Back Control"
                , favoriteSubmission = "Rear Naked Choke"
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
            , bio = "13-time World Champion Marcus 'Buchecha' Almeida is one of the most decorated BJJ athletes ever. Known for his incredible pressure passing and wrestling."
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
                , favoritePosition = "Side Control"
                , favoriteSubmission = "Armbar"
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
            , bio = "6x ADCC Champion and founder of Atos Jiu-Jitsu. André Galvão is known for his complete game and ability to develop world champions."
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
                , favoritePosition = "Mount"
                , favoriteSubmission = "Guillotine"
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
            , bio = "8x World Champion Leandro Lo was known for his explosive passing game and incredible athleticism. A true legend of the sport."
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
                , favoritePosition = "Knee Cut Pass"
                , favoriteSubmission = "Foot Lock"
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
      , nickname = "Aussie Submission Hunter"
      , nationality = "Australia"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.LegLocks
      , bio = "Australian leg lock specialist and co-founder of B-Team Jiu Jitsu. Known for creative entries and polished coaching."
      , titles = [ "ADCC Silver Medalist", "Multiple Polaris Champion" ]
      , favoritePosition = "Inside Sankaku"
      , favoriteSubmission = "Inside Heel Hook"
      }
    , { id = "kade-ruotolo"
      , name = "Kade Ruotolo"
      , nickname = "Kade"
      , nationality = "USA"
      , team = "Ruotolo Brothers / Atos"
      , weight = Types.Light
      , style = Types.Submission
      , bio = "Lightning-fast twin with an endless pace who mixes wrestling, scrambles, and front headlock attacks."
      , titles = [ "ADCC 2022 Lightweight Champion", "ONE Lightweight Submission Grappling Champion" ]
      , favoritePosition = "Front Headlock"
      , favoriteSubmission = "Darce Choke"
      }
    , { id = "tye-ruotolo"
      , name = "Tye Ruotolo"
      , nickname = "Tye"
      , nationality = "USA"
      , team = "Ruotolo Brothers / Atos"
      , weight = Types.Middle
      , style = Types.Balanced
      , bio = "Relentless passing machine who blends judo-style throws with modern leg entanglements."
      , titles = [ "WNO Champion", "ADCC Bronze Medalist" ]
      , favoritePosition = "Knee Slice Headquarters"
      , favoriteSubmission = "Armbar"
      }
    , { id = "nick-rodriguez"
      , name = "Nick Rodriguez"
      , nickname = "Nicky Rod"
      , nationality = "USA"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.SuperHeavy
      , style = Types.Wrestling
      , bio = "New Jersey wrestler turned submission grappler with explosive body-lock passing."
      , titles = [ "2x ADCC Silver Medalist" ]
      , favoritePosition = "Body Lock Half Guard"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "victor-hugo"
      , name = "Victor Hugo"
      , nickname = "Victor"
      , nationality = "Brazil"
      , team = "Six Blades Jiu-Jitsu"
      , weight = Types.UltraHeavy
      , style = Types.Submission
      , bio = "Towering guard player known for mixing modern lapel guards with slick triangles despite his size."
      , titles = [ "IBJJF Absolute Champion", "ADCC Medalist" ]
      , favoritePosition = "Closed Guard"
      , favoriteSubmission = "Triangle Choke"
      }
    , { id = "felipe-pena"
      , name = "Felipe Pena"
      , nickname = "Preguiça"
      , nationality = "Brazil"
      , team = "Gracie Barra"
      , weight = Types.Heavy
      , style = Types.Balanced
      , bio = "One of the few athletes to beat Gordon Ryan in superfights. Dangerous back takes and endurance."
      , titles = [ "ADCC Absolute Champion", "IBJJF World Champion" ]
      , favoritePosition = "Back Control"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "roger-gracie"
      , name = "Roger Gracie"
      , nickname = "Roger"
      , nationality = "United Kingdom"
      , team = "Gracie Barra"
      , weight = Types.Heavy
      , style = Types.Pressure
      , bio = "Considered the greatest gi competitor ever, famous for fundamental mount and collar chokes."
      , titles = [ "10x IBJJF World Champion", "ADCC Absolute Champion" ]
      , favoritePosition = "Mount"
      , favoriteSubmission = "Cross Collar Choke"
      }
    , { id = "lucas-lepri"
      , name = "Lucas Lepri"
      , nickname = "Lepri"
      , nationality = "Brazil"
      , team = "Alliance"
      , weight = Types.Light
      , style = Types.Passing
      , bio = "Precision passer with razor-sharp knee cuts and structured guard passing systems."
      , titles = [ "7x IBJJF World Champion" ]
      , favoritePosition = "Knee Cut Passing"
      , favoriteSubmission = "Bow and Arrow Choke"
      }
    , { id = "mica-galvao"
      , name = "Mica Galvão"
      , nickname = "Mica"
      , nationality = "Brazil"
      , team = "Melqui Galvão Jiu-Jitsu"
      , weight = Types.Feather
      , style = Types.Submission
      , bio = "Prodigy from Manaus blending berimbolos, wrestling, and relentless finishing instincts."
      , titles = [ "IBJJF World Champion", "ADCC Silver Medalist" ]
      , favoritePosition = "Open Guard"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "jt-torres"
      , name = "JT Torres"
      , nickname = "JT"
      , nationality = "USA"
      , team = "Essential BJJ"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "Two-time ADCC champion known for pace, pressure, and tactical mindset."
      , titles = [ "2x ADCC Champion" ]
      , favoritePosition = "Half Guard Top"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "mikey-musumeci"
      , name = "Mikey Musumeci"
      , nickname = "Darth Rigatoni"
      , nationality = "USA"
      , team = "Evolve / ONE"
      , weight = Types.LightFeather
      , style = Types.Guard
      , bio = "Technical mastermind famous for lapel innovations and the Musumeci footlock."
      , titles = [ "5x IBJJF World Champion", "ONE Flyweight Submission Grappling Champion" ]
      , favoritePosition = "Lapel Guard"
      , favoriteSubmission = "Musumeci Footlock"
      }
    , { id = "roberto-cyborg-abreu"
      , name = "Roberto \"Cyborg\" Abreu"
      , nickname = "Cyborg"
      , nationality = "Brazil"
      , team = "Fight Sports"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "Inventor of the tornado guard, blending acrobatic sweeps with crushing top pressure."
      , titles = [ "ADCC Absolute Champion" ]
      , favoritePosition = "Tornado Guard"
      , favoriteSubmission = "Arm Triangle"
      }
    , { id = "nicholas-meregali"
      , name = "Nicholas Meregali"
      , nickname = "Meregali"
      , nationality = "Brazil"
      , team = "New Wave Jiu Jitsu"
      , weight = Types.SuperHeavy
      , style = Types.Pressure
      , bio = "Modern gi and no-gi star combining long-frame guards with crushing collar pressure."
      , titles = [ "IBJJF World Champion", "ADCC Champion" ]
      , favoritePosition = "Collar-and-Sleeve Guard"
      , favoriteSubmission = "Bow and Arrow Choke"
      }
    , { id = "yuri-simoes"
      , name = "Yuri Simões"
      , nickname = "Yuri"
      , nationality = "Brazil"
      , team = "Brasa CTA"
      , weight = Types.MediumHeavy
      , style = Types.Balanced
      , bio = "Triple ADCC champion renowned for raw power, wrestling conversions, and grit."
      , titles = [ "3x ADCC Champion" ]
      , favoritePosition = "Body Lock Passing"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "joao-gabriel-rocha"
      , name = "João Gabriel Rocha"
      , nickname = "João Gabriel"
      , nationality = "Brazil"
      , team = "Double Five"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "Beloved competitor who pairs resilience with heavy top control and cross-face pressure."
      , titles = [ "IBJJF World Medalist", "ADCC Medalist" ]
      , favoritePosition = "Top Half Guard"
      , favoriteSubmission = "Kimura"
      }
    , { id = "kaynan-duarte"
      , name = "Kaynan Duarte"
      , nickname = "Kaynan"
      , nationality = "Brazil"
      , team = "Atos Jiu-Jitsu"
      , weight = Types.Heavy
      , style = Types.Balanced
      , bio = "Versatile champion equally comfortable guard pulling or blasting wrestling takedowns."
      , titles = [ "ADCC Champion", "IBJJF World Champion" ]
      , favoritePosition = "Mount"
      , favoriteSubmission = "Arm Triangle"
      }
    , { id = "isaac-doederlein"
      , name = "Isaac Doederlein"
      , nickname = "Isaac"
      , nationality = "USA"
      , team = "Alliance"
      , weight = Types.Feather
      , style = Types.Guard
      , bio = "Lightweight technician with signature lapel lasso and precise triangles."
      , titles = [ "IBJJF World Champion" ]
      , favoritePosition = "Lapel Lasso Guard"
      , favoriteSubmission = "Triangle Choke"
      }
    , { id = "lachlan-giles"
      , name = "Lachlan Giles"
      , nickname = "Lachlan"
      , nationality = "Australia"
      , team = "Absolute MMA"
      , weight = Types.Middle
      , style = Types.LegLocks
      , bio = "Coach-scientist who shocked ADCC with giant-slaying heel hooks from 50/50."
      , titles = [ "ADCC Absolute Bronze Medalist" ]
      , favoritePosition = "50/50 Guard"
      , favoriteSubmission = "Outside Heel Hook"
      }
    , { id = "rafael-lovato-jr"
      , name = "Rafael Lovato Jr"
      , nickname = "Lovato Jr"
      , nationality = "USA"
      , team = "Lovato Jiu-Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "Legendary American champion with textbook mount pressure and MMA success."
      , titles = [ "IBJJF World Champion", "Bellator Middleweight Champion" ]
      , favoritePosition = "High Mount"
      , favoriteSubmission = "Armbar"
      }
    , { id = "ronaldo-junior"
      , name = "Ronaldo Junior"
      , nickname = "Jacare Jr"
      , nationality = "Brazil"
      , team = "Atos Jiu-Jitsu"
      , weight = Types.Middle
      , style = Types.Passing
      , bio = "Audience favorite for non-stop toreando and cartwheel passing blitzes."
      , titles = [ "IBJJF Pan Champion" ]
      , favoritePosition = "Torreando Passing"
      , favoriteSubmission = "Loop Choke"
      }
    , { id = "tainan-dalpra"
      , name = "Tainan Dalpra"
      , nickname = "Tainan"
      , nationality = "Brazil"
      , team = "Art of Jiu Jitsu"
      , weight = Types.Middle
      , style = Types.Passing
      , bio = "AOJ superstar famed for relentless forward pressure and pristine posture."
      , titles = [ "2x IBJJF World Champion" ]
      , favoritePosition = "Knee Cut Passing"
      , favoriteSubmission = "Collar Choke"
      }
    , { id = "diogo-reis"
      , name = "Diogo \"Baby Shark\" Reis"
      , nickname = "Baby Shark"
      , nationality = "Brazil"
      , team = "Melqui Galvão Jiu-Jitsu"
      , weight = Types.Feather
      , style = Types.Wrestling
      , bio = "High-pace ADCC champion whose chain wrestling blends perfectly with back-take sequences."
      , titles = [ "ADCC 2022 66kg Champion" ]
      , favoritePosition = "Front Headlock"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "ethan-crelinsten"
      , name = "Ethan Crelinsten"
      , nickname = "Ethan"
      , nationality = "Canada"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.Light
      , style = Types.LegLocks
      , bio = "Known for guillotines and back attacks set up from aggressive wrestling."
      , titles = [ "ADCC North American Trials Champion" ]
      , favoritePosition = "Back Control"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "nicky-ryan"
      , name = "Nicky Ryan"
      , nickname = "Nicky"
      , nationality = "USA"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.Light
      , style = Types.Guard
      , bio = "Youngest ADCC competitor at 16, now a polished guard player with vicious triangles."
      , titles = [ "ADCC Trials Champion" ]
      , favoritePosition = "Butterfly Guard"
      , favoriteSubmission = "Triangle Choke"
      }
    , { id = "jozef-chen"
      , name = "Jozef Chen"
      , nickname = "Jozef"
      , nationality = "USA"
      , team = "B-Team Jiu Jitsu"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "Rising technician praised for analytical approach and composure beyond his years."
      , titles = [ "ADCC European Trials Champion" ]
      , favoritePosition = "Closed Guard"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "haisam-rida"
      , name = "Haisam Rida"
      , nickname = "Giraffe"
      , nationality = "Ghana"
      , team = "Carpe Diem"
      , weight = Types.Heavy
      , style = Types.Submission
      , bio = "Fan favorite known for flying submissions and upset victories on the ADCC stage."
      , titles = [ "ADCC Quarterfinalist" ]
      , favoritePosition = "Closed Guard"
      , favoriteSubmission = "Flying Armbar"
      }
    , { id = "giancarlo-bodoni"
      , name = "Giancarlo Bodoni"
      , nickname = "Giancarlo"
      , nationality = "USA"
      , team = "New Wave Jiu Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "John Danaher's latest champion boasting tight arm triangles and methodical passing."
      , titles = [ "ADCC 2022 88kg Champion" ]
      , favoritePosition = "Mount"
      , favoriteSubmission = "Arm Triangle"
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
      , bio = "Trailblazing Welsh champion combining aggressive guard pulls with fearless takedowns."
      , titles = [ "IBJJF World Champion", "ADCC Champion" ]
      , favoritePosition = "Closed Guard"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "helena-crevar"
      , name = "Helena Crevar"
      , nickname = "Helena"
      , nationality = "USA"
      , team = "New Wave Jiu Jitsu"
      , weight = Types.Middle
      , style = Types.Wrestling
      , bio = "Teen phenom with ruthless wrestling pressure and north-south chokes."
      , titles = [ "ADCC Trials Champion" ]
      , favoritePosition = "Body Lock Passing"
      , favoriteSubmission = "North-South Choke"
      }
    , { id = "adele-fornarino"
      , name = "Adele Fornarino"
      , nickname = "Adele"
      , nationality = "Australia"
      , team = "Absolute MMA"
      , weight = Types.Feather
      , style = Types.Guard
      , bio = "Creative Australian guard player known for berimbolos and triangle setups."
      , titles = [ "ADCC Oceania Trials Champion" ]
      , favoritePosition = "De La Riva Guard"
      , favoriteSubmission = "Armbar"
      }
    , { id = "ana-carolina-vieira"
      , name = "Ana Carolina Vieira"
      , nickname = "Baby"
      , nationality = "Brazil"
      , team = "GFTeam"
      , weight = Types.Middle
      , style = Types.Balanced
      , bio = "Multiple-time world champion with patient pressure passing and relentless armbars."
      , titles = [ "IBJJF World Champion" ]
      , favoritePosition = "Mount"
      , favoriteSubmission = "Armbar"
      }
    , { id = "beatriz-mesquita"
      , name = "Beatriz Mesquita"
      , nickname = "Bia"
      , nationality = "Brazil"
      , team = "Gracie Humaitá"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "All-time great with dynamic judo entries, guard passing, and finishing ability."
      , titles = [ "10x IBJJF World Champion", "ADCC Champion" ]
      , favoritePosition = "Closed Guard"
      , favoriteSubmission = "Armbar"
      }
    , { id = "gabrieli-pessanha"
      , name = "Gabrieli Pessanha"
      , nickname = "Gabi"
      , nationality = "Brazil"
      , team = "Infight"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "Modern queen of the absolute division with crushing top pressure and sweeps."
      , titles = [ "IBJJF Grand Slam Champion" ]
      , favoritePosition = "Mount"
      , favoriteSubmission = "Collar Choke"
      }
    , { id = "mayssa-bastos"
      , name = "Mayssa Bastos"
      , nickname = "Mayssa"
      , nationality = "Brazil"
      , team = "Unity Jiu Jitsu"
      , weight = Types.LightFeather
      , style = Types.Guard
      , bio = "Tiny technician famous for berimbolos, matrix entries, and technical finishes."
      , titles = [ "IBJJF World Champion" ]
      , favoritePosition = "Lapel Guard"
      , favoriteSubmission = "Toe Hold"
      }
    , { id = "elisabeth-clay"
      , name = "Elisabeth Clay"
      , nickname = "Liz Clay"
      , nationality = "USA"
      , team = "Ares BJJ"
      , weight = Types.Middle
      , style = Types.Guard
      , bio = "Leg-locking powerhouse with ruthless 50/50 attacks."
      , titles = [ "ADCC Medalist" ]
      , favoritePosition = "50/50 Guard"
      , favoriteSubmission = "Inside Heel Hook"
      }
    , { id = "bianca-basilio"
      , name = "Bianca Basilio"
      , nickname = "Bia Basilio"
      , nationality = "Brazil"
      , team = "Atos Jiu-Jitsu"
      , weight = Types.Feather
      , style = Types.Submission
      , bio = "Explosive athlete with flying armbars and relentless pace."
      , titles = [ "ADCC Champion", "IBJJF World Champion" ]
      , favoritePosition = "Open Guard"
      , favoriteSubmission = "Armbar"
      }
    , { id = "tayane-porfirio"
      , name = "Tayane Porfirio"
      , nickname = "Tayane"
      , nationality = "Brazil"
      , team = "Alliance"
      , weight = Types.UltraHeavy
      , style = Types.Pressure
      , bio = "Gi dominant champion with unstoppable mount and pressure passing."
      , titles = [ "IBJJF Grand Slam Champion" ]
      , favoritePosition = "Mount"
      , favoriteSubmission = "Cross Collar Choke"
      }
    , { id = "luiza-monteiro"
      , name = "Luiza Monteiro"
      , nickname = "Luiza"
      , nationality = "Brazil"
      , team = "Atos Jiu-Jitsu"
      , weight = Types.Light
      , style = Types.Passing
      , bio = "Veteran competitor using nonstop toreando chains to open guards."
      , titles = [ "IBJJF World Champion" ]
      , favoritePosition = "Torreando Passing"
      , favoriteSubmission = "Bow and Arrow Choke"
      }
    , { id = "nathalie-ribeiro"
      , name = "Nathalie Ribeiro"
      , nickname = "Tuco"
      , nationality = "Brazil"
      , team = "Checkmat"
      , weight = Types.Feather
      , style = Types.Guard
      , bio = "Known for creative lasso guards and tight triangle chains."
      , titles = [ "IBJJF World Champion" ]
      , favoritePosition = "Lasso Guard"
      , favoriteSubmission = "Triangle Choke"
      }
    , { id = "brianna-ste-marie"
      , name = "Brianna Ste-Marie"
      , nickname = "Brianna"
      , nationality = "Canada"
      , team = "Renzo Gracie"
      , weight = Types.Light
      , style = Types.Balanced
      , bio = "Canada's top competitor with suffocating closed guard and clinch takedowns."
      , titles = [ "ADCC Silver Medalist" ]
      , favoritePosition = "Closed Guard"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "julia-maele"
      , name = "Julia Maele"
      , nickname = "Julia"
      , nationality = "Norway"
      , team = "Kimura Nova União"
      , weight = Types.Middle
      , style = Types.Wrestling
      , bio = "European standout mixing judo grips with top pressure."
      , titles = [ "IBJJF European Champion" ]
      , favoritePosition = "Top Half Guard"
      , favoriteSubmission = "Arm Triangle"
      }
    , { id = "amy-campo"
      , name = "Amy Campo"
      , nickname = "Amy"
      , nationality = "USA"
      , team = "Zenith Jiu-Jitsu"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "ADCC champion famous for fearless scrambles and back control."
      , titles = [ "ADCC 2022 Champion" ]
      , favoritePosition = "Back Control"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "kendall-reusing"
      , name = "Kendall Reusing"
      , nickname = "Kendall"
      , nationality = "USA"
      , team = "Gracie Barra"
      , weight = Types.UltraHeavy
      , style = Types.Wrestling
      , bio = "Former wrestler translating body-locks into dominant top pressure."
      , titles = [ "ADCC North American Trials Champion" ]
      , favoritePosition = "Body Lock Passing"
      , favoriteSubmission = "Arm Triangle"
      }
    , { id = "danielle-kelly"
      , name = "Danielle Kelly"
      , nickname = "Danielle"
      , nationality = "USA"
      , team = "Silver Fox BJJ"
      , weight = Types.Light
      , style = Types.Submission
      , bio = "ONE Championship star blending aggressive guard play with MMA-ready attacks."
      , titles = [ "ONE Atomweight Submission Grappling Champion" ]
      , favoritePosition = "Closed Guard"
      , favoriteSubmission = "Rear Naked Choke"
      }
    , { id = "tammi-musumeci"
      , name = "Tammi Musumeci"
      , nickname = "Tammi"
      , nationality = "USA"
      , team = "Evolve / Pedigo Submission Fighting"
      , weight = Types.Light
      , style = Types.Guard
      , bio = "Multiple-time world champ with spider guard mastery and fierce competitiveness."
      , titles = [ "IBJJF World Champion" ]
      , favoritePosition = "Spider Guard"
      , favoriteSubmission = "Armbar"
      }
    , { id = "maggie-grindatti"
      , name = "Maggie Grindatti"
      , nickname = "Maggie"
      , nationality = "USA"
      , team = "Fight Sports"
      , weight = Types.MediumHeavy
      , style = Types.Pressure
      , bio = "American standout using heavy top pressure and no-gi experience."
      , titles = [ "IBJJF No-Gi World Champion" ]
      , favoritePosition = "Top Half Guard"
      , favoriteSubmission = "Americana"
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
