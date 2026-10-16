import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/nav_controller.dart';
import '../theme/lummings_theme.dart';
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
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LummingsColors.nestGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: nav.index,
            children: _pages,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: nav.index,
            onDestinationSelected: nav.go,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories_rounded),
                label: 'Adventures',
              ),
              NavigationDestination(
                icon: Icon(Icons.diamond_outlined),
                selectedIcon: Icon(Icons.diamond_rounded),
                label: 'Collection',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Care',
              ),
              NavigationDestination(
                icon: Icon(Icons.family_restroom_outlined),
                selectedIcon: Icon(Icons.family_restroom_rounded),
                label: 'Parent',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
