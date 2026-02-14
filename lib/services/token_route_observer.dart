import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../screens/login.dart'; // Import your LoginPage

// class TokenRouteObserver extends RouteObserver<PageRoute<dynamic>> {
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

//   void _checkToken(BuildContext context) async {
//     final token = await secureStorage.read(key: 'accessToken');

//     if (JwtDecoder.isExpired(token!)) {
//       // Clear all stored tokens
//       await secureStorage.deleteAll();

//       if (!context.mounted) return;

//       // print("Token expired, navigating to login");

//       // Show a dialog or snackbar if needed
//       // For example, you can use a snackbar to inform the user
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Session expired, please log in again."),
//         ),
//       );

//       // Navigate to login
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   void didPush(Route route, Route? previousRoute) {
//     super.didPush(route, previousRoute);
//     if (route is PageRoute) {
//       _checkToken(route.navigator!.context);
//     }
//   }

//   @override
//   void didPop(Route route, Route? previousRoute) {
//     super.didPop(route, previousRoute);
//     if (previousRoute is PageRoute) {
//       _checkToken(previousRoute.navigator!.context);
//     }
//   }
// }

class TokenRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  bool _isChecking = false;

  Future<void> _checkToken(BuildContext context) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final token = await secureStorage.read(key: 'accessToken');

      if (token == null || token.isEmpty) {
        return;
      }

      if (JwtDecoder.isExpired(token)) {
        await secureStorage.deleteAll();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired, please log in again."),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Token check error: $e");
    } finally {
      _isChecking = false;
    }
  }

  bool _isValidPageRoute(Route route) {
    return route is PageRoute &&
        route.settings.name != null; // ignore unnamed internal routes
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    if (_isValidPageRoute(route)) {
      _checkToken(route.navigator!.context);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    if (previousRoute != null && _isValidPageRoute(previousRoute)) {
      _checkToken(previousRoute.navigator!.context);
    }
  }
}
