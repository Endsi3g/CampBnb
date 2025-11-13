// Copyright 2024 Campbnb Québec. All rights reserved.
// Layout mobile avec bottom navigation bar

import 'package:flutter/material.dart';

/// Layout mobile avec bottom navigation bar
class MobileLayout extends StatelessWidget {
  final Widget child;
  final int? currentIndex;
  final Function(int)? onNavigationChanged;

  const MobileLayout({
    super.key,
    required this.child,
    this.currentIndex,
    this.onNavigationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex ?? 0,
        onTap: (index) {
          onNavigationChanged?.call(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

