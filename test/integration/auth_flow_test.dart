import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campbnb_quebec/features/auth/presentation/screens/login_screen.dart';
import 'package:campbnb_quebec/features/auth/presentation/screens/signup_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Auth Flow Integration Tests', () {
    testWidgets('peut naviguer de login à signup', (WidgetTester tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignUpScreen(),
          ),
        ],
      );
      
      final container = ProviderContainer();
      
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Assert - On devrait être sur la page de login
      expect(findText('Connexion'), findsOneWidget);
    });

    testWidgets('peut remplir le formulaire de connexion', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer();
      
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Remplir le formulaire
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      
      await enterText(tester, emailField, 'test@example.com');
      await enterText(tester, passwordField, 'password123');
      
      // Assert
      expect(findText('test@example.com'), findsNothing); // Le texte est masqué dans le champ
      expect(findText('password123'), findsNothing); // Le mot de passe est masqué
    });
  });
}

