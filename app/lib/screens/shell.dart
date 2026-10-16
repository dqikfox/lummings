import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/nav_controller.dart';
import 'home_screen.dart';
import 'adventures_screen.dart';
import 'collection_screen.dart';
import 'care_screen.dart';
import 'parent_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _pages = <Widget>[
    HomeScreen(),
    AdventuresScreen(),
    CollectionScreen(),
    CareScreen(),
    ParentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavController>();
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: nav.index,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.index,
        onDestinationSelected: nav.go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.auto_stories_rounded), label: 'Adventures'),
          NavigationDestination(
              icon: Icon(Icons.diamond_rounded), label: 'Collection'),
          NavigationDestination(
              icon: Icon(Icons.favorite_rounded), label: 'Care'),
          NavigationDestination(
              icon: Icon(Icons.family_restroom_rounded), label: 'Parent'),
        ],
      ),
    );
  }
}
