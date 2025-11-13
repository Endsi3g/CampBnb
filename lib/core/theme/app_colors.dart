import 'package:flutter/material.dart';

/// Palette de couleurs inspirée du Québec
class AppColors {
  AppColors._();

  // Couleurs principales
  static const Color primary = Color(0xFF2D572C); // Vert forêt
  static const Color secondary = Color(0xFF3B8EA5); // Bleu lac
  static const Color accent = Color(0xFFF5E5D5); // Beige bois
  static const Color neutral = Color(0xFFF5F5DC); // Beige clair

  // Arrière-plans
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF152210);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2A3F29);

  // Texte
  static const Color textPrimaryLight = Color(0xFF333333);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryLight = Color(0xFF5C5C5C);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // États
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Bordures
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF3A3A3A);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);
}
