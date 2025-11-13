#!/usr/bin/env python3
"""
Script de synchronisation des screens Google Stitch avec le repository.

Ce script :
1. Récupère les screens depuis Google Stitch (ou un dossier local)
2. Compare avec les versions existantes
3. Met à jour les fichiers si nécessaire
4. Génère un rapport des changements
"""

import os
import json
import hashlib
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple

# Configuration
STITCH_SCREENS_DIR = Path("stitch_reservation_process_screen")
DOCS_STITCH_DIR = Path("docs/stitch-screens")
MANIFEST_FILE = DOCS_STITCH_DIR / "manifest.json"


def calculate_file_hash(file_path: Path) -> str:
    """Calcule le hash SHA256 d'un fichier."""
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b""):
            sha256.update(chunk)
    return sha256.hexdigest()


def load_manifest() -> Dict:
    """Charge le manifest des screens."""
    if MANIFEST_FILE.exists():
        with open(MANIFEST_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}


def save_manifest(manifest: Dict):
    """Sauvegarde le manifest."""
    DOCS_STITCH_DIR.mkdir(parents=True, exist_ok=True)
    with open(MANIFEST_FILE, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)


def scan_stitch_screens() -> Dict[str, Dict]:
    """Scanne le dossier des screens Stitch et retourne un manifest."""
    screens = {}
    
    if not STITCH_SCREENS_DIR.exists():
        print(f"⚠️  Dossier {STITCH_SCREENS_DIR} introuvable")
        return screens
    
    for screen_dir in STITCH_SCREENS_DIR.iterdir():
        if not screen_dir.is_dir():
            continue
        
        screen_name = screen_dir.name
        code_file = screen_dir / "code.html"
        screen_file = screen_dir / "screen.png"
        
        if not code_file.exists() or not screen_file.exists():
            continue
        
        screens[screen_name] = {
            "name": screen_name,
            "code_hash": calculate_file_hash(code_file),
            "screen_hash": calculate_file_hash(screen_file),
            "code_size": code_file.stat().st_size,
            "screen_size": screen_file.stat().st_size,
            "last_modified": datetime.fromtimestamp(
                max(code_file.stat().st_mtime, screen_file.stat().st_mtime)
            ).isoformat(),
        }
    
    return screens


def compare_manifests(old: Dict, new: Dict) -> Tuple[List[str], List[str], List[str]]:
    """Compare deux manifests et retourne les différences."""
    added = []
    modified = []
    removed = []
    
    old_names = set(old.keys())
    new_names = set(new.keys())
    
    # Screens ajoutés
    added = list(new_names - old_names)
    
    # Screens supprimés
    removed = list(old_names - new_names)
    
    # Screens modifiés
    for name in old_names & new_names:
        old_screen = old[name]
        new_screen = new[name]
        
        if (old_screen.get("code_hash") != new_screen.get("code_hash") or
            old_screen.get("screen_hash") != new_screen.get("screen_hash")):
            modified.append(name)
    
    return added, modified, removed


def generate_report(added: List[str], modified: List[str], removed: List[str]) -> str:
    """Génère un rapport markdown des changements."""
    report = f"""# Rapport de Synchronisation Stitch Screens

**Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Résumé

- ✅ Screens ajoutés: {len(added)}
- 🔄 Screens modifiés: {len(modified)}
- ❌ Screens supprimés: {len(removed)}

"""
    
    if added:
        report += "## Screens Ajoutés\n\n"
        for name in added:
            report += f"- `{name}`\n"
        report += "\n"
    
    if modified:
        report += "## Screens Modifiés\n\n"
        for name in modified:
            report += f"- `{name}`\n"
        report += "\n"
    
    if removed:
        report += "## Screens Supprimés\n\n"
        for name in removed:
            report += f"- `{name}`\n"
        report += "\n"
    
    return report


def main():
    """Fonction principale."""
    print("🔄 Synchronisation des screens Google Stitch...")
    
    # Charger l'ancien manifest
    old_manifest = load_manifest()
    
    # Scanner les screens actuels
    new_manifest = scan_stitch_screens()
    
    if not new_manifest:
        print("❌ Aucun screen trouvé")
        return 1
    
    # Comparer
    added, modified, removed = compare_manifests(old_manifest, new_manifest)
    
    # Générer le rapport
    report = generate_report(added, modified, removed)
    
    # Sauvegarder le rapport
    report_file = DOCS_STITCH_DIR / f"sync-report-{datetime.now().strftime('%Y%m%d-%H%M%S')}.md"
    DOCS_STITCH_DIR.mkdir(parents=True, exist_ok=True)
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    # Sauvegarder le nouveau manifest
    save_manifest(new_manifest)
    
    # Afficher le résumé
    print(f"\n✅ Synchronisation terminée")
    print(f"   - Screens ajoutés: {len(added)}")
    print(f"   - Screens modifiés: {len(modified)}")
    print(f"   - Screens supprimés: {len(removed)}")
    print(f"   - Rapport: {report_file}")
    
    # Retourner un code d'erreur si des changements ont été détectés
    if added or modified or removed:
        return 0  # Changements détectés (pour déclencher la PR)
    else:
        return 0  # Pas de changements


if __name__ == "__main__":
    exit(main())


