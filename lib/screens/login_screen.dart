import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../widgets/app_text_field.dart';
import 'guest_home_screen.dart';
import 'home_shell.dart';
import 'pin_setup_screen.dart';
import 'pin_unlock_screen.dart';
import 'register_screen.dart';
import 'forgot_pin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription? _authSub;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;
  bool _usePinMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authSub = AuthService.instance.authChanges.listen((state) async {
      if (state.event == AuthChangeEvent.signedIn && mounted) {
        await AuthService.instance.completeGoogleSignInIfNeeded();
        final email = AuthService.instance.currentUserEmail ?? await AuthService.instance.rememberedEmail() ?? '';
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PinSetupScreen(
              email: email,
              nextScreen: const HomeShell(),
            ),
          ),
          (_) => false,
        );
      }
    });
    AuthService.instance.rememberedEmail().then((value) async {
      if (value != null && mounted) {
        _emailController.text = value;
        _usePinMode = await AuthService.instance.hasPinForEmail(value);
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _checkEmailMode(String value) async {
    final usePin = await AuthService.instance.hasPinForEmail(value.trim());
    if (mounted && usePin != _usePinMode) {
      setState(() {
        _usePinMode = usePin;
        _secretController.clear();
      });
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _secretController.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email and ${_usePinMode ? 'PIN' : 'password'}.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_usePinMode) {
        final ok = await AuthService.instance.verifyPin(
          email: email,
          pin: _secretController.text.trim(),
        );
        if (!ok) throw Exception('Invalid PIN.');
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeShell()),
          (_) => false,
        );
      } else {
        await AuthService.instance.signInWithPassword(
          email: email,
          password: _secretController.text,
        );
        if (!mounted) return;
        final hasPin = await AuthService.instance.hasPinForEmail(email);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => hasPin
                ? PinUnlockScreen(email: email)
                : PinSetupScreen(
                    email: email,
                    nextScreen: const HomeShell(),
                  ),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      setState(() => _error = 'Google login could not start. ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset('assets/images/logo_white.png', width: 200, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    hint: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    onChanged: _checkEmailMode,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    hint: _usePinMode ? 'Pin' : 'Password',
                    controller: _secretController,
                    obscureText: _obscure,
                    keyboardType: _usePinMode ? TextInputType.number : TextInputType.text,
                    maxLength: _usePinMode ? 4 : null,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForgotPinScreen(emailPrefill: _emailController.text.trim())));
                    },
                    child: const Text(
                      'Forgot Pin?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _loading ? null : _login,
                      child: Text(_loading ? 'Please wait...' : 'Login'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: AppColors.muted, fontSize: 15),
                          children: [
                            TextSpan(text: 'Not a member? '),
                            TextSpan(
                              text: 'Register now',
                              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Or continue with', style: TextStyle(color: AppColors.muted)),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleButton(color: AppColors.google, label: 'G', onTap: _googleLoading ? null : _googleLogin),
                    ],
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.text),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestHomeScreen()));
                      },
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
                      ),
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

  static Widget _circleButton({required Color color, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
    );
  }
}
