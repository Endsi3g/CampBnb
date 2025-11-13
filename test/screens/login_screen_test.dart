import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campbnb_quebec/features/auth/presentation/screens/login_screen.dart';
import 'package:campbnb_quebec/features/auth/presentation/providers/auth_provider.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('affiche le titre "Connexion"', (WidgetTester tester) async {
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
      
      // Assert
      expect(findText('Connexion'), findsOneWidget);
    });

    testWidgets('affiche le sous-titre', (WidgetTester tester) async {
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
      
      // Assert
      expect(findText('Connectez-vous à votre compte'), findsOneWidget);
    });

    testWidgets('affiche les champs email et mot de passe', (WidgetTester tester) async {
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
      
      // Assert
      expect(findText('Email'), findsOneWidget);
      expect(findText('Mot de passe'), findsOneWidget);
    });

    testWidgets('valide que l\'email est requis', (WidgetTester tester) async {
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
      
      // Tenter de soumettre sans email
      await tapButton(tester, 'Se connecter');
      await tester.pumpAndSettle();
      
      // Assert
      expect(findText('Veuillez entrer votre email'), findsOneWidget);
    });

    testWidgets('valide le format de l\'email', (WidgetTester tester) async {
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
      
      // Entrer un email invalide
      final emailField = find.byType(TextFormField).first;
      await enterText(tester, emailField, 'email-invalide');
      
      // Tenter de soumettre
      await tapButton(tester, 'Se connecter');
      await tester.pumpAndSettle();
      
      // Assert
      expect(findText('Email invalide'), findsOneWidget);
    });

    testWidgets('valide que le mot de passe est requis', (WidgetTester tester) async {
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
      
      // Entrer seulement l'email
      final emailField = find.byType(TextFormField).first;
      await enterText(tester, emailField, 'test@example.com');
      
      // Tenter de soumettre
      await tapButton(tester, 'Se connecter');
      await tester.pumpAndSettle();
      
      // Assert
      expect(findText('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('bascule la visibilité du mot de passe', (WidgetTester tester) async {
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
      
      // Trouver le bouton de visibilité
      final visibilityButton = find.byIcon(Icons.visibility);
      expect(visibilityButton, findsOneWidget);
      
      // Cliquer sur le bouton
      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();
      
      // Assert - L'icône devrait changer
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('affiche le bouton "Mot de passe oublié ?"', (WidgetTester tester) async {
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
      
      // Assert
      expect(findText('Mot de passe oublié ?'), findsOneWidget);
    });

    // Note: Test de chargement nécessite un mock plus complexe avec Riverpod
    // À implémenter avec mocktail ou mockito
  });
}

