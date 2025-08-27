module I18n exposing (..)

{-| This module handles internationalization (i18n) for the application.
It provides translations for all UI text in supported languages.
-}


-- TYPES


type Language
    = EN
    | FR


type alias Translation =
    { -- General
      appTitle : String
    , language : String
    , english : String
    , french : String
    , loading : String
    
    -- Header
    , headerTitle : String
    , headerSubtitle : String
    , headerDescription : String
    
    -- Features
    , personalizedPlans : String
    , progressTracking : String
    , eliteTechniques : String
    , championMindset : String
    
    -- Navigation
    , overview : String
    , heroes : String
    , actionPlan : String
    , progress : String
    
    -- Welcome Section
    , welcomeTitle : String
    , welcomeDescription : String
    , whatYouWillLearn : String
    , specificTechniques : String
    , trainingMethods : String
    , fightingPhilosophy : String
    , personalizedPlansDesc : String
    , yourProgress : String
    , detailedTracking : String
    , techniqueChecklist : String
    , achievementsToUnlock : String
    , progressStats : String
    
    -- How It Works
    , howItWorksTitle : String
    , chooseHero : String
    , chooseHeroDesc : String
    , followPlan : String
    , followPlanDesc : String
    , recordSessions : String
    , recordSessionsDesc : String
    , progressEvolve : String
    , progressEvolveDesc : String
    
    -- Heroes
    , heroesTitle : String
    , heroesDescription : String
    , selectHeroPrompt : String
    , selectHeroDescription : String
    , weeklyPlan : String
    , specializedTechniques : String
    , championMindsetDesc : String
    
    -- Hero Names & Descriptions
    , gordonRyan : String
    , gordonNickname : String
    , gordonDesc : String
    , buchecha : String
    , buchechaDesc : String
    , rafael : String
    , rafaelDesc : String
    , leandro : String
    , leandroDesc : String
    , galvao : String
    , galvaoDesc : String
    
    -- Training
    , readyToTrain : String
    , seePlan : String
    , trackProgress : String
    , keyPrinciples : String
    , principlesAndApproach : String
    , trainingMethod : String
    , technique : String
    , drilling : String
    , sparring : String
    , study : String
    , weeklyPlanTitle : String
    
    -- Plan
    , planTitle : String
    , planDescription : String
    , adaptedPrograms : String
    , adaptedProgramsDesc : String
    , provenMethods : String
    , provenMethodsDesc : String
    , guaranteedProgress : String
    , guaranteedProgressDesc : String
    
    -- Training Tips
    , championTips : String
    , physicalTraining : String
    , mentalRecovery : String
    , warmupRequired : String
    , warmupRequiredDesc : String
    , functionalStrength : String
    , functionalStrengthDesc : String
    , specificCardio : String
    , specificCardioDesc : String
    , sleepPriority : String
    , sleepPriorityDesc : String
    , visualization : String
    , visualizationDesc : String
    , videoAnalysis : String
    , videoAnalysisDesc : String
    
    -- Progress
    , progressTitle : String
    , progressDescription : String
    , sessions : String
    , sessionsDesc : String
    , techniques : String
    , techniquesDesc : String
    , statistics : String
    , statisticsDesc : String
    , achievements : String
    , achievementsDesc : String
    , progressTip : String
    
    -- Success Tips
    , successTips : String
    , starting : String
    , progression : String
    , excellence : String
    , chooseOneHero : String
    , setSmartGoals : String
    , recordAllSessions : String
    , patience : String
    , focusOnFewTechniques : String
    , reviewRegularly : String
    , teachToLearn : String
    , stayHumble : String
    , celebrateWins : String
    , championsReminder : String
    , championsQuote : String
    , championsSage : String
    
    -- Action Plan
    , weeklySchedule : String
    , monthlyGoals : String
    , beginnerSchedule : String
    , month1to2 : String
    , month3to4 : String
    , month5to6 : String
    , survival : String
    , survivalDesc : String
    , movement : String
    , movementDesc : String
    , attack : String
    , attackDesc : String
    
    -- Progress Tracking
    , newSession : String
    , totalSessions : String
    , trainingHours : String
    , masteredTechniques : String
    , recentSessions : String
    , selectHeroFirst : String
    , noSessionsYet : String
    , newSessionModal : String
    , date : String
    , hero : String
    , sessionType : String
    , duration : String
    , minutes : String
    , practicesTechniques : String
    , notes : String
    , cancel : String
    , save : String
    , selectHero : String
    , currentHero : String
    , heroSelectedDesc : String
    , noHeroSelected : String
    , selectHeroInstructions : String
    , clickNewSession : String
    
    -- Session Types
    , techniqueSession : String
    , drillingSession : String
    , sparringSession : String
    , competitionSession : String
    , openMatSession : String
    
    -- Missing Fields for Overview
    , universalPrinciples : String
    , mentalMindset : String
    , absoluteConfidence : String
    , constantPressure : String
    , creativity : String
    , tacticalPatience : String
    , leadership : String
    , training : String
    , techniqueFirst : String
    , drillingToAutomatism : String
    , cardioAsBase : String
    , regularVideoStudy : String
    , intelligentSparring : String
    , gettingStarted : String
    , smartGoals : String
    , patienceMarathon : String
    , focusOnTechniques : String
    , reviewNotes : String
    , celebrateVictories : String
    , championReminder : String
    , championQuote : String
    , championWisdom : String
    }



-- FUNCTIONS


{-| Get translations for the current language
-}
translations : Language -> Translation
translations lang =
    case lang of
        EN ->
            { -- General
              appTitle = "Train Like Pro"
            , language = "Language"
            , english = "English"
            , french = "Français"
            , loading = "Loading..."
            
            -- Header
            , headerTitle = "🥋 Train Like Pro"
            , headerSubtitle = "Your BJJ Learning Framework Inspired by Champions ⭐"
            , headerDescription = "Discover the training secrets of the greatest Brazilian Jiu-Jitsu legends. Gordon Ryan, Buchecha, Rafael Mendes, Leandro Lo, and André Galvão share their methods to help you progress effectively."
            
            -- Features
            , personalizedPlans = "Personalized plans"
            , progressTracking = "Progress tracking"
            , eliteTechniques = "Elite techniques"
            , championMindset = "Champion mindset"
            
            -- Navigation
            , overview = "🏠 Overview"
            , heroes = "🦸 Your Heroes"
            , actionPlan = "📋 Action Plan"
            , progress = "📊 Progress"
            
            -- Welcome Section
            , welcomeTitle = "🚀 Welcome to Your BJJ Journey"
            , welcomeDescription = "This platform guides you in learning Brazilian Jiu-Jitsu by drawing inspiration from the training methods of the greatest champions. Each hero brings their unique philosophy to help you develop your own style."
            , whatYouWillLearn = "🎯 What you'll learn"
            , specificTechniques = "Specific techniques for each champion's style"
            , trainingMethods = "Proven training methods"
            , fightingPhilosophy = "Fighting mindset and philosophy"
            , personalizedPlansDesc = "Personalized training plans"
            , yourProgress = "📈 Your progress"
            , detailedTracking = "Detailed session tracking"
            , techniqueChecklist = "Complete technique checklist"
            , achievementsToUnlock = "Achievements to unlock"
            , progressStats = "Real-time progress statistics"
            
            -- How It Works
            , howItWorksTitle = "🔧 How It Works"
            , chooseHero = "Choose Your Hero"
            , chooseHeroDesc = "Select the champion that matches your style or current goals"
            , followPlan = "Follow the Plan"
            , followPlanDesc = "Apply the specific training methods of your chosen hero"
            , recordSessions = "Record Your Sessions"
            , recordSessionsDesc = "Keep track of your training and practiced techniques"
            , progressEvolve = "Progress & Evolve"
            , progressEvolveDesc = "See your progression and unlock new achievements"
            
            -- Heroes
            , heroesTitle = "🦸 Choose Your BJJ Hero"
            , heroesDescription = "Each champion has developed their own style and training philosophy. Select the one that resonates with your current goals or discover new approaches to enrich your game."
            , selectHeroPrompt = "Select a Hero to Begin"
            , selectHeroDescription = "Click on one of the cards above to discover in detail the training methods of your favorite champion. You can then follow their personalized plan and adopt their philosophy."
            , weeklyPlan = "Detailed weekly plan"
            , specializedTechniques = "Specialized techniques"
            , championMindsetDesc = "Champion mindset"
            
            -- Hero Names & Descriptions
            , gordonRyan = "Gordon Ryan"
            , gordonNickname = "The King"
            , gordonDesc = "Perfect technique + Steel mental"
            , buchecha = "Buchecha"
            , buchechaDesc = "Pressure + Superhuman cardio"
            , rafael = "Rafael Mendes"
            , rafaelDesc = "Innovation + Fluidity"
            , leandro = "Leandro Lo"
            , leandroDesc = "Timing + Solid foundations"
            , galvao = "André Galvão"
            , galvaoDesc = "Leadership + Complete"
            
            -- Training
            , readyToTrain = "🚀 Ready to train like"
            , seePlan = "📋 See the Plan"
            , trackProgress = "📊 Track my Progress"
            , keyPrinciples = "Key Principles"
            , principlesAndApproach = "🎯 Principles & Approach"
            , trainingMethod = "Training Method"
            , technique = "🎯 Technique:"
            , drilling = "🔄 Drilling:"
            , sparring = "⚔️ Sparring:"
            , study = "📚 Study:"
            , weeklyPlanTitle = "📅 Weekly Plan"
            
            -- Plan
            , planTitle = "📋 Your BJJ Action Plan"
            , planDescription = "Transform your training with structured plans inspired by champions. Each program is designed to maximize your progression according to your level and goals."
            , adaptedPrograms = "Adapted Programs"
            , adaptedProgramsDesc = "Personalized plans according to your level, from beginner to advanced competitor"
            , provenMethods = "Proven Methods"
            , provenMethodsDesc = "Techniques and approaches used by the greatest world champions"
            , guaranteedProgress = "Guaranteed Progress"
            , guaranteedProgressDesc = "Progressive structure to develop your skills step by step"
            
            -- Training Tips
            , championTips = "💡 Champion Training Tips"
            , physicalTraining = "🏋️ Physical Training"
            , mentalRecovery = "🧠 Mental & Recovery"
            , warmupRequired = "Mandatory Warm-up"
            , warmupRequiredDesc = "15-20 min minimum before each session"
            , functionalStrength = "Functional Strength"
            , functionalStrengthDesc = "Prioritize compound movements"
            , specificCardio = "Specific Cardio"
            , specificCardioDesc = "High-intensity intervals adapted to BJJ"
            , sleepPriority = "Sleep Priority"
            , sleepPriorityDesc = "7-9h per night for recovery"
            , visualization = "Visualization"
            , visualizationDesc = "10 min/day of mental rehearsal"
            , videoAnalysis = "Video Analysis"
            , videoAnalysisDesc = "Study your sparring and the champions"
            
            -- Progress
            , progressTitle = "📊 Track Your BJJ Progress"
            , progressDescription = "Transform your training into concrete data! Record your sessions, track your techniques, and unlock achievements to stay motivated in your progression."
            , sessions = "Sessions"
            , sessionsDesc = "Record each training with details"
            , techniques = "Techniques"
            , techniquesDesc = "Complete checklist by hero"
            , statistics = "Statistics"
            , statisticsDesc = "Visualize your progress in real-time"
            , achievements = "Achievements"
            , achievementsDesc = "Unlock rewards"
            , progressTip = "💡 Tip: Record your sessions right after training so you don't forget the techniques practiced!"
            
            -- Success Tips
            , successTips = "🎯 Tips to Succeed in Your BJJ Journey"
            , starting = "🚀 Starting"
            , progression = "💡 Progression"
            , excellence = "🏆 Excellence"
            , chooseOneHero = "Start by choosing ONE hero and follow their approach"
            , setSmartGoals = "Set SMART goals (Specific, Measurable, Achievable)"
            , recordAllSessions = "Record ALL your sessions, even the short ones"
            , patience = "Patience: BJJ is a marathon, not a sprint"
            , focusOnFewTechniques = "Focus on 2-3 techniques maximum per session"
            , reviewRegularly = "Review your notes and videos regularly"
            , teachToLearn = "Teach what you learn to understand better"
            , stayHumble = "Stay humble and keep learning from everyone"
            , celebrateWins = "Celebrate your small victories and achievements"
            , championsReminder = "💪 Champions' Reminder"
            , championsQuote = "\"BJJ is not mastered, it is lived. Every mat is a lesson, every defeat an opportunity to learn.\""
            , championsSage = "- Collective wisdom from the legends of the tatami"
            
            -- Action Plan
            , weeklySchedule = "📅 Weekly Schedule (Beginner)"
            , monthlyGoals = "🎯 Monthly Goals"
            , beginnerSchedule = "Beginner Schedule"
            , month1to2 = "Month 1-2: Survival"
            , month3to4 = "Month 3-4: Movement"
            , month5to6 = "Month 5-6: Attack"
            , survival = "Survival"
            , survivalDesc = "Don't get submitted, basic positions"
            , movement = "Movement"
            , movementDesc = "Fluidity, transitions, first sweeps"
            , attack = "Attack"
            , attackDesc = "First submissions, active guard"
            
            -- Progress Tracking
            , newSession = "✨ New Session"
            , totalSessions = "Total Sessions"
            , trainingHours = "Training Hours"
            , masteredTechniques = "Mastered Techniques"
            , recentSessions = "🕐 Recent Sessions"
            , selectHeroFirst = "⚠️ Select a hero in the 'Your Heroes' tab to get started"
            , noSessionsYet = "No sessions recorded yet. Click 'New Session' to start!"
            , newSessionModal = "✨ New Training Session"
            , date = "📅 Date"
            , hero = "Hero"
            , sessionType = "Session Type"
            , duration = "Duration"
            , minutes = "minutes"
            , practicesTechniques = "Practiced Techniques"
            , notes = "Notes"
            , cancel = "❌ Cancel"
            , save = "💾 Save"
            , selectHero = "Select a hero"
            , currentHero = "Current Hero"
            , heroSelectedDesc = "Follow their training plan and philosophy"
            , noHeroSelected = "No Hero Selected"
            , selectHeroInstructions = "Choose a hero in the 'Heroes' tab to start your journey"
            , clickNewSession = "Click 'New Session' to start"
            
            -- Session Types
            , techniqueSession = "Technique"
            , drillingSession = "Drilling"
            , sparringSession = "Sparring"
            , competitionSession = "Competition"
            , openMatSession = "Open Mat"
            
            -- Missing Fields for Overview
            , universalPrinciples = "⚡ Universal Principles of Your Heroes"
            , mentalMindset = "Mental & Mindset"
            , absoluteConfidence = "Absolute confidence (Gordon Ryan)"
            , constantPressure = "Constant pressure (Buchecha)"
            , creativity = "Creativity (Rafael Mendes)"
            , tacticalPatience = "Tactical patience (Leandro Lo)"
            , leadership = "Leadership (André Galvão)"
            , training = "Training"
            , techniqueFirst = "Technique first"
            , drillingToAutomatism = "Drilling to automatism"
            , cardioAsBase = "Cardio as base"
            , regularVideoStudy = "Regular video study"
            , intelligentSparring = "Intelligent sparring"
            , gettingStarted = "Getting Started"
            , smartGoals = "Set SMART goals (Specific, Measurable, Achievable)"
            , patienceMarathon = "Patience: BJJ is a marathon, not a sprint"
            , focusOnTechniques = "Focus on 2-3 techniques maximum per session"
            , reviewNotes = "Review your notes and videos regularly"
            , celebrateVictories = "Celebrate your small victories and achievements"
            , championReminder = "💪 Champions' Reminder"
            , championQuote = "\"BJJ is not mastered, it is lived. Every mat is a lesson, every defeat an opportunity to learn.\""
            , championWisdom = "- Collective wisdom from the legends of the tatami"
            }

        FR ->
            { -- General
              appTitle = "Train Like Pro"
            , language = "Langue"
            , english = "English"
            , french = "Français"
            , loading = "Chargement..."
            
            -- Header
            , headerTitle = "🥋 Train Like Pro"
            , headerSubtitle = "Ton Cadre d'Apprentissage JJB Inspiré des Champions ⭐"
            , headerDescription = "Découvre les secrets d'entraînement des plus grandes légendes du Jiu-Jitsu Brésilien. Gordon Ryan, Buchecha, Rafael Mendes, Leandro Lo et André Galvão partagent leurs méthodes pour t'aider à progresser efficacement."
            
            -- Features
            , personalizedPlans = "Plans personnalisés"
            , progressTracking = "Suivi de progression"
            , eliteTechniques = "Techniques d'élite"
            , championMindset = "Mindset de champion"
            
            -- Navigation
            , overview = "🏠 Vue d'ensemble"
            , heroes = "🦸 Tes Héros"
            , actionPlan = "📋 Plan d'Action"
            , progress = "📊 Progression"
            
            -- Welcome Section
            , welcomeTitle = "🚀 Bienvenue dans Ton Voyage JJB"
            , welcomeDescription = "Cette plateforme t'accompagne dans ton apprentissage du Jiu-Jitsu Brésilien en s'inspirant des méthodes d'entraînement des plus grands champions. Chaque héros apporte sa philosophie unique pour t'aider à développer ton propre style."
            , whatYouWillLearn = "🎯 Ce que tu vas apprendre"
            , specificTechniques = "Techniques spécifiques à chaque style de champion"
            , trainingMethods = "Méthodes d'entraînement éprouvées"
            , fightingPhilosophy = "Mindset et philosophie de combat"
            , personalizedPlansDesc = "Plans d'entraînement personnalisés"
            , yourProgress = "📈 Ton progression"
            , detailedTracking = "Suivi détaillé de tes sessions"
            , techniqueChecklist = "Checklist des techniques à maîtriser"
            , achievementsToUnlock = "Achievements à débloquer"
            , progressStats = "Statistiques de progression"
            
            -- How It Works
            , howItWorksTitle = "🔧 Comment ça fonctionne"
            , chooseHero = "Choisis ton Héros"
            , chooseHeroDesc = "Sélectionne le champion qui correspond à ton style ou à tes objectifs actuels"
            , followPlan = "Suis le Plan"
            , followPlanDesc = "Applique les méthodes d'entraînement spécifiques à ton héros choisi"
            , recordSessions = "Enregistre tes Sessions"
            , recordSessionsDesc = "Garde une trace de tes entraînements et techniques pratiquées"
            , progressEvolve = "Progresse & Évolue"
            , progressEvolveDesc = "Vois ta progression et débloques de nouveaux achievements"
            
            -- Heroes
            , heroesTitle = "🦸 Choisis Ton Héros JJB"
            , heroesDescription = "Chaque champion a développé son propre style et sa philosophie d'entraînement. Sélectionne celui qui résonne avec tes objectifs actuels ou découvre de nouvelles approches pour enrichir ton jeu."
            , selectHeroPrompt = "Sélectionne un Héros pour Commencer"
            , selectHeroDescription = "Clique sur l'une des cartes ci-dessus pour découvrir en détail les méthodes d'entraînement de ton champion préféré. Tu pourras ensuite suivre son plan personnalisé et adopter sa philosophie."
            , weeklyPlan = "Plan hebdomadaire détaillé"
            , specializedTechniques = "Techniques spécialisées"
            , championMindsetDesc = "Mindset de champion"
            
            -- Hero Names & Descriptions
            , gordonRyan = "Gordon Ryan"
            , gordonNickname = "The King"
            , gordonDesc = "Technique parfaite + Mental d'acier"
            , buchecha = "Buchecha"
            , buchechaDesc = "Pression + Cardio surhumain"
            , rafael = "Rafael Mendes"
            , rafaelDesc = "Innovation + Fluidité"
            , leandro = "Leandro Lo"
            , leandroDesc = "Timing + Bases solides"
            , galvao = "André Galvão"
            , galvaoDesc = "Leadership + Complet"
            
            -- Training
            , readyToTrain = "🚀 Prêt à t'entraîner comme"
            , seePlan = "📋 Voir le Plan"
            , trackProgress = "📊 Suivre ma Progression"
            , keyPrinciples = "Principes Clés"
            , principlesAndApproach = "🎯 Principes & Approche"
            , trainingMethod = "Méthode d'Entraînement"
            , technique = "🎯 Technique:"
            , drilling = "🔄 Drilling:"
            , sparring = "⚔️ Sparring:"
            , study = "📚 Étude:"
            , weeklyPlanTitle = "📅 Plan Hebdomadaire"
            
            -- Plan
            , planTitle = "📋 Ton Plan d'Action JJB"
            , planDescription = "Transforme ton entraînement avec des plans structurés inspirés des champions. Chaque programme est conçu pour maximiser ta progression selon ton niveau et tes objectifs."
            , adaptedPrograms = "Programmes Adaptés"
            , adaptedProgramsDesc = "Plans personnalisés selon ton niveau, du débutant au compétiteur avancé"
            , provenMethods = "Méthodes Éprouvées"
            , provenMethodsDesc = "Techniques et approches utilisées par les plus grands champions mondiaux"
            , guaranteedProgress = "Progression Garantie"
            , guaranteedProgressDesc = "Structure progressive pour développer tes compétences étape par étape"
            
            -- Training Tips
            , championTips = "💡 Conseils d'Entraînement des Champions"
            , physicalTraining = "🏋️ Entraînement Physique"
            , mentalRecovery = "🧠 Mental & Récupération"
            , warmupRequired = "Échauffement Obligatoire"
            , warmupRequiredDesc = "15-20 min minimum avant chaque session"
            , functionalStrength = "Force Fonctionnelle"
            , functionalStrengthDesc = "Privilégie les mouvements composés"
            , specificCardio = "Cardio Spécifique"
            , specificCardioDesc = "Intervalles haute intensité adaptés au JJB"
            , sleepPriority = "Sommeil Prioritaire"
            , sleepPriorityDesc = "7-9h par nuit pour la récupération"
            , visualization = "Visualisation"
            , visualizationDesc = "10 min/jour de répétition mentale"
            , videoAnalysis = "Analyse Vidéo"
            , videoAnalysisDesc = "Étudie tes sparrings et les champions"
            
            -- Progress
            , progressTitle = "📊 Suivi de Ta Progression JJB"
            , progressDescription = "Transforme tes entraînements en données concrètes ! Enregistre tes sessions, suit tes techniques et débloques des achievements pour rester motivé dans ta progression."
            , sessions = "Sessions"
            , sessionsDesc = "Enregistre chaque entraînement avec détails"
            , techniques = "Techniques"
            , techniquesDesc = "Checklist complète par héros"
            , statistics = "Statistiques"
            , statisticsDesc = "Visualise tes progrès en temps réel"
            , achievements = "Achievements"
            , achievementsDesc = "Débloques des récompenses"
            , progressTip = "💡 Astuce : Enregistre tes sessions juste après l'entraînement pour ne rien oublier des techniques pratiquées !"
            
            -- Success Tips
            , successTips = "🎯 Conseils pour Réussir ton Parcours JJB"
            , starting = "🚀 Démarrage"
            , progression = "💡 Progression"
            , excellence = "🏆 Excellence"
            , chooseOneHero = "Commence par choisir UN héros et suit son approche"
            , setSmartGoals = "Fixe-toi des objectifs SMART (Spécifiques, Mesurables, Atteignables)"
            , recordAllSessions = "Enregistre TOUTES tes sessions, même les courtes"
            , patience = "Patience : le JJB est un marathon, pas un sprint"
            , focusOnFewTechniques = "Concentre-toi sur 2-3 techniques maximum par session"
            , reviewRegularly = "Révise régulièrement tes notes et vidéos"
            , teachToLearn = "Enseigne ce que tu apprends pour mieux comprendre"
            , stayHumble = "Reste humble et continue d'apprendre de tous"
            , celebrateWins = "Célèbre tes petites victoires et achievements"
            , championsReminder = "💪 Rappel des Champions"
            , championsQuote = "\"Le JJB ne se maîtrise pas, il se vit. Chaque tapis est une leçon, chaque défaite une opportunité d'apprendre.\""
            , championsSage = "- Sagesse collective des légendes du tatami"
            
            -- Action Plan
            , weeklySchedule = "📅 Semaine Type (Débutant)"
            , monthlyGoals = "🎯 Objectifs Mensuels"
            , beginnerSchedule = "Programme Débutant"
            , month1to2 = "Mois 1-2: Survie"
            , month3to4 = "Mois 3-4: Mouvement"
            , month5to6 = "Mois 5-6: Attaque"
            , survival = "Survie"
            , survivalDesc = "Ne pas se faire soumettre, positions de base"
            , movement = "Mouvement"
            , movementDesc = "Fluidité, transitions, premiers sweeps"
            , attack = "Attaque"
            , attackDesc = "Premières soumissions, garde active"
            
            -- Progress Tracking
            , newSession = "✨ Nouvelle Session"
            , totalSessions = "Sessions Totales"
            , trainingHours = "Heures d'Entraînement"
            , masteredTechniques = "Techniques Maîtrisées"
            , recentSessions = "🕐 Sessions Récentes"
            , selectHeroFirst = "⚠️ Sélectionne un héros dans l'onglet 'Tes Héros' pour commencer"
            , noSessionsYet = "Aucune session enregistrée. Clique sur 'Nouvelle Session' pour commencer!"
            , newSessionModal = "✨ Nouvelle Session d'Entraînement"
            , date = "📅 Date"
            , hero = "Héros"
            , sessionType = "Type de Session"
            , duration = "Durée"
            , minutes = "minutes"
            , practicesTechniques = "Techniques pratiquées"
            , notes = "Notes"
            , cancel = "❌ Annuler"
            , save = "💾 Enregistrer"
            , selectHero = "Sélectionner un héros"
            , currentHero = "Héros Actuel"
            , heroSelectedDesc = "Suis leur plan d'entraînement et leur philosophie"
            , noHeroSelected = "Aucun Héros Sélectionné"
            , selectHeroInstructions = "Choisis un héros dans l'onglet 'Héros' pour commencer ton parcours"
            , clickNewSession = "Clique sur 'Nouvelle Session' pour commencer"
            
            -- Session Types
            , techniqueSession = "Technique"
            , drillingSession = "Drilling"
            , sparringSession = "Sparring"
            , competitionSession = "Compétition"
            , openMatSession = "Open Mat"
            
            -- Missing Fields for Overview
            , universalPrinciples = "⚡ Principes Universels de tes Héros"
            , mentalMindset = "Mental & Mindset"
            , absoluteConfidence = "Confiance absolue (Gordon Ryan)"
            , constantPressure = "Pression constante (Buchecha)"
            , creativity = "Créativité (Rafael Mendes)"
            , tacticalPatience = "Patience tactique (Leandro Lo)"
            , leadership = "Leadership (André Galvão)"
            , training = "Entraînement"
            , techniqueFirst = "Technique avant tout"
            , drillingToAutomatism = "Drilling jusqu'à l'automatisme"
            , cardioAsBase = "Cardio comme base"
            , regularVideoStudy = "Étude vidéo régulière"
            , intelligentSparring = "Sparring intelligent"
            , gettingStarted = "Démarrage"
            , smartGoals = "Fixe-toi des objectifs SMART (Spécifiques, Mesurables, Atteignables)"
            , patienceMarathon = "Patience : le JJB est un marathon, pas un sprint"
            , focusOnTechniques = "Concentre-toi sur 2-3 techniques maximum par session"
            , reviewNotes = "Révise régulièrement tes notes et vidéos"
            , celebrateVictories = "Célèbre tes petites victoires et achievements"
            , championReminder = "💪 Rappel des Champions"
            , championQuote = "\"Le JJB ne se maîtrise pas, il se vit. Chaque tapis est une leçon, chaque défaite une opportunité d'apprendre.\""
            , championWisdom = "- Sagesse collective des légendes du tatami"
            }


{-| Convert Language to String for storage
-}
languageToString : Language -> String
languageToString lang =
    case lang of
        EN ->
            "en"

        FR ->
            "fr"


{-| Convert String to Language with fallback to EN
-}
stringToLanguage : String -> Language
stringToLanguage str =
    case str of
        "fr" ->
            FR

        _ ->
            EN


{-| Get locale string for the language (e.g., "en-US", "fr-FR")
-}
languageToLocale : Language -> String
languageToLocale lang =
    case lang of
        EN ->
            "en-US"

        FR ->
            "fr-FR"