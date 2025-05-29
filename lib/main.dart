import 'package:flutter/material.dart';
import 'package:gulf_app/screens/weather_screen.dart';
// import 'package:gulf_app/screens/dashboard.dart';
// import 'package:gulf_app/screens/weather_screen.dart';
import 'screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // home: const DashboardPage(dshbId: '')
      home: const SplashScreen(),
      // home: const WeatherScreen(),
    );
  }
}
