// lib/core/navigation/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/home/home_page.dart';
import '../../features/favorites/favorites_page.dart';
import '../../features/settings/settings_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    HomePage(),
    FavoritesPage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          elevation: 0,
          height: 70,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search),
              label: 'Buscar',
            ).animate(target: _currentIndex == 0 ? 1 : 0).scale(),
            
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline),
              selectedIcon: const Icon(Icons.favorite),
              label: 'Favoritos',
            ).animate(target: _currentIndex == 1 ? 1 : 0).scale(),
            
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: 'Configurações',
            ).animate(target: _currentIndex == 2 ? 1 : 0).scale(),
          ],
        ),
      ),
    );
  }
}
