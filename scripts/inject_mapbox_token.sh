#!/bin/bash

# Script pour injecter le token Mapbox depuis .env dans les fichiers de configuration

# Charger les variables d'environnement depuis .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  Fichier .env non trouvé. Créez-le avec MAPBOX_ACCESS_TOKEN=your_token"
    exit 1
fi

# Vérifier que le token existe
if [ -z "$MAPBOX_ACCESS_TOKEN" ]; then
    echo "⚠️  MAPBOX_ACCESS_TOKEN non défini dans .env"
    exit 1
fi

echo "🔧 Injection du token Mapbox..."

# Android - strings.xml
if [ -f "android/app/src/main/res/values/strings.xml" ]; then
    # Remplacer le token dans strings.xml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|YOUR_MAPBOX_ACCESS_TOKEN|$MAPBOX_ACCESS_TOKEN|g" android/app/src/main/res/values/strings.xml
    else
        # Linux
        sed -i "s|YOUR_MAPBOX_ACCESS_TOKEN|$MAPBOX_ACCESS_TOKEN|g" android/app/src/main/res/values/strings.xml
    fi
    echo "✅ Token injecté dans android/app/src/main/res/values/strings.xml"
else
    echo "⚠️  Fichier strings.xml non trouvé"
fi

# iOS - Info.plist
if [ -f "ios/Runner/Info.plist" ]; then
    # Remplacer le token dans Info.plist
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|YOUR_MAPBOX_ACCESS_TOKEN|$MAPBOX_ACCESS_TOKEN|g" ios/Runner/Info.plist
    else
        # Linux
        sed -i "s|YOUR_MAPBOX_ACCESS_TOKEN|$MAPBOX_ACCESS_TOKEN|g" ios/Runner/Info.plist
    fi
    echo "✅ Token injecté dans ios/Runner/Info.plist"
else
    echo "⚠️  Fichier Info.plist non trouvé"
fi

echo "✅ Injection terminée !"

