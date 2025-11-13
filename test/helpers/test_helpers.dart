import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Helper pour créer un MaterialApp avec Riverpod et GoRouter pour les tests
Widget createTestApp({
  required Widget child,
  List<Override>? overrides,
  GoRouter? router,
}) {
  final container = ProviderContainer(
    overrides: overrides ?? [],
  );

  if (router != null) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

/// Helper pour créer un widget testable avec Riverpod
Widget createTestableWidget(Widget child, {List<Override>? overrides}) {
  return createTestApp(
    child: child,
    overrides: overrides,
  );
}

/// Helper pour trouver un widget par type
T findWidgetByType<T>(WidgetTester tester) {
  return tester.widget<T>(find.byType(T));
}

/// Helper pour trouver un widget par texte
Finder findText(String text) {
  return find.text(text);
}

/// Helper pour trouver un widget par key
Finder findKey(Key key) {
  return find.byKey(key);
}

/// Helper pour attendre que l'animation soit terminée
Future<void> waitForAnimation(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// Helper pour simuler un tap
Future<void> tapButton(WidgetTester tester, String text) async {
  await tester.tap(findText(text));
  await tester.pumpAndSettle();
}

/// Helper pour entrer du texte dans un champ
Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Helper pour vérifier qu'un widget est visible
void expectWidgetVisible(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Helper pour vérifier qu'un widget n'est pas visible
void expectWidgetNotVisible(Finder finder) {
  expect(finder, findsNothing);
}

/// Helper pour vérifier qu'un widget est affiché plusieurs fois
void expectWidgetVisibleTimes(Finder finder, int times) {
  expect(finder, findsNWidgets(times));
}

/// Helper pour créer un mock router
GoRouter createMockRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Text('Home'),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Text('Login'),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(
          body: Text('Home'),
        ),
      ),
    ],
  );
}

