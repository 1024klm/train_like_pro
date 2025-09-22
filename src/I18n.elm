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
    , dashboard : String
    , heroes : String
    , academies : String
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
    
    -- Events
    , upcomingEvents : String
    , pastEvents : String
    , allEvents : String
    , eventDetails : String
    , location : String
    , date : String
    , participants : String
    
    -- Academy
    , topAcademies : String
    , schedule : String
    , instructors : String
    , contact : String
    , website : String
    
    -- Error Messages
    , pageNotFound : String
    , errorOccurred : String
    , tryAgain : String
    , goHome : String
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
    , dashboard = "Dashboard"
    , heroes = "Heroes"
    , academies = "Academies"
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
    , explorHeroes = "Explore Heroes"
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
    , featuredHeroes = "Featured Heroes"
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
    
    -- Events
    , upcomingEvents = "Upcoming Events"
    , pastEvents = "Past Events"
    , allEvents = "All Events"
    , eventDetails = "Event Details"
    , location = "Location"
    , date = "Date"
    , participants = "Participants"
    
    -- Academy
    , topAcademies = "Top Academies"
    , schedule = "Schedule"
    , instructors = "Instructors"
    , contact = "Contact"
    , website = "Website"
    
    -- Error Messages
    , pageNotFound = "404 - Page Not Found"
    , errorOccurred = "An error occurred"
    , tryAgain = "Try Again"
    , goHome = "Go Home"
    }


fr : Translations
fr =
    { -- App Info
      appTitle = "Train Like Pro"
    , appSubtitle = "Système de Gamification BJJ"
    , language = "Langue"
    , loading = "Chargement..."
    
    -- Navigation
    , dashboard = "Tableau de bord"
    , heroes = "Héros"
    , academies = "Académies"
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
    , explorHeroes = "Explorer les Héros"
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
    , featuredHeroes = "Héros en Vedette"
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
    
    -- Events
    , upcomingEvents = "Événements à Venir"
    , pastEvents = "Événements Passés"
    , allEvents = "Tous les Événements"
    , eventDetails = "Détails de l'Événement"
    , location = "Lieu"
    , date = "Date"
    , participants = "Participants"
    
    -- Academy
    , topAcademies = "Meilleures Académies"
    , schedule = "Horaire"
    , instructors = "Instructeurs"
    , contact = "Contact"
    , website = "Site Web"
    
    -- Error Messages
    , pageNotFound = "404 - Page Non Trouvée"
    , errorOccurred = "Une erreur s'est produite"
    , tryAgain = "Réessayer"
    , goHome = "Retour à l'Accueil"
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