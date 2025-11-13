// Copyright 2024 Campbnb Québec. All rights reserved.
// Layout adaptatif qui s'adapte selon la plateforme

import 'package:flutter/material.dart';
import '../../core/utils/platform_utils.dart';
import 'desktop_layout.dart';
import 'mobile_layout.dart';

/// Layout adaptatif qui choisit automatiquement entre desktop et mobile
class AdaptiveLayout extends StatelessWidget {
  final Widget child;
  final int? currentIndex;
  final Function(int)? onNavigationChanged;
  final String? title;

  const AdaptiveLayout({
    super.key,
    required this.child,
    this.currentIndex,
    this.onNavigationChanged,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.shouldUseDesktopLayout(context)) {
      return DesktopLayout(
        currentIndex: currentIndex,
        onNavigationChanged: onNavigationChanged,
        title: title,
        child: child,
      );
    } else {
      return MobileLayout(
        currentIndex: currentIndex,
        onNavigationChanged: onNavigationChanged,
        child: child,
      );
    }
  }
}

