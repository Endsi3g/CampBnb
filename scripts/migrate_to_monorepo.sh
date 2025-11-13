#!/bin/bash
# Script de migration vers le monorepo
# Usage: ./scripts/migrate_to_monorepo.sh [--skip-existing]

set -e

SKIP_EXISTING=false

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-existing)
            SKIP_EXISTING=true
            shift
            ;;
        *)
            echo "Usage: $0 [--skip-existing]"
            exit 1
            ;;
    esac
done

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Changer vers le répertoire racine du projet
cd "$PROJECT_ROOT"

echo "Migration vers le monorepo Campbnb Quebec..."

# Vérifier que nous sommes à la racine du projet
if [ ! -f "pubspec.yaml" ]; then
    echo "ERREUR: Ce script doit etre execute a la racine du projet"
    echo "Repertoire actuel: $PROJECT_ROOT"
    exit 1
fi

# Créer la structure si elle n'existe pas
echo "Creation de la structure..."
mkdir -p packages/shared/lib
mkdir -p packages/shared/assets

# Fonction pour copier un dossier
copy_directory_if_exists() {
    local source="$1"
    local dest="$2"
    local desc="$3"
    
    if [ -d "$source" ]; then
        echo "$desc..."
        
        # Vérifier si la destination existe déjà
        if [ -d "$dest" ] && [ "$SKIP_EXISTING" = false ]; then
            echo "  ATTENTION: $dest existe deja. Utilisez --skip-existing pour ecraser."
            return
        fi
        
        # Supprimer la destination si elle existe et qu'on veut écraser
        if [ -d "$dest" ] && [ "$SKIP_EXISTING" = true ]; then
            rm -rf "$dest"
        fi
        
        cp -r "$source" "$dest"
        echo "  OK: $source -> $dest"
    else
        echo "  SKIP: $source n'existe pas"
    fi
}

# Déplacer le code
copy_directory_if_exists "lib/core" "packages/shared/lib/core" "Deplacement de lib/core"
copy_directory_if_exists "lib/features" "packages/shared/lib/features" "Deplacement de lib/features"
copy_directory_if_exists "lib/shared" "packages/shared/lib/shared" "Deplacement de lib/shared"

# Déplacer les assets
if [ -d "assets" ]; then
    echo "Deplacement des assets..."
    
    if [ -d "packages/shared/assets" ] && [ "$SKIP_EXISTING" = false ]; then
        echo "  ATTENTION: packages/shared/assets existe deja. Utilisez --skip-existing pour ecraser."
    else
        if [ -d "packages/shared/assets" ] && [ "$SKIP_EXISTING" = true ]; then
            rm -rf packages/shared/assets
        fi
        cp -r assets packages/shared/
        echo "  OK: assets -> packages/shared/assets"
    fi
else
    echo "  SKIP: assets n'existe pas"
fi

# Déplacer les fichiers de configuration si nécessaire
if [ -f "analysis_options.yaml" ]; then
    echo "Copie de analysis_options.yaml..."
    
    if [ -f "packages/shared/analysis_options.yaml" ] && [ "$SKIP_EXISTING" = false ]; then
        echo "  ATTENTION: packages/shared/analysis_options.yaml existe deja. Utilisez --skip-existing pour ecraser."
    else
        cp analysis_options.yaml packages/shared/
        echo "  OK: analysis_options.yaml -> packages/shared/analysis_options.yaml"
    fi
fi

echo ""
echo "Migration terminee!"
echo ""
echo "Prochaines etapes :"
echo "  1. Verifier que le code a ete correctement deplace"
echo "  2. Installer les dependances :"
echo "     cd packages/shared && flutter pub get"
echo "     cd ../mobile && flutter pub get"
echo "     cd ../web && flutter pub get"
echo "  3. Tester les applications :"
echo "     cd packages/mobile && flutter run"
echo "     cd packages/web && flutter run -d chrome"
echo ""
echo "NOTE: Le code original dans lib/ n'a pas ete supprime."
echo "     Vous pouvez le supprimer manuellement apres verification."

