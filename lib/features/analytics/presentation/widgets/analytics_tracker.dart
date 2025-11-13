import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/analytics_service.dart';

/// Widget pour tracker automatiquement les vues d'écran
class AnalyticsTracker extends ConsumerStatefulWidget {
  final Widget child;
  final String screenName;
  final String? screenClass;
  final Map<String, dynamic>? properties;

  const AnalyticsTracker({
    super.key,
    required this.child,
    required this.screenName,
    this.screenClass,
    this.properties,
  });

  @override
  ConsumerState<AnalyticsTracker> createState() => _AnalyticsTrackerState();
}

class _AnalyticsTrackerState extends ConsumerState<AnalyticsTracker> {
  String? _previousScreen;
  DateTime? _screenStartTime;

  @override
  void initState() {
    super.initState();
    _trackScreenView();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mettre à jour le screen précédent si nécessaire
  }

  void _trackScreenView() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _screenStartTime = DateTime.now();
      final analytics = AnalyticsService.instance;

      await analytics.logEvent(
 eventName: 'screen_view',
 eventCategory: 'navigation',
 eventType: 'screen_view',
        screenName: widget.screenName,
        screenClass: widget.screenClass ?? widget.screenName,
        previousScreen: _previousScreen,
        properties: widget.properties,
      );

 // Mettre à jour la session avec l'écran d'entrée si c'est le premier
      // (géré par le service)
    });
  }

  @override
  void dispose() {
 // Logger le temps passé sur l'écran
    if (_screenStartTime != null) {
      final duration = DateTime.now().difference(_screenStartTime!);
      AnalyticsService.instance.logEvent(
 eventName: 'screen_exit',
 eventCategory: 'navigation',
 eventType: 'screen_exit',
        screenName: widget.screenName,
        properties: {
 'duration_seconds': duration.inSeconds,
          ...?widget.properties,
        },
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mixin pour tracker facilement les interactions
mixin AnalyticsMixin {
  /// Logger un clic sur un bouton
  Future<void> trackButtonClick({
    required String buttonName,
    String? screenName,
    Map<String, dynamic>? properties,
  }) async {
    await AnalyticsService.instance.logEvent(
 eventName: 'button_click',
 eventCategory: 'interaction',
 eventType: 'button_click',
      screenName: screenName,
      properties: {
 'button_name': buttonName,
        ...?properties,
      },
    );
  }

  /// Logger une recherche
  Future<void> trackSearch({
    required String query,
    Map<String, dynamic>? filters,
    int? resultsCount,
  }) async {
    await AnalyticsService.instance.logEvent(
 eventName: 'search',
 eventCategory: 'interaction',
 eventType: 'search',
      properties: {
 'query': query,
 'results_count': resultsCount,
        ...?filters,
      },
    );
  }

  /// Logger une vue de listing
  Future<void> trackListingView({
    required String listingId,
    String? listingTitle,
    String? propertyType,
    double? price,
  }) async {
    await AnalyticsService.instance.logEvent(
 eventName: 'listing_view',
 eventCategory: 'interaction',
 eventType: 'listing_view',
      properties: {
 'listing_id': listingId,
 'listing_title': listingTitle,
 'property_type': propertyType,
 'price': price,
      },
    );
  }

  /// Logger une conversion
  Future<void> trackConversion({
    required String conversionType,
    double? conversionValue,
    String? listingId,
    String? reservationId,
    String? funnelStep,
  }) async {
    await AnalyticsService.instance.logConversion(
      conversionType: conversionType,
      conversionValue: conversionValue,
      listingId: listingId,
      reservationId: reservationId,
      funnelStep: funnelStep,
    );
  }
}



