// Copyright 2024 Campbnb Québec. All rights reserved.
// Utilitaires pour la détection de plateforme et l'adaptation UI

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

/// Utilitaires pour la détection de plateforme
class PlatformUtils {
  PlatformUtils._();

  /// Vérifie si l'application s'exécute sur Windows
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows;
  }

  /// Vérifie si l'application s'exécute sur macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS || defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Vérifie si l'application s'exécute sur Linux
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux || defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Vérifie si l'application s'exécute sur Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid || defaultTargetPlatform == TargetPlatform.android;
  }

  /// Vérifie si l'application s'exécute sur iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS || defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Vérifie si l'application s'exécute sur le web
  static bool get isWeb => kIsWeb;

  /// Vérifie si l'application s'exécute sur un desktop (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) return UniversalPlatform.isDesktop;
    return isWindows || isMacOS || isLinux;
  }

  /// Vérifie si l'application s'exécute sur mobile (Android, iOS)
  static bool get isMobile {
    if (kIsWeb) return UniversalPlatform.isMobile;
    return isAndroid || isIOS;
  }

  /// Retourne le nom de la plateforme
  static String get platformName {
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  /// Retourne le type de plateforme (desktop, mobile, web)
  static String get platformType {
    if (isDesktop) return 'desktop';
    if (isMobile) return 'mobile';
    if (isWeb) return 'web';
    return 'unknown';
  }

  /// Retourne la taille minimale recommandée pour les fenêtres desktop
  static Size get recommendedDesktopWindowSize {
    if (isWindows || isLinux) {
      return const Size(1200, 800);
    } else if (isMacOS) {
      return const Size(1400, 900);
    }
    return const Size(1280, 720);
  }

  /// Retourne si l'application devrait utiliser un layout desktop
  static bool shouldUseDesktopLayout(BuildContext context) {
    if (isDesktop) return true;
    if (isWeb) {
      final width = MediaQuery.of(context).size.width;
      return width >= 1024; // Tablette et plus
    }
    return false;
  }
}

