import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/listing_model.dart';
import '../providers/search_filters_provider.dart';

class AdvancedSearchScreen extends ConsumerWidget {
  const AdvancedSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersNotifierProvider);
    final notifier = ref.read(searchFiltersNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
 title: const Text('Filtres avancés'),
        actions: [
          TextButton(
            onPressed: () {
              notifier.clearFilters();
            },
 child: const Text('Réinitialiser'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de camping
 Text('Type de camping', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ListingType.values.map((type) {
                final isSelected = filters.types.contains(type);
                return FilterChip(
                  label: Text(_getTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newTypes = List<ListingType>.from(filters.types);
                    if (selected) {
                      newTypes.add(type);
                    } else {
                      newTypes.remove(type);
                    }
                    notifier.setTypes(newTypes);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Prix
 Text('Prix par nuit', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
 labelText: 'Min',
 prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      notifier.setPriceRange(
                        value.isEmpty ? null : double.tryParse(value),
                        filters.maxPrice,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
 labelText: 'Max',
 prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      notifier.setPriceRange(
                        filters.minPrice,
                        value.isEmpty ? null : double.tryParse(value),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Région
 Text('Région', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: filters.region,
              decoration: const InputDecoration(
 hintText: 'Sélectionner une région',
              ),
              items: const [
 DropdownMenuItem(value: 'montreal', child: Text('Montréal')),
 DropdownMenuItem(value: 'quebec', child: Text('Québec')),
 DropdownMenuItem(value: 'laurentides', child: Text('Laurentides')),
 DropdownMenuItem(value: 'gaspesie', child: Text('Gaspésie')),
 DropdownMenuItem(value: 'saguenay', child: Text('Saguenay')),
              ],
              onChanged: (value) => notifier.setRegion(value),
            ),
            const SizedBox(height: 24),
 // Nombre d'invités
 Text('Nombre d\'invités', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Slider(
              value: (filters.minGuests ?? 1).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
 label: '${filters.minGuests ?? 1} invités',
              onChanged: (value) {
                notifier.setMinGuests(value.toInt());
              },
            ),
            const SizedBox(height: 24),
            // Note minimum
 Text('Note minimum', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Slider(
              value: filters.minRating ?? 0.0,
              min: 0,
              max: 5,
              divisions: 10,
 label: '${(filters.minRating ?? 0.0).toStringAsFixed(1)} ⭐',
              onChanged: (value) {
                notifier.setMinRating(value);
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
 text: 'Appliquer les filtres',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
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
}

