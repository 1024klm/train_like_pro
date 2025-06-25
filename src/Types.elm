module Types exposing (..)

import Browser exposing (UrlRequest)
import Dict exposing (Dict)
import Browser.Navigation exposing (Key)
import I18n exposing (Language, Translation)
import LocalStorage exposing (LocalStorage)
import Theme exposing (UserPreference)
import Url exposing (Url)


type alias UserConfig =
    { t : Translation
    , isDark : Bool
    }


type HeroId
    = Gordon
    | Buchecha
    | Rafael
    | Leandro
    | Galvao


type Tab
    = Overview
    | Heroes
    | Plan


type alias Hero =
    { name : String
    , nickname : String
    , color : String
    , lightColor : String
    , specialties : List String
    , philosophy : String
    , keyPrinciples : List String
    , trainingApproach : TrainingApproach
    , weeklyPlan : List String
    }


type alias TrainingApproach =
    { technique : String
    , drilling : String
    , sparring : String
    , study : String
    }


type alias LearningPhase =
    { phase : String
    , icon : String
    , focus : String
    , goals : List String
    }


type alias FrontendModel =
    { key : Key
    , localStorage : LocalStorage
    , clientId : String
    , selectedHero : Maybe HeroId
    , activeTab : Tab
    , heroes : Dict String Hero
    , learningPhases : List LearningPhase
    }


type alias BackendModel =
    { userSessions : Dict String UserSession
    }


type alias UserSession =
    { clientId : String
    , selectedHero : Maybe HeroId
    , visitCount : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | ReceivedLocalStorage LocalStorage
    | ChangeLanguage Language
    | ChangeTheme UserPreference
    | SelectHero (Maybe HeroId)
    | SetActiveTab Tab


type ToBackend
    = TrackHeroSelection (Maybe HeroId)
    | GetUserSession


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = SessionData UserSession