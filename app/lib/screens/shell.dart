import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'adventures_screen.dart';
import 'collection_screen.dart';
import 'care_screen.dart';
import 'parent_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    AdventuresScreen(),
    CollectionScreen(),
    CareScreen(),
    ParentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
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
