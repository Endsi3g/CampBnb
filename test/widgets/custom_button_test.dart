import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/shared/widgets/custom_button.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('affiche le texte du bouton', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Cliquer ici';
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomButton(
            text: buttonText,
            onPressed: null,
          ),
        ),
      );
      
      // Assert
      expect(findText(buttonText), findsOneWidget);
    });

    testWidgets('appelle onPressed quand le bouton est cliqué', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          CustomButton(
            text: 'Cliquer',
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      );
      
      await tapButton(tester, 'Cliquer');
      
      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('n\'appelle pas onPressed quand isLoading est true', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          CustomButton(
            text: 'Cliquer',
            isLoading: true,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      );
      
      await tester.tap(findText('Cliquer'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(wasPressed, isFalse);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('affiche un CircularProgressIndicator quand isLoading est true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomButton(
            text: 'Chargement',
            isLoading: true,
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('utilise les couleurs personnalisées', (WidgetTester tester) async {
      // Arrange
      const backgroundColor = Colors.red;
      const textColor = Colors.blue;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomButton(
            text: 'Bouton',
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        ),
      );
      
      // Assert
      final button = findWidgetByType<ElevatedButton>(tester);
      expect(button.style?.backgroundColor?.resolve({}), backgroundColor);
      expect(button.style?.foregroundColor?.resolve({}), textColor);
    });

    testWidgets('utilise la largeur personnalisée', (WidgetTester tester) async {
      // Arrange
      const customWidth = 200.0;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomButton(
            text: 'Bouton',
            width: customWidth,
          ),
        ),
      );
      
      // Assert
      final sizedBox = findWidgetByType<SizedBox>(tester);
      expect(sizedBox.width, customWidth);
    });

    testWidgets('utilise la hauteur personnalisée', (WidgetTester tester) async {
      // Arrange
      const customHeight = 60.0;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomButton(
            text: 'Bouton',
            height: customHeight,
          ),
        ),
      );
      
      // Assert
      final sizedBox = findWidgetByType<SizedBox>(tester);
      expect(sizedBox.height, customHeight);
    });

    testWidgets('bouton désactivé ne peut pas être cliqué', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          CustomButton(
            text: 'Désactivé',
            onPressed: null, // Désactivé
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      );
      
      // Le bouton devrait être null, donc onPressed ne devrait pas être appelé
      final button = findWidgetByType<ElevatedButton>(tester);
      expect(button.onPressed, isNull);
    });
  });
}

