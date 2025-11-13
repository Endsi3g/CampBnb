# Synchronisation des Screens Google Stitch

Ce document décrit le système de synchronisation des screens Google Stitch avec le repository Campbnb.

## Vue d'ensemble

Les screens Google Stitch sont des maquettes UI/UX générées qui servent de référence pour le développement. Ce système permet de:

- Synchroniser automatiquement les screens depuis Google Stitch
- Détecter les changements UI/UX
- Éviter les conflits entre branches
- Maintenir une traçabilité des versions

## Structure

```
stitch_reservation_process_screen/
├── screen_name_1/
│ ├── code.html # Code HTML généré
│ └── screen.png # Capture d'écran
├── screen_name_2/
│ ├── code.html
│ └── screen.png
└── ...

docs/stitch-screens/
├── manifest.json # Manifest des screens (hash, métadonnées)
└── sync-report-*.md # Rapports de synchronisation
```

## Processus de Synchronisation

### Automatique (GitHub Actions)

Un workflow GitHub Actions s'exécute quotidiennement à 2h UTC:

1. **Scan**: Scanne le dossier `stitch_reservation_process_screen/`
2. **Comparaison**: Compare avec le manifest précédent
3. **Détection**: Identifie les screens ajoutés, modifiés, supprimés
4. **Rapport**: Génère un rapport markdown
5. **PR**: Crée automatiquement une PR si des changements sont détectés

### Manuel

Vous pouvez aussi exécuter le script manuellement:

```bash
# Depuis la racine du projet
python scripts/sync_stitch_screens.py
```

## Manifest

Le fichier `manifest.json` contient les métadonnées de chaque screen:

```json
{
"screen_name": {
"name": "screen_name",
"code_hash": "sha256_hash",
"screen_hash": "sha256_hash",
"code_size": 12345,
"screen_size": 67890,
"last_modified": "2024-01-15T10:30:00"
}
}
```

## Détection des Changements

Le système détecte:

- **Screens ajoutés**: Nouveaux screens dans le dossier
- **Screens modifiés**: Hash du code ou de l'image changé
- **Screens supprimés**: Screen présent dans le manifest mais absent du dossier

## Rapports

Chaque synchronisation génère un rapport markdown avec:

- Date et heure de synchronisation
- Liste des screens ajoutés
- Liste des screens modifiés
- Liste des screens supprimés

## Utilisation pour le Développement

### Avant de développer une feature UI

1. Vérifiez les screens Stitch correspondants
2. Consultez le dernier rapport de synchronisation
3. Assurez-vous que les screens sont à jour

### Après une synchronisation

1. **Review la PR automatique**: Vérifiez les changements UI/UX
2. **Testez les écrans**: Assurez-vous que les changements sont cohérents
3. **Validez le design**: Vérifiez la cohérence avec le design system

## ️ Configuration

### Variables d'environnement (GitHub Secrets)

- `STITCH_API_KEY`: Clé API Google Stitch (si API disponible)

### Workflow GitHub Actions

Le workflow est configuré dans `.github/workflows/sync-stitch-screens.yml`

## Dépannage

### Le script ne détecte pas les changements

- Vérifiez que les fichiers sont bien dans `stitch_reservation_process_screen/`
- Vérifiez les permissions des fichiers
- Vérifiez que le manifest existe

### Conflits de synchronisation

Si plusieurs branches modifient les screens:

1. Mergez d'abord la branche avec les screens les plus récents
2. Résolvez les conflits manuellement si nécessaire
3. Relancez la synchronisation

## Screens Disponibles

Consultez le manifest pour la liste complète:

```bash
cat docs/stitch-screens/manifest.json
```

Ou consultez directement le dossier:

```bash
ls stitch_reservation_process_screen/
```

## Liens Utiles

- [Google Stitch Documentation](https://stitch.google/)
- [Workflow GitHub Actions](../.github/workflows/sync-stitch-screens.yml)
- [Script de synchronisation](../scripts/sync_stitch_screens.py)


