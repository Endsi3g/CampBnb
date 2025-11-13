# Guide de Tests - Campbnb Québec

**Guide complet pour écrire et exécuter les tests Flutter**

---

## Structure des Tests

```
test/
├── helpers/
│   ├── test_helpers.dart      # Helpers réutilisables
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
# Un fichier
flutter test test/widgets/custom_button_test.dart

# Un groupe de tests
flutter test --name "CustomButton"
```

### Avec couverture

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Tests en mode watch

```bash
flutter test --watch
```

---

## Types de Tests

### 1. Tests Widget

Testent les widgets individuels et leur comportement UI.

**Exemple:**
```dart
testWidgets('affiche le texte du bouton', (WidgetTester tester) async {
  await tester.pumpWidget(
    CustomButton(text: 'Cliquer', onPressed: () {}),
  );
  
  expect(find.text('Cliquer'), findsOneWidget);
});
```

### 2. Tests d'Intégration

Testent les flows complets entre plusieurs écrans.

**Exemple:**
```dart
testWidgets('peut naviguer de login à signup', (WidgetTester tester) async {
  // Test du flow complet
});
```

### 3. Tests Unitaires

Testent la logique métier (providers, services, repositories).

---

## Bonnes Pratiques

### 1. Structure AAA (Arrange-Act-Assert)

```dart
testWidgets('description', (WidgetTester tester) async {
  // Arrange - Préparer
  const text = 'Test';
  
  // Act - Exécuter
  await tester.pumpWidget(MyWidget(text: text));
  
  // Assert - Vérifier
  expect(find.text(text), findsOneWidget);
});
```

### 2. Tests Isolés

Chaque test doit être indépendant.

### 3. Noms Descriptifs

```dart
// ✅ Bon
testWidgets('affiche une erreur quand l\'email est invalide', ...)

// ❌ Mauvais
testWidgets('test1', ...)
```

### 4. Utilisation des Helpers

Utiliser les helpers dans `test/helpers/test_helpers.dart`:

```dart
await tester.pumpWidget(
  createTestableWidget(MyWidget()),
);
```

---

## Helpers Disponibles

### `createTestableWidget`

Crée un widget testable avec Riverpod.

```dart
await tester.pumpWidget(
  createTestableWidget(
    MyWidget(),
    overrides: [/* overrides */],
  ),
);
```

### `findText`

Trouve un widget par son texte.

```dart
expect(findText('Connexion'), findsOneWidget);
```

### `tapButton`

Simule un tap sur un bouton.

```dart
await tapButton(tester, 'Se connecter');
```

### `enterText`

Entre du texte dans un champ.

```dart
await enterText(tester, find.byType(TextFormField), 'test@example.com');
```

---

## Mocks

### Génération des Mocks

```bash
flutter pub run build_runner build
```

### Utilisation

```dart
final mockAuth = MockAuthRepository();
when(mockAuth.signIn(any, any)).thenAnswer((_) async => user);
```

---

## Tests avec Riverpod

### Override des Providers

```dart
final container = ProviderContainer(
  overrides: [
    authNotifierProvider.overrideWith(
      () => MockAuthNotifier(),
    ),
  ],
);

await tester.pumpWidget(
  UncontrolledProviderScope(
    container: container,
    child: MyWidget(),
  ),
);
```

---

## Tests avec GoRouter

### Configuration

```dart
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);

await tester.pumpWidget(
  MaterialApp.router(routerConfig: router),
);
```

---

## Debugging des Tests

### Vérifier l'arbre de widgets

```dart
debugDumpApp(); // Affiche l'arbre de widgets
```

### Prendre une capture d'écran

```dart
await expectLater(
  find.byType(MyWidget),
  matchesGoldenFile('goldens/my_widget.png'),
);
```

### Attendre les animations

```dart
await tester.pumpAndSettle(); // Attend que toutes les animations soient terminées
```

---

## Couverture Cible

- **Objectif**: 70%+
- **Actuel**: ~30% (à améliorer)

### Vérifier la couverture

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Checklist Avant Commit

- [ ] Tous les tests passent (`flutter test`)
- [ ] Couverture > 70% pour nouvelles features
- [ ] Tests pour nouvelles fonctionnalités
- [ ] Tests pour bugs corrigés
- [ ] Pas de tests flaky (instables)

---

## Ressources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Cookbook](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

**Dernière mise à jour**: 2024

