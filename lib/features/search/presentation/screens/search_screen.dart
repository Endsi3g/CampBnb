import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/listing_card.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../features/analytics/presentation/widgets/analytics_tracker.dart';
import '../../../../shared/services/analytics_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _mixin = _SearchAnalyticsMixin();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      _mixin.trackSearch(
        query: query,
        resultsCount: 0, // TODO: Mettre à jour avec le vrai nombre
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsTracker(
 screenName: 'search',
 screenClass: 'SearchScreen',
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
 hintText: 'Rechercher...',
            border: InputBorder.none,
          ),
          onSubmitted: _handleSearch,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _handleSearch(value);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODO: Intégrer la recherche intelligente avec Gemini
          // TODO: Afficher les résultats de recherche
          ListingCard(
            listing: ListingModel(
 id: '1',
 hostId: '1',
 title: 'Résultat de recherche',
 description: 'Description',
              type: ListingType.tent,
              latitude: 46.5,
              longitude: -75.5,
 address: 'Adresse',
 city: 'Ville',
 province: 'QC',
 postalCode: 'H1A 1A1',
              pricePerNight: 50.0,
              maxGuests: 4,
              bedrooms: 1,
              bathrooms: 1,
              images: [],
              amenities: [],
            ),
            onTap: () {},
          ),
        ],
      ),
      ),
    );
  }
}

// Mixin pour le tracking analytics dans SearchScreen
class _SearchAnalyticsMixin with AnalyticsMixin {
  @override
  Future<void> trackSearch({
    required String query,
    Map<String, dynamic>? filters,
    int? resultsCount,
  }) async {
    await AnalyticsService.instance.logEvent(
 eventName: 'search',
 eventCategory: 'interaction',
 eventType: 'search',
 screenName: 'search',
      properties: {
 'query': query,
 'results_count': resultsCount,
        ...?filters,
      },
    );
  }
}

