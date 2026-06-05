import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _NavItem('/', Icons.forest_outlined, Icons.forest, 'Pohon'),
    _NavItem('/quests', Icons.task_alt_outlined, Icons.task_alt, 'Quest'),
    _NavItem('/sleep', Icons.bedtime_outlined, Icons.bedtime, 'Tidur'),
    _NavItem('/stats', Icons.radar_outlined, Icons.radar, 'Statistik'),
    _NavItem(
      '/reflection',
      Icons.auto_stories_outlined,
      Icons.auto_stories,
      'Refleksi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _destinations.indexWhere((item) => item.path == location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (next) => context.go(_destinations[next].path),
        destinations: [
          for (final item in _destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.icon, this.selectedIcon, this.label);

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
