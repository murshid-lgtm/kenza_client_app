import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String?>>(
      future: Future.wait([
        AuthService.instance.rememberedName(),
        AuthService.instance.rememberedEmail(),
        AuthService.instance.rememberedMobile(),
      ]),
      builder: (context, snapshot) {
        final name = snapshot.data?[0] ?? 'Profile';
        final email = snapshot.data?[1] ?? '-';
        final mobile = snapshot.data?[2] ?? '-';
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  _infoCard('Name', name),
                  const SizedBox(height: 14),
                  _infoCard('Email', email),
                  const SizedBox(height: 14),
                  _infoCard('Mobile', mobile),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: onLogout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.text),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Logout', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
