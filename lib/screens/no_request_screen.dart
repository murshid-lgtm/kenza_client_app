import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_bottom_nav.dart';

class NoRequestScreen extends StatelessWidget {
  const NoRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: '55537',
                  prefixIcon: const Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.search, size: 100, color: Color(0xFFC4C4C4)),
              const SizedBox(height: 24),
              const Text(
                'Request not found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Try searching the request with\na different tracking ID.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 16),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (_) {},
      ),
    );
  }
}