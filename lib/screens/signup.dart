import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:gulf_app/components/userentry_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'signup_confirm.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Create a storage instance
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final fullNameText = TextEditingController();
  final phoneText = TextEditingController();
  final passText = TextEditingController();
  final repassText = TextEditingController();
  bool isLoading = false; // For showing a loading spinner
  bool _isHoveredForgotPassword = false;
  String selectedCountryCode = '+91';
  bool isPhoneFocused = false;
  final FocusNode phoneFocusNode = FocusNode();
  @override
  void dispose() {
    phoneFocusNode.dispose();
    super.dispose();
  }

  // Function to show the error or success messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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
                          "Register to get started",
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
                  "Enter your details below and start your journey with driver.io.",
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
                          'Full Name',
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
                              controller: fullNameText,
                              decoration: _inputDecoration(''),
                              style: GoogleFonts.poppins(
                                color: Color(0xFF244065),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Text(
                          'Enter Mobile Number',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6E7373),
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
                                        ? const Color(0xFF9ECF9A)
                                        : Color(0xFFB2C1C0),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.1), // Shadow color
                                      blurRadius: 6,
                                      offset: Offset(0, 3), // Shadow position
                                    ),
                                  ],
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedCountryCode,
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Color(0xFF244065)),
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        items:
                                            ['+91', '+1', '+44', '+61', '+971']
                                                .map((code) => DropdownMenuItem(
                                                      value: code,
                                                      child: Text(code),
                                                    ))
                                                .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              selectedCountryCode = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: phoneText,
                                        focusNode: phoneFocusNode,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '8777784755',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF244065),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        keyboardType: TextInputType.phone,
                                        style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
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
                    SizedBox(
                      height: 20,
                    ),
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
                              controller: passText,
                              decoration: _inputDecoration(''),
                              style: GoogleFonts.poppins(
                                color: Color(0xFF244065),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
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
                              decoration: _inputDecoration(''),
                              style: GoogleFonts.poppins(
                                color: Color(0xFF244065),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupConfirmPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF9ECF9A)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                child: Center(
                                  child: Text(
                                    "Create an account",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16.5,
                            right: 15,
                            child: Icon(
                              Icons.arrow_forward,
                              color: Color(0xFFFFFFFF),
                              size: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: [
                            Text(
                              "Already have an account?",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6E7373)),
                            ),
                            SizedBox(width: 4,),
                            InkWell(
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context)=> LoginPage()
                                    ));
                              },
                              child: Text(
                                "LOGIN",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF669933),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20,),
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
