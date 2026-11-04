// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:async';

import 'package:driver_pos/screens/congratulations.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
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
import 'services/session_service.dart';
import 'screens/payment_failed.dart';

// Use our custom observer globally
final RouteObserver<PageRoute> routeObserver = TokenRouteObserver();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final DeepLinkService deepLinkService = DeepLinkService();
final Map<String, WidgetBuilder> paymentRoutes = {
  '/payment-success': (_) => const CongratulationsPage(cngsId: ''),
  '/payment-failed': (_) => const PaymentFailedPage(),
};

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

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: ".env");

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'];
      // Replace with your actual DSN from Sentry
      options.sendDefaultPii = dotenv.env['SENTRY_SEND_DEFAULT_PII'] == 'true';
      options.enableLogs = dotenv.env['SENTRY_ENABLE_LOGS'] == 'true';
      options.tracesSampleRate =
          (double.tryParse(dotenv.env['SENTRY_TRACES_SAMPLE_RATE'] ?? '') ??
                  0.1)
              .clamp(0.0, 1.0)
              .toDouble();
    },
    // appRunner: () => runApp(MyApp()),

    appRunner: () => runApp(
      SentryWidget(
        child: const MyApp(),
      ),
    ),
  );

  // runApp(const MyApp());
}

bool isRealDevice() {
  // Simulator always has environment variable SIMULATOR_DEVICE_NAME
  return !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Widget> _initialScreenFuture;
  bool _deepLinksStarted = false;
  StreamSubscription<void>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _initialScreenFuture = _getInitialScreen();
    _sessionSubscription = SessionService.expired.listen((_) async {
      if (await SessionService().hasValidSession() || !mounted) return;
      final navigator = navigatorKey.currentState;
      if (navigator == null || !navigator.mounted) return;
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Session expired, please log in again.')),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  Future<Widget> _getInitialScreen() async {
    final bio = BiometricAuth();
    final destination = await SessionService().resolveStartup(
      isBiometricEnabled: bio.isBiometricEnabled,
      authenticate: () => bio.authenticate(reason: 'Authenticate to continue'),
    );
    return switch (destination) {
      SessionDestination.dashboard => const DashboardPage(),
      SessionDestination.login => const LoginPage(),
      SessionDestination.welcome => const SplashScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      routes: paymentRoutes,
      theme: AppTheme.light(),
      home: FutureBuilder<Widget>(
        future: _initialScreenFuture, // 🔥 now stable
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasData) {
            if (!_deepLinksStarted) {
              _deepLinksStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) deepLinkService.initDeepLinks();
              });
            }
            return snapshot.data!;
          }
          return const LoginPage();
        },
      ),
    );
  }
}
