import 'package:flutter/material.dart';
import '../widgets/top_brown_header.dart';
import '../core/app_colors.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box(String text) {
      return Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const TopBrownHeader(
            title: 'Sign up',
            subtitle: 'Create an account to get started',
          ),
          const SizedBox(height: 36),
          const Text(
            'Enter confirmation code',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Text(
            'A 6-digit code was sent to\nlucasscott3@email.com',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              box('1'),
              const SizedBox(width: 10),
              box('|'),
              const SizedBox(width: 10),
              box(''),
              const SizedBox(width: 10),
              box(''),
              const SizedBox(width: 10),
              box(''),
              const SizedBox(width: 10),
              box(''),
            ],
          ),
          const SizedBox(height: 34),
          const Text(
            'Resend code',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: const Text('Verify'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}