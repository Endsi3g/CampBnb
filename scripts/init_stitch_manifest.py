#!/usr/bin/env python3
"""
Script d'initialisation du manifest Stitch.

Ce script crée le manifest initial à partir des screens existants.
À exécuter une seule fois lors de la configuration initiale.
"""

import sys
from pathlib import Path

# Ajouter le script parent au path pour importer sync_stitch_screens
sys.path.insert(0, str(Path(__file__).parent))

from sync_stitch_screens import scan_stitch_screens, save_manifest

def main():
    """Initialise le manifest Stitch."""
    print("🔄 Initialisation du manifest Stitch...")
    
    # Scanner les screens
    screens = scan_stitch_screens()
    
    if not screens:
        print("❌ Aucun screen trouvé dans stitch_reservation_process_screen/")
        return 1
    
    # Sauvegarder le manifest
    save_manifest(screens)
    
    print(f"\n✅ Manifest initialisé avec {len(screens)} screens")
    print(f"   Manifest sauvegardé dans: docs/stitch-screens/manifest.json")
    
    return 0

if __name__ == "__main__":
    exit(main())


