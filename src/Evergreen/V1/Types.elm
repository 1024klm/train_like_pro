module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V1.I18n
import Evergreen.V1.LocalStorage
import Evergreen.V1.Theme
import Set
import Time
import Url


type WeightClass
    = Rooster
    | LightFeather
    | Feather
    | Light
    | Middle
    | MediumHeavy
    | Heavy
    | SuperHeavy
    | UltraHeavy


type FightingStyle
    = Guard
    | Passing
    | LegLocks
    | Wrestling
    | Balanced
    | Submission
    | Pressure


type HeroFilter
    = AllHeroes
    | ByWeight WeightClass
    | ByNationality String
    | ByStyle FightingStyle


type EventsFilter
    = UpcomingEvents
    | PastEvents
    | AllEvents


type Route
    = Home
    | Dashboard
    | HeroesRoute (Maybe HeroFilter)
    | HeroDetail String
    | Academies (Maybe String)
    | AcademyDetail String
    | Events EventsFilter
    | EventDetail String
    | Training
    | TrainingView
    | RoadmapView String
    | StylePath String
    | TechniqueLibrary
    | Progress
    | Profile
    | NotFound


type alias UserConfig =
    { t : Evergreen.V1.I18n.Translations
    , isDark : Bool
    , language : Evergreen.V1.I18n.Language
    }


type EventType
    = Tournament
    | SuperFight
    | Seminar
    | Camp


type alias DateRange =
    { start : String
    , end : String
    }


type alias Filters =
    { heroFilter : Maybe HeroFilter
    , academyLocation : Maybe String
    , eventType : Maybe EventType
    , dateRange : Maybe DateRange
    }


type AchievementCategory
    = ConsistencyAchievement
    | TechniqueAchievement
    | MilestoneAchievement
    | HeroAchievement
    | SocialAchievement


type alias Achievement =
    { id : String
    , name : String
    , description : String
    , icon : String
    , unlockedAt : Maybe String
    , category : AchievementCategory
    , points : Int
    }


type alias CompetitionRecord =
    { wins : Int
    , losses : Int
    , draws : Int
    , submissions : Int
    , points : Int
    , advantages : Int
    , titles : List String
    }


type TechniqueCategory
    = GuardTechnique
    | PassingTechnique
    | TakedownTechnique
    | SubmissionTechnique
    | EscapeTechnique
    | SweepTechnique


type Difficulty
    = Beginner
    | Intermediate
    | DifficultyAdvanced
    | Expert


type MasteryLevel
    = NotStarted
    | Learning
    | Practicing
    | Proficient
    | Advanced
    | Mastered


type alias Technique =
    { id : String
    , name : String
    , category : TechniqueCategory
    , difficulty : Difficulty
    , description : String
    , keyDetails : List String
    , videoUrl : Maybe String
    , xpValue : Int
    , prerequisites : List String
    , masteryLevel : MasteryLevel
    , relatedFighters : List String
    }


type alias SocialMedia =
    { instagram : Maybe String
    , youtube : Maybe String
    , twitter : Maybe String
    , website : Maybe String
    }


type VideoType
    = Match
    | Instructional
    | Interview
    | Highlight


type alias Video =
    { id : String
    , title : String
    , url : String
    , type_ : VideoType
    , date : String
    , thumbnail : String
    }


type alias HeroStats =
    { winRate : Float
    , submissionRate : Float
    , averageMatchTime : Float
    , favoritePosition : String
    , favoriteSubmission : String
    }


type alias Hero =
    { id : String
    , name : String
    , nickname : String
    , nationality : String
    , team : String
    , weight : WeightClass
    , style : FightingStyle
    , achievements : List Achievement
    , imageUrl : String
    , coverImageUrl : String
    , bio : String
    , record : CompetitionRecord
    , techniques : List Technique
    , socialMedia : SocialMedia
    , videos : List Video
    , stats : HeroStats
    }


type alias Coordinates =
    { latitude : Float
    , longitude : Float
    }


type alias Location =
    { city : String
    , state : String
    , country : String
    , address : String
    , coordinates : Maybe Coordinates
    }


type ProgramLevel
    = BeginnerProgram
    | IntermediateProgram
    | AdvancedProgram
    | CompetitionProgram
    | KidsProgram


type alias Program =
    { id : String
    , name : String
    , level : ProgramLevel
    , description : String
    , duration : String
    , price : Maybe Float
    }


type DayOfWeek
    = Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday


type alias ClassSchedule =
    { dayOfWeek : DayOfWeek
    , time : String
    , duration : Int
    , className : String
    , instructor : String
    }


type alias Academy =
    { id : String
    , name : String
    , location : Location
    , headCoach : String
    , established : Int
    , description : String
    , imageUrl : String
    , website : Maybe String
    , socialMedia : SocialMedia
    , notableMembers : List String
    , programs : List Program
    , schedule : List ClassSchedule
    }


type alias MatchResult =
    { matchId : String
    , division : String
    , round : String
    , competitor1 : String
    , competitor2 : String
    , winner : String
    , method : String
    , time : Maybe String
    }


type BeltLevel
    = White
    | Blue
    | Purple
    | Brown
    | Black


type alias Bracket =
    { division : String
    , weightClass : WeightClass
    , belt : BeltLevel
    , competitors : List String
    }


type EventStatus
    = EventUpcoming
    | EventLive
    | EventCompleted
    | EventCancelled


type alias Event =
    { id : String
    , name : String
    , date : String
    , location : Location
    , organization : String
    , type_ : EventType
    , imageUrl : String
    , description : String
    , registrationUrl : Maybe String
    , streamUrl : Maybe String
    , results : Maybe (List MatchResult)
    , brackets : List Bracket
    , status : EventStatus
    }


type SessionFocus
    = TechniqueFocus
    | DrillingFocus
    | SparringFocus
    | ConditioningFocus
    | CompetitionPrep


type alias SessionPlan =
    { dayNumber : Int
    , focus : SessionFocus
    , warmup : String
    , technique : List String
    , drilling : String
    , sparring : String
    , cooldown : String
    , duration : Int
    }


type alias WeekPlan =
    { weekNumber : Int
    , theme : String
    , sessions : List SessionPlan
    , notes : String
    }


type alias TrainingPlan =
    { id : String
    , name : String
    , heroId : String
    , duration : Int
    , level : Difficulty
    , goals : List String
    , weeks : List WeekPlan
    , created : String
    , progress : Float
    }


type alias TechniqueLog =
    { techniqueId : String
    , repetitions : Int
    , quality : Int
    , partner : Maybe String
    , notes : String
    , xpEarned : Int
    }


type SessionType
    = TechniqueSession
    | DrillingSession
    | SparringSession
    | CompetitionSession
    | OpenMatSession
    | PrivateSession


type MoodRating
    = Frustrated
    | Neutral
    | Good
    | Excellent
    | FlowState


type EnergyLevel
    = Exhausted
    | Tired
    | Normal
    | Energetic
    | PeakPerformance


type alias TrainingSession =
    { id : String
    , date : Time.Posix
    , planId : Maybe String
    , duration : Int
    , techniques : List TechniqueLog
    , notes : String
    , sessionType : SessionType
    , rating : Maybe Int
    , completed : Bool
    , xpEarned : Int
    , mood : MoodRating
    , energy : EnergyLevel
    }


type alias UserStats =
    { totalSessions : Int
    , totalHours : Float
    , currentStreak : Int
    , longestStreak : Int
    , techniquesLearned : Int
    , favoritePosition : Maybe String
    }


type alias SubSkillProgress =
    { name : String
    , level : Int
    , mastery : Float
    }


type alias SkillProgress =
    { skillId : String
    , name : String
    , level : Int
    , currentXP : Int
    , xpToNext : Int
    , subSkills : Dict.Dict String SubSkillProgress
    }


type alias TechniqueNote =
    { date : Time.Posix
    , content : String
    , quality : Int
    }


type alias TechniqueMastery =
    { techniqueId : String
    , name : String
    , repetitions : Int
    , successfulReps : Int
    , sparringSuccess : Int
    , lastPracticed : Time.Posix
    , mastery : MasteryLevel
    , notes : List TechniqueNote
    , xpEarned : Int
    }


type alias RoadmapProgress =
    { roadmapId : String
    , startedAt : Time.Posix
    , completedNodes : Set.Set String
    , currentNode : Maybe String
    , totalXPEarned : Int
    , completionPercentage : Float
    }


type Rarity
    = Common
    | Rare
    | Epic
    | Legendary


type alias PlayerTitle =
    { id : String
    , name : String
    , description : String
    , icon : String
    , rarity : Rarity
    , equipped : Bool
    }


type BadgeCategory
    = TechniqueBadge
    | ConsistencyBadge
    | CompetitionBadge
    | SocialBadge
    | SpecialBadge


type alias Badge =
    { id : String
    , name : String
    , description : String
    , icon : String
    , category : BadgeCategory
    , unlockedAt : Time.Posix
    }


type QuestType
    = DailyDrill String
    | TechniqueQuest String
    | SparringQuest
    | ConsistencyQuest
    | StudyQuest


type alias Quest =
    { id : String
    , title : String
    , description : String
    , type_ : QuestType
    , progress : Float
    , target : Int
    , xpReward : Int
    , completed : Bool
    , expiresAt : Time.Posix
    }


type MeasurableGoal
    = RepetitionGoal Int Int
    | TimeGoal Int Int
    | SuccessRateGoal Float Float
    | TechniqueGoal String Int
    | CustomGoal String


type alias WeeklyGoal =
    { id : String
    , description : String
    , measurable : MeasurableGoal
    , progress : Float
    , completed : Bool
    , xpReward : Int
    }


type alias WeeklyGoals =
    { goals : List WeeklyGoal
    , weekStart : Time.Posix
    , totalXPTarget : Int
    , currentXP : Int
    }


type alias UserProgress =
    { totalXP : Int
    , currentLevel : Int
    , levelProgress : Float
    , beltProgress : Float
    , skillTree : Dict.Dict String SkillProgress
    , techniqueMastery : Dict.Dict String TechniqueMastery
    , roadmapProgress : Dict.Dict String RoadmapProgress
    , unlockedAchievements : List String
    , titles : List PlayerTitle
    , badges : List Badge
    , dailyQuests : List Quest
    , weeklyGoals : WeeklyGoals
    , lastActive : Time.Posix
    , currentStreak : Int
    , longestStreak : Int
    }


type alias UserProfile =
    { id : String
    , username : String
    , email : String
    , avatar : Maybe String
    , beltLevel : BeltLevel
    , academy : Maybe String
    , startedTraining : String
    , favoriteHeroes : Set.Set String
    , favoriteAcademies : Set.Set String
    , savedEvents : Set.Set String
    , trainingGoals : List String
    , achievements : List Achievement
    , stats : UserStats
    , progress : UserProgress
    }


type alias Favorites =
    { heroes : Set.Set String
    , academies : Set.Set String
    , events : Set.Set String
    }


type NodeType
    = ConceptNode
    | TechniqueNode
    | DrillNode
    | SparringNode
    | TestNode


type alias Position =
    { x : Int
    , y : Int
    }


type alias NodeContent =
    { title : String
    , description : String
    , videoUrl : Maybe String
    , estimatedTime : Int
    , xpReward : Int
    , tips : List String
    , commonMistakes : List String
    }


type NodeStatus
    = NodeLocked
    | NodeAvailable
    | NodeInProgress Int
    | NodeCompleted
    | NodeMastered


type alias RoadmapNode =
    { id : String
    , type_ : NodeType
    , position : Position
    , content : NodeContent
    , status : NodeStatus
    , requiredForNext : List String
    }


type alias NodeConnection =
    { from : String
    , to : String
    }


type alias TechniqueRoadmap =
    { id : String
    , name : String
    , slug : String
    , description : String
    , hero : String
    , difficulty : Difficulty
    , estimatedWeeks : Int
    , prerequisites : List String
    , nodes : List RoadmapNode
    , connections : List NodeConnection
    }


type alias ActiveSession =
    { startTime : Time.Posix
    , techniques : List TechniqueLog
    , currentTechnique : Maybe String
    , totalXP : Int
    , notes : String
    }


type alias ModalState =
    { sessionModal : Bool
    , heroDetailModal : Maybe String
    , shareModal : Maybe String
    , filterModal : Bool
    }


type NotificationType
    = Success
    | Error
    | Info
    | Warning


type alias Notification =
    { id : String
    , type_ : NotificationType
    , message : String
    , timestamp : String
    }


type alias XPAnimation =
    { amount : Int
    , startTime : Time.Posix
    , position : Position
    }


type alias AnimationState =
    { heroCards : Bool
    , pageTransition : Bool
    , scrollProgress : Float
    , xpAnimation : Maybe XPAnimation
    , levelUpAnimation : Bool
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , route : Route
    , localStorage : Evergreen.V1.LocalStorage.LocalStorage
    , userConfig : UserConfig
    , clientId : String
    , mobileMenuOpen : Bool
    , searchQuery : String
    , activeFilters : Filters
    , heroes : Dict.Dict String Hero
    , academies : Dict.Dict String Academy
    , events : Dict.Dict String Event
    , trainingPlans : Dict.Dict String TrainingPlan
    , trainingSessions : List TrainingSession
    , userProfile : Maybe UserProfile
    , favorites : Favorites
    , userProgress : UserProgress
    , followChampionPlan : Bool
    , roadmaps : Dict.Dict String TechniqueRoadmap
    , activeRoadmap : Maybe String
    , activeSession : Maybe ActiveSession
    , sessionTimer : Int
    , loadingStates : Dict.Dict String Bool
    , modals : ModalState
    , notifications : List Notification
    , animations : AnimationState
    }


type alias SessionId =
    String


type alias ClientId =
    String


type alias Session =
    { id : SessionId
    , clientId : ClientId
    , userProfile : Maybe UserProfile
    , lastActivity : Time.Posix
    , favorites : Favorites
    }


type alias Analytics =
    { pageViews : Dict.Dict String Int
    , heroViews : Dict.Dict String Int
    , searchQueries : List String
    , popularTechniques : Dict.Dict String Int
    }


type alias BackendModel =
    { sessions : Dict.Dict SessionId Session
    , heroes : Dict.Dict String Hero
    , academies : Dict.Dict String Academy
    , events : Dict.Dict String Event
    , userProfiles : Dict.Dict String UserProfile
    , analytics : Analytics
    }


type FavoriteType
    = HeroFavorite
    | AcademyFavorite
    | EventFavorite


type ModalType
    = SessionModal
    | HeroModal String
    | ShareModal String
    | FilterModal
    | TechniqueSelectionModal


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | ReceivedLocalStorage Evergreen.V1.LocalStorage.LocalStorage
    | NavigateTo Route
    | ToggleMobileMenu
    | FocusMobileToggle
    | TrapFocus
        { firstId : String
        , lastId : String
        }
    | UpdateSearchQuery String
    | ApplyFilter HeroFilter
    | ClearFilters
    | ChangeLanguage Evergreen.V1.I18n.Language
    | ChangeTheme Evergreen.V1.Theme.UserPreference
    | ToggleFavorite FavoriteType String
    | Login String String
    | Logout
    | UpdateProfile UserProfile
    | SelectHero String
    | LoadHeroVideos String
    | PlayVideo Video
    | SelectAcademy String
    | ContactAcademy String
    | SelectEvent String
    | RegisterForEvent String
    | StartTrainingPlan String
    | SaveTrainingSession TrainingSession
    | UpdateSessionProgress String Float
    | RateSession String Int
    | StartSession
    | EndSession
    | LogTechnique TechniqueLog
    | IncrementReps String
    | DecrementReps String
    | SetQuality String Int
    | QuickSuccess Int
    | CompleteQuest String
    | ClaimAchievement String
    | SelectRoadmap String
    | SelectNode String
    | CompleteNode String
    | AnimateXP Int Position
    | AnimateLevelUp
    | UpdateSessionTimer Time.Posix
    | OpenModal ModalType
    | CloseModal
    | ShowNotification NotificationType String
    | DismissNotification String
    | ScrollToSection String
    | ToggleFollowChampion Bool
    | AnimationTick Time.Posix


type ToBackend
    = GetInitialData
    | SaveFavorites Favorites
    | TrackPageView Route
    | SearchHeroes String
    | GetHeroDetail String
    | GetAcademyDetail String
    | GetEventDetail String
    | SaveUserProfile UserProfile
    | SaveTrainingData TrainingSession
    | GetAnalytics
    | SaveProgress UserProgress
    | SaveTechniqueLog TechniqueLog
    | CompleteQuestBackend String
    | UnlockAchievement String
    | GetRoadmaps
    | UpdateRoadmapProgress String RoadmapProgress


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected SessionId ClientId
    | ClientDisconnected SessionId
    | UpdateAnalytics


type ToFrontend
    = InitialDataReceived
        { heroes : Dict.Dict String Hero
        , academies : Dict.Dict String Academy
        , events : Dict.Dict String Event
        , roadmaps : Dict.Dict String TechniqueRoadmap
        , userProgress : UserProgress
        }
    | HeroDetailReceived Hero
    | AcademyDetailReceived Academy
    | EventDetailReceived Event
    | FavoritesSaved Favorites
    | UserProfileSaved UserProfile
    | TrainingDataSaved TrainingSession
    | AnalyticsReceived Analytics
    | NotificationReceived Notification
    | ProgressUpdated UserProgress
    | XPEarned Int
    | LevelUp Int
    | AchievementUnlocked Achievement
    | QuestCompleted Quest
    | RoadmapProgressUpdated RoadmapProgress
