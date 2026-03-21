import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'companies_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';
import 'track_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  late final List<Widget> screens = [
    const _EmptyScreen(title: 'Home'),
    const RequestsScreen(),
    const TrackScreen(),
    const CompaniesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class _EmptyScreen extends StatelessWidget {
  final String title;

  const _EmptyScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(),
    );
  }
}