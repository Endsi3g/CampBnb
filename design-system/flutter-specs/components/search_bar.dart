// Search Bar Component
// Main search input with icon

import 'package:flutter/material.dart';
import '../theme.dart';

class SearchBar extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  const SearchBar({
    Key? key,
    this.hintText,
    this.onChanged,
    this.onTap,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isDarkMode
              ? AppColors.textPrimaryDark.withOpacity(0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText ?? 'Lieu, hébergement, dates',
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondary,
            size: 24,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDarkMode
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}


