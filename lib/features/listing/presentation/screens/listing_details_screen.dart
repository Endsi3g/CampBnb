import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../features/analytics/presentation/widgets/analytics_tracker.dart';
import '../../../../shared/services/analytics_service.dart';

class ListingDetailsScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailsScreen({super.key, required this.listing});

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Tracker la vue du listing
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AnalyticsService.instance.logEvent(
        eventName: 'listing_view',
        eventCategory: 'interaction',
        eventType: 'listing_view',
        screenName: 'listing_details',
        properties: {
          'listing_id': widget.listing.id,
          'listing_title': widget.listing.title,
          'property_type': widget.listing.type.toString(),
          'price': widget.listing.pricePerNight,
        },
      );
    });
  }

  String _getTypeLabel(ListingType type) {
    switch (type) {
      case ListingType.tent:
        return 'Tente';
      case ListingType.rv:
        return 'VR';
      case ListingType.readyToCamp:
        return 'Prêt-à-camper';
      case ListingType.wild:
        return 'Sauvage';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsTracker(
      screenName: 'listing_details',
      screenClass: 'ListingDetailsScreen',
      properties: {'listing_id': widget.listing.id},
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar avec image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: widget.listing.images.isNotEmpty
                    ? Image.network(
                        widget.listing.images.first,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.borderLight,
                        child: const Center(child: Icon(Icons.image, size: 64)),
                      ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
              ],
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.listing.title, style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      widget.listing.address,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.listing.description,
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    // Features
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.forest,
                          label: 'Type',
                          value: _getTypeLabel(widget.listing.type),
                        ),
                        _buildFeatureCard(
                          icon: Icons.people,
                          label: 'Invités',
                          value: '${widget.listing.maxGuests} max',
                        ),
                        _buildFeatureCard(
                          icon: Icons.bed,
                          label: 'Chambres',
                          value: '${widget.listing.bedrooms}',
                        ),
                        _buildFeatureCard(
                          icon: Icons.bathroom,
                          label: 'Salles de bain',
                          value: '${widget.listing.bathrooms}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    // Amenities
                    Text('Équipements', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.listing.amenities.map((amenity) {
                        return Chip(
                          label: Text(amenity),
                          backgroundColor: AppColors.accent,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${widget.listing.pricePerNight.toStringAsFixed(0)}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text('/ nuit', style: AppTextStyles.bodySmall),
                  ],
                ),
                CustomButton(
                  text: 'Réserver',
                  onPressed: () {
                    context.push('/reservation/${widget.listing.id}');
                  },
                  width: 150,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
