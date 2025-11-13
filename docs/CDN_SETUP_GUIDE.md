# Guide de Configuration CDN - Cloudflare

## Vue d'ensemble

Ce guide explique comment configurer Cloudflare CDN pour Campbnb avec distribution par région.

## Option 1: Cloudflare Pages (Recommandé)

### Configuration de Base

1. **Créer un projet Cloudflare Pages**:
   - Aller dans Cloudflare Dashboard > Workers & Pages
   - Créer une nouvelle application
   - Connecter votre repository GitHub

2. **Configurer les environnements**:
   - Production: `cdn.campbnb.com`
   - Staging: `cdn-dev.campbnb.com`

3. **Mettre à jour `cdn_config.dart`**:
```dart
static const Map<String, String> _productionCDNUrls = {
  'us-east': 'https://cdn-us-east.campbnb.com',
  'us-west': 'https://cdn-us-west.campbnb.com',
  'eu-west': 'https://cdn-eu-west.campbnb.com',
  'asia-pacific': 'https://cdn-asia.campbnb.com',
  'south-america': 'https://cdn-sa.campbnb.com',
};
```

### Routing par Région

Utiliser Cloudflare Workers pour router automatiquement:

```javascript
// worker.js
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  const region = getRegionFromRequest(request)
  
  // Router vers le bon CDN selon la région
  const cdnUrl = getCDNUrlForRegion(region)
  
  return fetch(`${cdnUrl}${url.pathname}`)
}

function getRegionFromRequest(request) {
  // Détecter la région depuis les headers Cloudflare
  const country = request.cf?.country
  const regionMap = {
    'US': 'us-east',
    'CA': 'us-east',
    'GB': 'eu-west',
    'FR': 'eu-west',
    'DE': 'eu-west',
    'JP': 'asia-pacific',
    'CN': 'asia-pacific',
    'KR': 'asia-pacific',
    'AU': 'asia-pacific',
    'MX': 'south-america',
    'BR': 'south-america',
  }
  return regionMap[country] || 'us-east'
}
```

## Option 2: Cloudflare R2 (Stockage d'Objets)

### Configuration

1. **Créer un bucket R2**:
   - Cloudflare Dashboard > R2 > Create bucket
   - Nom: `campbnb-assets`

2. **Configurer le domaine public**:
   - R2 > Manage R2 API Tokens
   - Créer un token avec permissions de lecture
   - Configurer un domaine custom: `cdn.campbnb.com`

3. **Uploader les assets**:
```bash
# Utiliser wrangler CLI
npm install -g wrangler
wrangler r2 bucket create campbnb-assets
wrangler r2 object put campbnb-assets/images/logo.png --file=./assets/images/logo.png
```

4. **Mettre à jour la configuration**:
```dart
static const String _fallbackCDN = 'https://cdn.campbnb.com';
```

## Option 3: Cloudflare Workers avec Routing Intelligent

### Configuration Complète

1. **Créer un Worker**:
```javascript
// cloudflare-worker.js
export default {
  async fetch(request, env) {
    const url = new URL(request.url)
    const path = url.pathname
    
    // Détecter la région
    const region = detectRegion(request)
    
    // Router vers le bon endpoint
    const cdnEndpoint = getCDNEndpoint(region)
    
    // Proxy la requête
    const response = await fetch(`${cdnEndpoint}${path}`, {
      method: request.method,
      headers: request.headers,
    })
    
    // Ajouter les headers de cache
    const newHeaders = new Headers(response.headers)
    newHeaders.set('Cache-Control', 'public, max-age=31536000')
    newHeaders.set('CDN-Region', region)
    
    return new Response(response.body, {
      status: response.status,
      headers: newHeaders,
    })
  }
}

function detectRegion(request) {
  const country = request.cf?.country
  // Mapping pays -> région CDN
  const mapping = {
    'US': 'us-east', 'CA': 'us-east',
    'GB': 'eu-west', 'FR': 'eu-west', 'DE': 'eu-west', 'ES': 'eu-west',
    'JP': 'asia-pacific', 'CN': 'asia-pacific', 'KR': 'asia-pacific',
    'MX': 'south-america', 'BR': 'south-america',
  }
  return mapping[country] || 'us-east'
}

function getCDNEndpoint(region) {
  const endpoints = {
    'us-east': 'https://r2-us-east.campbnb.com',
    'us-west': 'https://r2-us-west.campbnb.com',
    'eu-west': 'https://r2-eu-west.campbnb.com',
    'asia-pacific': 'https://r2-asia.campbnb.com',
    'south-america': 'https://r2-sa.campbnb.com',
  }
  return endpoints[region] || endpoints['us-east']
}
```

2. **Déployer le Worker**:
```bash
wrangler publish
```

3. **Configurer le domaine**:
   - Workers & Pages > Routes
   - Ajouter: `cdn.campbnb.com/*`

## Configuration dans l'Application

### Mettre à jour `cdn_config.dart`

```dart
// Production - Cloudflare Pages
static const Map<String, String> _productionCDNUrls = {
  'us-east': 'https://cdn-us-east.campbnb.com',
  'us-west': 'https://cdn-us-west.campbnb.com',
  'eu-west': 'https://cdn-eu-west.campbnb.com',
  'asia-pacific': 'https://cdn-asia.campbnb.com',
  'south-america': 'https://cdn-sa.campbnb.com',
};

// Ou utiliser un seul endpoint avec routing
static const Map<String, String> _productionCDNUrls = {
  'us-east': 'https://cdn.campbnb.com/us-east',
  'us-west': 'https://cdn.campbnb.com/us-west',
  'eu-west': 'https://cdn.campbnb.com/eu-west',
  'asia-pacific': 'https://cdn.campbnb.com/asia',
  'south-america': 'https://cdn.campbnb.com/sa',
};
```

## Optimisation des Images

### Cloudflare Images (Recommandé)

1. **Activer Cloudflare Images**:
   - Dashboard > Images
   - Créer un compte

2. **Utiliser dans l'application**:
```dart
static String getOptimizedImageUrl({
  required String imagePath,
  required String regionCode,
  int? width,
  int? height,
  String? format,
}) {
  final cdnUrl = getCdnUrlForRegion(regionCode);
  final params = <String>[];
  
  if (width != null) params.add('w=$width');
  if (height != null) params.add('h=$height');
  if (format != null) params.add('f=$format');
  
  // Cloudflare Images format
  return '$cdnUrl/cdn-cgi/image/${params.join(',')}/$imagePath';
}
```

## Variables d'Environnement

Ajouter dans `.env`:
```env
CLOUDFLARE_ACCOUNT_ID=your_account_id
CLOUDFLARE_API_TOKEN=your_api_token
CDN_DOMAIN=cdn.campbnb.com
```

## Tests

### Vérifier la Configuration

```dart
// Test dans l'application
void testCDN() {
  final url = CDNService.getCdnUrlForRegion('CA-QC');
  print('CDN URL for CA-QC: $url');
  // Devrait retourner: https://cdn-us-east.campbnb.com
}
```

### Tester avec curl

```bash
# Tester depuis différentes régions
curl -H "CF-IPCountry: US" https://cdn.campbnb.com/test.jpg
curl -H "CF-IPCountry: FR" https://cdn.campbnb.com/test.jpg
curl -H "CF-IPCountry: JP" https://cdn.campbnb.com/test.jpg
```

## Monitoring

### Cloudflare Analytics

1. **Dashboard Analytics**:
   - Voir les requêtes par région
   - Analyser les performances
   - Identifier les problèmes

2. **Métriques à suivre**:
   - Bandwidth par région
   - Cache hit ratio
   - Latence par région
   - Erreurs 4xx/5xx

## Coûts Estimés

### Cloudflare Pages
- Gratuit jusqu'à 500 builds/mois
- $20/mois pour plus de builds

### Cloudflare R2
- $0.015/GB stockage
- $0.36/GB sortie (premier 10GB gratuit/mois)

### Cloudflare Workers
- Gratuit jusqu'à 100,000 requêtes/jour
- $5/mois pour 10M requêtes

## Checklist de Déploiement

- [ ] Créer les buckets/workers Cloudflare
- [ ] Configurer les domaines
- [ ] Uploader les assets
- [ ] Mettre à jour `cdn_config.dart`
- [ ] Tester depuis différentes régions
- [ ] Configurer le monitoring
- [ ] Documenter les URLs de production

## Support

- [Cloudflare Documentation](https://developers.cloudflare.com/)
- [Cloudflare Community](https://community.cloudflare.com/)
- [R2 Documentation](https://developers.cloudflare.com/r2/)

---

**Dernière mise à jour**: 2024
**Responsable**: Équipe DevOps

