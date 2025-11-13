# Configuration GitHub Actions - Campbnb Québec

**Guide d'activation et de configuration des workflows GitHub Actions** | Mise à jour: 2024

---

## Workflows Disponibles

### 1. Overseer Daily Report

**Fichier**: `.github/workflows/overseer-daily-report.yml`

**Description**: Génère automatiquement un rapport quotidien de l'état du projet.

**Déclencheurs**:
- **Schedule**: Quotidien à 2h UTC (22h HNE / 23h HAE)
- **Workflow Dispatch**: Exécution manuelle possible
- **Push**: Sur branches `main` ou `develop` (si changements dans `lib/`, `supabase/`, `scripts/`)

**Fonctionnalités**:
- Génère rapport markdown (`docs/STATUS_REPORT.md`)
- Génère rapport JSON (`docs/STATUS_REPORT.json`)
- Commit automatique si changements détectés
- Upload artifacts pour historique (30 jours)

---

## Activation du Workflow

### Méthode 1: Activation Automatique (Recommandée)

Le workflow s'active automatiquement une fois poussé sur GitHub si:

1. ✅ Le fichier `.github/workflows/overseer-daily-report.yml` existe
2. ✅ La syntaxe YAML est valide
3. ✅ Le repository a GitHub Actions activé

**Vérification**:
- Aller dans l'onglet **Actions** du repository GitHub
- Le workflow devrait apparaître dans la liste
- Si une erreur apparaît, vérifier les logs

---

### Méthode 2: Activation Manuelle

Si le workflow n'apparaît pas automatiquement:

1. **Aller dans GitHub**:
   - Repository → Onglet **Actions**
   - Cliquer sur **Workflows** dans le menu de gauche

2. **Trouver le workflow**:
   - Chercher "Overseer Daily Status Report"
   - Cliquer dessus

3. **Activer le workflow**:
   - Si désactivé, cliquer sur **Enable workflow**
   - Le workflow sera maintenant actif

---

### Méthode 3: Exécution Manuelle (Test)

Pour tester le workflow immédiatement:

1. **Aller dans Actions**:
   - Repository → Onglet **Actions**
   - Sélectionner "Overseer Daily Status Report"

2. **Exécuter manuellement**:
   - Cliquer sur **Run workflow**
   - Sélectionner la branche (généralement `main`)
   - Cliquer sur **Run workflow**

3. **Vérifier l'exécution**:
   - Le workflow apparaîtra dans la liste des runs
   - Cliquer dessus pour voir les logs
   - Vérifier que tous les steps passent

---

## Configuration Requise

### Permissions GitHub

Le workflow nécessite les permissions suivantes:

1. **Contents**: Read & Write (pour commit automatique)
2. **Actions**: Read (pour exécuter le workflow)

**Vérification**:
- Repository → **Settings** → **Actions** → **General**
- Section **Workflow permissions**
- Vérifier que "Read and write permissions" est sélectionné

---

### Secrets GitHub (Optionnel)

Si le script nécessite des secrets (actuellement non requis):

1. **Aller dans Settings**:
   - Repository → **Settings** → **Secrets and variables** → **Actions**

2. **Ajouter un secret**:
   - Cliquer sur **New repository secret**
   - Nom: `SECRET_NAME`
   - Valeur: `secret_value`
   - Cliquer sur **Add secret**

**Note**: Le workflow actuel n'utilise pas de secrets, mais peut être étendu si nécessaire.

---

## Vérification du Workflow

### Checklist de Vérification

- [ ] Fichier `.github/workflows/overseer-daily-report.yml` existe
- [ ] Syntaxe YAML valide (pas d'erreurs)
- [ ] Workflow visible dans l'onglet Actions
- [ ] Permissions GitHub configurées correctement
- [ ] Test d'exécution manuelle réussi
- [ ] Rapport généré dans `docs/STATUS_REPORT.md`

---

## Dépannage

### Le workflow n'apparaît pas

**Problème**: Le workflow n'est pas visible dans l'onglet Actions.

**Solutions**:
1. Vérifier que le fichier est dans `.github/workflows/`
2. Vérifier la syntaxe YAML (utiliser un validateur)
3. Vérifier que GitHub Actions est activé pour le repository
4. Vérifier les permissions du repository

---

### Erreur: "Python was not found"

**Problème**: Le workflow échoue car Python n'est pas trouvé.

**Solution**: Le workflow utilise `actions/setup-python@v4` qui configure Python automatiquement. Si l'erreur persiste:
- Vérifier que la version Python est correcte (3.11)
- Vérifier les logs du step "Setup Python"

---

### Erreur: "Script not found"

**Problème**: Le script `scripts/overseer_status_check.py` n'est pas trouvé.

**Solutions**:
1. Vérifier que le fichier existe dans le repository
2. Vérifier le chemin dans le workflow
3. Vérifier que le fichier est commité (pas dans .gitignore)

---

### Le commit automatique ne fonctionne pas

**Problème**: Le workflow ne commit pas automatiquement les changements.

**Solutions**:
1. Vérifier les permissions GitHub (Contents: Write)
2. Vérifier que le workflow a accès au token GITHUB_TOKEN
3. Vérifier les logs du step "Commit and push report"
4. Vérifier que des changements sont détectés (step "Check for changes")

---

### Le workflow ne s'exécute pas automatiquement

**Problème**: Le workflow ne s'exécute pas à 2h UTC comme prévu.

**Solutions**:
1. Vérifier que le schedule est correct: `cron: '0 2 * * *'`
2. Vérifier que GitHub Actions est activé pour le repository
3. Vérifier que le workflow n'est pas désactivé
4. Note: Les workflows scheduled peuvent avoir un délai de quelques minutes

---

## Personnalisation

### Modifier la Fréquence

Pour changer la fréquence d'exécution, modifier le cron dans le workflow:

```yaml
on:
  schedule:
    # Quotidien à 2h UTC
    - cron: '0 2 * * *'
    
    # Toutes les 6 heures
    - cron: '0 */6 * * *'
    
    # Deux fois par jour (2h et 14h UTC)
    - cron: '0 2,14 * * *'
```

**Format cron**: `minute hour day month weekday`

---

### Modifier le Chemin de Sortie

Pour changer où le rapport est sauvegardé:

```yaml
- name: Generate status report
  run: |
    python scripts/overseer_status_check.py \
      --output docs/STATUS_REPORT.md \
      --format markdown
```

Modifier `--output docs/STATUS_REPORT.md` avec le chemin désiré.

---

### Ajouter des Notifications

Pour ajouter des notifications (email, Slack, etc.):

```yaml
- name: Send notification
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Workflow failed!'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Monitoring

### Voir l'Historique

1. **Onglet Actions**:
   - Repository → **Actions**
   - Sélectionner "Overseer Daily Status Report"
   - Voir tous les runs passés

2. **Artifacts**:
   - Chaque run génère des artifacts
   - Cliquer sur un run → **Artifacts**
   - Télécharger les rapports générés

---

### Métriques

**Suivre**:
- Nombre d'exécutions réussies/échouées
- Temps d'exécution moyen
- Fréquence des commits automatiques
- Taille des rapports générés

---

## Bonnes Pratiques

1. **Tester d'abord**:
   - Exécuter manuellement avant de compter sur le schedule
   - Vérifier que les rapports sont générés correctement

2. **Monitorer régulièrement**:
   - Vérifier l'onglet Actions régulièrement
   - S'assurer que le workflow s'exécute comme prévu

3. **Gérer les erreurs**:
   - Configurer des notifications en cas d'échec
   - Vérifier les logs en cas de problème

4. **Optimiser**:
   - Si le workflow est trop lent, optimiser les scripts
   - Si les rapports sont trop volumineux, ajuster le contenu

---

## Prochaines Étapes

Une fois le workflow activé:

1. ✅ **Tester l'exécution manuelle**
2. ✅ **Vérifier que les rapports sont générés**
3. ✅ **Vérifier que les commits automatiques fonctionnent**
4. ✅ **Attendre la première exécution automatique (2h UTC)**
5. ✅ **Monitorer les exécutions suivantes**

---

## Support

Pour toute question ou problème:
- Consulter les logs du workflow dans l'onglet Actions
- Vérifier la documentation GitHub Actions
- Créer une issue GitHub si nécessaire
- Contacter l'Agent GitHub

---

**Dernière mise à jour**: 2024  
**Responsable**: Agent GitHub  
**Statut**: Prêt à activer

