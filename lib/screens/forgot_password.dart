import 'package:driver_pos/repositories/feature_repositories.dart';
import 'package:driver_pos/theme/app_theme.dart';
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:driver_pos/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/userentry_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Create a storage instance
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final phoneText = TextEditingController();
  bool isLoading = false; // For showing a loading spinner
  String selectedCountryCode = '+91';
  bool isPhoneFocused = false;
  final FocusNode phoneFocusNode = FocusNode();
  @override
  void dispose() {
    phoneFocusNode.dispose();
    super.dispose();
  }

  // Function to show the error or success messages

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
                          "Forgot Password",
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
                  "Enter your email address to reset new password.",
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
                        'Enter Email Address',
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
                                    color: Colors.black
                                        .withValues(alpha: 0.1), // Shadow color
                                    blurRadius: 6,
                                    offset:
                                        const Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  // DropdownButtonHideUnderline(
                                  //   child: DropdownButton<String>(
                                  //     value: selectedCountryCode,
                                  //     icon: const Icon(Icons.arrow_drop_down,
                                  //         color: AppColors.ink),
                                  //     style: GoogleFonts.poppins(
                                  //       color: AppColors.ink,
                                  //       fontWeight: FontWeight.w600,
                                  //       fontSize: 14,
                                  //     ),
                                  //     items: ['+91', '+1', '+44', '+61', '+971']
                                  //         .map((code) => DropdownMenuItem(
                                  //               value: code,
                                  //               child: Text(code),
                                  //             ))
                                  //         .toList(),
                                  //     onChanged: (value) {
                                  //       if (value != null) {
                                  //         setState(() {
                                  //           selectedCountryCode = value;
                                  //         });
                                  //       }
                                  //     },
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 10),
                                  Expanded(
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
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // get env baseurl and golf code

                              final String baseUrl = ApiConfig.baseUrl;
                              final String golfCourseCode =
                                  ApiConfig.golfCourseCode;

                              print('Base URL: $baseUrl');
                              print('Golf Course Code: $golfCourseCode');

                              setState(() {
                                isLoading = true;
                              });

                              final email = phoneText.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter your email address.'),
                                  ),
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                return;
                              }

                              //check if it is a valid email
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(email)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter a valid email address.'),
                                  ),
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                return;
                              }

                              try {
                                final String golfCourseCode =
                                    ApiConfig.golfCourseCode;


                                final payload = {
                                  'email': email,
                                  'golfCourseCode': golfCourseCode,
                                };

                                final requestPayload =

                                        Map<String, dynamic>.from(payload);
                                final response = await authRepository.forgotPassword(requestPayload);

                                if (response.statusCode == 200) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Success'),
                                        content: const Text(
                                            'Password reset email has been sent.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //     content:
                                  //         Text('Password reset email sent.'),
                                  //   ),
                                  // );
                                } else {
                                  final Map<String, dynamic> responseBody =
                                      response.json;
                                  final String message = responseBody[
                                          'message'] ??
                                      'Failed to send password reset email.';
                                  print(
                                      'Failed to send password reset email. Status code: $message');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $message'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('An error occurred: $e')),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }

                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => const OtpPage()),
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10.0),
                              child: Center(
                                child: Text(
                                  "Get Mail",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.surface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
