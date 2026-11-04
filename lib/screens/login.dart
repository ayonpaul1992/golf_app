import 'package:driver_pos/controllers/async_action_controller.dart';
import 'package:driver_pos/repositories/feature_repositories.dart';
import 'package:driver_pos/services/session_service.dart';
import 'package:driver_pos/theme/app_theme.dart';
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:driver_pos/services/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/dashboard.dart';
import '/components/userentry_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'signup.dart';
import 'forgot_password.dart';
import 'reset_password.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/biometric_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.repository});
  final AuthRepository? repository;

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Create a storage instance
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final phoneText = TextEditingController();
  final passText = TextEditingController();
  final _loginAction = AsyncActionController<void>();
  bool get isLoading => _loginAction.isLoading;
  @override
  void initState() {
    super.initState();
    _loginAction.addListener(_actionChanged);
  }

  void _actionChanged() {
    if (mounted) setState(() {});
  }

  bool _isHoveredForgotPassword = false;
  String selectedCountryCode = '+91';
  bool isPhoneFocused = false;
  final FocusNode phoneFocusNode = FocusNode();
  @override
  void dispose() {
    _loginAction.dispose();
    phoneText.dispose();
    passText.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  // Function to show the error or success messages
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loginUser() {
    if (isLoading) return Future.value();
    return _loginAction.run(_performLogin);
  }

  Future<void> _performLogin() async {
    final String golfCourseCode = ApiConfig.golfCourseCode;

    try {
      final loginPayload = {
        'email': phoneText.text.trim(),
        'password': passText.text,
      };

      // Prepare the login payload
      final requestPayload = Map<String, dynamic>.from(loginPayload);

      final response = await (widget.repository ?? authRepository)
          .login(requestPayload, golfCourseCode);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.json;

        if (data['success'] == true) {
          final userData = data['data'];
          final String userId = userData['id'] ?? '';

          if (userData['isVerified'] == false) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(
                    userId: userId,
                    emailOrMobile: phoneText.text.trim(),
                    golfCourseCode: golfCourseCode,
                  ),
                ),
              );
            }
            return;
          }

          // Save tokens and other data
          await secureStorage.write(
              key: 'userName', value: userData['fullName']?.toString());
          await secureStorage.write(
              key: 'userEmail', value: userData['email']?.toString());
          await secureStorage.write(
              key: 'userPhone', value: userData['phoneNumber']?.toString());
          await secureStorage.write(
              key: 'profilePic', value: userData['profilePicture']?.toString());
          await secureStorage.write(
              key: 'accountNumber',
              value: userData['accountNumber']?.toString());
          await secureStorage.write(
              key: 'membership', value: userData['membership']?.toString());
          await secureStorage.write(
              key: 'golfCourseId',
              value: userData['golfCourse']['_id']?.toString());
          await secureStorage.write(
              key: 'golfCourseName',
              value: userData['golfCourse']['name']?.toString());
          await secureStorage.write(
              key: 'golfCourseLogo',
              value: userData['golfCourse']['logo']?.toString());
          await secureStorage.write(
              key: 'golfCourseSmallLogo',
              value: userData['golfCourse']['small_logo']?.toString());
          await SessionService().saveSession(
              data['accessToken'] as String, data['refreshToken'] as String?);

          if (mounted) {
            setupPushNotifications(userId);
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const DashboardPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                      position: animation.drive(tween), child: child);
                },
              ),
            );

            print('Login successful. User ID: $userId');

            SharedPreferences prefs = await SharedPreferences.getInstance();

            bool setupDone = prefs.getBool('biometric_setup_done') ?? false;

            if (!setupDone) {
              final enableBiometric = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Enable Biometric Login?"),
                  content: const Text(
                    "Would you like to use fingerprint or face ID to quickly log in next time?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );

              final biometric = BiometricAuth();

              if (enableBiometric == true) {
                final success = await biometric.enableBiometricAuth();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Biometric login enabled"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to enable biometric login"),
                    ),
                  );
                }
              } else {
                // User selected NO → make sure biometric is disabled
                await biometric.disableBiometricAuth();
              }

              // Mark that prompt was shown
              await prefs.setBool('biometric_setup_done', true);
            }

            // SharedPreferences prefs = await SharedPreferences.getInstance();

            // bool setupDone = prefs.getBool('biometric_setup_done') ?? false;

            // if (!setupDone) {
            //   final enableBiometric = await showDialog<bool>(
            //     context: context,
            //     builder: (ctx) => AlertDialog(
            //       title: const Text("Enable Biometric Login?"),
            //       content: const Text(
            //         "Would you like to use fingerprint or face ID to quickly log in next time?",
            //       ),
            //       actions: [
            //         TextButton(
            //           onPressed: () => Navigator.pop(ctx, false),
            //           child: const Text("No"),
            //         ),
            //         ElevatedButton(
            //           onPressed: () => Navigator.pop(ctx, true),
            //           child: const Text("Yes"),
            //         ),
            //       ],
            //     ),
            //   );

            //   final prefs = await SharedPreferences.getInstance();

            //   if (enableBiometric == true) {
            //     final biometric = BiometricAuth();
            //     final success = await biometric.enableBiometricAuth();

            //     if (success) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text("Biometric login enabled"),
            //         ),
            //       );
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text("Failed to enable biometric login"),
            //         ),
            //       );
            //     }
            //   }

            //   // Mark that the setup prompt was shown (regardless of user choice)
            //   await prefs.setBool('biometric_setup_done', true);
            // }
          }

          _showMessage(data['message'] ?? 'Logged in successfully');
        } else {
          _showMessage(data['message'] ?? 'Login failed');
        }
      } else {
        print('Login failed. Status code: ${response.statusCode}');
        _showMessage(response.message ??
            'Unable to sign in (HTTP ${response.statusCode}). Please try again.');
      }
    } on SocketException catch (e) {
      _showMessage('Network error: Could not connect to the server. $e');
      print('SocketException: $e');
    } catch (error) {
      _showMessage('Unexpected error: $error');
      print('Unexpected error: $error');
    }
  }

  Future<void> setupPushNotifications(String userId) async {
    try {
      // 1. Ask for permission
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint("✅ Notifications allowed");

        // 2. Get FCM token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          debugPrint("FCM registration is available");

          // 3. Send token to backend with userId
          // await sendTokenToServer(userId, fcmToken);
        }

        // 4. (Optional) iOS APNs token
        if (Platform.isIOS && !kIsWeb) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          debugPrint(apnsToken == null
              ? "APNs registration pending"
              : "APNs registration is available");
        }
      } else {
        debugPrint("❌ Notifications not allowed");
      }
    } catch (_) {
      debugPrint('Push registration unavailable; login remains active.');
    }
  }

  bool _isPassVisible = false;
  String? phoneMailError;
  String? passError;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: UserentryAppbar(
        scaffoldKey: _scaffoldKey,
        userId: '',
        showLeading: false,
      ),
      body: Container(
        color: AppColors.pageBackground,
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                "Quick. Simple. Secure.",
                style: GoogleFonts.poppins(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 1,
                          color: AppColors.border,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Login with phone no",
                          style: GoogleFonts.poppins(
                              color: AppColors.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 40,
                          height: 1,
                          color: AppColors.border,
                        ),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 15, left: 20, right: 20, bottom: 30),
                child: Text(
                  "Enter your mobile number to receive a one-time passcode and access your account instantly.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Enter Mobile Number or Email Id',
                        style: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FocusScope(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {
                              isPhoneFocused = hasFocus;
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 38.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: isPhoneFocused
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: phoneText,
                                focusNode: phoneFocusNode,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  hintStyle: TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.poppins(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                onChanged: (value) {
                                  if (value.length == 10 &&
                                      phoneMailError != null) {
                                    setState(() {
                                      phoneMailError = null;
                                    });
                                  }
                                },
                                autofillHints: const [AutofillHints.email],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (phoneMailError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 5),
                          child: Text(
                            phoneMailError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      Text(
                        'Enter Password',
                        style: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 38.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Colors.white, // Set background color if needed
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.1), // Shadow color
                                blurRadius: 6,
                                offset: const Offset(0, 3), // Shadow position
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.border, // Add a color here
                              width: 1, // Optional: set the border width
                            ),
                          ),
                          child: TextField(
                            controller: passText,
                            obscureText:
                                !_isPassVisible, // Toggle text visibilityk
                            decoration: _inputDecoration('**********').copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPassVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.textSubtle,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPassVisible =
                                        !_isPassVisible; // Toggle visibility
                                  });
                                },
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            autofillHints: const [AutofillHints.password],
                          ),
                        ),
                      ),
                      if (passError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 5),
                          child: Text(
                            passError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 38, right: 38, bottom: 20),
                    child: Stack(
                      children: [
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  bool hasError = false;

                                  setState(() {
                                    // Reset error messages
                                    phoneMailError = passError = null;

                                    String input = phoneText.text.trim();

                                    // Validate Mobile or Email
                                    if (input.isEmpty) {
                                      phoneMailError =
                                          'Mobile number or Email id is required.';
                                      hasError = true;
                                    } else if (RegExp(r'^[0-9]{10}$')
                                        .hasMatch(input)) {
                                      // ✅ Valid 10-digit phone number
                                    } else if (RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(input)) {
                                      // ✅ Valid email format
                                    } else {
                                      phoneMailError =
                                          'Enter valid mobile number or email address.';
                                      hasError = true;
                                    }

                                    // Validate Password
                                    if (passText.text.trim().isEmpty) {
                                      passError = 'Password is required.';
                                      hasError = true;
                                    }
                                  });

                                  if (hasError) {
                                    return; // 🚫 Stop if any error exists
                                  }

                                  _loginUser(); // ✅ Call login function if all validations passed
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Proceed",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.surface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const Positioned(
                          top: 16.5,
                          right: 15,
                          child: Icon(
                            Icons.arrow_forward,
                            color: AppColors.surface,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MouseRegion(
                        onEnter: (_) =>
                            setState(() => _isHoveredForgotPassword = true),
                        onExit: (_) =>
                            setState(() => _isHoveredForgotPassword = false),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage()));
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            minimumSize: MaterialStateProperty.all(Size.zero),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: Text(
                            "Forgot your password?",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              height: 1.0,
                              color: _isHoveredForgotPassword
                                  ? AppColors.accent
                                  : AppColors.textMuted, // 🔴 hover = red
                              decorationColor: _isHoveredForgotPassword
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()));
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          minimumSize: MaterialStateProperty.all(Size.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        child: Text(
                          "CREATE AN ACCOUNT",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                            height: 1.0, // match previous height
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 1,
        ),
      ),
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
    );
  }
}
