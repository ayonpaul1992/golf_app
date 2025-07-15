import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:gulf_app/screens/image_picker_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart'; // or your actual home screen

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final storage = const FlutterSecureStorage();
    String? isLoggedIn = await storage.read(key: 'isLoggedIn');
    String? token = await storage.read(key: 'accessToken');

    if (isLoggedIn == 'true' && token != null) {
      return const DashboardPage(); // replace with your main/home screen
      // return const ImagePickerScreen(); // fallback to image picker screen
    } else {
      // return const LoginPage(); // replace with your login screen
      return const SplashScreen(); // Show splash screen first
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // You can set this to 1.0 to disable all scaling,
        // or a maximum value like 1.2 to limit it.
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
            } else {
              return const LoginPage(); // fallback
            }
          },
        ),
      ),
    );
  }
}
