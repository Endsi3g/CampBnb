import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Contrôles de la carte (zoom, localisation, filtres)
class MapControls extends StatelessWidget {
  final VoidCallback onMyLocationTap;
  final VoidCallback onFiltersTap;

  const MapControls({
    super.key,
    required this.onMyLocationTap,
    required this.onFiltersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton ma localisation
        _ControlButton(
          icon: Icons.my_location,
          onTap: onMyLocationTap,
          backgroundColor: AppColors.secondary,
        ),
        const SizedBox(height: 12),

        // Bouton filtres
        _ControlButton(
          icon: Icons.filter_alt,
          onTap: onFiltersTap,
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}


