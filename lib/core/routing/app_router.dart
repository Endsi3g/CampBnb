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
      if (!isLoggedIn && !isOnWelcome && !isOnOnboarding && !isOnLogin && !isOnSignup) {
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
      GoRoute(
 path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
 path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
 path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
 path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
 path: '/listing/:id',
        builder: (context, state) {
 // TODO: Récupérer le listing depuis l'ID
 // Pour l'instant, on utilise un listing mock
          final listing = ListingModel(
 id: state.pathParameters['id'] ?? '',
 hostId: '1',
 title: 'Camping',
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
          );
          return ListingDetailsScreen(listing: listing);
        },
      ),
      GoRoute(
 path: '/reservation/:id',
        builder: (context, state) {
 // TODO: Récupérer le listing depuis l'ID
          final listing = ListingModel(
 id: state.pathParameters['id'] ?? '',
 hostId: '1',
 title: 'Camping',
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
          );
          return ReservationProcessScreen(listing: listing);
        },
      ),
      GoRoute(
 path: '/map',
        builder: (context, state) {
          // TODO: Récupérer les listings depuis le provider
          return MapScreen(listings: []);
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
          // TODO: Récupérer les infos de conversation depuis le provider
          return ChatConversationScreen(
            conversationId: conversationId,
            recipientName: 'Utilisateur',
          );
        },
      ),
      GoRoute(
        path: '/reservations',
        builder: (context, state) => const ReservationRequestsManagementScreen(),
      ),
      GoRoute(
        path: '/reservation/:id/details',
        builder: (context, state) {
          final reservationId = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final reservation = extra?['reservation'] as ReservationModel?;
          final listing = extra?['listing'] as ListingModel?;
          final isHost = extra?['isHost'] as bool? ?? false;
          
          if (reservation == null || listing == null) {
            // TODO: Récupérer depuis le provider
            return const Scaffold(
              body: Center(child: Text('Réservation non trouvée')),
            );
          }
          
          return ReservationRequestDetailsScreen(
            reservation: reservation,
            listing: listing,
            isHost: isHost,
          );
        },
      ),
      GoRoute(
        path: '/reservation/:id/suggest-dates',
        builder: (context, state) {
          final reservationId = state.pathParameters['id'] ?? '';
          // TODO: Récupérer la réservation depuis le provider
          final reservation = ReservationModel(
            id: reservationId,
            listingId: '1',
            guestId: '1',
            checkIn: DateTime.now(),
            checkOut: DateTime.now().add(const Duration(days: 3)),
            numberOfGuests: 2,
            totalPrice: 150.0,
            status: ReservationStatus.pending,
          );
          return SuggestAlternativeDatesScreen(reservation: reservation);
        },
      ),
      GoRoute(
        path: '/host/edit-listing/:id',
        builder: (context, state) {
          final listingId = state.pathParameters['id'] ?? '';
          final listing = state.extra as ListingModel?;
          
          if (listing == null) {
            // TODO: Récupérer depuis le provider
            return const Scaffold(
              body: Center(child: Text('Camping non trouvé')),
            );
          }
          
          return EditListingManagementScreen(listing: listing);
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
            appBar: AppBar(
              title: const Text('Assistant IA'),
            ),
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
          // TODO: Créer le screen des favoris
          return const Scaffold(
            body: Center(child: Text('Favoris')),
          );
        },
      ),
    ],
  );
});

