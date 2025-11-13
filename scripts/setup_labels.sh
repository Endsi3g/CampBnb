#!/bin/bash
# Script pour configurer les labels GitHub
# Usage: ./scripts/setup_labels.sh

set -e

# Vérifier que gh CLI est installé
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) n'est pas installé"
    echo "Installez-le depuis: https://cli.github.com/"
    exit 1
fi

# Vérifier l'authentification
if ! gh auth status &> /dev/null; then
    echo "❌ Vous n'êtes pas authentifié avec GitHub CLI"
    echo "Exécutez: gh auth login"
    exit 1
fi

echo "🏷️  Configuration des labels GitHub..."

# Lire le fichier JSON et créer les labels
while IFS= read -r line; do
    name=$(echo "$line" | jq -r '.name')
    color=$(echo "$line" | jq -r '.color')
    description=$(echo "$line" | jq -r '.description // ""')
    
    if [ -n "$name" ] && [ "$name" != "null" ]; then
        echo "  Création du label: $name"
        gh label create "$name" \
            --color "$color" \
            --description "$description" \
            --force 2>/dev/null || \
        gh label edit "$name" \
            --color "$color" \
            --description "$description" 2>/dev/null || true
    fi
done < <(jq -c '.[]' .github/labels.json)

echo "✅ Labels configurés avec succès !"


