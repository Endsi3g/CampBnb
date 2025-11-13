# 🏷️ Guide : Configurer les Labels GitHub

Ce guide vous explique comment configurer automatiquement tous les labels GitHub pour votre repository.

## 📋 Méthode 1 : Script Automatique (Recommandé)

### Prérequis

1. **GitHub CLI (gh)** doit être installé
   - Windows : `winget install GitHub.cli`
   - Mac : `brew install gh`
   - Linux : Voir [GitHub CLI Installation](https://cli.github.com/manual/installation)

2. **Authentification GitHub CLI**
   ```bash
   gh auth login
   ```

### Exécution du Script

#### Sur Linux/Mac :

```bash
# Rendre le script exécutable
chmod +x scripts/setup_labels.sh

# Exécuter le script
./scripts/setup_labels.sh
```

#### Sur Windows (PowerShell) :

```powershell
# Exécuter le script PowerShell
.\scripts\setup_labels_powershell.ps1
```

**Note** : Si le script bash ne fonctionne pas sur Windows, utilisez la méthode manuelle ou installez Git Bash.

### Vérification

Après l'exécution, vérifiez que les labels sont créés :

1. Allez sur https://github.com/Endsi3g/CampBnb/labels
2. Vous devriez voir tous les labels configurés

---

## 📋 Méthode 2 : Configuration Manuelle

Si le script ne fonctionne pas, vous pouvez créer les labels manuellement :

1. Allez sur https://github.com/Endsi3g/CampBnb/labels
2. Cliquez sur **New label**
3. Pour chaque label dans `.github/labels.json`, créez-le avec :
   - **Name** : Le nom du label
   - **Description** : La description
   - **Color** : La couleur (format hexadécimal)

### Liste des Labels à Créer

Consultez le fichier `.github/labels.json` pour la liste complète. Voici les principaux :

#### Labels de Type

- `bug` - Quelque chose ne fonctionne pas (rouge)
- `enhancement` - Nouvelle feature ou amélioration (bleu clair)
- `documentation` - Amélioration de la documentation (bleu)
- `technical-debt` - Dette technique à résoudre (jaune)

#### Labels de Priorité

- `good first issue` - Bon pour les nouveaux contributeurs (violet)
- `help wanted` - Besoin d'aide supplémentaire (vert)
- `priority: high` - Priorité haute
- `priority: low` - Priorité basse

#### Labels Spécifiques

- `ui/ux` - Changements d'interface utilisateur (beige)
- `flutter` - Relatif à Flutter (bleu)
- `dependencies` - Mise à jour des dépendances (bleu)
- `automated` - Généré automatiquement (bleu)
- `stitch-sync` - Synchronisation des screens Stitch (vert)

---

## 📋 Méthode 3 : Script PowerShell (Windows)

Si vous êtes sur Windows et que le script bash ne fonctionne pas, utilisez ce script PowerShell :

```powershell
# scripts/setup_labels_powershell.ps1
# Vérifier que gh CLI est installé
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI (gh) n'est pas installé" -ForegroundColor Red
    Write-Host "Installez-le depuis: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

# Vérifier l'authentification
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Vous n'êtes pas authentifié avec GitHub CLI" -ForegroundColor Red
    Write-Host "Exécutez: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host "🏷️  Configuration des labels GitHub..." -ForegroundColor Cyan

# Lire le fichier JSON
$labels = Get-Content .github/labels.json | ConvertFrom-Json

foreach ($label in $labels) {
    $name = $label.name
    $color = $label.color
    $description = $label.description
    
    Write-Host "  Création du label: $name" -ForegroundColor Green
    
    # Essayer de créer le label
    gh label create $name --color $color --description $description --force 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✅ $name créé" -ForegroundColor Green
    } else {
        # Essayer de mettre à jour le label existant
        gh label edit $name --color $color --description $description 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    🔄 $name mis à jour" -ForegroundColor Yellow
        } else {
            Write-Host "    ⚠️  Erreur pour $name" -ForegroundColor Red
        }
    }
}

Write-Host "`n✅ Labels configurés avec succès !" -ForegroundColor Green
```

---

## 🔍 Vérification des Labels

Après la configuration, vérifiez que tous les labels sont présents :

1. Allez sur https://github.com/Endsi3g/CampBnb/labels
2. Vous devriez voir environ 15-20 labels
3. Vérifiez que les couleurs et descriptions sont correctes

## 📝 Utilisation des Labels

### Dans les Issues

Lors de la création d'une issue, sélectionnez les labels appropriés :
- `bug` pour un bug
- `enhancement` pour une nouvelle feature
- `good first issue` pour les nouveaux contributeurs

### Dans les Pull Requests

Les labels peuvent être ajoutés automatiquement ou manuellement :
- `dependencies` pour les mises à jour de dépendances
- `automated` pour les PRs générées automatiquement
- `ui/ux` pour les changements d'interface

## 🔧 Personnalisation

Pour modifier les labels, éditez le fichier `.github/labels.json` :

```json
{
  "name": "mon-label",
  "color": "ff0000",
  "description": "Ma description"
}
```

Puis réexécutez le script de configuration.

## 📚 Ressources

- [GitHub Labels Documentation](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Labels JSON Format](https://docs.github.com/en/rest/issues/labels)

## 🆘 Problèmes Courants

### "gh: command not found"

- Installez GitHub CLI : https://cli.github.com/
- Vérifiez que le PATH est correctement configuré

### "Authentication required"

- Exécutez : `gh auth login`
- Suivez les instructions pour vous authentifier

### "Permission denied"

- Vérifiez que vous avez les permissions d'écriture sur le repository
- Vérifiez que vous êtes authentifié avec le bon compte

### Les labels ne s'affichent pas

- Rafraîchissez la page GitHub
- Vérifiez que le script s'est exécuté sans erreur
- Vérifiez les logs du script pour les erreurs

