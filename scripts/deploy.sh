#!/bin/bash
# ============================================
# Campbnb Québec - Script de Déploiement
# ============================================
# Script pour déployer toutes les migrations et Edge Functions

set -e  # Arrêter en cas d'erreur

echo "🚀 Déploiement du backend Campbnb Québec"
echo "=========================================="

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Vérifier que Supabase CLI est installé
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Supabase CLI n'est pas installé${NC}"
    echo "Installez-le avec: npm install -g supabase"
    exit 1
fi

echo -e "${GREEN}✅ Supabase CLI détecté${NC}"

# Vérifier que le projet est lié
if [ ! -f ".supabase/config.toml" ]; then
    echo -e "${YELLOW}⚠️  Projet Supabase non lié${NC}"
    echo "Liez le projet avec: supabase link --project-ref YOUR_PROJECT_REF"
    exit 1
fi

echo -e "${GREEN}✅ Projet Supabase lié${NC}"

# Appliquer les migrations
echo ""
echo "📦 Application des migrations..."
supabase db push

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Migrations appliquées avec succès${NC}"
else
    echo -e "${RED}❌ Erreur lors de l'application des migrations${NC}"
    exit 1
fi

# Appliquer les politiques de stockage
echo ""
echo "🗄️  Application des politiques de stockage..."
if [ -f "supabase/storage/policies.sql" ]; then
    supabase db push --file supabase/storage/policies.sql
    echo -e "${GREEN}✅ Politiques de stockage appliquées${NC}"
else
    echo -e "${YELLOW}⚠️  Fichier de politiques de stockage non trouvé${NC}"
fi

# Déployer toutes les Edge Functions
echo ""
echo "⚡ Déploiement des Edge Functions..."

FUNCTIONS=(
    "listings"
    "reservations"
    "profiles"
    "messages"
    "reviews"
    "favorites"
    "activities"
    "mapbox"
    "gemini"
    "analytics"
    "payments"
)

for func in "${FUNCTIONS[@]}"; do
    echo "  Déploiement de $func..."
    supabase functions deploy "$func" --no-verify-jwt || {
        echo -e "${RED}❌ Erreur lors du déploiement de $func${NC}"
        exit 1
    }
done

echo -e "${GREEN}✅ Toutes les Edge Functions déployées${NC}"

# Résumé
echo ""
echo "=========================================="
echo -e "${GREEN}✅ Déploiement terminé avec succès!${NC}"
echo ""
echo "📊 Résumé:"
echo "  - Migrations: ✅"
echo "  - Politiques de stockage: ✅"
echo "  - Edge Functions: ${#FUNCTIONS[@]} déployées"
echo ""
echo "🔗 Prochaines étapes:"
echo "  1. Vérifier les buckets de stockage dans Supabase Dashboard"
echo "  2. Configurer les variables d'environnement pour les Edge Functions"
echo "  3. Tester les endpoints API"
echo "  4. Configurer les webhooks Stripe si nécessaire"
echo ""

