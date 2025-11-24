// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:driver_pos/screens/congratulations.dart';
import 'package:driver_pos/screens/startup_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import '/services/token_route_observer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'services/deep_link_service.dart';
import 'services/biometric_auth.dart';

final RouteObserver<PageRoute> routeObserver = TokenRouteObserver();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final DeepLinkService deepLinkService = DeepLinkService();

// Handles background push notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📩 Background message: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: ".env");

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'];
      options.sendDefaultPii = true;
      options.enableLogs = true;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: MyApp(),
      ),
    ),
  );
}

bool isRealDevice() {
  return !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        routes: {
          '/payment-success': (context) =>
              const CongratulationsPage(cngsId: ''),
        },
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        // home: const BiometricSplashGate(),
        home: const StartupGate(),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
/// BIOMETRIC SPLASH GATE → Forces biometrics before dashboard ///
//////////////////////////////////////////////////////////////////

class BiometricSplashGate extends StatefulWidget {
  const BiometricSplashGate({super.key});

  @override
  State<BiometricSplashGate> createState() => _BiometricSplashGateState();
}

class _BiometricSplashGateState extends State<BiometricSplashGate> {
  final bio = BiometricAuth();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAppFlow();
    });
  }

  Future<void> _startAppFlow() async {
    final storage = const FlutterSecureStorage();
    final isLoggedIn = await storage.read(key: 'isLoggedIn') == 'true';
    final token = await storage.read(key: 'accessToken');

    // ---------------------------------------------
    // USER NOT LOGGED IN → GO TO LOGIN
    // ---------------------------------------------
    if (!isLoggedIn || token == null) {
      _goTo(const LoginPage());
      return;
    }

    // ---------------------------------------------
    // USER LOGGED IN → BIOMETRIC CHECK IF ENABLED
    // ---------------------------------------------
    final enabled = await bio.isBiometricEnabled();

    if (enabled) {
      final ok = await bio.authenticate(
        reason: "Authenticate to continue",
      );

      if (!ok) {
        print("Biometric failed → going to Login");
        _goTo(const LoginPage());
        return;
      }
    }

    // ---------------------------------------------
    // AUTH OK → PROCEED TO DASHBOARD
    // ---------------------------------------------
    _goTo(const DashboardPage());

    Future.microtask(() {
      deepLinkService.initDeepLinks();
    });
  }

  void _goTo(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
