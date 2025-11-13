import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campbnb_quebec/features/home/presentation/screens/home_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('affiche l\'écran d\'accueil', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer();
      
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('affiche un champ de recherche', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer();
      
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}

