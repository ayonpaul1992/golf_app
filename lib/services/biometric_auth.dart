// import 'package:flutter/foundation.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BiometricAuth {
//   final LocalAuthentication _auth = LocalAuthentication();

//   /// Checks if device supports biometrics and user is enrolled
//   Future<bool> get isDeviceSupported async {
//     try {
//       final supported = await _auth.isDeviceSupported();
//       final canCheck = await _auth.canCheckBiometrics;
//       return supported && canCheck;
//     } catch (e) {
//       debugPrint('Error checking biometric support: $e');
//       return false;
//     }
//   }

//   /// Returns list of available biometric types
//   Future<List<BiometricType>> getAvailableBiometrics() async {
//     try {
//       return await _auth.getAvailableBiometrics();
//     } catch (e) {
//       debugPrint('Error getting biometrics: $e');
//       return [];
//     }
//   }

//   /// Performs biometric authentication
//   Future<bool> authenticate(
//       {String reason = "Authenticate to continue"}) async {
//     try {
//       final isSupported = await isDeviceSupported;
//       if (!isSupported) {
//         debugPrint('Device does not support biometrics.');
//         return false;
//       }

//       final availableBiometrics = await getAvailableBiometrics();
//       if (availableBiometrics.isEmpty) {
//         debugPrint('No biometrics enrolled on device.');
//         return false;
//       }

//       final authenticated = await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: false, // no PIN fallback
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );

//       return authenticated;
//     } catch (e) {
//       debugPrint('Authentication error: $e');
//       return false;
//     }
//   }

//   /// Enables biometric authentication preference
//   Future<bool> enableBiometricAuth() async {
//     final success =
//         await authenticate(reason: "Set up biometric authentication");
//     if (success) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isBiometricEnabled', true);
//     }
//     return success;
//   }

//   /// Checks if biometric authentication is enabled by user
//   Future<bool> isBiometricEnabled() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('isBiometricEnabled') ?? false;
//   }

//   /// Disables biometric authentication
//   Future<void> disableBiometricAuth() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('isBiometricEnabled');
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuth {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isAuthenticating = false;

  /// Checks if device supports biometrics and user is enrolled
  Future<bool> get isDeviceSupported async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (e) {
      debugPrint('Error checking biometric support: $e');
      return false;
    }
  }

  /// Returns list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting biometrics: $e');
      return [];
    }
  }

  /// Performs biometric authentication (Safe against duplicate calls)
  Future<bool> authenticate({
    String reason = "Authenticate to continue",
  }) async {
    // 🚨 Prevent duplicate calls
    if (_isAuthenticating) {
      debugPrint("Authentication already in progress.");
      return false;
    }

    _isAuthenticating = true;

    try {
      final isSupported = await isDeviceSupported;
      if (!isSupported) {
        debugPrint('Device does not support biometrics.');
        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        debugPrint('No biometrics enrolled on device.');
        return false;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: false, // ⚠️ important change
          useErrorDialogs: true,
        ),
      );

      return authenticated;
    } on Exception catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  /// Enables biometric authentication preference
  Future<bool> enableBiometricAuth() async {
    final success =
        await authenticate(reason: "Set up biometric authentication");

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isBiometricEnabled', true);
    }

    return success;
  }

  /// Checks if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isBiometricEnabled') ?? false;
  }

  /// Disables biometric authentication
  Future<void> disableBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isBiometricEnabled');
  }
}

