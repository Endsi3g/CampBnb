import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Note: Pour générer les mocks, exécuter:
// flutter pub run build_runner build

/// Mock de base pour les tests
@GenerateMocks([])
void main() {}

/// Helper pour créer un ProviderContainer avec des overrides mockés
ProviderContainer createMockContainer({
  List<Override>? overrides,
}) {
  return ProviderContainer(
    overrides: overrides ?? [],
  );
}

