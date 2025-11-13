import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/add_campsite_screen.dart';

/// Bouton flottant pour ajouter un nouvel emplacement
class AddLocationButton extends StatelessWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const AddLocationButton({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCampsiteScreen(
              initialLatitude: initialLatitude,
              initialLongitude: initialLongitude,
            ),
          ),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_location_alt),
 label: const Text('Ajouter un emplacement'),
    );
  }
}

