# Configuration Sentry - Guide Complet

## ✅ Problèmes Résolus

### 1. PowerShell - Flutter/Dart non reconnus

**Solution**: Voir `docs/POWERSHELL_FLUTTER_SETUP.md`

**Résumé rapide**:
1. Ajouter Flutter au PATH système
2. Redémarrer PowerShell
3. Vérifier avec `flutter --version`

**Script PowerShell**: `scripts/test_sentry_manual.ps1`

## 📋 Configuration des Alertes Sentry

### Guide Complet

Voir `docs/SENTRY_ALERTS_SETUP.md` pour:
- Configuration des alertes critiques
- Configuration des alertes récurrentes
- Configuration des canaux (Email, Slack)
- Exemples de règles JSON

### Étapes Rapides

1. **Aller sur [sentry.io](https://sentry.io)**
2. **Sélectionner le projet Campbnb**
3. **Settings → Alerts → Create Alert Rule**
4. **Configurer les conditions et actions**
5. **Tester les alertes**

## 🔍 Vérification des Erreurs dans Sentry

### Guide Complet

Voir `docs/VERIFY_SENTRY_ERRORS.md` pour:
- Comment vérifier que les erreurs sont capturées
- Checklist de vérification
- Filtres utiles
- Dépannage

### Vérification Rapide

1. **Aller sur [sentry.io](https://sentry.io)**
2. **Sélectionner le projet Campbnb**
3. **Aller dans Issues**
4. **Vérifier**:
   - ✅ Les erreurs apparaissent
   - ✅ Le contexte est présent
   - ✅ Les breadcrumbs sont là
   - ✅ Les tags sont corrects

## 🧪 Tests

### Option 1: Script Batch (Recommandé - Pas de problème de politique)

```cmd
# Exécuter le script interactif
.\scripts\test_sentry.bat
```

### Option 1b: Script PowerShell (Si politique configurée)

```powershell
# Si politique d'exécution configurée
.\scripts\test_sentry_manual.ps1

# Ou avec bypass
powershell -ExecutionPolicy Bypass -File .\scripts\test_sentry_manual.ps1
```

**Note**: Si erreur de politique, voir `docs/POWERSHELL_EXECUTION_POLICY.md`

### Option 2: Tests Unitaires

```powershell
# Si Flutter est dans le PATH
flutter test test/monitoring/error_capture_test.dart
```

### Option 3: Test Manuel dans l'App

Ajouter temporairement dans l'application:

```dart
await ErrorMonitoringService().captureException(
  Exception('Test error - Vérification Sentry'),
  context: {
    'test': true,
    'environment': 'staging',
  },
);
```

## 📊 Checklist Complète

### Configuration

- [ ] Flutter/Dart configurés dans PowerShell (voir `POWERSHELL_FLUTTER_SETUP.md`)
- [ ] `SENTRY_DSN` configuré dans `.env`
- [ ] Sentry initialisé dans `main.dart`
- [ ] Intercepteurs intégrés dans les services

### Alertes

- [ ] Alertes pour erreurs fatales configurées
- [ ] Alertes pour erreurs récurrentes configurées
- [ ] Alertes pour nouveaux types d'erreurs configurées
- [ ] Canaux de notification configurés (Email, Slack)

### Vérification

- [ ] Erreurs apparaissent dans Sentry
- [ ] Contexte est correctement renseigné
- [ ] Breadcrumbs sont présents
- [ ] Tags sont appliqués
- [ ] Performances sont tracées

## 🔗 Ressources

- **Configuration PowerShell**: `docs/POWERSHELL_FLUTTER_SETUP.md`
- **Configuration Alertes**: `docs/SENTRY_ALERTS_SETUP.md`
- **Vérification Erreurs**: `docs/VERIFY_SENTRY_ERRORS.md`
- **Configuration Monitoring**: `docs/MONITORING_SETUP.md`

## 🚀 Prochaines Étapes

1. ✅ Résoudre le problème PowerShell
2. ✅ Configurer les alertes Sentry
3. ✅ Vérifier les erreurs dans Sentry
4. ⏳ Analyser les erreurs les plus fréquentes
5. ⏳ Prioriser les corrections
6. ⏳ Surveiller les tendances

## 📞 Support

Pour toute question:
1. Consulter la documentation dans `docs/`
2. Vérifier le dashboard Sentry
3. Consulter les logs de l'application

