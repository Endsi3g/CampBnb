# 📜 Scripts d'Automatisation

## 🗺️ inject_mapbox_token

Scripts pour injecter automatiquement le token Mapbox depuis `.env` dans les fichiers de configuration Android et iOS.

### Utilisation

#### Python (Recommandé - Multi-plateforme)

```bash
python scripts/inject_mapbox_token.py
```

ou

```bash
python3 scripts/inject_mapbox_token.py
```

#### Bash (macOS/Linux)

```bash
chmod +x scripts/inject_mapbox_token.sh
./scripts/inject_mapbox_token.sh
```

#### PowerShell (Windows)

```powershell
powershell -ExecutionPolicy Bypass -File scripts/inject_mapbox_token.ps1
```

### Prérequis

1. Fichier `.env` à la racine du projet avec :
   ```env
   MAPBOX_ACCESS_TOKEN=pk.eyJ1IjoieW91cnVzZXJuYW1lIiwiYSI6ImNscXh4eHh4eHh4eHh4In0.your_token_here
   ```

2. Pour Python : Python 3.6+ installé

### Ce que fait le script

1. Lit le fichier `.env`
2. Extrait `MAPBOX_ACCESS_TOKEN`
3. Remplace `YOUR_MAPBOX_ACCESS_TOKEN` dans :
   - `android/app/src/main/res/values/strings.xml`
   - `ios/Runner/Info.plist`

### Exemple de sortie

```
🔧 Injection du token Mapbox...
✅ Token injecté dans android/app/src/main/res/values/strings.xml
✅ Token injecté dans ios/Runner/Info.plist
✅ Injection terminée ! 2 fichier(s) mis à jour.
```

### Dépannage

**Erreur : "Fichier .env non trouvé"**
- Créez le fichier `.env` à la racine du projet
- Ajoutez `MAPBOX_ACCESS_TOKEN=your_token`

**Erreur : "MAPBOX_ACCESS_TOKEN non défini"**
- Vérifiez que la ligne dans `.env` est : `MAPBOX_ACCESS_TOKEN=your_token`
- Pas d'espaces autour du `=`

**Erreur : "Placeholder non trouvé"**
- Vérifiez que les fichiers contiennent `YOUR_MAPBOX_ACCESS_TOKEN`
- Si déjà remplacé, le script ne fera rien (c'est normal)
