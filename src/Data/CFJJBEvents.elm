module Data.CFJJBEvents exposing (cfjjbEvents)

{-| French BJJ Competitions from CFJJB
Data sourced from https://cfjjb.com/competitions/calendrier-competitions

Last updated: 2025-10-11
-}

import Dict exposing (Dict)
import Types exposing (..)


cfjjbEvents : Dict String Event
cfjjbEvents =
    Dict.fromList
        -- OCTOBER 2025
        [ ( "cfjjb-paris-oct-4-gi"
          , { id = "cfjjb-paris-oct-4-gi"
            , name = "Open Région Île de France"
            , date = "2025-10-04"
            , location =
                { city = "Paris"
                , state = "Île-de-France"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Tournament
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Compétition régionale de Jiu-Jitsu Brésilien en kimono pour l'Île-de-France"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-paris-oct-5-nogi"
          , { id = "cfjjb-paris-oct-5-nogi"
            , name = "Open Région Île de France NO GI"
            , date = "2025-10-05"
            , location =
                { city = "Paris"
                , state = "Île-de-France"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Tournament
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Compétition régionale de Jiu-Jitsu Brésilien sans kimono (NO GI) pour l'Île-de-France"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-paris-oct-5-kids"
          , { id = "cfjjb-paris-oct-5-kids"
            , name = "Open Région Île de France Kids"
            , date = "2025-10-05"
            , location =
                { city = "Paris"
                , state = "Île-de-France"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Camp
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Compétition régionale de Jiu-Jitsu Brésilien pour enfants en kimono"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-paris-oct-5-kids-nogi"
          , { id = "cfjjb-paris-oct-5-kids-nogi"
            , name = "Open Région Île de France Kids NO GI"
            , date = "2025-10-05"
            , location =
                { city = "Paris"
                , state = "Île-de-France"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Camp
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Compétition régionale de Jiu-Jitsu Brésilien pour enfants sans kimono (NO GI)"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-nantes-oct-11-gi"
          , { id = "cfjjb-nantes-oct-11-gi"
            , name = "Open de Nantes"
            , date = "2025-10-11"
            , location =
                { city = "Nantes"
                , state = "Pays de la Loire"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Tournament
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Open de Nantes - Compétition de Jiu-Jitsu Brésilien en kimono"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-nantes-oct-11-nogi"
          , { id = "cfjjb-nantes-oct-11-nogi"
            , name = "Open de Nantes NO GI"
            , date = "2025-10-11"
            , location =
                { city = "Nantes"
                , state = "Pays de la Loire"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Tournament
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Open de Nantes - Compétition de Jiu-Jitsu Brésilien sans kimono (NO GI)"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-nantes-oct-11-kids"
          , { id = "cfjjb-nantes-oct-11-kids"
            , name = "Open de Nantes Kids"
            , date = "2025-10-11"
            , location =
                { city = "Nantes"
                , state = "Pays de la Loire"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Camp
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Open de Nantes - Compétition de Jiu-Jitsu Brésilien pour enfants en kimono"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-nantes-oct-11-kids-nogi"
          , { id = "cfjjb-nantes-oct-11-kids-nogi"
            , name = "Open de Nantes Kids NO GI"
            , date = "2025-10-11"
            , location =
                { city = "Nantes"
                , state = "Pays de la Loire"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Camp
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Open de Nantes - Compétition de Jiu-Jitsu Brésilien pour enfants sans kimono (NO GI)"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-toulouse-oct-18-gi"
          , { id = "cfjjb-toulouse-oct-18-gi"
            , name = "Open de Toulouse"
            , date = "2025-10-18"
            , location =
                { city = "Saint Orens de Gameville"
                , state = "Occitanie"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Tournament
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Open de Toulouse - Compétition de Jiu-Jitsu Brésilien en kimono (18-19 octobre)"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        , ( "cfjjb-toulouse-oct-18-nogi"
          , { id = "cfjjb-toulouse-oct-18-nogi"
            , name = "Open de Toulouse NO GI"
            , date = "2025-10-18"
            , location =
                { city = "Saint Orens de Gameville"
                , state = "Occitanie"
                , country = "France"
                , address = ""
                , coordinates = Nothing
                }
            , organization = "CFJJB"
            , type_ = Tournament
            , imageUrl = "/images/events/cfjjb-default.jpg"
            , description = "Open de Toulouse - Compétition de Jiu-Jitsu Brésilien sans kimono (NO GI) - (18-19 octobre)"
            , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
            , streamUrl = Nothing
            , results = Nothing
            , brackets = []
            , status = EventUpcoming
            }
          )
        ]
