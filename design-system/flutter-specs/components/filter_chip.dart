// Filter Chip Component
// Reusable filter chip for quick filters

import 'package:flutter/material.dart';
import '../theme.dart';

class FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const FilterChip({
    Key? key,
    required this.label,
    this.isActive = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode ? AppColors.primaryDarkMode : AppColors.primary)
              : (isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : (isDarkMode
                    ? AppColors.primaryDarkMode.withOpacity(0.5)
                    : AppColors.primary.withOpacity(0.2)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive
                    ? Colors.white
                    : (isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.expand_more,
              size: 20,
              color: isActive
                  ? Colors.white.withOpacity(0.8)
                  : (isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}


