import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../widgets/top_brown_header.dart';
import 'home_shell.dart';
import 'pin_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final OtpFlow flow;
  final PendingRegistration? pendingRegistration;
  final String title;
  final String subtitle;

  const OtpScreen({
    super.key,
    required this.email,
    required this.flow,
    this.pendingRegistration,
    required this.title,
    required this.subtitle,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  String get _token => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_token.length != 6) {
      setState(() => _error = 'Enter the full 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.verifyEmailOtp(
        email: widget.email,
        token: _token,
        flow: widget.flow,
        registration: widget.pendingRegistration,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PinSetupScreen(
            email: widget.email,
            title: widget.flow == OtpFlow.forgotPin ? 'Create new PIN' : 'Set your 4-digit PIN',
            subtitle: widget.flow == OtpFlow.forgotPin
                ? 'Your identity is verified. Choose a new PIN.'
                : 'Verification complete. Set your 4-digit PIN.',
            nextScreen: const HomeShell(),
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      if (widget.flow == OtpFlow.signup) {
        await AuthService.instance.resendSignupOtp(widget.email);
      } else {
        await AuthService.instance.sendForgotPinOtp(widget.email);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code sent again.')),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget _box(int index) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.text),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
        },
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
            const SizedBox(height: 36),
            Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => Padding(
                padding: EdgeInsets.only(right: index == 5 ? 0 : 10),
                child: _box(index),
              )),
            ),
            const SizedBox(height: 34),
            GestureDetector(
              onTap: _resend,
              child: const Text('Resend code', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _loading ? null : _verify,
                  child: Text(_loading ? 'Verifying...' : 'Verify'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
