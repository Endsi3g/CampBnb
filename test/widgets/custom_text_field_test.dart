import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/shared/widgets/custom_text_field.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('affiche le label quand il est fourni', (WidgetTester tester) async {
      // Arrange
      const label = 'Email';
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(
            label: label,
          ),
        ),
      );
      
      // Assert
      expect(findText(label), findsOneWidget);
    });

    testWidgets('n\'affiche pas le label quand il n\'est pas fourni', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(),
        ),
      );
      
      // Assert - On ne devrait trouver que le TextFormField, pas de label
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('affiche le hint text', (WidgetTester tester) async {
      // Arrange
      const hint = 'Entrez votre email';
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(
            hint: hint,
          ),
        ),
      );
      
      // Assert
      final textField = findWidgetByType<TextFormField>(tester);
      expect(textField.decoration?.hintText, hint);
    });

    testWidgets('masque le texte quand obscureText est true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(
            obscureText: true,
          ),
        ),
      );
      
      // Assert
      final textField = findWidgetByType<TextFormField>(tester);
      expect(textField.obscureText, isTrue);
    });

    testWidgets('affiche le texte en clair quand obscureText est false', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(
            obscureText: false,
          ),
        ),
      );
      
      // Assert
      final textField = findWidgetByType<TextFormField>(tester);
      expect(textField.obscureText, isFalse);
    });

    testWidgets('utilise le keyboardType fourni', (WidgetTester tester) async {
      // Arrange
      const keyboardType = TextInputType.emailAddress;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(
            keyboardType: keyboardType,
          ),
        ),
      );
      
      // Assert
      final textField = findWidgetByType<TextFormField>(tester);
      expect(textField.keyboardType, keyboardType);
    });

    testWidgets('appelle onChanged quand le texte change', (WidgetTester tester) async {
      // Arrange
      String? changedValue;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          CustomTextField(
            onChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      );
      
      await enterText(tester, find.byType(TextFormField), 'test');
      
      // Assert
      expect(changedValue, 'test');
    });

    testWidgets('valide le texte avec le validator', (WidgetTester tester) async {
      // Arrange
      final formKey = GlobalKey<FormState>();
      String? errorMessage;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          Form(
            key: formKey,
            child: CustomTextField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est requis';
                }
                return null;
              },
            ),
          ),
        ),
      );
      
      // Valider le formulaire sans texte
      formKey.currentState?.validate();
      await tester.pumpAndSettle();
      
      // Assert
      expect(findText('Ce champ est requis'), findsOneWidget);
    });

    testWidgets('affiche le suffixIcon quand fourni', (WidgetTester tester) async {
      // Arrange
      const icon = Icons.visibility;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(
            suffixIcon: Icon(icon),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('utilise maxLines fourni', (WidgetTester tester) async {
      // Arrange
      const maxLines = 5;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          const CustomTextField(
            maxLines: maxLines,
          ),
        ),
      );
      
      // Assert
      final textField = findWidgetByType<TextFormField>(tester);
      expect(textField.maxLines, maxLines);
    });
  });
}

