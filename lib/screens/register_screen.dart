import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/top_brown_header.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _agree = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      setState(() => _error = 'Please fill all fields.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!_agree) {
      setState(() => _error = 'Please accept the terms to continue.');
      return;
    }

    final pending = PendingRegistration(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signUpWithPasswordOtp(pending);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: pending.email,
            flow: OtpFlow.signup,
            pendingRegistration: pending,
            title: 'Enter confirmation code',
            subtitle: 'A 6-digit code was sent to\n${pending.email}',
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }

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
                  _sectionLabel('Name'),
                  AppTextField(hint: 'Lucas Scott', controller: _nameController),
                  const SizedBox(height: 16),
                  _sectionLabel('Contact Details'),
                  AppTextField(
                    hint: 'name@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hint: '+974 55443322',
                    keyboardType: TextInputType.phone,
                    controller: _mobileController,
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('Password'),
                  AppTextField(
                    hint: 'Create a password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hint: 'Confirm password',
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agree,
                        onChanged: (value) => setState(() => _agree = value ?? false),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(color: AppColors.muted),
                              children: [
                                TextSpan(text: 'I\'ve read and agree with the '),
                                TextSpan(
                                  text: 'Terms and\nConditions',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
                                ),
                                TextSpan(text: ' and the '),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(_loading ? 'Creating...' : 'Verify'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: AppColors.muted, fontSize: 15),
                          children: [
                            TextSpan(text: 'Already a member? '),
                            TextSpan(
                              text: 'Login now',
                              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text('Or register with', style: TextStyle(color: AppColors.muted)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _CircleSocial(color: AppColors.google, label: 'G'),
                    ],
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

class _CircleSocial extends StatelessWidget {
  final Color color;
  final String label;

  const _CircleSocial({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
      ),
    );
  }
}
