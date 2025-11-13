// Copyright 2024 Campbnb Québec. All rights reserved.
// Layout desktop avec sidebar pour Windows et autres plateformes desktop

import 'package:flutter/material.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/theme/app_colors.dart';

/// Layout desktop avec sidebar de navigation
class DesktopLayout extends StatefulWidget {
  final Widget child;
  final int? currentIndex;
  final Function(int)? onNavigationChanged;
  final String? title;

  const DesktopLayout({
    super.key,
    required this.child,
    this.currentIndex,
    this.onNavigationChanged,
    this.title,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser Material Design avec style Windows-friendly
    return _buildMaterialLayout(context);
  }

  /// Layout avec Material Design (adapté pour Windows et autres desktops)
  Widget _buildMaterialLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              widget.onNavigationChanged?.call(index);
            },
            labelType: _sidebarExpanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            extended: _sidebarExpanded,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Accueil'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text('Recherche'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: Text('Favoris'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Réservations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profil'),
              ),
            ],
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(_sidebarExpanded
                        ? Icons.chevron_left
                        : Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _sidebarExpanded = !_sidebarExpanded;
                      });
                    },
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Paramètres'),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenu principal
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

