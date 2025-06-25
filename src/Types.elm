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
    | Progress


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


type alias TrainingSession =
    { id : String
    , date : String
    , heroId : HeroId
    , duration : Int
    , techniques : List String
    , notes : String
    , sessionType : SessionType
    }


type SessionType
    = Technique
    | Drilling
    | Sparring
    | Competition
    | OpenMat


type alias TechniqueProgress =
    { techniqueId : String
    , name : String
    , heroId : HeroId
    , category : String
    , status : TechniqueStatus
    , lastPracticed : Maybe String
    , notes : String
    }


type TechniqueStatus
    = NotStarted
    | Learning
    | InDrilling
    | Mastered


type alias Achievement =
    { id : String
    , name : String
    , description : String
    , icon : String
    , unlockedAt : Maybe String
    , category : AchievementCategory
    }


type AchievementCategory
    = Consistency
    | TechniqueCategory
    | Milestone
    | HeroCategory


type alias NewSessionForm =
    { heroId : Maybe HeroId
    , duration : String
    , sessionType : SessionType
    , techniques : String
    , notes : String
    , date : String
    }


type alias FrontendModel =
    { key : Key
    , localStorage : LocalStorage
    , clientId : String
    , selectedHero : Maybe HeroId
    , activeTab : Tab
    , heroes : Dict String Hero
    , learningPhases : List LearningPhase
    , trainingSessions : List TrainingSession
    , techniqueProgress : List TechniqueProgress
    , achievements : List Achievement
    , showAddSessionModal : Bool
    , newSessionForm : NewSessionForm
    }


type alias BackendModel =
    { userSessions : Dict String UserSession
    }


type alias UserSession =
    { clientId : String
    , selectedHero : Maybe HeroId
    , visitCount : Int
    , trainingSessions : List TrainingSession
    , techniqueProgress : List TechniqueProgress
    , achievements : List Achievement
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
    | ToggleAddSessionModal
    | UpdateNewSessionForm NewSessionForm
    | SaveTrainingSession
    | DeleteTrainingSession String
    | UpdateTechniqueStatus String TechniqueStatus
    | AddTechniqueNote String String


type ToBackend
    = TrackHeroSelection (Maybe HeroId)
    | GetUserSession
    | SaveSession TrainingSession
    | DeleteSession String
    | UpdateTechnique String TechniqueStatus
    | SaveTechniqueNote String String


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = SessionData UserSession
    | SessionSaved TrainingSession
    | SessionDeleted String
    | TechniqueUpdated String TechniqueStatus
    | AchievementUnlocked Achievement