import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/listing_model.dart';
import 'add_listing_screen.dart';

class EditListingManagementScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const EditListingManagementScreen({super.key, required this.listing});

  @override
  ConsumerState<EditListingManagementScreen> createState() =>
      _EditListingManagementScreenState();
}

class _EditListingManagementScreenState
    extends ConsumerState<EditListingManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le camping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale
            _buildImageSection(),
            const SizedBox(height: 24),

            // Informations de base
            _buildBasicInfoSection(),
            const SizedBox(height: 24),

            // Localisation
            _buildLocationSection(),
            const SizedBox(height: 24),

            // Prix et capacité
            _buildPricingSection(),
            const SizedBox(height: 24),

            // Équipements
            _buildAmenitiesSection(),
            const SizedBox(height: 32),

            // Actions
            CustomButton(
              text: 'Enregistrer les modifications',
              onPressed: () {
                // TODO: Implémenter sauvegarde
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modifications enregistrées')),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Naviguer vers l'écran d'édition complet
                context.push(
                  '/host/edit-listing/${widget.listing.id}',
                  extra: widget.listing,
                );
              },
              child: const Text('Édition complète'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Images', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.listing.images.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.listing.images.first,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            // TODO: Ouvrir sélecteur d'images
          },
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Modifier les images'),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations de base', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        _buildInfoRow('Titre', widget.listing.title),
        const Divider(),
        _buildInfoRow('Description', widget.listing.description),
        const Divider(),
        _buildInfoRow('Type', widget.listing.type.name),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localisation', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow('Adresse', widget.listing.address),
              const Divider(),
              _buildInfoRow('Ville', widget.listing.city),
              const Divider(),
              _buildInfoRow('Province', widget.listing.province),
              const Divider(),
              _buildInfoRow('Code postal', widget.listing.postalCode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prix et capacité', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'Prix par nuit',
                '${widget.listing.pricePerNight} \$',
              ),
              const Divider(),
              _buildInfoRow('Invités max', '${widget.listing.maxGuests}'),
              const Divider(),
              _buildInfoRow('Chambres', '${widget.listing.bedrooms}'),
              const Divider(),
              _buildInfoRow('Salles de bain', '${widget.listing.bathrooms}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Équipements', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.listing.amenities.map((amenity) {
            return Chip(
              label: Text(amenity),
              backgroundColor: AppColors.primary.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyLarge,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le camping'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce camping ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter suppression
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Camping supprimé')));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
