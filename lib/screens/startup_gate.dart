import 'package:flutter/material.dart';
import '../services/biometric_auth.dart';
import '../services/session_service.dart';
import 'dashboard.dart';
import 'login.dart';
import 'splash_screen.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  final BiometricAuth bio = BiometricAuth();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlow());
  }

  Future<void> _startFlow() async {
    final destination = await SessionService().resolveStartup(
      isBiometricEnabled: bio.isBiometricEnabled,
      authenticate: () => bio.authenticate(
        reason: 'Please authenticate to access your account',
      ),
    );
    _go(destination == SessionDestination.dashboard
        ? const DashboardPage()
        : const LoginPage());
  }

  void _go(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // your loading screen
  }
}
