// ignore_for_file: deprecated_member_use, use_build_context_synchronously, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gulf_app/components/userentry_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io show File;
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

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
  String? profilePicturePath;
  Uint8List? profilePictureBytes;

  @override
  void initState() {
    super.initState();
    _callSignupApi();
  }

  void _openImagePicker(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
      );
      // print("Picked file: ${pickedFile?.path}");

      if (pickedFile != null) {
        if (kIsWeb) {
          // Handle Web
          final Uint8List bytes = await pickedFile.readAsBytes();

          // Store image in memory or encode to base64
          profilePictureBytes = bytes;
          // await secureStorage.write(
          //     key: 'profilePic', value: base64Encode(bytes));
          // print("Stored base64 in secureStorage");

          setState(() {
            profilePicturePath =
                'data:image/jpeg;base64,${base64Encode(bytes)}';
          });
        } else {
          // Handle Android/iOS
          final savedPath =
              '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final io.File savedImage =
              await io.File(pickedFile.path).copy(savedPath);

          // print("Saved image path: ${savedImage.path}");
          setState(() {
            profilePicturePath = savedImage.path;
          });
          // await secureStorage.write(key: 'profilePic', value: savedImage.path);
          // print("Saved path: $profilePicturePath");
        }

        if (context.mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _callSignupApi() async {
    // Example API call, replace with your actual endpoint and logic
    final response = await http.get(
        Uri.parse('https://api.dev.driverpos.io/api/v1/pageSettings/Xy1zAb56'));
    if (response.statusCode == 200) {
      final data = response.body; // Process the response data as needed
      final decodedData = jsonDecode(data);
      formFields = List<Map<String, dynamic>>.from(decodedData['data']);
      // print('Form fields: $formFields');
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
  Future<void> _submitForm(formData) async {
    print('Form Data: $formData');
    // Example form submission logic, replace with your actual endpoint and logic
    final url = 'https://api.dev.driverpos.io/api/v1/auth/sign-up';

    final payload = formData;

    final secret = 'course1999golf01'; // must match Node backend ENCRYPT_SECRET
    final keyHash = sha256.convert(utf8.encode(secret)).bytes;
    final secretKey = SecretKey(keyHash);
    final algorithm = AesGcm.with256bits();
    final iv = algorithm.newNonce();

    final secretBox = await algorithm.encrypt(
      utf8.encode(jsonEncode(payload)),
      secretKey: secretKey,
      nonce: iv,
    );

    final encryptedPayload = {
      'iv': base64Encode(iv),
      'data': base64Encode(secretBox.cipherText),
      'tag': base64Encode(secretBox.mac.bytes),
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(encryptedPayload),
    );

    if (response.statusCode == 200) {
      // Signup success
      jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Signup Successful'),
          content: const Text('Your account has been created.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Signup error
      String errorMsg = 'Signup failed';
      try {
        final error = jsonDecode(response.body);
        errorMsg = error['message'] ?? errorMsg;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
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

                        // ...formFields
                        //     .where((field) => field['isDisplayed'] == true)
                        //     .map((field) {
                        //   return Column(
                        //     children: [
                        //       Text(
                        //         field['displayName'] ?? '',
                        //         style: GoogleFonts.poppins(
                        //           color: const Color(0xFF6E7373),
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.w400,
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //       const SizedBox(height: 20),
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 38.0,
                        //         ),
                        //         child: Container(
                        //           decoration: BoxDecoration(
                        //             color: Colors.white,
                        //             borderRadius: BorderRadius.circular(50),
                        //             boxShadow: [
                        //               BoxShadow(
                        //                 color: Colors.black.withOpacity(0.1),
                        //                 blurRadius: 6,
                        //                 offset: const Offset(0, 3),
                        //               ),
                        //             ],
                        //             border: Border.all(
                        //               color: const Color(0xFFB2C1C0),
                        //               width: 1,
                        //             ),
                        //           ),
                        //           child: Builder(
                        //             builder: (context) {
                        //               switch (field['fieldType']) {
                        //                 case 'email':
                        //                   return TextField(
                        //                     enabled: true,
                        //                     decoration: _inputDecoration(
                        //                       field['placeholder'] ?? '',
                        //                     ),
                        //                     keyboardType:
                        //                         TextInputType.emailAddress,
                        //                     style: GoogleFonts.poppins(
                        //                       color: const Color(0xFF244065),
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 14,
                        //                     ),
                        //                   );
                        //                 case 'password':
                        //                   return TextField(
                        //                     enabled: true,
                        //                     decoration: _inputDecoration(
                        //                       field['placeholder'] ?? '',
                        //                     ),
                        //                     obscureText: true,
                        //                     style: GoogleFonts.poppins(
                        //                       color: const Color(0xFF244065),
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 14,
                        //                     ),
                        //                   );
                        //                 case 'number':
                        //                   return TextField(
                        //                     enabled: true,
                        //                     decoration: _inputDecoration(
                        //                         field['placeholder'] ?? ''),
                        //                     keyboardType: TextInputType.number,
                        //                     inputFormatters: [
                        //                       // Only allow digits
                        //                       FilteringTextInputFormatter
                        //                           .digitsOnly,
                        //                     ],
                        //                     style: GoogleFonts.poppins(
                        //                       color: const Color(0xFF244065),
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 14,
                        //                     ),
                        //                   );
                        //                 case 'date':
                        //                   String? dateValue = field['value'];
                        //                   return StatefulBuilder(
                        //                     builder: (context, setState) {
                        //                       return TextField(
                        //                         enabled: true,
                        //                         decoration: _inputDecoration(
                        //                           dateValue ??
                        //                               field['placeholder'] ??
                        //                               '',
                        //                         ),
                        //                         readOnly: true,
                        //                         onTap: () async {
                        //                           DateTime? pickedDate =
                        //                               await showDatePicker(
                        //                             context: context,
                        //                             initialDate: DateTime.now(),
                        //                             firstDate: DateTime(1900),
                        //                             lastDate: DateTime(2100),
                        //                           );
                        //                           if (pickedDate != null) {
                        //                             setState(() {
                        //                               dateValue =
                        //                                   "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        //                             });
                        //                           }
                        //                         },
                        //                         style: GoogleFonts.poppins(
                        //                           color: const Color(
                        //                             0xFF244065,
                        //                           ),
                        //                           fontWeight: FontWeight.w600,
                        //                           fontSize: 14,
                        //                         ),
                        //                       );
                        //                     },
                        //                   );
                        //                 case 'file':
                        //                   return InkWell(
                        //                     onTap: () {
                        //                       // Implement file picker logic here
                        //                     },
                        //                     child: Padding(
                        //                       padding:
                        //                           const EdgeInsets.symmetric(
                        //                         vertical: 14.0,
                        //                         horizontal: 8.0,
                        //                       ),
                        //                       child: Row(
                        //                         children: [
                        //                           const Icon(
                        //                             Icons.attach_file,
                        //                             color: Color(
                        //                               0xFF244065,
                        //                             ),
                        //                           ),
                        //                           const SizedBox(width: 8),
                        //                           Text(
                        //                             field['placeholder'] ??
                        //                                 'Choose file',
                        //                             style: GoogleFonts.poppins(
                        //                               color: const Color(
                        //                                 0xFF244065,
                        //                               ),
                        //                               fontWeight:
                        //                                   FontWeight.w600,
                        //                               fontSize: 14,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   );
                        //                 case 'Text':
                        //                 default:
                        //                   return TextField(
                        //                     enabled: true,
                        //                     decoration: _inputDecoration(
                        //                       field['placeholder'] ?? '',
                        //                     ),
                        //                     style: GoogleFonts.poppins(
                        //                       color: const Color(0xFF244065),
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 14,
                        //                     ),
                        //                   );
                        //               }
                        //             },
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(height: 20),
                        //     ],
                        //   );
                        // }),

                        ...formFields
                            .where((field) => field['isDisplayed'] == true)
                            .map((field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  field['displayName'] ?? '',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF6E7373),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                                            onChanged: (value) =>
                                                field['value'] = value,
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
                                            onChanged: (value) =>
                                                field['value'] = value,
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
                                            onChanged: (value) =>
                                                field['value'] = value,
                                            decoration: _inputDecoration(
                                                field['placeholder'] ?? ''),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          );
                                        case 'date':
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              String? dateValue =
                                                  field['value'];
                                              return TextField(
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
                                                    String formatted =
                                                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                                    setState(() =>
                                                        dateValue = formatted);
                                                    field['value'] = formatted;
                                                  }
                                                },
                                                decoration: _inputDecoration(
                                                    dateValue ??
                                                        field['placeholder'] ??
                                                        ''),
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              );
                                            },
                                          );
                                        case 'file':
                                          return InkWell(
                                            onTap: () async {
                                              // File picker logic here

                                              showModalBottomSheet(
                                                context: context,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                                builder:
                                                    (BuildContext context) {
                                                  return SafeArea(
                                                    child: Wrap(
                                                      children: [
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons
                                                                  .photo_library),
                                                          title: const Text(
                                                              'Choose from Gallery'),
                                                          onTap: () async {
                                                            Navigator.pop(
                                                                context); // Close the bottom sheet **before** launching the picker

                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              if (mounted) {
                                                                _openImagePicker(
                                                                    context,
                                                                    ImageSource
                                                                        .gallery);
                                                              }
                                                            });

                                                            // _openImagePicker(context);
                                                          },
                                                        ),
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons.camera_alt),
                                                          title: const Text(
                                                              'Take a Picture'),
                                                          onTap: () async {
                                                            // Use image_picker package for taking a picture
                                                            // Example:
                                                            // final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                                            Navigator.pop(
                                                                context);
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              if (context
                                                                  .mounted) {
                                                                _openImagePicker(
                                                                    context,
                                                                    ImageSource
                                                                        .camera);
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );

                                              // For example, using file_picker package
                                              // FilePickerResult? result = await FilePicker.platform.pickFiles();
                                              // if (result != null) {
                                              //   field['value'] = result.files.single.path;
                                              // } else {
                                              //   field['value'] = null; // User canceled the picker
                                              // }
                                              // ScaffoldMessenger.of(context)
                                              //     .showSnackBar(
                                              //   const SnackBar(
                                              //     content: Text(
                                              //       'File picker not implemented yet.',
                                              //     ),
                                              //   ),
                                              // );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.attach_file,
                                                      color: Color(0xFF244065)),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    field['placeholder'] ??
                                                        'Choose file',
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                          0xFF244065),
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
                                            onChanged: (value) =>
                                                field['value'] = value,
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
                                  onPressed: () async {
                                    bool isValid = true;
                                    String errorMessage = '';

                                    for (var field in formFields.where(
                                        (f) => f['isDisplayed'] == true)) {
                                      if ((field['isRequired'] ?? false) &&
                                          (field['value'] == null ||
                                              field['value']
                                                  .toString()
                                                  .trim()
                                                  .isEmpty)) {
                                        isValid = false;
                                        errorMessage =
                                            '${field['displayName']} is required.';
                                        break;
                                      }
                                    }

                                    if (isValid) {
                                      Map<String, dynamic> formData = {};
                                      formData['golfCourseCode'] =
                                          'Xy1zAb56'; // Example static value
                                      for (var field in formFields.where(
                                          (f) => f['isDisplayed'] == true)) {
                                        formData[field['fieldName']] =
                                            field['value'];
                                      }

                                      if (formFields.any((f) =>
                                          f['fieldType'] == 'file' &&
                                          f['value'] != null)) {
                                        var fileField = formFields.firstWhere(
                                            (f) => f['fieldType'] == 'file');
                                        formData['profilePicture'] =
                                            fileField['value'];
                                      }

                                      // print('Form Data: $formData');
                                      await _submitForm(formData);

                                      // Submit or navigate
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(errorMessage),
                                        ),
                                      );
                                    }
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
                                child: Icon(Icons.arrow_forward,
                                    color: Color(0xFFFFFFFF), size: 18),
                              )
                            ],
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //       left: 38, right: 38, bottom: 20),
                        //   child: Stack(
                        //     children: [
                        //       SizedBox(
                        //         width: double.infinity,
                        //         child: ElevatedButton(
                        //           onPressed: () async {
                        //             bool isValid = true;
                        //             String errorMessage = '';

                        //             for (var field in formFields.where(
                        //                 (f) => f['isDisplayed'] == true)) {
                        //               // Example validation: required fields
                        //               if ((field['isRequired'] ?? false) &&
                        //                   (field['value'] == null ||
                        //                       field['value']
                        //                           .toString()
                        //                           .trim()
                        //                           .isEmpty)) {
                        //                 isValid = false;
                        //                 errorMessage =
                        //                     '${field['displayName']} is required.';
                        //                 break;
                        //               }
                        //               // Add more validation logic as needed (e.g., email format, password length)
                        //             }

                        //             if (isValid) {
                        //               Map<String, dynamic> formData = {};
                        //               for (var field in formFields.where(
                        //                   (f) => f['isDisplayed'] == true)) {
                        //                 formData[field['fieldName']] =
                        //                     field['value'];
                        //               }
                        //               print('Form Data: $formData');
                        //               // await _submitForm();
                        //               // Optionally navigate to confirmation page
                        //               // Navigator.push(context, MaterialPageRoute(builder: (context) => SignupConfirmPage()));
                        //             } else {
                        //               ScaffoldMessenger.of(context)
                        //                   .showSnackBar(
                        //                 SnackBar(
                        //                   content: Text(errorMessage),
                        //                 ),
                        //               );
                        //             }
                        //           },
                        //           style: ElevatedButton.styleFrom(
                        //               backgroundColor: const Color(0xFF9ECF9A)),
                        //           child: Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //                 horizontal: 15.0, vertical: 10.0),
                        //             child: Center(
                        //               child: Text(
                        //                 "Create an account",
                        //                 style: GoogleFonts.poppins(
                        //                   color: const Color(0xFFFFFFFF),
                        //                   fontSize: 16,
                        //                   fontWeight: FontWeight.w600,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       const Positioned(
                        //         top: 16.5,
                        //         right: 15,
                        //         child: Icon(
                        //           Icons.arrow_forward,
                        //           color: Color(0xFFFFFFFF),
                        //           size: 18,
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),

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
