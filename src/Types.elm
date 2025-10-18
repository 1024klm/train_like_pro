module Types exposing (..)

import Browser exposing (UrlRequest)
import Dict exposing (Dict)
import Set exposing (Set)
import Browser.Navigation exposing (Key)
import I18n exposing (Language, Translations)
import LocalStorage exposing (LocalStorage)
import Theme exposing (UserPreference)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, (</>), (<?>))
import Url.Parser.Query as Query
import Time


-- USER CONFIGURATION

type alias UserConfig =
    { t : Translations
    , isDark : Bool
    , language : Language
    }


-- ROUTING

type Route
    = Home
    | Dashboard
    | HeroesRoute (Maybe HeroFilter)
    | HeroDetail String
    | Events EventsFilter
    | EventDetail String
    | Training
    | TrainingView
    | RoadmapView String
    | StylePath String -- New: Path based on fighter style
    | TechniqueLibrary
    | Progress
    | Profile
    | SignUpPage
    | LoginPage
    | NotFound


type HeroFilter
    = AllHeroes
    | ByWeight WeightClass
    | ByNationality String
    | ByStyle FightingStyle


type EventsFilter
    = UpcomingEvents
    | PastEvents
    | AllEvents


-- HERO DATA

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


type alias CompetitionRecord =
    { wins : Int
    , losses : Int
    , draws : Int
    , submissions : Int
    , points : Int
    , advantages : Int
    , titles : List String
    }


type alias HeroStats =
    { winRate : Float
    , submissionRate : Float
    , averageMatchTime : Float
    , favoritePosition : String
    , favoriteSubmission : String
    }


type alias Technique =
    { id : String
    , name : String
    , category : TechniqueCategory
    , difficulty : Difficulty
    , description : String
    , keyDetails : List String
    , videoUrl : Maybe String
    , xpValue : Int -- XP gagné par pratique
    , prerequisites : List String -- IDs des techniques requises
    , masteryLevel : MasteryLevel -- Nouveau: niveau de maîtrise
    , relatedFighters : List String -- Combattants qui utilisent cette technique
    }


type alias WeeklyGoal =
    { id : String
    , description : String
    , measurable : MeasurableGoal
    , progress : Float
    , completed : Bool
    , xpReward : Int
    }


type MeasurableGoal
    = RepetitionGoal Int Int -- current/target
    | TimeGoal Int Int -- minutes current/target
    | SuccessRateGoal Float Float
    | TechniqueGoal String Int -- technique ID, target reps
    | CustomGoal String


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


type alias SocialMedia =
    { instagram : Maybe String
    , youtube : Maybe String
    , twitter : Maybe String
    , website : Maybe String
    }


type alias Video =
    { id : String
    , title : String
    , url : String
    , type_ : VideoType
    , date : String
    , thumbnail : String
    }


type VideoType
    = Match
    | Instructional
    | Interview
    | Highlight


-- LOCATION DATA

type alias Location =
    { city : String
    , state : String
    , country : String
    , address : String
    , coordinates : Maybe Coordinates
    }


type alias Coordinates =
    { latitude : Float
    , longitude : Float
    }


-- EVENT DATA

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


type EventType
    = Tournament
    | SuperFight
    | Seminar
    | Camp


type EventStatus
    = EventUpcoming
    | EventLive
    | EventCompleted
    | EventCancelled


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


type alias Bracket =
    { division : String
    , weightClass : WeightClass
    , belt : BeltLevel
    , competitors : List String
    }


type BeltLevel
    = White
    | Blue
    | Purple
    | Brown
    | Black


-- TRAINING DATA

type alias TrainingPlan =
    { id : String
    , name : String
    , heroId : String
    , duration : Int -- weeks
    , level : Difficulty
    , goals : List String
    , weeks : List WeekPlan
    , created : String
    , progress : Float
    }


type alias WeekPlan =
    { weekNumber : Int
    , theme : String
    , sessions : List SessionPlan
    , notes : String
    }


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


type SessionFocus
    = TechniqueFocus
    | DrillingFocus
    | SparringFocus
    | ConditioningFocus
    | CompetitionPrep


type alias TrainingSession =
    { id : String
    , date : Time.Posix
    , planId : Maybe String
    , duration : Int -- minutes
    , techniques : List TechniqueLog
    , notes : String
    , sessionType : SessionType
    , rating : Maybe Int
    , completed : Bool
    , xpEarned : Int -- Total XP de la session
    , mood : MoodRating
    , energy : EnergyLevel
    }


type alias TechniqueLog =
    { techniqueId : String
    , repetitions : Int
    , quality : Int -- 1-5 stars
    , partner : Maybe String
    , notes : String
    , xpEarned : Int
    }


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


type SessionType
    = TechniqueSession
    | DrillingSession
    | SparringSession
    | CompetitionSession
    | OpenMatSession
    | PrivateSession


type alias Achievement =
    { id : String
    , name : String
    , description : String
    , icon : String
    , unlockedAt : Maybe String
    , category : AchievementCategory
    , points : Int
    }


type AchievementCategory
    = ConsistencyAchievement
    | TechniqueAchievement
    | MilestoneAchievement
    | HeroAchievement
    | SocialAchievement


-- USER DATA

type alias UserProfile =
    { id : String
    , username : String
    , email : String
    , avatar : Maybe String
    , beltLevel : BeltLevel
    , academy : Maybe String
    , startedTraining : String
    , favoriteHeroes : Set String
    , savedEvents : Set String
    , trainingGoals : List String
    , achievements : List Achievement
    , stats : UserStats
    , progress : UserProgress -- NOUVEAU: Progression gamifiée
    }


type alias UserStats =
    { totalSessions : Int
    , totalHours : Float
    , currentStreak : Int
    , longestStreak : Int
    , techniquesLearned : Int
    , favoritePosition : Maybe String
    }


-- GAMIFICATION DATA

type alias UserProgress =
    { -- XP & Levels
      totalXP : Int
    , currentLevel : Int -- 1-100
    , levelProgress : Float -- 0.0 to 1.0
    , beltProgress : Float -- 0.0 to 1.0
    
      -- Skills & Techniques
    , skillTree : Dict String SkillProgress
    , techniqueMastery : Dict String TechniqueMastery
    , roadmapProgress : Dict String RoadmapProgress
    
      -- Achievements & Stats
    , unlockedAchievements : List String
    , titles : List PlayerTitle
    , badges : List Badge
    
      -- Daily/Weekly
    , dailyQuests : List Quest
    , weeklyGoals : WeeklyGoals
    , lastActive : Time.Posix
    , currentStreak : Int -- Jours consécutifs d'entraînement
    , longestStreak : Int -- Record de streak
    }


type alias SkillProgress =
    { skillId : String
    , name : String -- "Guard", "Passing", "Takedowns"
    , level : Int -- 1-10
    , currentXP : Int
    , xpToNext : Int
    , subSkills : Dict String SubSkillProgress
    }


type alias SubSkillProgress =
    { name : String
    , level : Int
    , mastery : Float
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


-- Fighter Style Paths (Gordon Ryan, Mikey Galvao, etc.)

type alias FighterStylePath =
    { id : String
    , fighterName : String -- "Gordon Ryan", "Mikey Galvao", etc.
    , styleDescription : String
    , signature : String -- "King of leg locks", "Berimbolo master"
    , techniques : List String -- IDs des techniques
    , roadmap : TechniqueRoadmap
    , estimatedTime : Int -- Semaines pour maîtriser
    , difficulty : Difficulty
    }


type alias FighterTrainingPlan =
    { id : String
    , userId : String
    , activePaths : List String -- Fighter style paths actifs
    , weeklySchedule : WeeklyTrainingSchedule
    , techniquesToPractice : List PlannedTechnique
    , completedTechniques : Set String
    , currentFocus : Maybe String -- Technique ID en focus cette semaine
    }


type alias WeeklyTrainingSchedule =
    { monday : Maybe TrainingSessionPlan
    , tuesday : Maybe TrainingSessionPlan
    , wednesday : Maybe TrainingSessionPlan
    , thursday : Maybe TrainingSessionPlan
    , friday : Maybe TrainingSessionPlan
    , saturday : Maybe TrainingSessionPlan
    , sunday : Maybe TrainingSessionPlan
    }


type alias TrainingSessionPlan =
    { techniques : List String -- Technique IDs
    , duration : Int -- Minutes
    , type_ : SessionType
    , notes : String
    }


type alias PlannedTechnique =
    { techniqueId : String
    , scheduledDate : Time.Posix
    , repetitions : Int
    , completed : Bool
    , xpEarned : Int
    }


type alias TechniqueNote =
    { date : Time.Posix
    , content : String
    , quality : Int -- 1-5 stars
    }


type alias PlayerTitle =
    { id : String
    , name : String -- "Guard Specialist", "Submission Hunter"
    , description : String
    , icon : String
    , rarity : Rarity
    , equipped : Bool
    }


type alias Badge =
    { id : String
    , name : String
    , description : String
    , icon : String
    , category : BadgeCategory
    , unlockedAt : Time.Posix
    }


type BadgeCategory
    = TechniqueBadge
    | ConsistencyBadge
    | CompetitionBadge
    | SocialBadge
    | SpecialBadge


type Rarity
    = Common
    | Rare
    | Epic
    | Legendary


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


type QuestType
    = DailyDrill String -- "Complete 50 armbar reps"
    | TechniqueQuest String
    | SparringQuest
    | ConsistencyQuest
    | StudyQuest -- Watch videos


type alias WeeklyGoals =
    { goals : List WeeklyGoal
    , weekStart : Time.Posix
    , totalXPTarget : Int
    , currentXP : Int
    }


-- ROADMAP DATA

type alias TechniqueRoadmap =
    { id : String
    , name : String
    , slug : String
    , description : String
    , hero : String -- Champion associé
    , difficulty : Difficulty
    , estimatedWeeks : Int
    , prerequisites : List String
    , nodes : List RoadmapNode
    , connections : List NodeConnection
    }


type alias RoadmapNode =
    { id : String
    , type_ : NodeType
    , position : Position
    , content : NodeContent
    , status : NodeStatus
    , requiredForNext : List String
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
    , estimatedTime : Int -- minutes
    , xpReward : Int
    , tips : List String
    , commonMistakes : List String
    }


type NodeStatus
    = NodeLocked
    | NodeAvailable
    | NodeInProgress Int -- Pourcentage
    | NodeCompleted
    | NodeMastered


type alias NodeConnection =
    { from : String
    , to : String
    }


type alias RoadmapProgress =
    { roadmapId : String
    , startedAt : Time.Posix
    , completedNodes : Set String
    , currentNode : Maybe String
    , totalXPEarned : Int
    , completionPercentage : Float
    }


-- FRONTEND MODEL

type alias FrontendModel =
    { key : Key
    , url : Url
    , route : Route
    , localStorage : LocalStorage
    , userConfig : UserConfig
    , clientId : String
    
    -- Navigation
    , mobileMenuOpen : Bool
    , searchQuery : String
    , activeFilters : Filters
    
    -- Data
    , heroes : Dict String Hero
    , events : Dict String Event
    , trainingPlans : Dict String TrainingPlan
    , trainingSessions : List TrainingSession
    
    -- User
    , userProfile : Maybe UserProfile
    , favorites : Favorites
    , userProgress : UserProgress -- Progression gamifiée
    
    -- Roadmaps
    , roadmaps : Dict String TechniqueRoadmap
    , activeRoadmap : Maybe String
    
    -- Training Session Active
    , activeSession : Maybe ActiveSession
    , sessionTimer : Int -- secondes
    
    -- UI State
    , loadingStates : Dict String Bool
    , modals : ModalState
    , notifications : List Notification
    , animations : AnimationState
    , claimedPlanItems : Set String
    }


type alias Filters =
    { heroFilter : Maybe HeroFilter
    , academyLocation : Maybe String
    , eventType : Maybe EventType
    , dateRange : Maybe DateRange
    }


type alias DateRange =
    { start : String
    , end : String
    }


type alias Favorites =
    { heroes : Set String
    , events : Set String
    }


type alias ModalState =
    { sessionModal : Bool
    , heroDetailModal : Maybe String
    , shareModal : Maybe String
    , filterModal : Bool
    }


type alias AnimationState =
    { heroCards : Bool
    , pageTransition : Bool
    , scrollProgress : Float
    , xpAnimation : Maybe XPAnimation
    , levelUpAnimation : Bool
    }


type alias XPAnimation =
    { amount : Int
    , startTime : Time.Posix
    , position : Position
    }


type alias ActiveSession =
    { startTime : Time.Posix
    , techniques : List TechniqueLog
    , currentTechnique : Maybe String
    , totalXP : Int
    , notes : String
    }


type alias Notification =
    { id : String
    , type_ : NotificationType
    , message : String
    , timestamp : String
    }


type NotificationType
    = Success
    | Error
    | Info
    | Warning


-- BACKEND MODEL

type alias BackendModel =
    { sessions : Dict SessionId Session
    , heroes : Dict String Hero
    , events : Dict String Event
    , userProfiles : Dict String UserProfile
    , analytics : Analytics
    }


type alias Session =
    { id : SessionId
    , clientId : ClientId
    , userProfile : Maybe UserProfile
    , lastActivity : Time.Posix
    , favorites : Favorites
    }


type alias SessionId = String
type alias ClientId = String


type alias Analytics =
    { pageViews : Dict String Int
    , heroViews : Dict String Int
    , searchQueries : List String
    , popularTechniques : Dict String Int
    }


-- MESSAGES

type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | ReceivedLocalStorage LocalStorage
    
    -- Navigation
    | NavigateTo Route
    | ToggleMobileMenu
    | FocusMobileToggle
    | TrapFocus { firstId : String, lastId : String }
    | UpdateSearchQuery String
    | ApplyFilter HeroFilter
    | ClearFilters
    
    -- User Actions
    | ChangeLanguage Language
    | ChangeTheme UserPreference
    | ToggleFavorite FavoriteType String
    | Login String String
    | Logout
    | UpdateProfile UserProfile
    
    -- Heroes
    | SelectHero String
    | LoadHeroVideos String
    | PlayVideo Video

    -- Events
    | SelectEvent String
    | RegisterForEvent String
    
    -- Training
    | StartTrainingPlan String
    | SaveTrainingSession TrainingSession
    | UpdateSessionProgress String Float
    | RateSession String Int
    
    -- Gamification
    | StartSession
    | EndSession
    | LogTechnique TechniqueLog
    | IncrementReps String
    | DecrementReps String
    | SetQuality String Int
    | CompleteQuest String
    | ClaimAchievement String
    | SelectRoadmap String
    | SelectNode String
    | CompleteNode String
    | AnimateXP Int Position
    | AnimateLevelUp
    | UpdateSessionTimer Time.Posix
    
    -- UI
    | OpenModal ModalType
    | CloseModal
    | ShowNotification NotificationType String
    | DismissNotification String
    | ScrollToSection String
    | AnimationTick Time.Posix
    | ClaimPlanXP String Int


type FavoriteType
    = HeroFavorite
    | EventFavorite


type ModalType
    = SessionModal
    | HeroModal String
    | ShareModal String
    | FilterModal
    | TechniqueSelectionModal


type ToBackend
    = GetInitialData
    | SaveFavorites Favorites
    | TrackPageView Route
    | SearchHeroes String
    | GetHeroDetail String
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
        { heroes : Dict String Hero
        , events : Dict String Event
        , roadmaps : Dict String TechniqueRoadmap
        , userProgress : UserProgress
        }
    | HeroDetailReceived Hero
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