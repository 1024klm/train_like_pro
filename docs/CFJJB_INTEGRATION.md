# Intégration des Compétitions CFJJB

Ce document explique comment les compétitions de la Confédération Française de Jiu-Jitsu Brésilien (CFJJB) sont intégrées dans l'application Train Like Pro.

## Vue d'ensemble

Les compétitions françaises de Jiu-Jitsu Brésilien sont automatiquement récupérées depuis le site officiel de la CFJJB (https://cfjjb.com/competitions/calendrier-competitions) et affichées dans la section Événements de l'application.

## Architecture

### Fichiers concernés

1. **`src/Data/CFJJBEvents.elm`** - Module Elm contenant les événements CFJJB
2. **`src/Data.elm`** - Module principal fusionnant les événements internationaux et français
3. **`scripts/scrape-cfjjb.js`** - Script Node.js pour récupérer les données du site CFJJB

### Structure des données

Chaque compétition CFJJB suit la structure `Event` définie dans `Types.elm`:

```elm
type alias Event =
    { id : String
    , name : String
    , date : String
    , location : Location
    , organization : String  -- "CFJJB"
    , type_ : EventType      -- Tournament ou Camp (pour enfants)
    , imageUrl : String
    , description : String
    , registrationUrl : Maybe String
    , streamUrl : Maybe String
    , results : Maybe (List MatchResult)
    , brackets : List Bracket
    , status : EventStatus
    }
```

### Catégories de compétitions

Les compétitions CFJJB sont classées en plusieurs catégories :
- **GI** : Compétitions en kimono (type: `Tournament`)
- **NO GI** : Compétitions sans kimono (type: `Tournament`)
- **KIDS** : Compétitions pour enfants (type: `Camp`)
- **KIDS NO GI** : Compétitions pour enfants sans kimono (type: `Camp`)

## Mise à jour des données

### Méthode manuelle

Pour mettre à jour les compétitions CFJJB manuellement :

```bash
npm run update:cfjjb
```

Cette commande :
1. Récupère les données depuis le site CFJJB
2. Parse le calendrier des compétitions
3. Génère le fichier `src/Data/CFJJBEvents.elm`
4. Crée également un fichier JSON de débogage dans `scripts/cfjjb-events.json`

### Structure du script de scraping

Le script `scripts/scrape-cfjjb.js` effectue les opérations suivantes :

1. **Récupération HTML** : Télécharge la page du calendrier CFJJB
2. **Parsing** : Extrait les informations des compétitions (nom, date, lieu, catégorie, statut)
3. **Transformation** : Convertit les données au format Elm
4. **Génération** : Crée le module Elm `Data.CFJJBEvents`

### Format des dates

Les dates sont converties du format français au format ISO 8601 (YYYY-MM-DD) :
- Exemple : "04 octobre 2025" → "2025-10-04"

## Intégration dans l'application

### Dans Data.elm

Les événements CFJJB sont fusionnés avec les événements internationaux :

```elm
import Data.CFJJBEvents exposing (cfjjbEvents)

initEvents : Dict String Event
initEvents =
    Dict.union internationalEvents cfjjbEvents
```

### Affichage dans le frontend

Les compétitions CFJJB apparaissent automatiquement dans :
- La page **Events** (`/events`)
- Les filtres par type d'événement
- Le calendrier des compétitions

Pour filtrer uniquement les compétitions françaises, utilisez :
- Filtre par organisation : "CFJJB"
- Filtre par pays : "France"

## Maintenance

### Ajout de nouvelles compétitions

1. **Automatique** : Exécutez `npm run update:cfjjb` pour récupérer les dernières compétitions du site CFJJB

2. **Manuel** : Éditez directement `src/Data/CFJJBEvents.elm` et ajoutez un nouvel événement :

```elm
, ( "cfjjb-{ville}-{date}-{type}"
  , { id = "cfjjb-{ville}-{date}-{type}"
    , name = "Open de {Ville}"
    , date = "YYYY-MM-DD"
    , location =
        { city = "{Ville}"
        , state = "{Région}"
        , country = "France"
        , address = ""
        , coordinates = Nothing
        }
    , organization = "CFJJB"
    , type_ = Tournament  -- ou Camp pour les kids
    , imageUrl = "/images/events/cfjjb-default.jpg"
    , description = "Compétition de Jiu-Jitsu Brésilien à {Ville}"
    , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
    , streamUrl = Nothing
    , results = Nothing
    , brackets = []
    , status = EventUpcoming
    }
  )
```

### Mise à jour du scraper

Si la structure HTML du site CFJJB change, vous devrez mettre à jour le script `scripts/scrape-cfjjb.js` :

1. Inspectez la nouvelle structure HTML
2. Adaptez les regex ou sélecteurs dans la fonction `parseCompetitions()`
3. Testez avec `npm run update:cfjjb`
4. Vérifiez le fichier généré `scripts/cfjjb-events.json`

## Limitations actuelles

- **Scraping basique** : Le script utilise des regex simples qui peuvent nécessiter des ajustements si le HTML du site CFJJB change
- **Données statiques** : Les compétitions sont intégrées au code source (pas de chargement dynamique)
- **Pas de temps réel** : Les données doivent être mises à jour manuellement en exécutant le script

## Améliorations futures

1. **Scraping robuste** : Utiliser une bibliothèque comme Cheerio ou JSDOM pour un parsing HTML plus fiable
2. **Actualisation automatique** : Configurer un cron job ou GitHub Action pour mettre à jour les compétitions quotidiennement
3. **API backend** : Créer un endpoint Lamdera qui récupère les données à la demande
4. **Cache intelligent** : Implémenter un système de cache pour éviter des requêtes excessives au site CFJJB
5. **Notifications** : Ajouter un système d'alerte pour les nouvelles compétitions ou changements de statut

## Support

Pour toute question ou problème concernant l'intégration CFJJB :
1. Vérifiez que le site CFJJB est accessible
2. Exécutez le script de mise à jour avec `npm run update:cfjjb`
3. Consultez les logs dans `scripts/cfjjb-events.json`
4. Vérifiez que le fichier `src/Data/CFJJBEvents.elm` compile correctement

## Références

- Site CFJJB : https://cfjjb.com/competitions/calendrier-competitions
- Documentation Lamdera : https://dashboard.lamdera.app/docs
- Types.elm : Définitions des types Event
