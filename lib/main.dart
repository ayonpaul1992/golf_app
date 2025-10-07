import 'dart:io';

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

// Use our custom observer globally
final RouteObserver<PageRoute> routeObserver = TokenRouteObserver();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

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
      options.sendDefaultPii = true;
      options.enableLogs = true;

      options.tracesSampleRate =
          1.0; // capture 100% of transactions (adjust for production)

      // options.profilesSampleRate = 1.0;

      // if (Platform.isIOS && !Platform.isMacOS) {
      //   if (defaultTargetPlatform == TargetPlatform.iOS && !isRealDevice()) {
      //     options.profilesSampleRate = 0.0;
      //   }
      // }
    },
    // appRunner: () => runApp(MyApp()),

    appRunner: () => runApp(
      SentryWidget(
        child: MyApp(),
      ),
    ),
  );

  // runApp(const MyApp());
}

bool isRealDevice() {
  // Simulator always has environment variable SIMULATOR_DEVICE_NAME
  return !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final storage = const FlutterSecureStorage();
    final isLoggedIn = await storage.read(key: 'isLoggedIn');
    final token = await storage.read(key: 'accessToken');

    if (isLoggedIn == 'true' && token != null) {
      return const DashboardPage();
    }
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: rootScaffoldMessengerKey, // ✅ global snackbar key

        navigatorObservers: [routeObserver],
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            } else if (snapshot.hasData) {
              return snapshot.data!;
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
