import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showCompanies;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showCompanies = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      _item(
        index: 0,
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      _item(
        index: 1,
        label: 'Requests',
        icon: Icons.work_outline,
        activeIcon: Icons.work,
      ),
      _item(
        index: 2,
        label: 'Track',
        icon: Icons.search,
        activeIcon: Icons.search,
      ),
      if (showCompanies)
        _item(
          index: 3,
          label: 'Companies',
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
        ),
      _item(
        index: showCompanies ? 4 : 3,
        label: 'Profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.bg,
        elevation: 0,
        selectedItemColor: AppColors.text,
        unselectedItemColor: AppColors.text,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        items: items,
      ),
    );
  }

  BottomNavigationBarItem _item({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}