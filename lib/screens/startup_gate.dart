import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/biometric_auth.dart';
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
    final storage = const FlutterSecureStorage();
    final isLoggedIn = await storage.read(key: 'isLoggedIn');
    final token = await storage.read(key: 'accessToken');

    final loggedIn = (isLoggedIn == 'true' && token != null);

    if (!loggedIn) {
      _go(const LoginPage());
      return;
    }

    final bioEnabled = await bio.isBiometricEnabled();

    // Ask biometric if enabled
    if (bioEnabled) {
      final ok = await bio.authenticate(
          reason: "Please authenticate to access your account");

      if (!ok) {
        _go(const LoginPage());
        return;
      }
    }

    // Go to dashboard after successful biometric
    _go(const DashboardPage());
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
