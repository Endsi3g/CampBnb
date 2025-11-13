import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/models/listing_model.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  ListingType _selectedType = ListingType.tent;
  int _maxGuests = 4;
  int _bedrooms = 1;
  int _bathrooms = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Créer le listing via le repository
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce créée avec succès !')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une annonce')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations de base', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'Titre',
                hint: 'Ex: Camping du Lac Tranquille',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Décrivez votre camping...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Type de camping', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ListingType.values.map((type) {
                  final label = _getTypeLabel(type);
                  final isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Localisation', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Adresse',
                hint: '123 Rue Principale',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cityController,
                label: 'Ville',
                hint: 'Mont-Tremblant',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Détails', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceController,
                label: 'Prix par nuit (\$)',
                hint: '50',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCounter(
                'Invités maximum',
                _maxGuests,
                (value) => setState(() => _maxGuests = value),
              ),
              const SizedBox(height: 16),
              _buildCounter(
                'Chambres',
                _bedrooms,
                (value) => setState(() => _bedrooms = value),
              ),
              const SizedBox(height: 16),
              _buildCounter(
                'Salles de bain',
                _bathrooms,
                (value) => setState(() => _bathrooms = value),
              ),
              const SizedBox(height: 32),
              CustomButton(text: 'Créer l\'annonce', onPressed: _handleSubmit),
            ],
          ),
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

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
        Row(
          children: [
            IconButton(
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text(value.toString(), style: AppTextStyles.bodyLarge),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
