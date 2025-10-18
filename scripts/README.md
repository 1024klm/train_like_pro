# Scripts

Ce dossier contient les scripts utilitaires pour le projet Train Like Pro.

## scrape-cfjjb.js

Script de scraping pour récupérer automatiquement les compétitions depuis le site de la CFJJB.

### Utilisation

```bash
# Depuis la racine du projet
npm run update:cfjjb

# Ou directement
node scripts/scrape-cfjjb.js
```

### Ce que fait le script

1. Télécharge le calendrier des compétitions depuis https://cfjjb.com/competitions/calendrier-competitions
2. Parse les données des compétitions (nom, date, lieu, catégorie, statut)
3. Génère le module Elm `src/Data/CFJJBEvents.elm`
4. Crée un fichier JSON de débogage `scripts/cfjjb-events.json`

### Sorties

- **`src/Data/CFJJBEvents.elm`** : Module Elm avec les événements CFJJB formatés pour l'application
- **`scripts/cfjjb-events.json`** : Fichier JSON brut des compétitions (utile pour le débogage)

### Exemple de sortie

```elm
cfjjbEvents : Dict String Event
cfjjbEvents =
    Dict.fromList
        [ ( "cfjjb-paris-oct-4-gi"
          , { id = "cfjjb-paris-oct-4-gi"
            , name = "Open Région Île de France"
            , date = "2025-10-04"
            , location = { city = "Paris", state = "Île-de-France", ... }
            , organization = "CFJJB"
            , type_ = Tournament
            , ...
            }
          )
        ]
```

### Dépendances

Utilise uniquement Node.js natif (https, fs, path) - pas de dépendances externes requises.

### Maintenance

Si le site CFJJB change de structure HTML, vous devrez adapter les fonctions de parsing dans le script :
- `parseCompetitions()` : Extraction des compétitions depuis HTML
- `parseDate()` : Conversion des dates françaises
- `extractCategories()` : Détection des catégories (GI, NO GI, Kids)
