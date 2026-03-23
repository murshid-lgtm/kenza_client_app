import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'pin_setup_screen.dart';
import 'pin_unlock_screen.dart';

class AppBootstrapScreen extends StatelessWidget {
  const AppBootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BootstrapState>(
      future: AuthService.instance.bootstrap(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final state = snapshot.data!;
        if (!state.hasSession) return const LoginScreen();
        if (state.requiresPinSetup) {
          return PinSetupScreen(
            email: state.email ?? '',
            title: 'Set your 4-digit PIN',
            subtitle: 'Use this PIN for faster future sign in.',
            nextScreen: const HomeShell(),
          );
        }
        return PinUnlockScreen(email: state.email ?? '');
      },
    );
  }
}
