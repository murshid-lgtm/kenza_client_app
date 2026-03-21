import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'requests_screen.dart';
import 'track_screen.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  int currentIndex = 0;

  late final List<Widget> screens = [
    const _GuestEmptyScreen(),
    const RequestsScreen(),
    const TrackScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        showCompanies: false,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class _GuestEmptyScreen extends StatelessWidget {
  const _GuestEmptyScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(),
    );
  }
}