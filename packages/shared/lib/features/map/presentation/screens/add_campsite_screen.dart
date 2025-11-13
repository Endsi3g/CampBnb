import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/campsite_location.dart';
import '../../domain/repositories/map_repository.dart';
import '../providers/map_providers.dart';
import '../widgets/mapbox_map_widget.dart';
import '../widgets/location_picker_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/services/mapbox_service.dart';

/// Écran pour ajouter un nouvel emplacement de camping
class AddCampsiteScreen extends ConsumerStatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final bool allowLocationSelection;

  const AddCampsiteScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.allowLocationSelection = true,
  });

  @override
  ConsumerState<AddCampsiteScreen> createState() => _AddCampsiteScreenState();
}

class _AddCampsiteScreenState extends ConsumerState<AddCampsiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;
  CampsiteType _selectedType = CampsiteType.tent;
  bool _isLoading = false;
  bool _isSearchingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLatitude = widget.initialLatitude;
    _selectedLongitude = widget.initialLongitude;
    if (_selectedLatitude != null && _selectedLongitude != null) {
      _getAddressFromCoordinates(_selectedLatitude!, _selectedLongitude!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates(double lat, double lon) async {
    setState(() => _isSearchingAddress = true);
    
    try {
      final mapboxService = ref.read(mapboxServiceProvider);
      final result = await mapboxService.reverseGeocode(lat, lon);
      
      if (result != null && mounted) {
        setState(() {
 _selectedAddress = result['place_name'] as String?;
          _isSearchingAddress = false;
        });
      } else {
        setState(() => _isSearchingAddress = false);
      }
    } catch (e) {
      setState(() => _isSearchingAddress = false);
    }
  }

  Future<void> _onLocationSelected(double lat, double lon) async {
    setState(() {
      _selectedLatitude = lat;
      _selectedLongitude = lon;
    });
    await _getAddressFromCoordinates(lat, lon);
  }

  Future<void> _onSearchAddress(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearchingAddress = true);

    try {
      final mapboxService = ref.read(mapboxServiceProvider);
      final result = await mapboxService.geocode(query);
      
      if (result != null && mounted) {
 final coordinates = result['geometry']?['coordinates'] as List?;
        if (coordinates != null && coordinates.length >= 2) {
          final lon = (coordinates[0] as num).toDouble();
          final lat = (coordinates[1] as num).toDouble();
          
          setState(() {
            _selectedLatitude = lat;
            _selectedLongitude = lon;
 _selectedAddress = result['place_name'] as String?;
            _isSearchingAddress = false;
          });
        } else {
          setState(() => _isSearchingAddress = false);
        }
      } else {
        setState(() => _isSearchingAddress = false);
      }
    } catch (e) {
      setState(() => _isSearchingAddress = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
 content: Text('Veuillez sélectionner un emplacement sur la carte'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(mapRepositoryProvider);
      
 // Récupère l'ID de l'utilisateur actuel (à adapter selon votre système d'auth)
 final userId = 'current_user_id'; // TODO: Récupérer depuis l'auth

      final campsite = CampsiteLocation(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        pricePerNight: _priceController.text.trim().isEmpty
            ? null
            : double.tryParse(_priceController.text.trim()),
        hostId: userId,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createCampsite(campsite);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
 content: Text('Emplacement créé avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
 content: Text('Erreur lors de la création: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
 title: const Text('Ajouter un emplacement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
 // Carte pour sélectionner l'emplacement
            Expanded(
              flex: 2,
              child: widget.allowLocationSelection
                  ? LocationPickerMap(
                      initialLatitude: _selectedLatitude,
                      initialLongitude: _selectedLongitude,
                      onLocationSelected: _onLocationSelected,
                      onSearchAddress: _onSearchAddress,
                      selectedAddress: _selectedAddress,
                      isSearchingAddress: _isSearchingAddress,
                    )
                  : MapboxMapWidget(
                      campsites: const [],
                      initialLatitude: _selectedLatitude,
                      initialLongitude: _selectedLongitude,
                      initialZoom: 15.0,
                    ),
            ),

            // Formulaire
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nom
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
 labelText: 'Nom de l\'emplacement *',
 hintText: 'Ex: Camping du Lac Vert',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
 return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Type
                    DropdownButtonFormField<CampsiteType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
 labelText: 'Type d\'emplacement *',
                        border: OutlineInputBorder(),
                      ),
                      items: CampsiteType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
 labelText: 'Description',
 hintText: 'Décrivez votre emplacement...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Prix
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
 labelText: 'Prix par nuit (CAD)',
 hintText: 'Ex: 45.00',
                        border: OutlineInputBorder(),
 prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final price = double.tryParse(value.trim());
                          if (price == null || price < 0) {
 return 'Prix invalide';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Adresse sélectionnée
                    if (_selectedAddress != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedAddress!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Bouton de soumission
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
 'Créer l\'emplacement',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(CampsiteType type) {
    switch (type) {
      case CampsiteType.tent:
 return 'Tente';
      case CampsiteType.rv:
 return 'VR (Véhicule récréatif)';
      case CampsiteType.cabin:
 return 'Chalet / Prêt-à-camper';
      case CampsiteType.wild:
 return 'Camping sauvage';
      case CampsiteType.lake:
 return 'Emplacement au bord d\'un lac';
      case CampsiteType.forest:
 return 'Emplacement en forêt';
      case CampsiteType.beach:
 return 'Emplacement sur la plage';
      case CampsiteType.mountain:
 return 'Emplacement en montagne';
    }
  }
}

