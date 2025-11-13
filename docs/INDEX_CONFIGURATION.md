# 📑 Index : Configuration GitHub

Index de tous les guides de configuration GitHub pour CampBnb.

## 🎯 Guides Principaux

### 1. [Guide de Configuration Complet](GUIDE_CONFIGURATION_COMPLETE.md)
Guide récapitulatif avec checklist complète de toutes les étapes de configuration.

### 2. [Configurer les Secrets GitHub](CONFIGURER_SECRETS_GITHUB.md)
Guide détaillé pour configurer tous les secrets GitHub nécessaires aux workflows CI/CD.

### 3. [Configurer les Branch Protection Rules](CONFIGURER_BRANCH_PROTECTION.md)
Guide pour sécuriser les branches `main` et `develop` avec des règles de protection.

### 4. [Configurer les Labels GitHub](CONFIGURER_LABELS_GITHUB.md)
Guide pour créer automatiquement ou manuellement tous les labels GitHub.

## 📋 Guides de Setup

- [Setup Initial](SETUP.md) - Configuration initiale du repository
- [Git Workflow](GIT_WORKFLOW.md) - Processus Git et conventions
- [Déploiement](DEPLOYMENT.md) - Guide de déploiement

## 🔧 Scripts Disponibles

### Configuration Labels

- **Linux/Mac** : `scripts/setup_labels.sh`
- **Windows** : `scripts/setup_labels_powershell.ps1`

### Initialisation Git

- **Linux/Mac** : `scripts/init_git.sh`
- **Windows** : `scripts/init_git.ps1`

### Résolution Problèmes Git

- **Windows** : `scripts/fix_git_push.ps1`

## 📚 Ordre Recommandé de Configuration

1. ✅ **Repository créé** (déjà fait)
2. ⏳ **Secrets GitHub** → [Guide](CONFIGURER_SECRETS_GITHUB.md)
3. ⏳ **Branch Protection** → [Guide](CONFIGURER_BRANCH_PROTECTION.md)
4. ⏳ **Labels GitHub** → [Guide](CONFIGURER_LABELS_GITHUB.md)

## 🧪 Tests de Vérification

Après chaque étape, testez la configuration :

- **Secrets** : Créez une PR et vérifiez que les workflows s'exécutent
- **Branch Protection** : Essayez de push sur `main` (devrait échouer)
- **Labels** : Créez une issue et vérifiez les labels disponibles

## 🆘 Support

- [Documentation GitHub](https://docs.github.com/)
- [Issues](https://github.com/Endsi3g/CampBnb/issues)
- [Guide de Setup](SETUP.md)

