// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:driver_pos/screens/congratulations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// Use our custom observer globally
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Widget> _initialScreenFuture;

  @override
  void initState() {
    super.initState();
    _initialScreenFuture = _getInitialScreen();
  }

  Future<Widget> _getInitialScreen() async {
    final storage = const FlutterSecureStorage();
    final isLoggedIn = await storage.read(key: 'isLoggedIn');
    final token = await storage.read(key: 'accessToken');

    if (isLoggedIn == 'true' && token != null) {
      final bio = BiometricAuth();
      final isBioEnabled = await bio.isBiometricEnabled();

      if (isBioEnabled) {
        final authenticated = await bio.authenticate(
          reason: "Authenticate to continue",
        );

        if (!authenticated) {
          Future.delayed(const Duration(milliseconds: 100), () {
            SystemNavigator.pop();
          });
        }
      }

      return const DashboardPage();
    }

    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      routes: {
        '/payment-success': (context) => const CongratulationsPage(cngsId: ''),
      },
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: FutureBuilder<Widget>(
        future: _initialScreenFuture, // 🔥 now stable
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasData) {
            Future.microtask(() {
              deepLinkService.initDeepLinks();
            });
            return snapshot.data!;
          }
          return const LoginPage();
        },
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   Future<Widget> _getInitialScreen() async {
//     final storage = const FlutterSecureStorage();
//     final isLoggedIn = await storage.read(key: 'isLoggedIn');
//     final token = await storage.read(key: 'accessToken');

//     if (isLoggedIn == 'true' && token != null) {
//       // Check biometrics
//       final bio = BiometricAuth();
//       final isBioEnabled = await bio.isBiometricEnabled();

//       if (isBioEnabled) {
//         final authenticated = await bio.authenticate(
//           reason: "Authenticate to continue",
//         );

//         if (!authenticated) {
//           // return const LoginPage(); // fallback
//           Future.delayed(const Duration(milliseconds: 100), () {
//             SystemNavigator.pop(); // Fully closes the app
//           });
//         }
//       }

//       return const DashboardPage();
//     }

//     return const SplashScreen();
//   }

//   // Future<Widget> _getInitialScreen() async {
//   //   final storage = const FlutterSecureStorage();
//   //   final isLoggedIn = await storage.read(key: 'isLoggedIn');
//   //   final token = await storage.read(key: 'accessToken');

//   //   if (isLoggedIn == 'true' && token != null) {
//   //     return const DashboardPage();
//   //   }
//   //   return const SplashScreen();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(
//         textScaler: const TextScaler.linear(1.0),
//       ),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         scaffoldMessengerKey: rootScaffoldMessengerKey, // ✅ global snackbar key
//         navigatorKey: navigatorKey,
//         navigatorObservers: [routeObserver],
//         routes: {
//           '/payment-success': (context) =>
//               const CongratulationsPage(cngsId: ''),
//         },
//         theme: ThemeData(
//           textTheme: GoogleFonts.poppinsTextTheme(),
//         ),
//         home: FutureBuilder<Widget>(
//           future: _getInitialScreen(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const SplashScreen();
//             } else if (snapshot.hasData) {
//               // ✅ Initialize deep links after app starts
//               Future.microtask(() {
//                 deepLinkService.initDeepLinks();
//               });
//               return snapshot.data!;
//             }
//             return const LoginPage();
//           },
//         ),
//       ),
//     );
//   }
// }
