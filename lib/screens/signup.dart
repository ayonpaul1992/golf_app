// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final fullNameText = TextEditingController();
  final phoneText = TextEditingController();
  final passText = TextEditingController();
  final repassText = TextEditingController();
  bool isLoading = true; // For showing a loading spinner
  String selectedCountryCode = '+91';
  bool isPhoneFocused = false;
  final FocusNode phoneFocusNode = FocusNode();

  List<Map<String, dynamic>> formFields = [];

  @override
  void initState() {
    super.initState();
    _callSignupApi();
  }

  Future<void> _callSignupApi() async {
    // Example API call, replace with your actual endpoint and logic
    final response = await http.get(
        Uri.parse('https://api.dev.driverpos.io/api/v1/pageSettings/Xy1zAb56'));
    if (response.statusCode == 200) {
      final data = response.body; // Process the response data as needed
      final decodedData = jsonDecode(data);
      formFields = List<Map<String, dynamic>>.from(decodedData['data']);
      print('Form fields: $formFields');
      // Set loading to false after data is fetched
    } else {
      // Handle error
      final error = response.body; // Process the error response
      print('API call failed: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    // Example form submission logic, replace with your actual endpoint and logic
    final url = 'https://api.dev.driverpos.io/api/v1/auth/sign-up';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "fname": 'Arnab',
        "lname": 'Banerjee',
        "email": 'ab@gmail.com',
        "password": "123456",
        "phoneNumber": "8798881231",
        //dateOfBirth:2000-01-08
        "golfCourseCode": 'Xy1zAb56'
      }),
    );
    if (response.statusCode == 200) {
      // Handle successful signup
      final responseData = jsonDecode(response.body);
      print('Signup successful: $responseData');
      // Store user data securely
      // await secureStorage.write(key: 'userId', value: responseData['userId']);
      // Navigate to confirmation page or home page
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SignupConfirmPage()),
      // );
    } else {
      // Handle error
      final error = jsonDecode(response.body);
      print('Signup failed: $error');
      // _showError(error['message'] ?? 'An error occurred');
    }
  }

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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9ECF9A),
              ),
            )
          : Container(
              color: const Color(0xFFFAFCFA),
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
                        color: const Color(0xFF669933),
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
                                color: const Color(0xFFB2C1C0),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Register to get started",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF244065),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 40,
                                height: 1,
                                color: const Color(0xFFB2C1C0),
                              ),
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 20, right: 20, bottom: 30),
                      child: Text(
                        "Enter your details below and start your journey with driver.io.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6E7373),
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Dynamic Form Fields

                        ...formFields
                            .where((field) => field['isDisplayed'] == true)
                            .map((field) {
                          return Column(
                            children: [
                              Text(
                                field['displayName'] ?? '',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6E7373),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 38.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(0xFFB2C1C0),
                                      width: 1,
                                    ),
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      switch (field['fieldType']) {
                                        case 'email':
                                          return TextField(
                                            enabled: true,
                                            decoration: _inputDecoration(
                                                field['placeholder'] ?? ''),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          );
                                        case 'password':
                                          return TextField(
                                            enabled: true,
                                            decoration: _inputDecoration(
                                                field['placeholder'] ?? ''),
                                            obscureText: true,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          );
                                        case 'number':
                                          return TextField(
                                            enabled: true,
                                            decoration: _inputDecoration(
                                                field['placeholder'] ?? ''),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              // Only allow digits
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          );
                                        case 'date':
                                          String? dateValue = field['value'];
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return TextField(
                                                enabled: true,
                                                decoration: _inputDecoration(
                                                  dateValue ??
                                                      field['placeholder'] ??
                                                      '',
                                                ),
                                                readOnly: true,
                                                onTap: () async {
                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (pickedDate != null) {
                                                    setState(() {
                                                      dateValue =
                                                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                                    });
                                                  }
                                                },
                                                style: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF244065,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              );
                                            },
                                          );
                                        case 'file':
                                          return InkWell(
                                            onTap: () {
                                              // Implement file picker logic here
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.attach_file,
                                                    color: Color(
                                                      0xFF244065,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    field['placeholder'] ??
                                                        'Choose file',
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                        0xFF244065,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        case 'Text':
                                        default:
                                          return TextField(
                                            enabled: true,
                                            decoration: _inputDecoration(
                                                field['placeholder'] ?? ''),
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),

                        // Column(
                        //   children: [
                        //     Text(
                        //       'Enter Mobile Number',
                        //       style: GoogleFonts.poppins(
                        //         color: const Color(0xFF6E7373),
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w400,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //     const SizedBox(height: 20),
                        //     FocusScope(
                        //       child: Focus(
                        //         onFocusChange: (hasFocus) {
                        //           setState(() {
                        //             isPhoneFocused = hasFocus;
                        //           });
                        //         },
                        //         child: Padding(
                        //           padding: const EdgeInsets.symmetric(
                        //               horizontal: 38.0),
                        //           child: Container(
                        //             decoration: BoxDecoration(
                        //               color: Colors.white,
                        //               borderRadius: BorderRadius.circular(50),
                        //               border: Border.all(
                        //                 color: isPhoneFocused
                        //                     ? const Color(0xFF9ECF9A)
                        //                     : const Color(0xFFB2C1C0),
                        //                 width: 1,
                        //               ),
                        //               boxShadow: [
                        //                 BoxShadow(
                        //                   color: Colors.black
                        //                       .withOpacity(0.1), // Shadow color
                        //                   blurRadius: 6,
                        //                   offset: const Offset(
                        //                       0, 3), // Shadow position
                        //                 ),
                        //               ],
                        //             ),
                        //             padding: const EdgeInsets.symmetric(
                        //                 horizontal: 12),
                        //             child: Row(
                        //               children: [
                        //                 DropdownButtonHideUnderline(
                        //                   child: DropdownButton<String>(
                        //                     value: selectedCountryCode,
                        //                     icon: const Icon(
                        //                         Icons.arrow_drop_down,
                        //                         color: Color(0xFF244065)),
                        //                     style: GoogleFonts.poppins(
                        //                       color: const Color(0xFF244065),
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 14,
                        //                     ),
                        //                     items: [
                        //                       '+91',
                        //                       '+1',
                        //                       '+44',
                        //                       '+61',
                        //                       '+971'
                        //                     ]
                        //                         .map((code) => DropdownMenuItem(
                        //                               value: code,
                        //                               child: Text(code),
                        //                             ))
                        //                         .toList(),
                        //                     onChanged: (value) {
                        //                       if (value != null) {
                        //                         setState(() {
                        //                           selectedCountryCode = value;
                        //                         });
                        //                       }
                        //                     },
                        //                   ),
                        //                 ),
                        //                 const SizedBox(width: 10),
                        //                 Expanded(
                        //                   child: TextField(
                        //                     controller: phoneText,
                        //                     focusNode: phoneFocusNode,
                        //                     decoration: const InputDecoration(
                        //                       border: InputBorder.none,
                        //                       hintText: '',
                        //                       hintStyle: TextStyle(
                        //                         color: Color(0xFF244065),
                        //                         fontWeight: FontWeight.w600,
                        //                         fontSize: 14,
                        //                       ),
                        //                     ),
                        //                     keyboardType: TextInputType.phone,
                        //                     style: GoogleFonts.poppins(
                        //                       color: const Color(0xFF244065),
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 14,
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // Column(
                        //   children: [
                        //     Text(
                        //       'Password',
                        //       style: GoogleFonts.poppins(
                        //         color: const Color(0xFF6E7373),
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w400,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //     const SizedBox(height: 20),
                        //     Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 38.0),
                        //       child: Container(
                        //         decoration: BoxDecoration(
                        //           color: Colors
                        //               .white, // Set background color if needed
                        //           borderRadius: BorderRadius.circular(50),
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black
                        //                   .withOpacity(0.1), // Shadow color
                        //               blurRadius: 6,
                        //               offset:
                        //                   const Offset(0, 3), // Shadow position
                        //             ),
                        //           ],
                        //           border: Border.all(
                        //             color: const Color(
                        //                 0xFFB2C1C0), // Add a color here
                        //             width: 1, // Optional: set the border width
                        //           ),
                        //         ),
                        //         child: TextField(
                        //           controller: passText,
                        //           decoration: _inputDecoration(''),
                        //           style: GoogleFonts.poppins(
                        //             color: const Color(0xFF244065),
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 14,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 25,
                        // ),
                        // Column(
                        //   children: [
                        //     Text(
                        //       'Confirm Password',
                        //       style: GoogleFonts.poppins(
                        //         color: const Color(0xFF6E7373),
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w400,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //     const SizedBox(height: 20),
                        //     Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 38.0),
                        //       child: Container(
                        //         decoration: BoxDecoration(
                        //           color: Colors
                        //               .white, // Set background color if needed
                        //           borderRadius: BorderRadius.circular(50),
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black
                        //                   .withOpacity(0.1), // Shadow color
                        //               blurRadius: 6,
                        //               offset:
                        //                   const Offset(0, 3), // Shadow position
                        //             ),
                        //           ],
                        //           border: Border.all(
                        //             color: const Color(
                        //                 0xFFB2C1C0), // Add a color here
                        //             width: 1, // Optional: set the border width
                        //           ),
                        //         ),
                        //         child: TextField(
                        //           controller: repassText,
                        //           decoration: _inputDecoration(''),
                        //           style: GoogleFonts.poppins(
                        //             color: const Color(0xFF244065),
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 14,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        //Dynamic Form Fields End

                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 38, right: 38, bottom: 20),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Call the submit function
                                    _submitForm();
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         SignupConfirmPage(),
                                    //   ),
                                    // );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9ECF9A)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 10.0),
                                    child: Center(
                                      child: Text(
                                        "Create an account",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFFFFFFF),
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
                                      color: const Color(0xFF6E7373)),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()));
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
                        const SizedBox(
                          height: 20,
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
