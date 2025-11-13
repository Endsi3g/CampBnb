#!/bin/bash
# Script d'initialisation Git pour CampBnb
# Usage: ./scripts/init_git.sh

set -e

echo "🚀 Initialisation du repository Git pour CampBnb..."

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
    echo "❌ Git n'est pas installé"
    exit 1
fi

# Vérifier si on est déjà dans un repo Git
if [ -d .git ]; then
    echo "⚠️  Un repository Git existe déjà"
    read -p "Voulez-vous continuer ? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Initialiser Git si nécessaire
if [ ! -d .git ]; then
    echo "📦 Initialisation de Git..."
    git init
fi

# Ajouter tous les fichiers
echo "📝 Ajout des fichiers..."
git add .

# Créer le premier commit
echo "💾 Création du premier commit..."
git commit -m "first commit: Infrastructure GitHub complète pour CampBnb" || {
    echo "⚠️  Aucun changement à commiter"
}

# Renommer la branche en main
echo "🌿 Configuration de la branche main..."
git branch -M main

# Vérifier si le remote existe déjà
if git remote get-url origin &> /dev/null; then
    echo "⚠️  Le remote 'origin' existe déjà"
    read -p "Voulez-vous le remplacer ? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
        git remote add origin https://github.com/Endsi3g/CampBnb.git
    fi
else
    echo "🔗 Ajout du remote origin..."
    git remote add origin https://github.com/Endsi3g/CampBnb.git
fi

echo ""
echo "✅ Initialisation terminée !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Créez le repository sur GitHub : https://github.com/new"
echo "   - Nom : CampBnb"
echo "   - Visibilité : Public ou Private"
echo "   - NE PAS initialiser avec README, .gitignore ou license"
echo ""
echo "2. Poussez le code :"
echo "   git push -u origin main"
echo ""
echo "3. Configurez les secrets GitHub (voir docs/SETUP.md)"
echo "4. Configurez les branch protection rules"
echo "5. Exécutez scripts/setup_labels.sh pour configurer les labels"

