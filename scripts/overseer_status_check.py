#!/usr/bin/env python3
"""
Outil de suivi automatique pour l'Overseer - Campbnb Québec

Ce script génère un rapport complet de l'état du projet :
- Couverture des screens Stitch
- État des intégrations API
- Qualité du code
- Documentation
- Tests

Usage:
    python scripts/overseer_status_check.py [--output docs/STATUS_REPORT.md]
"""

import os
import re
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, asdict
from datetime import datetime
import argparse

@dataclass
class IntegrationStatus:
    """Statut d'une intégration."""
    name: str
    status: str  # active, partial, missing, error
    config_file: str = ""
    notes: str = ""

@dataclass
class ScreenCoverage:
    """Couverture d'un screen."""
    stitch_name: str
    flutter_file: str = ""
    status: str = "missing"  # implemented, partial, missing
    priority: str = "low"  # high, medium, low

@dataclass
class ProjectStatus:
    """Statut global du projet."""
    timestamp: str
    screens_coverage: List[ScreenCoverage]
    integrations: List[IntegrationStatus]
    test_coverage: float = 0.0
    documentation_complete: float = 0.0
    total_screens: int = 0
    implemented_screens: int = 0
    partial_screens: int = 0
    missing_screens: int = 0

class OverseerStatusChecker:
    """Vérificateur de statut pour l'Overseer."""
    
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.stitch_dir = project_root / "stitch_reservation_process_screen"
        self.lib_dir = project_root / "lib"
        self.docs_dir = project_root / "docs"
        self.supabase_dir = project_root / "supabase"
        
    def check_screens_coverage(self) -> List[ScreenCoverage]:
        """Vérifie la couverture des screens Stitch."""
        coverage = []
        
        if not self.stitch_dir.exists():
            return coverage
        
        # Mapping connu screens Stitch -> Flutter
        known_mappings = {
            "welcome_screen": ("welcome_screen.dart", "implemented", "high"),
            "log_in_screen_1": ("login_screen.dart", "implemented", "high"),
            "log_in_screen_2": ("login_screen.dart", "implemented", "high"),
            "sign_up_screen": ("signup_screen.dart", "implemented", "high"),
            "onboarding_screen_1__discovery": ("onboarding_screen.dart", "partial", "high"),
            "onboarding_screen_2__easy_booking": ("onboarding_screen.dart", "partial", "high"),
            "onboarding_screen_3__become_a_host": ("onboarding_screen.dart", "partial", "high"),
            "campbnb_québec_home_screen_1": ("home_screen.dart", "implemented", "high"),
            "campbnb_québec_home_screen_2": ("home_screen.dart", "implemented", "high"),
            "search_and_results_page": ("search_screen.dart", "partial", "high"),
            "campsite_details_screen": ("listing_details_screen.dart", "partial", "high"),
            "reservation_process_screen": ("reservation_process_screen.dart", "partial", "high"),
            "reservation_request_details": ("", "missing", "high"),
            "reservation_requests_management": ("", "missing", "high"),
            "suggest_alternative_dates_screen": ("", "missing", "medium"),
            "full-screen_interactive_map": ("full_map_screen.dart", "implemented", "high"),
            "map_screen": ("map_screen.dart", "implemented", "high"),
            "user_profile_screen": ("profile_screen.dart", "partial", "medium"),
            "host_dashboard_screen": ("host_dashboard_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_1": ("add_listing_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_2": ("add_listing_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_3": ("add_listing_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_4": ("add_listing_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_5": ("add_listing_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_6": ("add_listing_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_7": ("add_listing_screen.dart", "partial", "high"),
            "add_listing_(step_1__info)_8": ("add_listing_screen.dart", "partial", "high"),
            "edit_listing_management_screen": ("", "missing", "medium"),
            "messaging_inbox_screen": ("messaging_inbox_screen.dart", "partial", "high"),
            "chat_conversation_screen": ("", "missing", "high"),
            "main_settings_screen_with_white_background": ("settings_screen.dart", "partial", "medium"),
            "notification_settings_screen": ("", "missing", "medium"),
            "security_&_account_settings": ("", "missing", "medium"),
            "help_&_support_center": ("", "missing", "low"),
        }
        
        # Trouver tous les screens Stitch
        stitch_screens = []
        if self.stitch_dir.exists():
            for item in self.stitch_dir.iterdir():
                if item.is_dir() and not item.name.startswith('.'):
                    stitch_screens.append(item.name)
        
        # Créer la liste de couverture
        for stitch_name in sorted(stitch_screens):
            if stitch_name in known_mappings:
                flutter_file, status, priority = known_mappings[stitch_name]
                # Chercher le chemin complet
                flutter_path = self._find_flutter_file(flutter_file) if flutter_file else ""
                coverage.append(ScreenCoverage(
                    stitch_name=stitch_name,
                    flutter_file=flutter_path,
                    status=status,
                    priority=priority
                ))
            else:
                coverage.append(ScreenCoverage(
                    stitch_name=stitch_name,
                    status="missing",
                    priority="low"
                ))
        
        return coverage
    
    def _find_flutter_file(self, filename: str) -> str:
        """Trouve le chemin d'un fichier Flutter."""
        for root, dirs, files in os.walk(self.lib_dir):
            if filename in files:
                return str(Path(root) / filename)
        return ""
    
    def check_integrations(self) -> List[IntegrationStatus]:
        """Vérifie l'état des intégrations."""
        integrations = []
        
        # Supabase
        supabase_config = self.project_root / ".env"
        supabase_functions = self.supabase_dir / "functions"
        has_functions = supabase_functions.exists() and any(supabase_functions.iterdir())
        
        integrations.append(IntegrationStatus(
            name="Supabase",
            status="active" if (supabase_config.exists() or has_functions) else "partial",
            config_file=".env" if supabase_config.exists() else "",
            notes="Edge Functions" if has_functions else "Configuration à vérifier"
        ))
        
        # Gemini
        gemini_service = self.lib_dir / "core" / "services" / "gemini_service.dart"
        gemini_config = self.lib_dir / "core" / "config" / "gemini_config.dart"
        integrations.append(IntegrationStatus(
            name="Gemini 2.5",
            status="active" if gemini_service.exists() and gemini_config.exists() else "partial",
            config_file=str(gemini_config.relative_to(self.project_root)) if gemini_config.exists() else "",
            notes="Service et config présents" if gemini_service.exists() else "À configurer"
        ))
        
        # Mapbox
        mapbox_config = self.lib_dir / "core" / "config" / "mapbox_config.dart"
        mapbox_service = self.lib_dir / "features" / "map" / "data" / "services" / "mapbox_service.dart"
        integrations.append(IntegrationStatus(
            name="Mapbox",
            status="active" if mapbox_config.exists() and mapbox_service.exists() else "partial",
            config_file=str(mapbox_config.relative_to(self.project_root)) if mapbox_config.exists() else "",
            notes="Service et config présents" if mapbox_service.exists() else "À configurer"
        ))
        
        # Stripe
        stripe_integration = any(
            "stripe" in str(p).lower() 
            for p in self.lib_dir.rglob("*.dart")
        )
        integrations.append(IntegrationStatus(
            name="Stripe",
            status="missing" if not stripe_integration else "partial",
            notes="À implémenter" if not stripe_integration else "Intégration en cours"
        ))
        
        # Firebase
        firebase_config = self.project_root / "firebase.json"
        firebase_integration = any(
            "firebase" in str(p).lower() 
            for p in self.lib_dir.rglob("*.dart")
        )
        integrations.append(IntegrationStatus(
            name="Firebase",
            status="partial" if firebase_integration else "missing",
            config_file="firebase.json" if firebase_config.exists() else "",
            notes="Notifications push à configurer"
        ))
        
        return integrations
    
    def check_documentation(self) -> float:
        """Vérifie la complétude de la documentation."""
        required_docs = [
            "README.md",
            "ARCHITECTURE.md",
            "SETUP.md",
            "API_DOCUMENTATION.md",
            "GEMINI_INTEGRATION.md",
            "docs/MAPBOX_INTEGRATION.md",
            "docs/STITCH_SCREENS.md",
            "docs/GIT_WORKFLOW.md",
            "OVERSEER.md",
        ]
        
        found = 0
        for doc in required_docs:
            doc_path = self.project_root / doc
            if doc_path.exists():
                found += 1
        
        return (found / len(required_docs)) * 100
    
    def check_tests(self) -> float:
        """Vérifie la couverture des tests."""
        # Estimation basée sur la présence de fichiers de test
        test_dir = self.project_root / "test"
        if not test_dir.exists():
            return 0.0
        
        test_files = list(test_dir.rglob("*_test.dart"))
        source_files = list(self.lib_dir.rglob("*.dart"))
        
        # Estimation : si on a des tests, on suppose au moins 30% de couverture
        # (c'est une estimation, pas une mesure réelle)
        if test_files:
            ratio = len(test_files) / max(len(source_files), 1)
            return min(ratio * 100, 100.0)
        
        return 0.0
    
    def generate_status_report(self) -> ProjectStatus:
        """Génère un rapport de statut complet."""
        screens = self.check_screens_coverage()
        integrations = self.check_integrations()
        
        total = len(screens)
        implemented = sum(1 for s in screens if s.status == "implemented")
        partial = sum(1 for s in screens if s.status == "partial")
        missing = sum(1 for s in screens if s.status == "missing")
        
        return ProjectStatus(
            timestamp=datetime.now().isoformat(),
            screens_coverage=screens,
            integrations=integrations,
            test_coverage=self.check_tests(),
            documentation_complete=self.check_documentation(),
            total_screens=total,
            implemented_screens=implemented,
            partial_screens=partial,
            missing_screens=missing
        )
    
    def generate_markdown_report(self, status: ProjectStatus) -> str:
        """Génère un rapport markdown."""
        report = []
        report.append("# 📊 Rapport de Statut - Campbnb Québec\n\n")
        report.append(f"**Date** : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        report.append("---\n\n")
        
        # Résumé exécutif
        report.append("## 📈 Résumé Exécutif\n\n")
        coverage_pct = (status.implemented_screens / max(status.total_screens, 1)) * 100
        report.append(f"- **Screens implémentés** : {status.implemented_screens}/{status.total_screens} ({coverage_pct:.1f}%)\n")
        report.append(f"- **Screens partiels** : {status.partial_screens}\n")
        report.append(f"- **Screens manquants** : {status.missing_screens}\n")
        report.append(f"- **Couverture tests** : {status.test_coverage:.1f}%\n")
        report.append(f"- **Documentation** : {status.documentation_complete:.1f}%\n\n")
        
        # Intégrations
        report.append("## 🔌 Intégrations\n\n")
        report.append("| Intégration | Statut | Configuration | Notes |\n")
        report.append("|-------------|--------|---------------|-------|\n")
        
        for integration in status.integrations:
            status_emoji = {
                "active": "✅",
                "partial": "🟡",
                "missing": "⚠️",
                "error": "❌"
            }
            emoji = status_emoji.get(integration.status, "❓")
            config = integration.config_file if integration.config_file else "-"
            notes = integration.notes if integration.notes else "-"
            report.append(f"| {integration.name} | {emoji} {integration.status} | `{config}` | {notes} |\n")
        
        report.append("\n")
        
        # Screens par priorité
        report.append("## 🎯 Screens par Priorité\n\n")
        
        for priority in ["high", "medium", "low"]:
            priority_screens = [s for s in status.screens_coverage if s.priority == priority]
            if not priority_screens:
                continue
            
            priority_name = {
                "high": "🔴 Haute",
                "medium": "🟡 Moyenne",
                "low": "🟢 Basse"
            }.get(priority, priority)
            
            report.append(f"### {priority_name} Priorité\n\n")
            report.append("| Screen Stitch | Screen Flutter | Statut |\n")
            report.append("|---------------|----------------|--------|\n")
            
            for screen in priority_screens:
                status_emoji = {
                    "implemented": "✅",
                    "partial": "🟡",
                    "missing": "⚠️"
                }
                emoji = status_emoji.get(screen.status, "❓")
                flutter_file = screen.flutter_file.split("/")[-1] if screen.flutter_file else "-"
                report.append(f"| `{screen.stitch_name}` | `{flutter_file}` | {emoji} {screen.status} |\n")
            
            report.append("\n")
        
        # Actions prioritaires
        missing_high = [s for s in status.screens_coverage if s.status == "missing" and s.priority == "high"]
        if missing_high:
            report.append("## ⚠️ Actions Prioritaires\n\n")
            report.append("### Screens Manquants (Haute Priorité)\n\n")
            for screen in missing_high:
                report.append(f"- [ ] `{screen.stitch_name}`\n")
            report.append("\n")
        
        # Recommandations
        report.append("## 💡 Recommandations\n\n")
        
        if status.test_coverage < 50:
            report.append(f"- ⚠️ **Tests** : Couverture actuelle {status.test_coverage:.1f}%. Objectif : 70%+\n")
        
        if status.documentation_complete < 80:
            report.append(f"- ⚠️ **Documentation** : Complétude {status.documentation_complete:.1f}%. Objectif : 100%\n")
        
        missing_integrations = [i for i in status.integrations if i.status == "missing"]
        if missing_integrations:
            report.append("- ⚠️ **Intégrations manquantes** :\n")
            for integration in missing_integrations:
                report.append(f"  - {integration.name}\n")
        
        report.append("\n---\n\n")
        report.append(f"*Rapport généré automatiquement le {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n")
        
        return "".join(report)
    
    def generate_json_report(self, status: ProjectStatus) -> str:
        """Génère un rapport JSON."""
        return json.dumps(asdict(status), indent=2, ensure_ascii=False)

def main():
    """Point d'entrée principal."""
    parser = argparse.ArgumentParser(description="Outil de suivi automatique pour l'Overseer")
    parser.add_argument(
        "--output",
        type=str,
        default="docs/STATUS_REPORT.md",
        help="Chemin du fichier de sortie (markdown)"
    )
    parser.add_argument(
        "--json",
        type=str,
        default=None,
        help="Chemin du fichier JSON de sortie (optionnel)"
    )
    parser.add_argument(
        "--format",
        choices=["markdown", "json", "both"],
        default="markdown",
        help="Format de sortie"
    )
    
    args = parser.parse_args()
    
    project_root = Path(__file__).parent.parent
    checker = OverseerStatusChecker(project_root)
    
    import sys
    # Configurer l'encodage UTF-8 pour la sortie
    if sys.stdout.encoding != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8') if hasattr(sys.stdout, 'reconfigure') else None
    
    try:
        print("Verification du statut du projet...")
    except UnicodeEncodeError:
        print("Verification du statut du projet...")
    
    status = checker.generate_status_report()
    
    if args.format in ["markdown", "both"]:
        report = checker.generate_markdown_report(status)
        output_path = project_root / args.output
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(report, encoding="utf-8")
        print(f"Rapport markdown sauvegarde : {output_path}")
    
    if args.format in ["json", "both"]:
        json_output = args.json or str(Path(args.output).with_suffix(".json"))
        json_path = project_root / json_output
        json_path.parent.mkdir(parents=True, exist_ok=True)
        json_path.write_text(checker.generate_json_report(status), encoding="utf-8")
        print(f"Rapport JSON sauvegarde : {json_path}")
    
    # Afficher un résumé
    print("\nResume :")
    print(f"  Screens : {status.implemented_screens}/{status.total_screens} implementes ({status.implemented_screens*100//max(status.total_screens,1)}%)")
    print(f"  Tests : {status.test_coverage:.1f}%")
    print(f"  Documentation : {status.documentation_complete:.1f}%")
    print(f"  Integrations actives : {sum(1 for i in status.integrations if i.status == 'active')}/{len(status.integrations)}")

if __name__ == "__main__":
    main()


