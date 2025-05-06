import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:gulf_app/components/userentry_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'password_confirm.dart';

class ResetPasswordPage extends StatefulWidget {
  final String emailOrMobile;
  final String golfCourseCode;
  final String userId;

  const ResetPasswordPage({
    Key? key,
    required this.userId,
    required this.emailOrMobile,
    this.golfCourseCode = 'YdTIjvWB',
  }) : super(key: key);

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}
class ResetPasswordPageState extends State<ResetPasswordPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Create a storage instance
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final passText = TextEditingController();
  final repassText = TextEditingController();
  bool _isLoading = false; // Track loading state
  // Function to show the error or success messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetPassword() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      passError = null;
      repassError = null;
    });

    String password = passText.text.trim();
    String confirmPassword = repassText.text.trim();
    String emailOrMobile = widget.emailOrMobile.trim();
    String userId = widget.userId.trim();

    bool hasError = false;

    if (password.isEmpty) {
      passError = "Please enter a password.";
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      repassError = "Please confirm your password.";
      hasError = true;
    }

    if (!hasError && password != confirmPassword) {
      repassError = "Passwords do not match.";
      hasError = true;
    }

    if (!hasError && password.length < 6) {
      passError = "Password must be at least 6 characters long.";
      hasError = true;
    }

    if (emailOrMobile.isEmpty) {
      _showMessage("Email or Mobile is missing. Cannot reset password.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (hasError) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      var headers = {
        'Content-Type': 'application/json',
      };

      Map<String, dynamic> body = {
        'newPassword': password,
        'confirmPassword': confirmPassword,
        'userId': userId,
        'golfCourseCode': widget.golfCourseCode,
      };

      if (emailOrMobile.contains('@')) {
        body['email'] = emailOrMobile;
      } else {
        body['email'] = '${emailOrMobile}@dummy.com';
        body['mobile'] = emailOrMobile;
      }

      final String url = 'https://api.dev.driverpos.io/api/v1/auth/password?role=customer';

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          _showMessage("Password changed successfully! Please log in.");
          passText.clear();
          repassText.clear();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
            );
          }
        } else {
          _showMessage(data['message'] ?? "Failed to change password.");
        }
      } else {
        var data = json.decode(response.body);
        _showMessage(data['message'] ?? "Failed to change password. Please try again.");
      }
    } on SocketException catch (e) {
      _showMessage("Network error: $e");
      print("SocketException error: $e");
    } catch (e) {
      _showMessage("An error occurred. Please try again later.");
      print("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isPassVisible = false;
  String? passError;
  String? repassError;

  @override
  Widget build(BuildContext context) {
return Scaffold(
  key: _scaffoldKey,
  appBar: UserentryAppbar(
    scaffoldKey: _scaffoldKey,
    userId: widget.userId,
    showLeading: false,
  ),
  body: Container(
    color: Color(0xFFFAFCFA),
    width: double.infinity,
    height: double.infinity,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            "Quick. Simple. Secure.",
            style: GoogleFonts.poppins(
              color: Color(0xFF669933),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: Color(0xFFB2C1C0),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Reset Password",
                      style: GoogleFonts.poppins(
                          color: Color(0xFF244065),
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 40,
                      height: 1,
                      color: Color(0xFFB2C1C0),
                    ),
                  ],
                )),
          ),
          Padding(
            padding:
            EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 30),
            child: Text(
              "As you are not verified setup your new password and secure your account.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Color(0xFF6E7373),
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Password',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6E7373),
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
                          color: Colors.white, // Background color
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xFFB2C1C0), // Add a color here
                            width: 1, // Optional: set the border width
                          ),
                        ),
                        child: TextField(
                          controller: passText,
                          decoration: _inputDecoration('**********').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPassVisible ? Icons.visibility : Icons.visibility_off,
                                color: Color(0xFF648683),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPassVisible = !_isPassVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                          style:  GoogleFonts.poppins(
                            color: Color(0xFF244065),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          autofillHints: [AutofillHints.password],
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
                SizedBox(
                  height: 25,
                ),
                Column(
                  children: [
                    Text(
                      'Confirm Password',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6E7373),
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
                          color: Colors
                              .white, // Set background color if needed
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.1), // Shadow color
                              blurRadius: 6,
                              offset: Offset(0, 3), // Shadow position
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xFFB2C1C0), // Add a color here
                            width: 1, // Optional: set the border width
                          ),
                        ),
                        child: TextField(
                          controller: repassText,
                          decoration: _inputDecoration('**********').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPassVisible ? Icons.visibility : Icons.visibility_off,
                                color: Color(0xFF648683),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPassVisible = !_isPassVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            color: Color(0xFF244065),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          autofillHints: [AutofillHints.password],
                        ),
                      ),
                    ),
                    if (repassError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 5),
                        child: Text(
                          repassError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 38, right: 38, bottom: 20),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword, // Disable button when loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9ECF9A),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Reset password",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: const Color(0xFFFFFFFF),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
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
          color: Color(0xFF9ECF9A),
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
        color: const Color(0xFF6E7373),
        fontSize: 14,
      ),
    );
  }
}