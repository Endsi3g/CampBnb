import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../shared/widgets/listing_card.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/layouts/adaptive_layout.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.push('/search');
        break;
      case 2:
        context.push('/favorites');
        break;
      case 3:
        context.push('/reservations');
        break;
      case 4:
        context.push('/profile');
        break;
      case 5:
        context.push('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformUtils.shouldUseDesktopLayout(context);

    return AdaptiveLayout(
      currentIndex: 0,
      onNavigationChanged: _handleNavigation,
      title: 'Campbnb Québec',
      child: SafeArea(
        child: isDesktop
            ? _buildDesktopContent(context)
            : _buildMobileContent(context),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.forest, size: 32, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('Campbnb Québec', style: AppTextStyles.h3)),
            ],
          ),
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Lieu, hébergement, dates',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () => context.push('/search'),
          ),
        ),
        const SizedBox(height: 16),
        // Filter Chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('Prix', isSelected: false),
              const SizedBox(width: 8),
              _buildFilterChip('Type', isSelected: true),
              const SizedBox(width: 8),
              _buildFilterChip('Région', isSelected: false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Listings
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListingCard(
                listing: ListingModel(
                  id: '1',
                  hostId: '1',
                  title: 'Camping du Lac Tranquille',
                  description: 'Un camping paisible au bord du lac',
                  type: ListingType.readyToCamp,
                  latitude: 46.5,
                  longitude: -75.5,
                  address: 'Parc national du Mont-Tremblant',
                  city: 'Mont-Tremblant',
                  province: 'QC',
                  postalCode: 'J8E 1T1',
                  pricePerNight: 45.0,
                  maxGuests: 4,
                  bedrooms: 1,
                  bathrooms: 1,
                  images: [],
                  amenities: [],
                ),
                onTap: () => context.push('/listing/1'),
              ),
              const SizedBox(height: 16),
              ListingCard(
                listing: ListingModel(
                  id: '2',
                  hostId: '2',
                  title: 'Chalet Évasion Boréale',
                  description: 'Chalet moderne en forêt boréale',
                  type: ListingType.readyToCamp,
                  latitude: 46.3,
                  longitude: -74.2,
                  address: 'Saint-Donat',
                  city: 'Saint-Donat',
                  province: 'QC',
                  postalCode: 'J0T 2C0',
                  pricePerNight: 180.0,
                  maxGuests: 6,
                  bedrooms: 2,
                  bathrooms: 1,
                  images: [],
                  amenities: [],
                ),
                onTap: () => context.push('/listing/2'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header desktop
          Row(
            children: [
              Icon(Icons.forest, size: 40, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Campbnb Québec', style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 24),
          // Search Bar desktop (plus large)
          SizedBox(
            width: 600,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Lieu, hébergement, dates',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () => context.push('/search'),
            ),
          ),
          const SizedBox(height: 24),
          // Filter Chips desktop
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Prix', isSelected: false),
              _buildFilterChip('Type', isSelected: true),
              _buildFilterChip('Région', isSelected: false),
              _buildFilterChip('Équipements', isSelected: false),
              _buildFilterChip('Disponibilité', isSelected: false),
            ],
          ),
          const SizedBox(height: 24),
          // Listings Grid (desktop)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              padding: const EdgeInsets.all(0),
              itemCount: 6, // Exemple avec 6 listings
              itemBuilder: (context, index) {
                return ListingCard(
                  listing: ListingModel(
                    id: index.toString(),
                    hostId: '1',
                    title: 'Camping du Lac Tranquille',
                    description: 'Un camping paisible au bord du lac',
                    type: ListingType.readyToCamp,
                    latitude: 46.5,
                    longitude: -75.5,
                    address: 'Parc national du Mont-Tremblant',
                    city: 'Mont-Tremblant',
                    province: 'QC',
                    postalCode: 'J8E 1T1',
                    pricePerNight: 45.0 + (index * 10),
                    maxGuests: 4,
                    bedrooms: 1,
                    bathrooms: 1,
                    images: [],
                    amenities: [],
                  ),
                  onTap: () => context.push('/listing/${index}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
      ),
    );
  }
}
