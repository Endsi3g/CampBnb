import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/mapbox_config.dart';
import '../../domain/entities/campsite_location.dart';

/// Panneau de filtres pour la carte
class MapFiltersSheet extends StatefulWidget {
  final List<CampsiteType> selectedTypes;
  final double? minPrice;
  final double? maxPrice;
  final String? selectedRegion;
  final Function(List<CampsiteType>) onTypesChanged;
  final Function(double?, double?) onPriceChanged;
  final Function(String?) onRegionChanged;
  final VoidCallback onClose;

  const MapFiltersSheet({
    super.key,
    required this.selectedTypes,
    this.minPrice,
    this.maxPrice,
    this.selectedRegion,
    required this.onTypesChanged,
    required this.onPriceChanged,
    required this.onRegionChanged,
    required this.onClose,
  });

  @override
  State<MapFiltersSheet> createState() => _MapFiltersSheetState();
}

class _MapFiltersSheetState extends State<MapFiltersSheet> {
  late List<CampsiteType> _selectedTypes;
  late RangeValues _priceRange;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
    _priceRange = RangeValues(
      widget.minPrice ?? 0,
      widget.maxPrice ?? 500,
    );
    _selectedRegion = widget.selectedRegion;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // En-tête
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
 'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          const Divider(),

          // Type de camping
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
 'Type de camping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CampsiteType.values.map((type) {
                    final isSelected = _selectedTypes.contains(type);
                    return FilterChip(
                      label: Text(_getTypeLabel(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                        widget.onTypesChanged(_selectedTypes);
                      },
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Prix par nuit
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
 'Prix / nuit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  labels: RangeLabels(
 '\$${_priceRange.start.toInt()}',
 '\$${_priceRange.end.toInt()}',
                  ),
                  onChanged: (values) {
                    setState(() => _priceRange = values);
                    widget.onPriceChanged(
                      _priceRange.start,
                      _priceRange.end,
                    );
                  },
                ),
              ],
            ),
          ),

          // Région
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
 'Région',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
 hintText: 'Toutes les régions',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
 child: Text('Toutes les régions'),
                    ),
                    ...MapboxConfig.quebecRegions.map((region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(region),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRegion = value);
                    widget.onRegionChanged(value);
                  },
                ),
              ],
            ),
          ),

 // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTypes = [];
                        _priceRange = const RangeValues(0, 500);
                        _selectedRegion = null;
                      });
                      widget.onTypesChanged([]);
                      widget.onPriceChanged(null, null);
                      widget.onRegionChanged(null);
                    },
 child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
 child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(CampsiteType type) {
    switch (type) {
      case CampsiteType.tent:
 return 'Tente';
      case CampsiteType.rv:
 return 'VR';
      case CampsiteType.cabin:
 return 'Prêt-à-camper';
      case CampsiteType.wild:
 return 'Sauvage';
      case CampsiteType.lake:
 return 'Lac';
      case CampsiteType.forest:
 return 'Forêt';
      case CampsiteType.beach:
 return 'Plage';
      case CampsiteType.mountain:
 return 'Montagne';
    }
  }
}


