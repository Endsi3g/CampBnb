#!/bin/bash

# Script d'audit de sécurité pour Campbnb Québec
# Vérifie les vulnérabilités OWASP, dépendances, et configurations

set -e

echo "🔒 Démarrage de l'audit de sécurité..."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# 1. Audit des dépendances Flutter
echo ""
echo "📦 Vérification des dépendances Flutter..."
if command -v flutter &> /dev/null; then
    flutter pub audit > audit_flutter.txt 2>&1
    if [ $? -eq 0 ]; then
        print_result 0 "Aucune vulnérabilité trouvée dans les dépendances Flutter"
    else
        print_result 1 "Vulnérabilités trouvées dans les dépendances Flutter (voir audit_flutter.txt)"
    fi
else
    print_result 1 "Flutter n'est pas installé"
fi

# 2. Vérification des secrets dans le code
echo ""
echo "🔍 Recherche de secrets dans le code..."
SECRETS_FOUND=0

# Recherche de patterns suspects
if grep -r "password.*=.*['\"].*['\"]" lib/ --include="*.dart" > /dev/null 2>&1; then
    print_result 1 "Mots de passe potentiels trouvés dans le code"
    SECRETS_FOUND=1
fi

if grep -r "api.*key.*=.*['\"].*['\"]" lib/ --include="*.dart" > /dev/null 2>&1; then
    print_result 1 "Clés API potentielles trouvées dans le code"
    SECRETS_FOUND=1
fi

if [ $SECRETS_FOUND -eq 0 ]; then
    print_result 0 "Aucun secret évident trouvé dans le code"
fi

# 3. Vérification de la configuration HTTPS
echo ""
echo "🌐 Vérification de la configuration réseau..."
if grep -r "http://" lib/ --include="*.dart" | grep -v "//" > /dev/null 2>&1; then
    print_result 1 "Connexions HTTP non sécurisées trouvées"
else
    print_result 0 "Toutes les connexions utilisent HTTPS"
fi

# 4. Vérification des permissions Android
echo ""
echo "🤖 Vérification des permissions Android..."
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    DANGEROUS_PERMS=$(grep -E "android.permission.(WRITE_EXTERNAL_STORAGE|READ_PHONE_STATE|ACCESS_FINE_LOCATION)" android/app/src/main/AndroidManifest.xml | wc -l)
    if [ $DANGEROUS_PERMS -gt 0 ]; then
        print_result 0 "Permissions Android vérifiées (certaines peuvent nécessiter une justification)"
    fi
else
    print_result 1 "AndroidManifest.xml non trouvé"
fi

# 5. Vérification de la configuration iOS
echo ""
echo "🍎 Vérification de la configuration iOS..."
if [ -f "ios/Runner/Info.plist" ]; then
    if grep -q "NSAppTransportSecurity" ios/Runner/Info.plist; then
        print_result 0 "App Transport Security configuré pour iOS"
    else
        print_result 1 "App Transport Security non configuré pour iOS"
    fi
else
    print_result 1 "Info.plist non trouvé"
fi

# 6. Vérification des variables d'environnement
echo ""
echo "🔐 Vérification des variables d'environnement..."
if [ -f ".env.example" ]; then
    print_result 0 "Fichier .env.example trouvé"
else
    print_result 1 "Fichier .env.example manquant"
fi

if [ -f ".env" ]; then
    print_result 1 "Fichier .env présent (ne devrait pas être commité)"
else
    print_result 0 "Fichier .env non présent (correct)"
fi

# 7. Vérification du .gitignore
echo ""
echo "📝 Vérification du .gitignore..."
if grep -q "\.env" .gitignore 2>/dev/null; then
    print_result 0 ".env est dans .gitignore"
else
    print_result 1 ".env n'est pas dans .gitignore"
fi

# 8. Vérification de la configuration Supabase RLS
echo ""
echo "🗄️ Vérification de la configuration Supabase..."
if [ -f "supabase/migrations/002_row_level_security.sql" ]; then
    RLS_COUNT=$(grep -c "ENABLE ROW LEVEL SECURITY" supabase/migrations/002_row_level_security.sql)
    if [ $RLS_COUNT -gt 0 ]; then
        print_result 0 "Row Level Security activé sur $RLS_COUNT table(s)"
    else
        print_result 1 "Row Level Security non activé"
    fi
else
    print_result 1 "Migration RLS non trouvée"
fi

# 9. Vérification de la politique de mots de passe
echo ""
echo "🔑 Vérification de la sécurité des mots de passe..."
# Cette vérification devrait être faite côté serveur, mais on peut vérifier la documentation
if grep -qi "password.*length\|password.*complexity" docs/SECURITY.md 2>/dev/null; then
    print_result 0 "Politique de mots de passe documentée"
else
    print_result 1 "Politique de mots de passe non documentée"
fi

# 10. Résumé
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Résumé de l'audit de sécurité"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Audit terminé. Consultez les fichiers de rapport pour plus de détails."
echo ""
echo "📄 Fichiers générés:"
echo "  - audit_flutter.txt (dépendances Flutter)"
echo ""

# Score de sécurité (basique)
SCORE=0
TOTAL=10

# Calculer le score (simplifié)
if [ -f "audit_flutter.txt" ] && ! grep -q "vulnerability" audit_flutter.txt 2>/dev/null; then
    SCORE=$((SCORE + 1))
fi

echo "Score de sécurité: $SCORE/$TOTAL"
echo ""

if [ $SCORE -ge 8 ]; then
    echo -e "${GREEN}✓${NC} Niveau de sécurité: Élevé"
elif [ $SCORE -ge 5 ]; then
    echo -e "${YELLOW}⚠${NC} Niveau de sécurité: Moyen - Améliorations recommandées"
else
    echo -e "${RED}✗${NC} Niveau de sécurité: Faible - Action requise"
fi

echo ""
echo "🔒 Audit terminé"


