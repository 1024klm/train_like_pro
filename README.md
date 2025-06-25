# 🥋 Train Like Pro - BJJ Heroes Framework

Une application web interactive pour apprendre le Jiu-Jitsu Brésilien en s'inspirant des légendes du sport. Construite avec [Lamdera](https://lamdera.com) (Elm full-stack).

![Elm](https://img.shields.io/badge/Elm-0.19.1-blue)
![Lamdera](https://img.shields.io/badge/Lamdera-Latest-green)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.0-38B2AC)

## 🎯 Aperçu

Train Like Pro est une application qui te permet de découvrir et d'apprendre des plus grands champions de JJB :
- **Gordon Ryan** - "The King" 
- **Marcus Buchecha** - "The Phenom"
- **Rafael Mendes** - "The Wizard"
- **Leandro Lo** - "The Passer"
- **André Galvão** - "The General"

## ✨ Fonctionnalités

- 📱 **Interface Responsive** - Fonctionne sur desktop et mobile
- 🌓 **Mode Sombre** - Support du thème clair/sombre
- 👥 **Profils de Champions** - Découvre les techniques et philosophies de chaque héros
- 📅 **Plans d'Entraînement** - Plans hebdomadaires inspirés par chaque champion
- 🎯 **Phases d'Apprentissage** - Guide structuré pour progresser (0-6 mois, 6-18 mois, 18+ mois)
- 💾 **Persistance des Données** - Tes sélections sont sauvegardées côté serveur

## 🚀 Démarrage Rapide

### Prérequis

- [Node.js](https://nodejs.org/) (v14 ou plus récent)
- [Lamdera](https://dashboard.lamdera.app/docs/download)

### Installation

```bash
# Clone le repository
git clone https://github.com/1024klm/train_like_pro.git
cd train_like_pro

# Installe les dépendances
npm install
```

### Développement

```bash
# Lance l'application en mode développement
npm start

# L'application sera accessible sur http://localhost:8000
```

### Build

```bash
# Compile pour la production
lamdera build
```

### Tests

```bash
# Lance les tests
npm test

# Lance les tests en mode watch
npm run test:watch
```

## 🏗️ Architecture

```
train_like_pro/
├── src/
│   ├── Frontend.elm      # Logique client et vues
│   ├── Backend.elm       # Logique serveur
│   ├── Types.elm         # Types partagés
│   ├── I18n.elm         # Internationalisation
│   ├── Theme.elm        # Gestion des thèmes
│   └── styles.css       # Styles Tailwind
├── tests/               # Tests end-to-end
├── public/              # Assets statiques
└── elm-pkg-js/          # Modules JavaScript
```

## 📚 Structure de l'Application

### 3 Onglets Principaux

1. **Vue d'ensemble** 
   - Les 3 phases d'apprentissage
   - Principes universels des champions

2. **Tes Héros**
   - Cartes interactives des 5 champions
   - Détails sur clic : spécialités, principes, plan hebdomadaire

3. **Plan d'Action**
   - Programme hebdomadaire personnalisé
   - Objectifs mensuels progressifs
   - Mentalité de champion

## 🛠️ Technologies Utilisées

- **[Lamdera](https://lamdera.com)** - Framework Elm full-stack
- **[Elm](https://elm-lang.org)** - Langage fonctionnel pour le web
- **[Tailwind CSS](https://tailwindcss.com)** - Framework CSS utility-first
- **[elm-test-rs](https://github.com/mpizenberg/elm-test-rs)** - Test runner pour Elm

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésite pas à :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit tes changements (`git commit -m 'Add some AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous license MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- Les champions de JJB qui inspirent ce projet
- La communauté Lamdera et Elm
- Tous les pratiquants de JJB qui cherchent à s'améliorer

---

Fait avec ❤️ et 🥋 par [1024klm](https://github.com/1024klm)