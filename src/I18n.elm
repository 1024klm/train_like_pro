module I18n exposing (..)

{-| Complete internationalization module for Train Like Pro
Supports English and French languages
-}

import Time


-- TYPES

type Language
    = EN
    | FR


type alias Translations =
    { -- App Info
      appTitle : String
    , appSubtitle : String
    , language : String
    , loading : String
    
    -- Navigation
    , home : String
    , dashboard : String
    , heroes : String
    , events : String
    , training : String
    , profile : String
    , helpSupport : String
    , navigation : String
    , skipToContent : String
    , helpComingSoon : String
    
    -- Dashboard
    , level : String
    , experience : String
    , xpToLevel : String
    , xpToLevelUp : String
    , streak : String
    , days : String
    , day : String
    , todaysFocus : String
    , todaysFocusSubtitle : String
    , startYourJourney : String
    , createAccount : String
    , dailyProgress : String
    , quests : String
    , questsNew : String
    
    -- Training
    , trainingActive : String
    , currentDrill : String
    , sessionXP : String
    , techniques : String
    , endSession : String
    , startTraining : String
    , readyToTrain : String
    , readyToTrainSubtitle : String
    , noActiveSession : String
    , selectTechnique : String
    , chooseNextTechnique : String
    , addRep : String
    , perfect : String
    
    -- Profile
    , welcome : String
    , guest : String
    , signUp : String
    , logIn : String
    , alreadyHaveAccount : String
    , profileInfo : String
    , statistics : String
    , achievements : String
    , goals : String
    , addGoal : String
    , favorites : String
    , noAchievementsYet : String
    , noFavorites : String
    , noGoalsSet : String
    
    -- Gamification
    , dailyQuests : String
    , dailyQuestsSubtitle : String
    , todaysMissions : String
    , allQuestsCompleted : String
    , comeBackTomorrow : String
    , weeklyGoal : String
    , xpTargetProgress : String
    , complete : String
    , completed : String
    , locked : String
    , earned : String
    , progress : String
    , progressTo : String
    
    -- Roadmaps
    , activeRoadmaps : String
    , learningPathways : String
    , noActiveRoadmaps : String
    , browseRoadmaps : String
    , weeks : String
    , week : String
    
    -- Belts
    , whiteBelt : String
    , blueBelt : String
    , purpleBelt : String
    , brownBelt : String
    , blackBelt : String
    , master : String
    
    -- Techniques Mastery
    , learning : String
    , practicing : String
    , proficient : String
    , advanced : String
    , mastered : String
    , techniqueMastery : String
    
    -- Messages & Notifications
    , signUpFeature : String
    , loginFeature : String
    , comingSoon : String
    , helpDocumentation : String
    , goalSettingFeature : String
    , externalLink : String
    
    -- Actions
    , explorHeroes : String
    , createTrainingPlan : String
    , startSession : String
    , viewDetails : String
    , register : String
    , watchStream : String
    , save : String
    , cancel : String
    , close : String
    , confirm : String
    
    -- Stats
    , xpToday : String
    , trainingStreak : String
    , totalXP : String
    , sessions : String

    -- New training focused strings
    , chooseYourPath : String
    , viewAllFighters : String
    , todaysTraining : String
    , readyToMaster : String
    , techniquesLearned : String
    , weeklyBonus : String
    , completeAllGoals : String
    , rank : String
    , nextGoal : String
    , thisWeek : String
    
    -- Time
    , today : String
    , yesterday : String
    , tomorrow : String
    , minutes : String
    , hours : String
    , seconds : String
    
    -- Hero Page
    , featuredHeroes : String
    , learnFromLegends : String
    , trainLikeChampion : String
    , biography : String
    , competitionRecord : String
    , wins : String
    , losses : String
    , draws : String
    , signatureTechniques : String
    , videos : String
    , addToFavorites : String
    , favorited : String
    , heroNotFound : String
    , socialMedia : String
    , winRate : String
    , submissionRate : String
    , avgMatchTime : String
    , favoritePosition : String
    , favoriteSubmission : String
    
    -- Events
    , upcomingEvents : String
    , pastEvents : String
    , allEvents : String
    , eventDetails : String
    , location : String
    , date : String
    , participants : String
    , contact : String
    , website : String
    
    -- Error Messages
    , pageNotFound : String
    , errorOccurred : String
    , tryAgain : String
    , goHome : String
    , notFoundDescription : String

    -- Global UI
    , searchPlaceholder : String
    , sessionProgressLabel : String
    , planTitle : String
    , planSubtitle : String
    , planButtonLabel : String
    , momentumOverview : String
    , progressDescriptor : String
    , beltProgress : String
    , adjustGoals : String
    , weeklyGoalsDescription : String
    , weeklyBonusReminder : String
    , weeklyGoalSessions : String
    , weeklyGoalTechniques : String
    , weeklyGoalMinutes : String
    , weeklyGoalVideos : String
    , goalsCompletedMessage : String
    , noGoalsMessage : String
    , noSessionsYet : String
    , logFirstSession : String
    , duration : String
    , quality : String
    , quickNotes : String
    , switchTechnique : String
    , selectTechniquePrompt : String
    , sessionTechniques : String
    , sessionStats : String
    , todaysGoalsTitle : String
    , recentSessions : String

    -- Home
    , heroBadge : String
    , heroTitleLine1 : String
    , heroTitleLine2 : String
    , heroTitleHighlight : String
    , heroSubtitle : String

    -- Fighter Paths
    , pathActive : String
    , pathContinue : String
    , pathExplore : String
    , fighterPathDescription : String
    , fighterPathComingSoon : String

    -- Technique Library & Progress
    , techniqueLibraryTitle : String
    , techniqueLibraryDescription : String
    , techniqueLibraryComingSoon : String
    , progressPageTitle : String
    , progressPageDescription : String
    , progressTrackingComingSoon : String

    -- Events
    , eventsSubtitle : String
    , eventsCountSingular : String
    , eventsCountPlural : String
    , eventsFilterAll : String
    , eventsFilterUpcoming : String
    , eventsFilterPast : String
    , eventStatusUpcoming : String
    , eventStatusLive : String
    , eventStatusCompleted : String
    , eventStatusCancelled : String
    , eventInformation : String
    , venue : String
    , organization : String
    , statusLabel : String
    , typeLabel : String
    , brackets : String
    , links : String
    , eventNotFound : String
    , eventNotFoundDescription : String

    -- Training
    , trainingPlans : String
    , trainingPlansSubtitle : String
    , totalSessionsLabel : String
    , hoursTrainedLabel : String

    -- Forms & Auth
    , signUpSubtitle : String
    , fullName : String
    , fullNamePlaceholder : String
    , emailPlaceholder : String
    , passwordPlaceholder : String
    , confirmPassword : String
    , confirmPasswordPlaceholder : String
    , rememberMe : String
    , forgotPassword : String
    , dontHaveAccount : String
    , welcomeBack : String
    , loginSubtitle : String
    , passwordResetFeature : String

    -- Footer
    , footerTagline : String
    , footerExplore : String
    , footerResources : String
    , footerConnect : String
    , footerTechniqueLibrary : String
    , footerTrainingTips : String
    , footerCompetitionRules : String
    , footerBlog : String
    , footerCopyright : String

    -- Modals & Animations
    , logTrainingSession : String
    , sessionLoggingSoon : String
    , levelUp : String
    , achievementUnlocked : String
    , questComplete : String
    }


-- TRANSLATIONS

en : Translations
en =
    { -- App Info
      appTitle = "Train Like Pro"
    , appSubtitle = "BJJ Gamification System"
    , language = "Language"
    , loading = "Loading..."
    
    -- Navigation
    , home = "Home"
    , dashboard = "Dashboard"
    , heroes = "Champions"
    , events = "Events"
    , training = "Training"
    , profile = "Profile"
    , helpSupport = "Help & Support"
    , navigation = "Navigation"
    , skipToContent = "Skip to main content"
    , helpComingSoon = "Help documentation coming soon! For now, explore the app to learn."
    
    -- Dashboard
    , level = "LEVEL"
    , experience = "EXPERIENCE"
    , xpToLevel = "XP TO LEVEL UP"
    , xpToLevelUp = "XP TO LEVEL UP"
    , streak = "Streak"
    , days = "days"
    , day = "day"
    , todaysFocus = "TODAY'S FOCUS"
    , todaysFocusSubtitle = "Your active training mission"
    , startYourJourney = "Start Your Journey"
    , createAccount = "Create an account to track your training progress, save favorites, and unlock achievements."
    , dailyProgress = "Daily Progress"
    , quests = "Quests"
    , questsNew = "new"
    
    -- Training
    , trainingActive = "TRAINING ACTIVE"
    , currentDrill = "CURRENT DRILL"
    , sessionXP = "SESSION XP"
    , techniques = "TECHNIQUES"
    , endSession = "END SESSION"
    , startTraining = "START TRAINING"
    , readyToTrain = "READY TO TRAIN?"
    , readyToTrainSubtitle = "Start your training session to earn XP and track progress"
    , noActiveSession = "No active training session"
    , selectTechnique = "SELECT TECHNIQUE"
    , chooseNextTechnique = "Choose your next technique"
    , addRep = "ADD REP"
    , perfect = "PERFECT!"
    
    -- Profile
    , welcome = "Welcome"
    , guest = "Guest"
    , signUp = "Sign Up"
    , logIn = "Log In"
    , alreadyHaveAccount = "Already have an account? Log in"
    , profileInfo = "Profile Information"
    , statistics = "Statistics"
    , achievements = "ACHIEVEMENTS"
    , goals = "Goals"
    , addGoal = "Add Goal"
    , favorites = "Favorites"
    , noAchievementsYet = "No achievements yet"
    , noFavorites = "No favorites yet"
    , noGoalsSet = "No goals set"
    
    -- Gamification
    , dailyQuests = "DAILY QUESTS"
    , dailyQuestsSubtitle = "Today's missions"
    , todaysMissions = "Today's missions"
    , allQuestsCompleted = "ALL QUESTS COMPLETED!"
    , comeBackTomorrow = "Come back tomorrow for new challenges"
    , weeklyGoal = "WEEKLY GOAL"
    , xpTargetProgress = "XP target progress"
    , complete = "COMPLETE"
    , completed = "Completed"
    , locked = "LOCKED"
    , earned = "EARNED"
    , progress = "PROGRESS"
    , progressTo = "PROGRESS TO"
    
    -- Roadmaps
    , activeRoadmaps = "ACTIVE ROADMAPS"
    , learningPathways = "Your learning pathways"
    , noActiveRoadmaps = "No active roadmaps. Start your learning journey!"
    , browseRoadmaps = "BROWSE ROADMAPS"
    , weeks = "WEEKS"
    , week = "WEEK"
    
    -- Belts
    , whiteBelt = "White Belt"
    , blueBelt = "Blue Belt"
    , purpleBelt = "Purple Belt"
    , brownBelt = "Brown Belt"
    , blackBelt = "Black Belt"
    , master = "MASTER"
    
    -- Techniques Mastery
    , learning = "LEARNING"
    , practicing = "PRACTICING"
    , proficient = "PROFICIENT"
    , advanced = "ADVANCED"
    , mastered = "MASTERED"
    , techniqueMastery = "Technique Mastery"
    
    -- Messages & Notifications
    , signUpFeature = "Sign up feature coming soon!"
    , loginFeature = "Login feature coming soon!"
    , comingSoon = "Coming soon!"
    , helpDocumentation = "Help documentation coming soon! For now, explore the app to learn."
    , goalSettingFeature = "Goal setting feature coming soon!"
    , externalLink = "External link will open in new tab"
    
    -- Actions
    , explorHeroes = "Explore Champions"
    , createTrainingPlan = "Create Training Plan"
    , startSession = "Start Session"
    , viewDetails = "View Details"
    , register = "Register"
    , watchStream = "Watch Stream"
    , save = "Save"
    , cancel = "Cancel"
    , close = "Close"
    , confirm = "Confirm"
    
    -- Stats
    , xpToday = "XP Today"
    , trainingStreak = "TRAINING STREAK"
    , totalXP = "Total XP"
    , sessions = "Sessions"
    , rank = "RANK"
    , nextGoal = "Next Goal"
    , thisWeek = "This Week"

    -- New training focused strings
    , chooseYourPath = "Choose Your Path"
    , viewAllFighters = "View All Fighters →"
    , todaysTraining = "Today's Training Plan"
    , readyToMaster = "Ready to master new techniques? Your journey continues today."
    , techniquesLearned = "Techniques Learned"
    , weeklyBonus = "Weekly Bonus XP"
    , completeAllGoals = "Complete all goals"
    
    -- Time
    , today = "Today"
    , yesterday = "Yesterday"
    , tomorrow = "Tomorrow"
    , minutes = "minutes"
    , hours = "hours"
    , seconds = "seconds"
    
    -- Hero Page
    , featuredHeroes = "Featured Champions"
    , learnFromLegends = "Learn from the legends who shaped the sport"
    , trainLikeChampion = "Train Like a Champion"
    , biography = "Biography"
    , competitionRecord = "Competition Record"
    , wins = "Wins"
    , losses = "Losses"
    , draws = "Draws"
    , signatureTechniques = "Signature Techniques"
    , videos = "Videos"
    , addToFavorites = "Add to Favorites"
    , favorited = "Favorited"
    , heroNotFound = "Hero not found"
    , socialMedia = "Social Media"
    , winRate = "Win Rate"
    , submissionRate = "Submission Rate"
    , avgMatchTime = "Avg Match Time"
    , favoritePosition = "Favorite Position"
    , favoriteSubmission = "Favorite Submission"
    
    -- Events
    , upcomingEvents = "Upcoming Events"
    , pastEvents = "Past Events"
    , allEvents = "All Events"
    , eventDetails = "Event Details"
    , location = "Location"
    , date = "Date"
    , participants = "Participants"
    , contact = "Contact"
    , website = "Website"
    
    -- Error Messages
    , pageNotFound = "404 - Page Not Found"
    , errorOccurred = "An error occurred"
    , tryAgain = "Try Again"
    , goHome = "Go Home"
    , notFoundDescription = "The page you're looking for doesn't exist."

    -- Global UI
    , searchPlaceholder = "Search heroes, academies..."
    , sessionProgressLabel = "Session progress"
    , planTitle = "Training focus"
    , planSubtitle = "Structure your repetition work and stay tuned to details."
    , planButtonLabel = "Open session"
    , momentumOverview = "Momentum overview"
    , progressDescriptor = "Keep a clear pulse on volume, XP, and consistency."
    , beltProgress = "Belt progress"
    , adjustGoals = "Adjust"
    , weeklyGoalsDescription = "Map this week's targets and tick them off with intention."
    , weeklyBonusReminder = "bonus if every goal is completed this week."
    , weeklyGoalSessions = "Complete 5 training sessions"
    , weeklyGoalTechniques = "Master 3 new techniques"
    , weeklyGoalMinutes = "Log 300 minutes of mat time"
    , weeklyGoalVideos = "Review 10 competition videos"
    , goalsCompletedMessage = "All goals completed! Great job! 🎉"
    , noGoalsMessage = "No active goals"
    , noSessionsYet = "No training sessions yet"
    , logFirstSession = "Log Your First Session"
    , duration = "Duration"
    , quality = "Quality"
    , quickNotes = "Quick Notes"
    , switchTechnique = "Switch Technique"
    , selectTechniquePrompt = "Select a technique to practice"
    , sessionTechniques = "Session Techniques"
    , sessionStats = "Session Stats"
    , todaysGoalsTitle = "Today's Goals"
    , recentSessions = "Recent Sessions"

    -- Home
    , heroBadge = "Elite Training Program"
    , heroTitleLine1 = "Unlock your jiu-jitsu"
    , heroTitleLine2 = "with a plan "
    , heroTitleHighlight = "built by champions"
    , heroSubtitle = "Track sessions, intuitive dashboards, and champion-inspired routines to stay consistent on the mats."

    -- Fighter Paths
    , pathActive = "Active"
    , pathContinue = "Continue"
    , pathExplore = "Explore"
    , fighterPathDescription = "Learn the complete system and techniques of this fighter."
    , fighterPathComingSoon = "Fighter path system coming soon!"

    -- Technique Library & Progress
    , techniqueLibraryTitle = "Technique Library"
    , techniqueLibraryDescription = "Browse and learn all available techniques."
    , techniqueLibraryComingSoon = "Technique library coming soon!"
    , progressPageTitle = "Your Progress"
    , progressPageDescription = "Track your journey and achievements."
    , progressTrackingComingSoon = "Progress tracking coming soon!"

    -- Events
    , eventsSubtitle = "Tournaments, superfights, seminars and training camps"
    , eventsCountSingular = "event"
    , eventsCountPlural = "events"
    , eventsFilterAll = "All"
    , eventsFilterUpcoming = "Upcoming"
    , eventsFilterPast = "Past"
    , eventStatusUpcoming = "Upcoming"
    , eventStatusLive = "LIVE"
    , eventStatusCompleted = "Completed"
    , eventStatusCancelled = "Cancelled"
    , eventInformation = "Event Information"
    , venue = "Venue"
    , organization = "Organization"
    , statusLabel = "Status"
    , typeLabel = "Type"
    , brackets = "Brackets"
    , links = "Links"
    , eventNotFound = "Event not found"
    , eventNotFoundDescription = "We couldn't find this event. Please try another one."

    -- Training
    , trainingPlans = "Training Plans"
    , trainingPlansSubtitle = "Choose a hero and follow their training methodology"
    , totalSessionsLabel = "Total Sessions"
    , hoursTrainedLabel = "Hours Trained"

    -- Forms & Auth
    , signUpSubtitle = "Join Train Like Pro and start your journey"
    , fullName = "Full Name"
    , fullNamePlaceholder = "John Doe"
    , emailPlaceholder = "john@example.com"
    , passwordPlaceholder = "••••••••"
    , confirmPassword = "Confirm Password"
    , confirmPasswordPlaceholder = "••••••••"
    , rememberMe = "Remember me"
    , forgotPassword = "Forgot password?"
    , dontHaveAccount = "Don't have an account? Sign up"
    , welcomeBack = "Welcome Back"
    , loginSubtitle = "Log in to continue your training"
    , passwordResetFeature = "Password reset coming soon!"

    -- Footer
    , footerTagline = "Train like champions with guidance from the greatest athletes in BJJ history."
    , footerExplore = "Explore"
    , footerResources = "Resources"
    , footerConnect = "Connect"
    , footerTechniqueLibrary = "Technique Library"
    , footerTrainingTips = "Training Tips"
    , footerCompetitionRules = "Competition Rules"
    , footerBlog = "Blog"
    , footerCopyright = "© 2024 BJJ Heroes. Train Like Champions. All rights reserved."

    -- Modals & Animations
    , logTrainingSession = "Log Training Session"
    , sessionLoggingSoon = "Session logging coming soon!"
    , levelUp = "LEVEL UP!"
    , achievementUnlocked = "Achievement Unlocked!"
    , questComplete = "Quest Complete!"
    }


fr : Translations
fr =
    { -- App Info
      appTitle = "Train Like Pro"
    , appSubtitle = "Système de Gamification BJJ"
    , language = "Langue"
    , loading = "Chargement..."
    
    -- Navigation
    , home = "Accueil"
    , dashboard = "Tableau de bord"
    , heroes = "Champions"
    , events = "Événements"
    , training = "Entraînement"
    , profile = "Profil"
    , helpSupport = "Aide et Support"
    , navigation = "Navigation"
    , skipToContent = "Aller au contenu principal"
    , helpComingSoon = "La documentation d'aide arrive bientôt! Pour l'instant, explorez l'application pour apprendre."
    
    -- Dashboard
    , level = "NIVEAU"
    , experience = "EXPÉRIENCE"
    , xpToLevel = "XP POUR MONTER DE NIVEAU"
    , xpToLevelUp = "XP POUR MONTER DE NIVEAU"
    , streak = "Série"
    , days = "jours"
    , day = "jour"
    , todaysFocus = "FOCUS DU JOUR"
    , todaysFocusSubtitle = "Votre mission d'entraînement active"
    , startYourJourney = "Commencez Votre Aventure"
    , createAccount = "Créez un compte pour suivre vos progrès, sauvegarder vos favoris et débloquer des succès."
    , dailyProgress = "Progrès quotidien"
    , quests = "Quêtes"
    , questsNew = "nouvelles"
    
    -- Training
    , trainingActive = "ENTRAÎNEMENT ACTIF"
    , currentDrill = "EXERCICE ACTUEL"
    , sessionXP = "XP DE SESSION"
    , techniques = "TECHNIQUES"
    , endSession = "TERMINER SESSION"
    , startTraining = "COMMENCER L'ENTRAÎNEMENT"
    , readyToTrain = "PRÊT À VOUS ENTRAÎNER?"
    , readyToTrainSubtitle = "Commencez votre session pour gagner de l'XP et suivre vos progrès"
    , noActiveSession = "Aucune session active"
    , selectTechnique = "CHOISIR TECHNIQUE"
    , chooseNextTechnique = "Choisissez votre prochaine technique"
    , addRep = "AJOUTER REP"
    , perfect = "PARFAIT!"
    
    -- Profile
    , welcome = "Bienvenue"
    , guest = "Invité"
    , signUp = "S'inscrire"
    , logIn = "Se connecter"
    , alreadyHaveAccount = "Vous avez déjà un compte? Connectez-vous"
    , profileInfo = "Informations du profil"
    , statistics = "Statistiques"
    , achievements = "SUCCÈS"
    , goals = "Objectifs"
    , addGoal = "Ajouter un objectif"
    , favorites = "Favoris"
    , noAchievementsYet = "Aucun succès pour le moment"
    , noFavorites = "Aucun favori pour le moment"
    , noGoalsSet = "Aucun objectif défini"
    
    -- Gamification
    , dailyQuests = "QUÊTES QUOTIDIENNES"
    , dailyQuestsSubtitle = "Missions du jour"
    , todaysMissions = "Missions du jour"
    , allQuestsCompleted = "TOUTES LES QUÊTES COMPLÉTÉES!"
    , comeBackTomorrow = "Revenez demain pour de nouveaux défis"
    , weeklyGoal = "OBJECTIF HEBDOMADAIRE"
    , xpTargetProgress = "Progression de l'objectif XP"
    , complete = "COMPLET"
    , completed = "Complété"
    , locked = "VERROUILLÉ"
    , earned = "OBTENU"
    , progress = "PROGRÈS"
    , progressTo = "PROGRESSION VERS"
    
    -- Roadmaps
    , activeRoadmaps = "PARCOURS ACTIFS"
    , learningPathways = "Vos parcours d'apprentissage"
    , noActiveRoadmaps = "Aucun parcours actif. Commencez votre voyage d'apprentissage!"
    , browseRoadmaps = "PARCOURIR LES PARCOURS"
    , weeks = "SEMAINES"
    , week = "SEMAINE"
    
    -- Belts
    , whiteBelt = "Ceinture Blanche"
    , blueBelt = "Ceinture Bleue"
    , purpleBelt = "Ceinture Violette"
    , brownBelt = "Ceinture Marron"
    , blackBelt = "Ceinture Noire"
    , master = "MAÎTRE"
    
    -- Techniques Mastery
    , learning = "APPRENTISSAGE"
    , practicing = "PRATIQUE"
    , proficient = "COMPÉTENT"
    , advanced = "AVANCÉ"
    , mastered = "MAÎTRISÉ"
    , techniqueMastery = "Maîtrise des Techniques"
    
    -- Messages & Notifications
    , signUpFeature = "La fonction d'inscription arrive bientôt!"
    , loginFeature = "La fonction de connexion arrive bientôt!"
    , comingSoon = "Bientôt disponible!"
    , helpDocumentation = "Documentation d'aide bientôt disponible! Pour l'instant, explorez l'application."
    , goalSettingFeature = "La fonction d'objectifs arrive bientôt!"
    , externalLink = "Le lien externe s'ouvrira dans un nouvel onglet"
    
    -- Actions
    , explorHeroes = "Explorer les Champions"
    , createTrainingPlan = "Créer un Plan d'Entraînement"
    , startSession = "Démarrer Session"
    , viewDetails = "Voir les Détails"
    , register = "S'inscrire"
    , watchStream = "Regarder le Stream"
    , save = "Sauvegarder"
    , cancel = "Annuler"
    , close = "Fermer"
    , confirm = "Confirmer"
    
    -- Stats
    , xpToday = "XP Aujourd'hui"
    , trainingStreak = "SÉRIE D'ENTRAÎNEMENT"
    , totalXP = "XP Total"
    , sessions = "Sessions"
    , rank = "RANG"
    , nextGoal = "Prochain Objectif"
    , thisWeek = "Cette Semaine"

    -- New training focused strings
    , chooseYourPath = "Choisissez Votre Voie"
    , viewAllFighters = "Voir Tous les Combattants →"
    , todaysTraining = "Programme d'Entraînement du Jour"
    , readyToMaster = "Prêt à maîtriser de nouvelles techniques ? Votre voyage continue aujourd'hui."
    , techniquesLearned = "Techniques Apprises"
    , weeklyBonus = "Bonus XP Hebdomadaire"
    , completeAllGoals = "Compléter tous les objectifs"
    
    -- Time
    , today = "Aujourd'hui"
    , yesterday = "Hier"
    , tomorrow = "Demain"
    , minutes = "minutes"
    , hours = "heures"
    , seconds = "secondes"
    
    -- Hero Page
    , featuredHeroes = "Champions en vedette"
    , learnFromLegends = "Apprenez des légendes qui ont façonné le sport"
    , trainLikeChampion = "Entraînez-vous Comme un Champion"
    , biography = "Biographie"
    , competitionRecord = "Palmarès de Compétition"
    , wins = "Victoires"
    , losses = "Défaites"
    , draws = "Matchs Nuls"
    , signatureTechniques = "Techniques Signature"
    , videos = "Vidéos"
    , addToFavorites = "Ajouter aux Favoris"
    , favorited = "Favori"
    , heroNotFound = "Héros introuvable"
    , socialMedia = "Réseaux sociaux"
    , winRate = "Taux de victoire"
    , submissionRate = "Taux de soumission"
    , avgMatchTime = "Temps moyen de combat"
    , favoritePosition = "Position favorite"
    , favoriteSubmission = "Soumission favorite"
    
    -- Events
    , upcomingEvents = "Événements à Venir"
    , pastEvents = "Événements Passés"
    , allEvents = "Tous les Événements"
    , eventDetails = "Détails de l'Événement"
    , location = "Lieu"
    , date = "Date"
    , participants = "Participants"
    , contact = "Contact"
    , website = "Site Web"
    
    -- Error Messages
    , pageNotFound = "404 - Page Non Trouvée"
    , errorOccurred = "Une erreur s'est produite"
    , tryAgain = "Réessayer"
    , goHome = "Retour à l'Accueil"
    , notFoundDescription = "La page que tu cherches n'existe pas."

    -- Global UI
    , searchPlaceholder = "Rechercher des héros, académies..."
    , sessionProgressLabel = "Progression de la session"
    , planTitle = "Plan d'entraînement"
    , planSubtitle = "Structure ta répétition et reste attentif aux détails."
    , planButtonLabel = "Voir la session"
    , momentumOverview = "Vue d'ensemble du momentum"
    , progressDescriptor = "Garde un œil sur ton volume, ton XP et ta constance."
    , beltProgress = "Progression ceinture"
    , adjustGoals = "Ajuster"
    , weeklyGoalsDescription = "Visualise tes objectifs de la semaine et valide-les un par un."
    , weeklyBonusReminder = "de bonus si tous les objectifs sont réalisés cette semaine."
    , weeklyGoalSessions = "Compléter 5 sessions d'entraînement"
    , weeklyGoalTechniques = "Maîtriser 3 nouvelles techniques"
    , weeklyGoalMinutes = "Enregistrer 300 minutes de temps de tatami"
    , weeklyGoalVideos = "Revoir 10 vidéos de compétition"
    , goalsCompletedMessage = "Tous les objectifs sont complétés ! Bravo ! 🎉"
    , noGoalsMessage = "Aucun objectif actif"
    , noSessionsYet = "Aucune session d'entraînement pour l'instant"
    , logFirstSession = "Enregistrer ta première session"
    , duration = "Durée"
    , quality = "Qualité"
    , quickNotes = "Notes rapides"
    , switchTechnique = "Changer de technique"
    , selectTechniquePrompt = "Sélectionne une technique à pratiquer"
    , sessionTechniques = "Techniques de la session"
    , sessionStats = "Statistiques de la session"
    , todaysGoalsTitle = "Objectifs du jour"
    , recentSessions = "Sessions récentes"

    -- Home
    , heroBadge = "Programme d'entraînement élite"
    , heroTitleLine1 = "Libère ton jiu-jitsu"
    , heroTitleLine2 = "avec un plan "
    , heroTitleHighlight = "prêt à l'emploi"
    , heroSubtitle = "Suivi des séances, tableaux de bord intuitifs et routines inspirées des champions pour rester constant sur le tatami."

    -- Fighter Paths
    , pathActive = "En cours"
    , pathContinue = "Poursuivre"
    , pathExplore = "Découvrir"
    , fighterPathDescription = "Découvre le système complet et les techniques de ce combattant."
    , fighterPathComingSoon = "Le système des parcours combattants arrive bientôt !"

    -- Technique Library & Progress
    , techniqueLibraryTitle = "Bibliothèque de techniques"
    , techniqueLibraryDescription = "Parcours et apprends toutes les techniques disponibles."
    , techniqueLibraryComingSoon = "La bibliothèque de techniques arrive bientôt !"
    , progressPageTitle = "Ta progression"
    , progressPageDescription = "Suis ton parcours et tes réussites."
    , progressTrackingComingSoon = "Le suivi de progression arrive bientôt !"

    -- Events
    , eventsSubtitle = "Tournois, superfights, séminaires et camps d'entraînement"
    , eventsCountSingular = "événement"
    , eventsCountPlural = "événements"
    , eventsFilterAll = "Tous"
    , eventsFilterUpcoming = "À venir"
    , eventsFilterPast = "Passés"
    , eventStatusUpcoming = "À venir"
    , eventStatusLive = "EN DIRECT"
    , eventStatusCompleted = "Terminé"
    , eventStatusCancelled = "Annulé"
    , eventInformation = "Informations sur l'événement"
    , venue = "Lieu"
    , organization = "Organisation"
    , statusLabel = "Statut"
    , typeLabel = "Type"
    , brackets = "Tableaux"
    , links = "Liens"
    , eventNotFound = "Événement introuvable"
    , eventNotFoundDescription = "Nous n'avons pas trouvé cet événement. Essaie une autre recherche."

    -- Training
    , trainingPlans = "Plans d'entraînement"
    , trainingPlansSubtitle = "Choisis un héros et suis sa méthodologie d'entraînement"
    , totalSessionsLabel = "Sessions totales"
    , hoursTrainedLabel = "Heures d'entraînement"

    -- Forms & Auth
    , signUpSubtitle = "Rejoins Train Like Pro et lance ton aventure"
    , fullName = "Nom complet"
    , fullNamePlaceholder = "Jean Dupont"
    , emailPlaceholder = "jean@exemple.com"
    , passwordPlaceholder = "••••••••"
    , confirmPassword = "Confirmer le mot de passe"
    , confirmPasswordPlaceholder = "••••••••"
    , rememberMe = "Se souvenir de moi"
    , forgotPassword = "Mot de passe oublié ?"
    , dontHaveAccount = "Pas encore de compte ? Inscris-toi"
    , welcomeBack = "Bon retour"
    , loginSubtitle = "Connecte-toi pour poursuivre ton entraînement"
    , passwordResetFeature = "La réinitialisation du mot de passe arrive bientôt !"

    -- Footer
    , footerTagline = "Entraîne-toi comme les champions avec les plus grands athlètes de l'histoire du BJJ."
    , footerExplore = "Explorer"
    , footerResources = "Ressources"
    , footerConnect = "Connexion"
    , footerTechniqueLibrary = "Bibliothèque de techniques"
    , footerTrainingTips = "Conseils d'entraînement"
    , footerCompetitionRules = "Règles de compétition"
    , footerBlog = "Blog"
    , footerCopyright = "© 2024 BJJ Heroes. Entraîne-toi comme les champions. Tous droits réservés."

    -- Modals & Animations
    , logTrainingSession = "Journal de session d'entraînement"
    , sessionLoggingSoon = "L'enregistrement des sessions arrive bientôt !"
    , levelUp = "NIVEAU SUPÉRIEUR !"
    , achievementUnlocked = "Succès débloqué !"
    , questComplete = "Quête terminée !"
    }


-- HELPER FUNCTIONS

translate : Language -> Translations
translate lang =
    case lang of
        EN -> en
        FR -> fr


languageToString : Language -> String
languageToString lang =
    case lang of
        EN -> "EN"
        FR -> "FR"


languageFromString : String -> Language
languageFromString str =
    case String.toUpper str of
        "FR" -> FR
        _ -> EN


-- Alias for decoder compatibility
stringToLanguage : String -> Language
stringToLanguage =
    languageFromString


-- Convenience functions for common translations

t : Language -> (Translations -> String) -> String
t lang accessor =
    accessor (translate lang)


-- Format functions with language support

formatStreak : Language -> Int -> String
formatStreak lang count =
    let
        trans = translate lang
    in
    if count == 1 then
        String.fromInt count ++ " " ++ trans.day
    else
        String.fromInt count ++ " " ++ trans.days


formatXP : Language -> Int -> String
formatXP lang xp =
    String.fromInt xp ++ " XP"


formatLevel : Language -> Int -> String
formatLevel lang level =
    let
        trans = translate lang
    in
    trans.level ++ " " ++ String.fromInt level


formatWeeks : Language -> Int -> String
formatWeeks lang count =
    let
        trans = translate lang
    in
    if count == 1 then
        String.fromInt count ++ " " ++ trans.week
    else
        String.fromInt count ++ " " ++ trans.weeks


formatEventsCount : Language -> Int -> String
formatEventsCount lang count =
    let
        trans = translate lang
        label =
            if count == 1 then
                trans.eventsCountSingular
            else
                trans.eventsCountPlural
    in
    String.fromInt count ++ " " ++ label


formatDate : Language -> Time.Posix -> String
formatDate lang posix =
    let
        zone = Time.utc
        y = Time.toYear zone posix
        m = Time.toMonth zone posix
        d = Time.toDay zone posix

        monthName =
            case ( lang, m ) of
                ( FR, Time.Jan ) -> "janv."
                ( FR, Time.Feb ) -> "févr."
                ( FR, Time.Mar ) -> "mars"
                ( FR, Time.Apr ) -> "avr."
                ( FR, Time.May ) -> "mai"
                ( FR, Time.Jun ) -> "juin"
                ( FR, Time.Jul ) -> "juil."
                ( FR, Time.Aug ) -> "août"
                ( FR, Time.Sep ) -> "sept."
                ( FR, Time.Oct ) -> "oct."
                ( FR, Time.Nov ) -> "nov."
                ( FR, Time.Dec ) -> "déc."
                ( EN, Time.Jan ) -> "Jan"
                ( EN, Time.Feb ) -> "Feb"
                ( EN, Time.Mar ) -> "Mar"
                ( EN, Time.Apr ) -> "Apr"
                ( EN, Time.May ) -> "May"
                ( EN, Time.Jun ) -> "Jun"
                ( EN, Time.Jul ) -> "Jul"
                ( EN, Time.Aug ) -> "Aug"
                ( EN, Time.Sep ) -> "Sep"
                ( EN, Time.Oct ) -> "Oct"
                ( EN, Time.Nov ) -> "Nov"
                ( EN, Time.Dec ) -> "Dec"
    in
    String.fromInt d ++ " " ++ monthName ++ " " ++ String.fromInt y


formatFullDate : Language -> Time.Posix -> String
formatFullDate lang posix =
    let
        zone = Time.utc
        weekday = Time.toWeekday zone posix
        m = Time.toMonth zone posix
        d = Time.toDay zone posix

        weekdayName =
            case ( lang, weekday ) of
                ( FR, Time.Mon ) -> "lundi"
                ( FR, Time.Tue ) -> "mardi"
                ( FR, Time.Wed ) -> "mercredi"
                ( FR, Time.Thu ) -> "jeudi"
                ( FR, Time.Fri ) -> "vendredi"
                ( FR, Time.Sat ) -> "samedi"
                ( FR, Time.Sun ) -> "dimanche"
                ( EN, Time.Mon ) -> "Monday"
                ( EN, Time.Tue ) -> "Tuesday"
                ( EN, Time.Wed ) -> "Wednesday"
                ( EN, Time.Thu ) -> "Thursday"
                ( EN, Time.Fri ) -> "Friday"
                ( EN, Time.Sat ) -> "Saturday"
                ( EN, Time.Sun ) -> "Sunday"

        monthName =
            case ( lang, m ) of
                ( FR, Time.Jan ) -> "janv."
                ( FR, Time.Feb ) -> "févr."
                ( FR, Time.Mar ) -> "mars"
                ( FR, Time.Apr ) -> "avr."
                ( FR, Time.May ) -> "mai"
                ( FR, Time.Jun ) -> "juin"
                ( FR, Time.Jul ) -> "juil."
                ( FR, Time.Aug ) -> "août"
                ( FR, Time.Sep ) -> "sept."
                ( FR, Time.Oct ) -> "oct."
                ( FR, Time.Nov ) -> "nov."
                ( FR, Time.Dec ) -> "déc."
                ( EN, Time.Jan ) -> "Jan"
                ( EN, Time.Feb ) -> "Feb"
                ( EN, Time.Mar ) -> "Mar"
                ( EN, Time.Apr ) -> "Apr"
                ( EN, Time.May ) -> "May"
                ( EN, Time.Jun ) -> "Jun"
                ( EN, Time.Jul ) -> "Jul"
                ( EN, Time.Aug ) -> "Aug"
                ( EN, Time.Sep ) -> "Sep"
                ( EN, Time.Oct ) -> "Oct"
                ( EN, Time.Nov ) -> "Nov"
                ( EN, Time.Dec ) -> "Dec"
    in
    weekdayName ++ ", " ++ monthName ++ " " ++ String.fromInt d
