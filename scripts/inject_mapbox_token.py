#!/usr/bin/env python3
"""
Script Python pour injecter le token Mapbox depuis .env dans les fichiers de configuration
Compatible Windows, macOS et Linux
"""

import os
import re
import sys
from pathlib import Path

def load_env_file():
    """Charge les variables d'environnement depuis .env"""
    env_path = Path('.env')
    if not env_path.exists():
        print("⚠️  Fichier .env non trouvé. Créez-le avec MAPBOX_ACCESS_TOKEN=your_token")
        sys.exit(1)
    
    env_vars = {}
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                if '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    
    return env_vars

def inject_token_in_file(file_path, token, placeholder):
    """Injecte le token dans un fichier"""
    file_path = Path(file_path)
    if not file_path.exists():
        print(f"⚠️  Fichier {file_path} non trouvé")
        return False
    
    try:
        content = file_path.read_text(encoding='utf-8')
        if placeholder in content:
            content = content.replace(placeholder, token)
            file_path.write_text(content, encoding='utf-8')
            print(f"✅ Token injecté dans {file_path}")
            return True
        else:
            print(f"⚠️  Placeholder '{placeholder}' non trouvé dans {file_path}")
            return False
    except Exception as e:
        print(f"❌ Erreur lors de l'injection dans {file_path}: {e}")
        return False

def main():
    """Fonction principale"""
    print("🔧 Injection du token Mapbox...")
    
    # Charger les variables d'environnement
    env_vars = load_env_file()
    
    # Récupérer le token
    mapbox_token = env_vars.get('MAPBOX_ACCESS_TOKEN')
    if not mapbox_token:
        print("⚠️  MAPBOX_ACCESS_TOKEN non défini dans .env")
        sys.exit(1)
    
    placeholder = "YOUR_MAPBOX_ACCESS_TOKEN"
    success_count = 0
    
    # Android - strings.xml
    android_path = Path("android/app/src/main/res/values/strings.xml")
    if inject_token_in_file(android_path, mapbox_token, placeholder):
        success_count += 1
    
    # iOS - Info.plist
    ios_path = Path("ios/Runner/Info.plist")
    if inject_token_in_file(ios_path, mapbox_token, placeholder):
        success_count += 1
    
    if success_count > 0:
        print(f"✅ Injection terminée ! {success_count} fichier(s) mis à jour.")
    else:
        print("⚠️  Aucun fichier n'a été mis à jour.")
        sys.exit(1)

if __name__ == "__main__":
    main()

