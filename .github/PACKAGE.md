# 📦 Package GitHub - CampBnb Québec

## Vue d'ensemble

Ce workflow GitHub Actions crée automatiquement un package complet de l'application CampBnb Québec lors de la création d'un tag de version.

## Déclenchement

Le package est créé automatiquement lorsque :
- Un tag de version est poussé (format: `v1.0.0`)
- Le workflow est déclenché manuellement via `workflow_dispatch`

## Contenu du Package

Chaque package contient :

### Applications Android
- **APK** (`campbnb-quebec-{version}.apk`) : Application Android Package
- **AAB** (`campbnb-quebec-{version}.aab`) : Android App Bundle (pour Google Play)

### Archives
- **TAR.GZ** (`campbnb-quebec-{version}.tar.gz`) : Archive compressée
- **ZIP** (`campbnb-quebec-{version}.zip`) : Archive ZIP

### Métadonnées
- `VERSION.txt` : Numéro de version
- `COMMIT_SHA.txt` : Hash du commit
- `BUILD_DATE.txt` : Date de build (ISO 8601)
- `pubspec.yaml` : Configuration Flutter
- `README.md` : Documentation

## Utilisation

### Créer un Package Automatiquement

1. **Créer un tag de version** :
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. Le workflow se déclenche automatiquement et :
   - Build l'application Android (APK + AAB)
   - Crée les archives
   - Crée une GitHub Release avec tous les fichiers

### Créer un Package Manuellement

1. Aller dans **Actions** > **Create GitHub Package**
2. Cliquer sur **Run workflow**
3. Entrer la version (ex: `1.0.0`)
4. Cliquer sur **Run workflow**

### Télécharger le Package

1. Aller dans **Releases** sur GitHub
2. Sélectionner la version désirée
3. Télécharger les fichiers nécessaires :
   - **APK** : Pour installation directe sur Android
   - **AAB** : Pour publication sur Google Play Store
   - **Archives** : Pour distribution ou backup

## Installation

### Installation de l'APK

1. Télécharger le fichier `.apk`
2. Sur votre appareil Android :
   - Activer **Sources inconnues** dans les paramètres
   - Ouvrir le fichier APK téléchargé
   - Suivre les instructions d'installation

### Publication sur Google Play

1. Télécharger le fichier `.aab`
2. Se connecter à [Google Play Console](https://play.google.com/console)
3. Créer une nouvelle version de l'application
4. Uploader le fichier AAB
5. Compléter les informations de release
6. Publier

## Structure du Package

```
campbnb-quebec-{version}/
├── campbnb-quebec-{version}.apk
├── campbnb-quebec-{version}.aab
├── VERSION.txt
├── COMMIT_SHA.txt
├── BUILD_DATE.txt
├── pubspec.yaml
└── README.md
```

## Versions

Le système de versionnement suit [Semantic Versioning](https://semver.org/) :
- **MAJOR** : Changements incompatibles
- **MINOR** : Nouvelles fonctionnalités compatibles
- **PATCH** : Corrections de bugs

Exemples :
- `v1.0.0` : Version initiale
- `v1.1.0` : Nouvelles fonctionnalités
- `v1.1.1` : Corrections de bugs
- `v2.0.0` : Changements majeurs

## Permissions Requises

Le workflow nécessite les permissions suivantes :
- `contents: write` : Pour créer les releases
- `packages: write` : Pour uploader les packages

## Variables d'Environnement

Le build nécessite les secrets GitHub suivants :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `MAPBOX_ACCESS_TOKEN`
- `GEMINI_API_KEY`

## Dépannage

### Le workflow échoue

1. Vérifier que tous les secrets sont configurés
2. Vérifier que Flutter est à jour
3. Consulter les logs dans **Actions**

### Le package n'apparaît pas

1. Vérifier que le tag est bien poussé
2. Attendre la fin du workflow
3. Vérifier dans **Releases**

### L'APK ne s'installe pas

1. Vérifier que **Sources inconnues** est activé
2. Vérifier la compatibilité Android (minimum API 21)
3. Vérifier l'espace de stockage disponible

## Support

Pour toute question ou problème :
- Ouvrir une [Issue](https://github.com/Endsi3g/CampBnb/issues)
- Consulter la [documentation](docs/README.md)

---

*Dernière mise à jour : 2024*

