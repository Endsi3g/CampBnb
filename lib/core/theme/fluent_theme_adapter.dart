// Copyright 2024 Campbnb Québec. All rights reserved.
// Adaptateur pour intégrer Fluent UI avec le thème de l'application

import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import '../../core/utils/platform_utils.dart';
import 'app_colors.dart';

/// Adaptateur de thème Fluent UI pour Windows
class FluentThemeAdapter {
  /// Crée un thème Fluent UI basé sur le thème Material de l'application
  static fluent.FluentThemeData createFluentTheme({required bool isDark}) {
    final brightness = isDark
        ? fluent.Brightness.dark
        : fluent.Brightness.light;

    return fluent.FluentThemeData(
      brightness: brightness,
      accentColor: fluent.Color(
        isDark ? AppColors.primaryDark.value : AppColors.primary.value,
      ),
      scaffoldBackgroundColor: fluent.Color(
        isDark
            ? AppColors.backgroundDark.value
            : AppColors.backgroundLight.value,
      ),
      cardColor: fluent.Color(
        isDark ? AppColors.surfaceDark.value : AppColors.surfaceLight.value,
      ),
      // Personnalisation des couleurs
      resources: fluent.ResourceDictionary(
        colors: fluent.ResourceDictionaryColors(
          cardStrokeColorDefault: fluent.Color(AppColors.borderLight.value),
          controlFillColorDefault: fluent.Color(AppColors.surfaceLight.value),
          controlFillColorSecondary: fluent.Color(AppColors.surfaceLight.value),
          textFillColorPrimary: fluent.Color(
            isDark
                ? AppColors.textPrimaryDark.value
                : AppColors.textPrimaryLight.value,
          ),
          textFillColorSecondary: fluent.Color(
            isDark
                ? AppColors.textSecondaryDark.value
                : AppColors.textSecondaryLight.value,
          ),
        ),
      ),
    );
  }

  /// Wrapper pour utiliser Fluent UI sur Windows et Material ailleurs
  static Widget buildWithTheme({required Widget child, required bool isDark}) {
    if (PlatformUtils.isWindows) {
      return fluent.FluentApp(
        theme: createFluentTheme(isDark: isDark),
        darkTheme: createFluentTheme(isDark: true),
        color: fluent.Color(AppColors.primary.value),
        child: child,
      );
    } else {
      // Utiliser Material Design pour les autres plateformes
      return child;
    }
  }
}
