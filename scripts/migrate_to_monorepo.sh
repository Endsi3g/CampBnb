#!/bin/bash
# Script de migration vers le monorepo
# Usage: ./scripts/migrate_to_monorepo.sh

set -e

echo "🚀 Migration vers le monorepo Campbnb Québec..."

# Vérifier que nous sommes à la racine du projet
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté à la racine du projet"
    exit 1
fi

# Créer la structure si elle n'existe pas
echo "📁 Création de la structure..."
mkdir -p packages/shared/lib
mkdir -p packages/shared/assets

# Déplacer le code
if [ -d "lib/core" ]; then
    echo "📦 Déplacement de lib/core..."
    cp -r lib/core packages/shared/lib/
fi

if [ -d "lib/features" ]; then
    echo "📦 Déplacement de lib/features..."
    cp -r lib/features packages/shared/lib/
fi

if [ -d "lib/shared" ]; then
    echo "📦 Déplacement de lib/shared..."
    cp -r lib/shared packages/shared/lib/
fi

# Déplacer les assets
if [ -d "assets" ]; then
    echo "🎨 Déplacement des assets..."
    cp -r assets packages/shared/
fi

# Déplacer les fichiers de configuration si nécessaire
if [ -f "analysis_options.yaml" ]; then
    echo "⚙️  Copie de analysis_options.yaml..."
    cp analysis_options.yaml packages/shared/
fi

echo ""
echo "✅ Migration terminée!"
echo ""
echo "📝 Prochaines étapes :"
echo "   1. Vérifier que le code a été correctement déplacé"
echo "   2. Installer les dépendances :"
echo "      cd packages/shared && flutter pub get"
echo "      cd ../mobile && flutter pub get"
echo "      cd ../web && flutter pub get"
echo "   3. Tester les applications :"
echo "      cd packages/mobile && flutter run"
echo "      cd packages/web && flutter run -d chrome"
echo ""
echo "⚠️  Note: Le code original dans lib/ n'a pas été supprimé."
echo "   Vous pouvez le supprimer manuellement après vérification."

