# Tests - Campbnb Québec

**Structure de tests pour l'application Flutter**

---

## Structure

```
test/
├── helpers/
│   ├── test_helpers.dart      # Helpers pour les tests
│   └── mocks.dart              # Mocks et fakes
├── widgets/
│   ├── custom_button_test.dart
│   ├── custom_text_field_test.dart
│   └── listing_card_test.dart
├── screens/
│   ├── login_screen_test.dart
│   ├── home_screen_test.dart
│   └── ...
├── integration/
│   └── auth_flow_test.dart
└── README.md
```

---

## Exécution des Tests

### Tous les tests

```bash
flutter test
```

### Tests spécifiques

```bash
flutter test test/widgets/custom_button_test.dart
```

### Avec couverture

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Bonnes Pratiques

### 1. Structure AAA (Arrange-Act-Assert)

```dart
testWidgets('description du test', (WidgetTester tester) async {
  // Arrange - Préparer les données
  const buttonText = 'Cliquer';
  
  // Act - Exécuter l'action
  await tester.pumpWidget(MyWidget());
  
  // Assert - Vérifier le résultat
  expect(findText(buttonText), findsOneWidget);
});
```

### 2. Tests Isolés

Chaque test doit être indépendant et ne pas dépendre d'autres tests.

### 3. Noms Descriptifs

Les noms de tests doivent décrire clairement ce qui est testé.

### 4. Utilisation des Helpers

Utiliser les helpers dans `test/helpers/test_helpers.dart` pour éviter la duplication.

---

## Types de Tests

### Tests Widget

Testent les widgets individuels et leur comportement.

### Tests d'Intégration

Testent les flows complets entre plusieurs écrans.

### Tests Unitaires

Testent la logique métier (providers, services, repositories).

---

## Mocks

Pour générer les mocks avec Mockito:

```bash
flutter pub run build_runner build
```

---

## Couverture Cible

- **Objectif**: 70%+
- **Actuel**: ~30% (à améliorer)

---

**Dernière mise à jour**: 2024

