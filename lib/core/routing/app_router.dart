import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/listing/presentation/screens/listing_details_screen.dart';
import '../../features/reservation/presentation/screens/reservation_process_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_settings_screen.dart';
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/host/presentation/screens/host_dashboard_screen.dart';
import '../../features/host/presentation/screens/add_listing_screen.dart';
import '../../features/messaging/presentation/screens/messaging_inbox_screen.dart';
import '../../features/messaging/presentation/screens/chat_conversation_screen.dart';
import '../../features/reservation/presentation/screens/reservation_request_details_screen.dart';
import '../../features/reservation/presentation/screens/reservation_requests_management_screen.dart';
import '../../features/reservation/presentation/screens/suggest_alternative_dates_screen.dart';
import '../../features/host/presentation/screens/edit_listing_management_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/help_support_center_screen.dart';
import '../../features/settings/presentation/screens/security_settings_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/listing/presentation/providers/listing_provider.dart';
import '../../features/reservation/presentation/providers/reservation_provider.dart';
import '../../features/map/presentation/providers/map_providers.dart';
import '../../features/map/domain/entities/campsite_location.dart';
import '../../features/messaging/presentation/providers/message_provider.dart';
import '../../features/messaging/domain/repositories/message_repository.dart';
import '../../features/ai_chat/widgets/gemini_chat_widget.dart';
import '../../shared/models/listing_model.dart';
import '../../shared/models/reservation_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isOnWelcome = state.matchedLocation == '/welcome';
      final isOnOnboarding = state.matchedLocation == '/onboarding';
      final isOnLogin = state.matchedLocation == '/login';
      final isOnSignup = state.matchedLocation == '/signup';

      // Si l'utilisateur n'est pas connecté et n'est pas sur une page d'auth
      if (!isLoggedIn &&
          !isOnWelcome &&
          !isOnOnboarding &&
          !isOnLogin &&
          !isOnSignup) {
        return '/welcome';
      }

      // Si l'utilisateur est connecté et est sur la page welcome
      if (isLoggedIn && isOnWelcome) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) {
          final listingId = state.pathParameters['id'] ?? '';
          final ref = ProviderScope.containerOf(context);
          final listingAsync = ref.read(listingByIdProvider(listingId));

          return FutureBuilder<ListingModel>(
            future: listingAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Erreur')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${snapshot.error ?? 'Listing non trouvé'}',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Retour à l\'accueil'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListingDetailsScreen(listing: snapshot.data!);
            },
          );
        },
      ),
      GoRoute(
        path: '/reservation/:id',
        builder: (context, state) {
          final listingId = state.pathParameters['id'] ?? '';
          final ref = ProviderScope.containerOf(context);
          final listingAsync = ref.read(listingByIdProvider(listingId));

          return FutureBuilder<ListingModel>(
            future: listingAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Erreur')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${snapshot.error ?? 'Listing non trouvé'}',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Retour à l\'accueil'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ReservationProcessScreen(listing: snapshot.data!);
            },
          );
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) {
          final ref = ProviderScope.containerOf(context);
          final campsitesAsync = ref.read(campsitesProvider);

          return FutureBuilder<List<CampsiteLocation>>(
            future: campsitesAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final listings =
                  snapshot.data?.map((campsite) {
                    return ListingModel(
                      id: campsite.id,
                      hostId: campsite.hostId,
                      title: campsite.name,
                      description: campsite.description ?? '',
                      type: _mapCampsiteTypeToListingType(campsite.type),
                      latitude: campsite.latitude,
                      longitude: campsite.longitude,
                      address: campsite.address ?? '',
                      city: campsite.city ?? '',
                      province: campsite.province ?? 'QC',
                      postalCode: '',
                      pricePerNight: campsite.pricePerNight ?? 0.0,
                      maxGuests: 4,
                      bedrooms: 0,
                      bathrooms: 0,
                      images: campsite.imageUrl != null
                          ? [campsite.imageUrl!]
                          : [],
                      amenities: [],
                    );
                  }).toList() ??
                  [];

              return MapScreen(listings: listings);
            },
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/analytics/dashboard',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/host/dashboard',
        builder: (context, state) => const HostDashboardScreen(),
      ),
      GoRoute(
        path: '/host/add-listing',
        builder: (context, state) => const AddListingScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagingInboxScreen(),
      ),
      GoRoute(
        path: '/messages/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'] ?? '';
          final ref = ProviderScope.containerOf(context);
          // Récupérer les infos de conversation depuis le provider
          final conversationAsync = ref.read(
            conversationByIdProvider(conversationId),
          );

          return FutureBuilder<Map<String, dynamic>>(
            future: conversationAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final recipientName =
                  snapshot.data?['recipientName'] as String? ?? 'Utilisateur';

              return ChatConversationScreen(
                conversationId: conversationId,
                recipientName: recipientName,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/reservations',
        builder: (context, state) =>
            const ReservationRequestsManagementScreen(),
      ),
      GoRoute(
        path: '/reservation/:id/details',
        builder: (context, state) {
          final reservationId = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final isHost = extra?['isHost'] as bool? ?? false;
          final ref = ProviderScope.containerOf(context);

          final reservationAsync = ref.read(
            reservationByIdProvider(reservationId),
          );

          return FutureBuilder<ReservationModel>(
            future: reservationAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: Text('Réservation non trouvée')),
                );
              }

              final reservation = snapshot.data!;
              final listingAsync = ref.read(
                listingByIdProvider(reservation.listingId),
              );

              return FutureBuilder<ListingModel>(
                future: listingAsync,
                builder: (context, listingSnapshot) {
                  if (listingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (listingSnapshot.hasError || !listingSnapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: Text('Listing non trouvé')),
                    );
                  }

                  return ReservationRequestDetailsScreen(
                    reservation: reservation,
                    listing: listingSnapshot.data!,
                    isHost: isHost,
                  );
                },
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/reservation/:id/suggest-dates',
        builder: (context, state) {
          final reservationId = state.pathParameters['id'] ?? '';
          final ref = ProviderScope.containerOf(context);
          final reservationAsync = ref.read(
            reservationByIdProvider(reservationId),
          );

          return FutureBuilder<ReservationModel>(
            future: reservationAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: Text('Réservation non trouvée')),
                );
              }

              return SuggestAlternativeDatesScreen(reservation: snapshot.data!);
            },
          );
        },
      ),
      GoRoute(
        path: '/host/edit-listing/:id',
        builder: (context, state) {
          final listingId = state.pathParameters['id'] ?? '';
          final listing = state.extra as ListingModel?;
          final ref = ProviderScope.containerOf(context);

          if (listing != null) {
            return EditListingManagementScreen(listing: listing);
          }

          // Récupérer depuis le provider si non fourni
          final listingAsync = ref.read(listingByIdProvider(listingId));

          return FutureBuilder<ListingModel>(
            future: listingAsync,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: Text('Camping non trouvé')),
                );
              }

              return EditListingManagementScreen(listing: snapshot.data!);
            },
          );
        },
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpSupportCenterScreen(),
      ),
      GoRoute(
        path: '/help/chat',
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Assistant IA')),
            body: GeminiChatWidget(
              title: 'Assistant Campbnb',
              userContext: 'Aide et support',
            ),
          );
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) {
          // Screen des favoris - à implémenter
          return const Scaffold(
            appBar: AppBar(title: Text('Mes Favoris')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64),
                  SizedBox(height: 16),
                  Text('Fonctionnalité à venir'),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
});

/// Helper pour mapper CampsiteType vers ListingType
ListingType _mapCampsiteTypeToListingType(CampsiteType type) {
  switch (type) {
    case CampsiteType.tent:
      return ListingType.tent;
    case CampsiteType.rv:
      return ListingType.rv;
    case CampsiteType.cabin:
      return ListingType.readyToCamp;
    case CampsiteType.wild:
      return ListingType.wild;
    default:
      return ListingType.tent;
  }
}
