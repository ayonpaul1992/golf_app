import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

// Route observer for tracking navigation
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

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

  // Request notification permissions (iOS only)
  await _requestNotificationPermissions();

  // Log tokens for testing (comment out in production)
  await logFcmAndApnsTokens();

  runApp(const MyApp());
}

Future<void> _requestNotificationPermissions() async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');
}

Future<void> logFcmAndApnsTokens() async {
  try {
    // Make sure permissions are already granted before trying
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      debugPrint("🔑 FCM token: $fcmToken");
    } else {
      debugPrint("⚠️ Could not retrieve FCM token yet");
    }

    // Get APNs token only on real iOS device
    if (Platform.isIOS && !kIsWeb) {
      try {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        debugPrint("📌 APNs token: $apnsToken");
      } catch (e) {
        debugPrint("⚠️ APNs token not available (likely simulator): $e");
      }
    }
  } catch (e, st) {
    debugPrint("❌ Error getting tokens: $e\n$st");
  }
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
