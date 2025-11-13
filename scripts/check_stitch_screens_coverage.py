#!/usr/bin/env python3
"""
Script de vérification de la couverture des screens Stitch dans le code Flutter.

Ce script analyse les screens Google Stitch et vérifie leur correspondance
avec le code Flutter existant.

Usage:
    python scripts/check_stitch_screens_coverage.py
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple
from dataclasses import dataclass
from datetime import datetime

@dataclass
class ScreenStatus:
    """Statut d'un screen Stitch."""
    name: str
    stitch_path: Path
    flutter_file: str = ""
    status: str = "missing"  # implemented, partial, missing
    notes: str = ""

class StitchScreenChecker:
    """Vérificateur de couverture des screens Stitch."""
    
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.stitch_dir = project_root / "stitch_reservation_process_screen"
        self.lib_dir = project_root / "lib" / "features"
        self.screens: List[ScreenStatus] = []
        
    def find_stitch_screens(self) -> List[str]:
        """Trouve tous les screens Stitch."""
        screens = []
        if not self.stitch_dir.exists():
            return screens
            
        for item in self.stitch_dir.iterdir():
            if item.is_dir() and not item.name.startswith('.'):
                screens.append(item.name)
        return sorted(screens)
    
    def find_flutter_screens(self) -> Dict[str, str]:
        """Trouve tous les screens Flutter."""
        flutter_screens = {}
        
        if not self.lib_dir.exists():
            return flutter_screens
        
        # Patterns pour trouver les screens
        patterns = [
            r"(\w+_screen)\.dart$",
            r"(\w+Screen)\.dart$",
        ]
        
        for feature_dir in self.lib_dir.iterdir():
            if not feature_dir.is_dir():
                continue
                
            screens_dir = feature_dir / "presentation" / "screens"
            if not screens_dir.exists():
                continue
                
            for file in screens_dir.rglob("*.dart"):
                for pattern in patterns:
                    match = re.search(pattern, file.name)
                    if match:
                        screen_name = match.group(1)
                        relative_path = str(file.relative_to(self.project_root))
                        flutter_screens[screen_name.lower()] = relative_path
        
        return flutter_screens
    
    def normalize_name(self, name: str) -> str:
        """Normalise un nom de screen pour la correspondance."""
        # Enlever underscores, espaces, caractères spéciaux
        normalized = re.sub(r'[^a-z0-9]', '', name.lower())
        return normalized
    
    def check_coverage(self) -> List[ScreenStatus]:
        """Vérifie la couverture des screens Stitch."""
        stitch_screens = self.find_stitch_screens()
        flutter_screens = self.find_flutter_screens()
        
        results = []
        
        # Mapping connu (à compléter manuellement si nécessaire)
        known_mappings = {
            "welcome_screen": ("welcome", "implemented", "high"),
            "log_in_screen_1": ("login", "implemented", "high"),
            "log_in_screen_2": ("login", "implemented", "high"),
            "sign_up_screen": ("signup", "implemented", "high"),
            "onboarding_screen_1__discovery": ("onboarding", "implemented", "high"),
            "onboarding_screen_2__easy_booking": ("onboarding", "implemented", "high"),
            "onboarding_screen_3__become_a_host": ("onboarding", "implemented", "high"),
            "campbnb_québec_home_screen_1": ("home", "implemented", "high"),
            "campbnb_québec_home_screen_2": ("home", "implemented", "high"),
            "search_and_results_page": ("search", "implemented", "high"),
            "campsite_details_screen": ("listingdetails", "partial", "high"),
            "reservation_process_screen": ("reservationprocess", "implemented", "high"),
            "reservation_request_details": ("reservationrequestdetails", "implemented", "high"),
            "reservation_requests_management": ("reservationrequestsmanagement", "implemented", "high"),
            "suggest_alternative_dates_screen": ("suggestalternativedates", "implemented", "high"),
            "full-screen_interactive_map": ("fullmap", "implemented", "high"),
            "map_screen": ("map", "implemented", "high"),
            "user_profile_screen": ("profile", "implemented", "high"),
            "host_dashboard_screen": ("hostdashboard", "implemented", "high"),
            "add_listing_(step_1__info)_1": ("addlisting", "implemented", "high"),
            "add_listing_(step_1__info)_2": ("addlisting", "implemented", "high"),
            "add_listing_(step_1__info)_3": ("addlisting", "implemented", "high"),
            "add_listing_(step_1__info)_4": ("addlisting", "implemented", "high"),
            "add_listing_(step_1__info)_5": ("addlisting", "implemented", "high"),
            "add_listing_(step_1__info)_6": ("addlisting", "implemented", "high"),
            "add_listing_(step_1__info)_7": ("addlisting", "implemented", "high"),
            "add_listing_(step_1__info)_8": ("addlisting", "implemented", "high"),
            "edit_listing_management_screen": ("editlistingmanagement", "implemented", "high"),
            "messaging_inbox_screen": ("messaginginbox", "implemented", "high"),
            "chat_conversation_screen": ("chatconversation", "implemented", "high"),
            "main_settings_screen_with_white_background": ("settings", "implemented", "high"),
            "notification_settings_screen": ("notificationsettings", "implemented", "medium"),
            "security_&_account_settings": ("securitysettings", "implemented", "high"),
            "help_&_support_center": ("helpsupportcenter", "implemented", "medium"),
        }
        
        for stitch_name in stitch_screens:
            status = ScreenStatus(
                name=stitch_name,
                stitch_path=self.stitch_dir / stitch_name
            )
            
            # Chercher correspondance
            normalized_stitch = self.normalize_name(stitch_name)
            found = False
            
            # Essayer mapping connu
            if stitch_name in known_mappings:
                flutter_key, mapped_status, priority = known_mappings[stitch_name]
                for flutter_name, flutter_path in flutter_screens.items():
                    if flutter_key in self.normalize_name(flutter_name):
                        status.flutter_file = flutter_path
                        status.status = mapped_status
                        found = True
                        break
            
            # Essayer correspondance automatique
            if not found:
                for flutter_name, flutter_path in flutter_screens.items():
                    normalized_flutter = self.normalize_name(flutter_name)
                    if normalized_stitch in normalized_flutter or normalized_flutter in normalized_stitch:
                        status.flutter_file = flutter_path
                        status.status = "partial"  # Probablement partiel
                        found = True
                        break
            
            if not found:
                status.status = "missing"
                status.notes = "Screen Flutter non trouvé"
            
            results.append(status)
        
        return results
    
    def generate_report(self, results: List[ScreenStatus]) -> str:
        """Génère un rapport markdown."""
        report = []
        report.append("# 📊 Rapport de Couverture Screens Stitch\n")
        report.append(f"**Date** : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        report.append(f"**Total screens Stitch** : {len(results)}\n\n")
        
        # Statistiques
        implemented = sum(1 for r in results if r.status == "implemented")
        partial = sum(1 for r in results if r.status == "partial")
        missing = sum(1 for r in results if r.status == "missing")
        
        report.append("## 📈 Statistiques\n\n")
        report.append(f"- ✅ **Implémentés** : {implemented} ({implemented*100//len(results)}%)\n")
        report.append(f"- 🟡 **Partiels** : {partial} ({partial*100//len(results)}%)\n")
        report.append(f"- ⚠️ **Manquants** : {missing} ({missing*100//len(results)}%)\n\n")
        
        # Détails
        report.append("## 📋 Détails par Screen\n\n")
        report.append("| Screen Stitch | Screen Flutter | Statut | Notes |\n")
        report.append("|---------------|----------------|--------|-------|\n")
        
        for result in sorted(results, key=lambda x: (x.status != "implemented", x.name)):
            status_emoji = {
                "implemented": "✅",
                "partial": "🟡",
                "missing": "⚠️"
            }
            emoji = status_emoji.get(result.status, "❓")
            
            flutter_file = result.flutter_file if result.flutter_file else "-"
            notes = result.notes if result.notes else "-"
            
            report.append(f"| `{result.name}` | `{flutter_file}` | {emoji} {result.status} | {notes} |\n")
        
        # Screens manquants prioritaires
        missing_screens = [r for r in results if r.status == "missing"]
        if missing_screens:
            report.append("\n## ⚠️ Screens Manquants\n\n")
            for screen in missing_screens:
                report.append(f"- `{screen.name}`\n")
        
        return "".join(report)
    
    def run(self) -> str:
        """Exécute la vérification et génère le rapport."""
        results = self.check_coverage()
        return self.generate_report(results)

def main():
    """Point d'entrée principal."""
    project_root = Path(__file__).parent.parent
    import sys
    import io
    
    # Forcer UTF-8 pour l'encodage de sortie (Windows)
    if sys.platform == 'win32':
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    
    checker = StitchScreenChecker(project_root)
    report = checker.run()
    
    # Afficher le rapport
    print(report)
    
    # Sauvegarder le rapport
    report_path = project_root / "docs" / "STITCH_COVERAGE_REPORT.md"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(report, encoding="utf-8")
    print(f"\n✅ Rapport sauvegardé dans : {report_path}")

if __name__ == "__main__":
    main()

