import 'package:flutter/material.dart';

import '../core/auth_service.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'pin_setup_screen.dart';
import 'pin_unlock_screen.dart';

class AppBootstrapScreen extends StatefulWidget {
  const AppBootstrapScreen({super.key});

  @override
  State<AppBootstrapScreen> createState() => _AppBootstrapScreenState();
}

class _AppBootstrapScreenState extends State<AppBootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final state = await AuthService.instance.bootstrap();

    if (!mounted) return;

    if (!state.hasSession) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (state.requiresPinUnlock && state.email != null && state.email!.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PinUnlockScreen(email: state.email!)),
      );
      return;
    }

    if (state.requiresPinSetup && state.email != null && state.email!.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PinSetupScreen(
            email: state.email!,
            nextScreen: const HomeShell(),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
