// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:io' as io show File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart'; // for MediaType

class MyEditPage extends StatefulWidget {
  final String myEdId;
  const MyEditPage({super.key, required this.myEdId});

  @override
  State<StatefulWidget> createState() => MyEditPageState();
}

class MyEditPageState extends State<MyEditPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;
  bool isDateFieldFocused = false; // Rename from isLoading for clarity
  String? dobError;
  DateTime? _selectedDate;
  bool _isExpanded = true;
  final customerIdText = TextEditingController();
  final fullNmText = TextEditingController();
  final lastNmText = TextEditingController();
  final emailIdText = TextEditingController();
  final lgnemailIdText = TextEditingController();
  final phoneNoText = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  final passText = TextEditingController();
  String? passError;
  String? emailError;
  String? lgnemailError;
  String? phoneError;
  String? firstNameError;
  String? lastNameError;
  String? customerIdError;
  String? addressError;
  String? cityError;
  String? stateError;
  String? zipError;

  // state variables for profile picture
  String? profilePicturePath;

  Uint8List? profilePictureBytes; // for web
  @override
  void dispose() {
    phoneNoText.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
    fetchUserProfile();
    // fetchPostalCodeData('00501'); // Example postal code
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      final token = await secureStorage.read(key: 'accessToken');
      final response = await http.get(
        Uri.parse('https://api.dev.driverpos.io/api/v1/customer/myProfile'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final dataJson = json.decode(response.body);
        final data = dataJson['data'] as Map<String, dynamic>;
        // print("Fetched data: $data");
        setState(() {
          customerIdText.text = data['accountNumber'] ?? '';
          fullNmText.text = data['fname'] ?? '';
          lastNmText.text = data['lname'] ?? '';
          emailIdText.text = data['email'] ?? '';
          lgnemailIdText.text = data['email'] ?? '';
          phoneNoText.text = data['phoneNumber'] ?? '';
          addressController.text =
              data['personalInfo']['address']['streetAddress'] ?? '';
          cityController.text = data['personalInfo']['address']['city'] ?? '';
          stateController.text = data['personalInfo']['address']['state'] ?? '';
          zipController.text = data['personalInfo']['address']['zipCode'] ?? '';
          profilePicturePath = data['profilePicture'] ?? '';
          passText.text = ''; // Do not prefill password for security
          if (data['personalInfo']['dateOfBirth'] != null &&
              data['personalInfo']['dateOfBirth'].isNotEmpty) {
            try {
              final parsedDate =
                  DateTime.parse(data['personalInfo']['dateOfBirth']);
              _selectedDate = parsedDate;
              _dateController.text =
                  DateFormat("MMM dd, yyyy").format(parsedDate);
            } catch (_) {
              _dateController.text = '';
            }
          }
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPostalCodeData(String postalCode) async {
    String url =
        'http://api.geonames.org/postalCodeLookupJSON?postalcode=$postalCode&country=US&username=tuhinkapri';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("✅ API Response: $data");

        cityController.text = data['postalcodes'][0]['placeName'] ?? '';
        stateController.text = data['postalcodes'][0]['adminName1'] ?? '';
      } else {
        print("⚠️ Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("❌ Exception caught: $e");
    }
  }

  void _showDatePicker(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: const FractionalOffset(0.5, 0.42),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20), bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SfDateRangePicker(
                    initialSelectedDate: _selectedDate,
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: const Color(0xFF9ECF9A),
                    todayHighlightColor: const Color(0xFF9ECF9A),
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: GoogleFonts.poppins(
                        color: const Color(0xFF3F4B4B),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      setState(() {
                        _selectedDate = args.value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(
                              () => isDateFieldFocused = false); // Reset border
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          if (_selectedDate != null) {
                            final formattedDate = DateFormat("MMM dd, yyyy")
                                .format(_selectedDate!);
                            setState(() {
                              _dateController.text = formattedDate;
                              isDateFieldFocused = false; // Reset border
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF9ECF9A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "OK",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // create a function to hanmdle form submission
  void _handleFormSubmission() async {
    setState(() {
      emailError = lgnemailError = phoneError = passError = dobError =
          firstNameError = lastNameError = customerIdError =
              addressError = cityError = stateError = zipError = null;

      // --- Validation ---
      if (fullNmText.text.isEmpty) firstNameError = "First Name is required";
      if (lastNmText.text.isEmpty) lastNameError = "Last Name is required";
      if (cityController.text.isEmpty) cityError = "City Name is required";
      if (stateController.text.isEmpty) stateError = "State Name is required";
      if (addressController.text.isEmpty) addressError = "Address is required";
      if (zipController.text.isEmpty) zipError = "Zip code is required";
      if (emailIdText.text.isEmpty) {
        emailError = "Email is required";
      } else if (!RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$')
          .hasMatch(emailIdText.text)) {
        emailError = "Enter a valid email address";
      }
      if (phoneNoText.text.isEmpty) {
        phoneError = "Phone number is required";
      } else if (!RegExp(r'^\d{10}$').hasMatch(phoneNoText.text)) {
        phoneError = "Enter a valid 10-digit phone number";
      }
      if (_dateController.text.isEmpty) {
        dobError = "Date of birth is required";
      }

      isLoading = true;
    });

    // --- Read image if any ---
    String? imagePath = profilePictureBytes != null
        ? base64Encode(profilePictureBytes ?? Uint8List(0))
        : profilePicturePath;
    Uint8List? imageBytes;

    // print("Now Image path: $imagePath");

    if (kIsWeb) {
      // Check if imagePath is a base64 string or a URL
      if (imagePath!.startsWith('http')) {
        // It's a URL, do nothing (let the server handle it)
      } else {
        // Assume it's base64 string
        imageBytes = base64Decode(imagePath);
      }
    }

    // --- Prepare multipart request ---
    final token = await secureStorage.read(key: 'accessToken');

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('https://api.dev.driverpos.io/api/v1/customer/myProfile'),
    ); // 🔁 Force PUT method

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    // Text fields
    request.fields['fname'] = fullNmText.text;
    request.fields['lname'] = lastNmText.text;
    request.fields['email'] = emailIdText.text;
    request.fields['phoneNumber'] = phoneNoText.text;
    request.fields['personalInfo[address][streetAddress]'] =
        addressController.text;
    request.fields['personalInfo[address][city]'] = cityController.text;
    request.fields['personalInfo[address][state]'] = stateController.text;
    request.fields['personalInfo[address][zipCode]'] = zipController.text;
    request.fields['personalInfo[dateOfBirth]'] = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : '';

    if (kIsWeb && imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'profilePicture',
          imageBytes,
          // make dynamic filename
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else if (!kIsWeb && io.File(imagePath!).existsSync()) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // --- Send request ---
    try {
      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200 || res.statusCode == 204) {
        // print("Profile updated successfully: ${res.body}");
        await secureStorage.write(
          key: 'userName',
          value: "${fullNmText.text} ${lastNmText.text}",
        );
        await secureStorage.write(key: 'userEmail', value: emailIdText.text);
        await secureStorage.write(key: 'userPhone', value: phoneNoText.text);
        await secureStorage.write(
            key: 'profilePic',
            value: res.body.isNotEmpty
                ? json.decode(res.body)['data']['profilePicture']
                : ''); // Update profile picture path in secure storage

        // print("Profile updated successfully: ${res.body}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myEdId, // ✅ Pass the correct userId
        showLeading: true, // ✅ Set to true to show the back button
        onBackPressed: () {
          Navigator.pop(context); // Optional: customize back behavior if needed
        },
      ),
      drawer: CustomDrawer(
        activeTile: '',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    SingleChildScrollView(
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
                              "Edit Profile",
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
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print('Profile picture tapped');
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo_library),
                                          title:
                                              const Text('Choose from Gallery'),
                                          onTap: () async {
                                            Navigator.pop(
                                                context); // Close the bottom sheet **before** launching the picker

                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              if (mounted) {
                                                _openImagePicker(context,
                                                    ImageSource.gallery);
                                              }
                                            });

                                            // _openImagePicker(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('Take a Picture'),
                                          onTap: () async {
                                            // Use image_picker package for taking a picture
                                            // Example:
                                            // final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                            Navigator.pop(context);
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              if (context.mounted) {
                                                _openImagePicker(context,
                                                    ImageSource.camera);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              clipBehavior: Clip.none, // allow overflow
                              width: 162,
                              height: 162, // slightly larger to allow overflow
                              child: Stack(
                                clipBehavior: Clip
                                    .none, // important for visibility outside the stack
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 5),
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 162,
                                        height: 162,
                                        child: (profilePicturePath != null &&
                                                profilePicturePath!.isNotEmpty)
                                            ? (kIsWeb ||
                                                    profilePicturePath!
                                                        .startsWith('http')
                                                ? Image.network(
                                                    profilePicturePath!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                        "assets/images/user-svgrepo-com.png",
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.file(
                                                    io.File(
                                                        profilePicturePath!),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                        "assets/images/user-svgrepo-com.png",
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  ))
                                            : Image.asset(
                                                "assets/images/user-svgrepo-com.png",
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -10,
                                    left: 65,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF9ECF9A),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.edit,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header Row with Toggle Arrow
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFB2C1C0),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Account information",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF244065),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 22,
                                  color: const Color(0xFF669933),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Expandable Fields
                        if (_isExpanded) ...[
                          _buildLabel("Customer ID"),
                          const SizedBox(height: 10),
                          _buildTextField(customerIdText),
                          if (customerIdError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      customerIdError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.44,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHalfField("First Name", fullNmText),
                                    if (firstNameError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12.0, top: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                firstNameError!,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.44,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHalfField("Last Name", lastNmText),
                                    if (lastNameError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12.0, top: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                lastNameError!,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildLabel("Email"),
                          const SizedBox(height: 10),
                          _buildTextField(emailIdText, isEmail: true),
                          if (emailError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      emailError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          _buildLabel("Phone Number"),
                          const SizedBox(height: 10),
                          _buildTextField(phoneNoText, isPhone: true),
                          if (phoneError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      phoneError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          _buildLabel("Date of brith"),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: double.infinity,
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
                                color: isDateFieldFocused
                                    ? const Color(0xFF9ECF9A)
                                    : const Color(0xFFB2C1C0),
                                width: 1,
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDateFieldFocused = true;
                                  });
                                  _showDatePicker(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 12.8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _dateController.text.isNotEmpty
                                            ? _dateController.text
                                            : "Select Date",
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: Color(0xFF648683),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (dobError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      dobError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          _buildLabel("Address"),
                          const SizedBox(height: 10),
                          _buildTextField(addressController, maxLines: 1),
                          if (addressError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      addressError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 10,
                            runSpacing: 15,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.44,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHalfField("City", cityController),
                                    if (cityError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12.0, top: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                cityError!,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.44,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHalfField("State", stateController),
                                    if (stateError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12.0, top: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                stateError!,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.44,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHalfField("Zip", zipController),
                                    if (zipError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12.0, top: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                zipError!,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 7,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // Reset all errors
                                emailError = lgnemailError = phoneError =
                                    passError = dobError = firstNameError =
                                        lastNameError = customerIdError =
                                            addressError = cityError =
                                                stateError = zipError = null;

                                // Validation
                                if (customerIdText.text.isEmpty) {
                                  customerIdError = "Customer ID is required";
                                }
                                if (fullNmText.text.isEmpty) {
                                  firstNameError = "First Name is required";
                                }
                                if (lastNmText.text.isEmpty) {
                                  lastNameError = "Last Name is required";
                                }
                                if (cityController.text.isEmpty) {
                                  cityError = "City Name is required";
                                }
                                if (stateController.text.isEmpty) {
                                  stateError = "State Name is required";
                                }
                                if (addressController.text.isEmpty) {
                                  addressError = "Address is required";
                                }
                                if (zipController.text.isEmpty) {
                                  zipError = "Zip code is required";
                                }

                                // Email validation (lowercase, must have '@' and domain like '.com')
                                if (emailIdText.text.isEmpty) {
                                  emailError = "Email is required";
                                } else if (!RegExp(
                                        r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$')
                                    .hasMatch(emailIdText.text)) {
                                  emailError = "Enter a valid email address";
                                }

                                if (lgnemailIdText.text.isEmpty) {
                                  lgnemailError = "Email is required";
                                } else if (!RegExp(
                                        r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$')
                                    .hasMatch(lgnemailIdText.text)) {
                                  lgnemailError = "Enter a valid email address";
                                }

                                // Phone validation
                                if (phoneNoText.text.isEmpty) {
                                  phoneError = "Phone number is required";
                                } else if (phoneNoText.text.length < 10) {
                                  phoneError =
                                      "Phone number must be at least 10 digits";
                                } else if (phoneNoText.text.length > 10) {
                                  phoneError =
                                      "Phone number cannot be more than 10 digits";
                                }

                                // Date of birth validation
                                if (_dateController.text.isEmpty) {
                                  dobError = "Date of birth is required";
                                }

                                // Password validation
                                if (passText.text.isEmpty) {
                                  passError = "Password is required";
                                } else if (passText.text.length < 6) {
                                  passError =
                                      "Password must be at least 6 characters";
                                }

                                // Proceed if no errors
                                if (emailError == null &&
                                    lgnemailError == null &&
                                    phoneError == null &&
                                    passError == null &&
                                    dobError == null &&
                                    firstNameError == null &&
                                    lastNameError == null &&
                                    customerIdError == null &&
                                    cityError == null &&
                                    stateError == null &&
                                    zipError == null &&
                                    addressError == null) {
                                  // Proceed to next screen or save data
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartPage(myCartId: '')));
                                }

                                _handleFormSubmission();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF9ECF9A),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: const Color(0xFF9ECF9A), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
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

  Widget _buildLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: const Color(0xFF6E7373),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool isEmail = false,
    bool isLgEmail = false,
    bool isPhone = false,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    int maxLines = 1,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                color: errorText != null ? Colors.red : const Color(0xFFB2C1C0),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              //read only if it is Customer ID

              readOnly: controller == customerIdText ? true : false,
              obscureText: isPassword ? obscureText : false,
              keyboardType: isEmail || isLgEmail
                  ? TextInputType.emailAddress
                  : isPhone
                      ? TextInputType.phone
                      : TextInputType.multiline,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                if (isPhone) FilteringTextInputFormatter.digitsOnly,
                if (isPhone) LengthLimitingTextInputFormatter(10),
                if (isEmail || isLgEmail)
                  FilteringTextInputFormatter.deny(
                      RegExp(r'[A-Z]')), // Prevent uppercase
              ],
              onChanged: (value) {
                if (isEmail || isLgEmail) {
                  if (!value.contains('@') || !value.contains('.')) {
                    setState(() {
                      if (isEmail) {
                        emailError = "Enter a valid email address";
                      } else if (isLgEmail) {
                        lgnemailError = "Enter a valid email address";
                      }
                    });
                  } else {
                    setState(() {
                      if (isEmail) {
                        emailError = null;
                      } else if (isLgEmail) {
                        lgnemailError = null;
                      }
                    });
                  }
                } else if (isPhone) {
                  if (value.length < 10) {
                    setState(() {
                      phoneError = "Phone number must be at least 10 digits";
                    });
                  } else if (value.length > 10) {
                    setState(() {
                      phoneError = "Phone number cannot be more than 10 digits";
                    });
                  } else {
                    setState(() {
                      phoneError = null;
                    });
                  }
                }
              },
              maxLines: maxLines,
              decoration:
                  _inputDecoration(isPassword ? '**********' : '').copyWith(
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF648683),
                        ),
                        onPressed: onToggleVisibility,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 10),

                        child: controller == customerIdText
                            ? null
                            : const Icon(
                                Icons.edit,
                                color: Color(0xFF6B7280),
                                size: 18,
                              ),

                        // child: Icon(
                        //   Icons.edit,
                        //   color: Color(0xFF6B7280),
                        //   size: 18,
                        // ),
                      ),
              ),
              style: GoogleFonts.poppins(
                color: const Color(0xFF244065),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              autofillHints: isPassword ? [AutofillHints.password] : null,
            ),
          ),
          if (errorText != null) const SizedBox(height: 5),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHalfField(String label, TextEditingController controller,
      {String? errorText}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.46,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 10),
          Container(
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
                color: errorText != null ? Colors.red : const Color(0xFFB2C1C0),
                width: 1,
              ),
            ),
            child: TextField(
                controller: controller,
                readOnly: controller == cityController ||
                        controller == stateController
                    ? true
                    : false,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      30), // Add this line for the 30-letter limit
                ],
                style: GoogleFonts.poppins(
                  color: const Color(0xFF244065),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                decoration: _inputDecoration('').copyWith(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: controller == cityController ||
                            controller == stateController
                        ? null
                        : const Icon(
                            Icons.edit,
                            color: Color(0xFF6B7280),
                            size: 18,
                          ),
                  ),
                ),
                onChanged: (value) {
                  if (label == "Zip" && value.length >= 5) {
                    // Call only when 5+ digits entered
                    fetchPostalCodeData(value);
                  }
                }),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 5),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
