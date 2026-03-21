import 'package:flutter/material.dart';
import '../widgets/top_brown_header.dart';
import '../widgets/app_text_field.dart';
import '../core/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TopBrownHeader(
              title: 'Sign up',
              subtitle: 'Create an account to get started',
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const AppTextField(hint: 'Lucas Scott'),
                  const SizedBox(height: 18),
                  const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const AppTextField(hint: 'name@email.com'),
                  const SizedBox(height: 14),
                  const AppTextField(hint: 'Mobile no'),
                  const SizedBox(height: 18),
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const AppTextField(hint: 'Create a password'),
                  const SizedBox(height: 14),
                  const AppTextField(hint: 'Confirm password'),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.check_box_outline_blank),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "I've read and agree with the Terms and Conditions and the Privacy Policy.",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}