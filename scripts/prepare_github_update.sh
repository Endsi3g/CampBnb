#!/bin/bash
# Script Bash pour préparer la mise à jour GitHub
# Usage: ./scripts/prepare_github_update.sh

echo "🚀 Préparation de la mise à jour GitHub"
echo ""

# Vérifier l'état Git
echo "📊 Vérification de l'état Git..."
status=$(git status --short)
if [ -n "$status" ]; then
    echo "✅ Fichiers modifiés détectés:"
    echo "$status"
else
    echo "⚠️  Aucun fichier modifié détecté"
fi

echo ""
echo "📝 Derniers commits:"
git log --oneline -5

echo ""
echo "🔍 Vérification des fichiers importants..."

# Vérifier les fichiers clés
files=(
    "ANALYSE_PROJET_COMPLETE_2024.md"
    "docs/CHANGELOG.md"
    "docs/TIMEOUTS_ET_CACHE.md"
    "docs/VERIFICATION_CACHE.md"
    "lib/core/cache/cache_service.dart"
    "lib/core/services/reservation_timeout_service.dart"
    "supabase/functions/reservation-timeouts/index.ts"
    "supabase/migrations/006_reservation_timeouts.sql"
    "supabase/migrations/007_search_optimization.sql"
)

all_exist=true
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (manquant)"
        all_exist=false
    fi
done

echo ""
if [ "$all_exist" = true ]; then
    echo "✅ Tous les fichiers importants sont présents"
else
    echo "⚠️  Certains fichiers sont manquants"
fi

echo ""
echo "📋 Commandes suggérées:"
echo ""
echo "1. Ajouter tous les fichiers:"
echo "   git add ."
echo ""
echo "2. Vérifier les fichiers ajoutés:"
echo "   git status"
echo ""
echo "3. Commit avec message:"
echo "   git commit -m 'feat: Ajout timeouts automatiques, cache persistant et optimisations recherche'"
echo ""
echo "4. Push vers GitHub:"
echo "   git push origin main"
echo ""

# Proposer d'exécuter les commandes
read -p "Voulez-vous exécuter ces commandes maintenant? (O/N) " response
if [[ "$response" =~ ^[Oo]$ ]]; then
    echo ""
    echo "📦 Ajout des fichiers..."
    git add .
    
    echo ""
    echo "📝 Création du commit..."
    git commit -m "feat: Ajout timeouts automatiques, cache persistant et optimisations recherche

✨ Nouvelles fonctionnalités:
- Timeouts automatiques pour réservations (annulation après 24h)
- Cache persistant avec Hive (support offline)
- Optimisation recherche full-text PostgreSQL
- Interface de debug dans les paramètres

🔧 Améliorations:
- Performance recherche 10x plus rapide
- Support offline partiel
- Gestion automatique réservations expirées

📚 Documentation:
- Guide timeouts et cache
- Guide vérification cache
- Analyse complète projet 2024

🧪 Tests:
- 11 tests unitaires cache
- Validateur de cache
- Scripts de test"
    
    echo ""
    echo "🚀 Push vers GitHub..."
    branch=$(git branch --show-current)
    echo "Branche actuelle: $branch"
    
    read -p "Pousser vers GitHub? (O/N) " push_response
    if [[ "$push_response" =~ ^[Oo]$ ]]; then
        git push origin "$branch"
        echo ""
        echo "✅ Mise à jour GitHub terminée!"
    else
        echo ""
        echo "ℹ️  Commit créé localement. Push manuel requis."
    fi
else
    echo ""
    echo "ℹ️  Commandes préparées. Exécution manuelle requise."
fi

echo ""

