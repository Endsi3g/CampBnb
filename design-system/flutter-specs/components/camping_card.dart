// Camping Card Component
// Reusable card for displaying camping listings

import 'package:flutter/material.dart';
import '../theme.dart';

class CampingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String type;
  final double price;
  final String? badge;
  final VoidCallback? onTap;

  const CampingCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.type,
    required this.price,
    this.badge,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 192,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 192,
                        color: AppColors.neutral,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondaryLight,
                        ),
                      );
                    },
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(label: badge!),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.displaySmall.copyWith(
                            color: isDarkMode
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          location,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          type,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: isDarkMode
                          ? AppColors.primaryDarkMode
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' / nuit',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  Color _getBadgeColor() {
    switch (label.toLowerCase()) {
      case 'populaire':
        return AppColors.secondary;
      case 'nouveau':
        return AppColors.primary;
      case 'bord de l\'eau':
        return AppColors.secondary.withOpacity(0.8);
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


