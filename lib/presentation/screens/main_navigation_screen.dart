import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'search/vehicle_search_screen.dart';
import 'challan/issue_challan_screen.dart';
import 'history/challan_history_screen.dart';
import 'profile/inspector_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String? _prefilledSearchQuery;

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onSearchPlate(String plate) {
    setState(() {
      _prefilledSearchQuery = plate;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigateTab: _onNavigateTab,
        onSearchPlate: _onSearchPlate,
      ),
      VehicleSearchScreen(
        key: ValueKey(_prefilledSearchQuery),
        initialQuery: _prefilledSearchQuery,
      ),
      const IssueChallanScreen(),
      const ChallanHistoryScreen(),
      const InspectorProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index != 1) {
                _prefilledSearchQuery = null;
              }
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.saved_search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Challan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.manage_history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
      ),
    );
  }
}
