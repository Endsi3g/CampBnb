import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/shared/widgets/listing_card.dart';
import 'package:campbnb_quebec/shared/models/listing_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ListingCard Widget Tests', () {
    final mockListing = ListingModel(
      id: '1',
      hostId: 'host1',
      title: 'Camping Test',
      description: 'Description test',
      type: ListingType.tent,
      latitude: 46.8139,
      longitude: -71.2080,
      address: '123 Rue Test',
      city: 'Québec',
      province: 'QC',
      postalCode: 'G1A 1A1',
      pricePerNight: 50.0,
      maxGuests: 4,
      bedrooms: 2,
      bathrooms: 1,
      images: ['https://example.com/image.jpg'],
      amenities: [],
      status: ListingStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('affiche le titre du listing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          ListingCard(listing: mockListing),
        ),
      );
      
      // Assert
      expect(findText(mockListing.title), findsOneWidget);
    });

    testWidgets('affiche la ville et la province', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          ListingCard(listing: mockListing),
        ),
      );
      
      // Assert
      expect(findText('${mockListing.city}, ${mockListing.province}'), findsOneWidget);
    });

    testWidgets('affiche le prix par nuit', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          ListingCard(listing: mockListing),
        ),
      );
      
      // Assert
      expect(findText('\$${mockListing.pricePerNight.toStringAsFixed(0)}'), findsOneWidget);
    });

    testWidgets('appelle onTap quand la carte est cliquée', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          ListingCard(
            listing: mockListing,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      );
      
      await tester.tap(find.byType(ListingCard));
      await tester.pumpAndSettle();
      
      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('affiche une icône par défaut quand il n\'y a pas d\'images', (WidgetTester tester) async {
      // Arrange
      final listingWithoutImages = mockListing.copyWith(
        images: const [],
      );
      
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          ListingCard(listing: listingWithoutImages),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('affiche le badge "Populaire"', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          ListingCard(listing: mockListing),
        ),
      );
      
      // Assert
      expect(findText('Populaire'), findsOneWidget);
    });

    testWidgets('affiche le type de listing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestableWidget(
          ListingCard(listing: mockListing),
        ),
      );
      
      // Assert - Le type devrait être affiché (Tente pour tent)
      expect(findText('Tente'), findsOneWidget);
    });
  });
}

