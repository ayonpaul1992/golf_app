import 'dart:convert';

import 'package:driver_pos/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import '/screens/parchase_giftcard_three.dart';
import 'package:http/http.dart' as http;

// Add a global RouteObserver for navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class ParchaseGiftCardTwoPage extends StatefulWidget {
  final String selectedCardId;
  final String selectedCardImage;
  final String
      message; // Recipient Name from Step 1, now collected here as rcptText
  final String golfCourseId; // Custom note from Step 1

  const ParchaseGiftCardTwoPage({
    super.key,
    required this.selectedCardId,
    required this.selectedCardImage,
    required this.message,
    required this.golfCourseId,
  });

  @override
  State<StatefulWidget> createState() => ParchaseGiftCardTwoPageState();
}

class ParchaseGiftCardTwoPageState extends State<ParchaseGiftCardTwoPage>
    with RouteAware, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String? userName;

  // Controllers for recipient details
  final rcptText = TextEditingController(); // Recipient Name
  final rcptPhText = TextEditingController(); // Recipient Mobile No
  final rcptEmText = TextEditingController(); // Recipient Email
  final rcptFromText = TextEditingController(); // From Name (Sender)

  // FocusNodes for fields: Essential for managing focus programmatically and dismissing keyboard
  final FocusNode rcptFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode fromFocusNode = FocusNode();
  final FocusNode customAmountFocusNode = FocusNode();

  // State variables for form management
  bool _isFormValid = false;
  bool _showValidationHint = false;
  bool _showNameError = false;
  bool _showPhoneError = false;
  bool _showEmailError = false;
  bool _showFromError = false;

  // --- AMOUNT SELECTION STATE ---
  int selectedIndex =
      0; // Index of the selected amount. -1 if custom failed validation.
  String?
      selectedFinalAmount; // Stores the final selected amount string (e.g., "50.00")
  bool isCustomEditing = false;
  final TextEditingController customAmountController = TextEditingController();

  final List<Map<String, String>> amounts = [
    {"first": "\$", "second": "25.00"},
    {"first": "\$", "second": "50.00"},
    {"first": "\$", "second": "75.00"},
    {
      "first": "Add",
      "second": "+"
    }, // Custom amount entry (always the last index)
  ];

  final List<String> cardImages = [
    "assets/images/prcrd1.png",
    "assets/images/prcrd2.png",
    "assets/images/prcrd3.png",
    "assets/images/prcrd4.png",
    "assets/images/prcrd5.png",
    "assets/images/prcrd6.png",
    "assets/images/prcrd7.png",
  ];

  List<String> phoneSuggestions = [];
  List<String> emailSuggestions = [];

  int selectedImageIndex = 0;

  // --- CORE VALIDATION LOGIC ---
  bool _isFieldBlank(TextEditingController controller) {
    return controller.text.trim().isEmpty;
  }

  bool _isEmailValid() {
    if (_isFieldBlank(rcptEmText)) return false;

    String email = rcptEmText.text.trim();

    // ✅ More accurate email validation
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

    return emailRegex.hasMatch(email);
  }

  bool _isPhoneValid() {
    final phone = rcptPhText.text.trim();
    if (phone.isEmpty) return false;
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  bool _checkIfFormValid() {
    final isRecipientInfoFilledAndValid = !_isFieldBlank(rcptText) &&
        !_isFieldBlank(rcptFromText) &&
        _isEmailValid() &&
        _isPhoneValid();

    final isAmountSelectedAndValid = selectedFinalAmount != null &&
        double.tryParse(selectedFinalAmount!) != null &&
        double.tryParse(selectedFinalAmount!)! > 0;

    return isRecipientInfoFilledAndValid && isAmountSelectedAndValid;
  }

  void _validateForm() {
    String? currentAmountString;

    if (selectedIndex >= 0 && selectedIndex < amounts.length - 1) {
      currentAmountString = amounts[selectedIndex]["second"];
    } else if (selectedIndex == amounts.length - 1) {
      currentAmountString = isCustomEditing
          ? customAmountController.text.trim()
          : amounts[selectedIndex]["second"];
    }

    double? parsedAmount =
        double.tryParse(currentAmountString?.replaceAll('\$', '') ?? '');
    if (parsedAmount != null && parsedAmount > 0) {
      selectedFinalAmount = parsedAmount.toStringAsFixed(2);
    } else {
      selectedFinalAmount = null;
    }

    bool newIsValid = _checkIfFormValid();

    if (_isFormValid != newIsValid) {
      setState(() {
        _isFormValid = newIsValid;
      });
    }
  }

  void _handleCustomAmountSubmit(String value, int index) {
    final amount = double.tryParse(value.trim());

    if (amount == null || amount <= 0) {
      // Invalid amount
      setState(() {
        selectedFinalAmount = null;
        _showValidationHint = true;
        isCustomEditing = true;
      });
      return;
    }

    // Valid amount
    setState(() {
      selectedIndex = index;
      selectedFinalAmount = amount.toStringAsFixed(2); // ✅ Fixed here
      isCustomEditing = false;
      _showValidationHint = false;

      // Update the display text in amounts
      amounts[index] = {
        "first": "\$",
        "second": amount.toStringAsFixed(2),
      };

      _validateForm(); // Optional but recommended
    });
  }

  fetchUserPhoneSuggestions(String param) async {
    final String baseUrl = ApiConfig.baseUrl;

    String apiUrl = '$baseUrl/customer/email-or-phone?phoneNumber=$param';

    String? token = await secureStorage.read(key: 'accessToken') ?? '';
    try {
      // Replace with your actual API call using http or dio
      // Example using http package:
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final phoneNumber = data['data']['phoneNumber'] ?? '';
        final name = data['data']['fullName'] ?? '';

        final namePhone = '$phoneNumber - $name';

        setState(() {
          phoneSuggestions = [namePhone];
        });

        print(phoneSuggestions);
      }
    } catch (e) {}
  }

  fetchUserEmailSuggestions(String param) async {
    final String baseUrl = ApiConfig.baseUrl;

    String apiUrl = '$baseUrl/customer/email-or-phone?email=$param';

    String? token = await secureStorage.read(key: 'accessToken') ?? '';
    try {
      // Replace with your actual API call using http or dio
      // Example using http package:
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final email = data['data']['email'] ?? '';
        final name = data['data']['fullName'] ?? '';

        final nameEmail = '$email - $name';

        setState(() {
          emailSuggestions = [nameEmail];
          // rcptText.text = name; // Fetched recipient name
          // rcptEmText.text = email;
        });

        print(emailSuggestions);
      }
    } catch (e) {}
  }

  fetchUserDetailsByPhone(String param) async {
    // Simulate a network call to fetch user details based on phone number
    await Future.delayed(const Duration(seconds: 1));

    final String baseUrl = ApiConfig.baseUrl;

    String apiUrl = '$baseUrl/customer/email-or-phone?phoneNumber=$param';

    String? token = await secureStorage.read(key: 'accessToken') ?? '';
    try {
      // Replace with your actual API call using http or dio
      // Example using http package:
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data);

        // final phoneNumber = data['data']['phoneNumber'] ?? '';
        // final name = data['data']['fullName'] ?? '';

        // final namePhone = '$phoneNumber - $name';

        setState(() {
          // phoneSuggestions = [namePhone];

          rcptText.text = data['data']['fullName']; // Fetched recipient name
          rcptEmText.text = data['data']['email'];
          // golfCourseId = secureStorage.read(key: 'golfCourseId') as String;
          // phoneSuggestions =
          //     List<String>.from(data['data']['phoneNumber'] ?? []);
        });

        // print(phoneSuggestions);

        // print(giftCardObjects);

        // print('as');

        // print(tabs);
      }
    } catch (e) {
      // Handle error (show snackbar, etc.)
    }

    // For demonstration, let's assume we fetched the following details
    // setState(() {
    //   rcptText.text = "John Doe"; // Fetched recipient name
    //   rcptEmText.text = " ";
    // });
  }

  fetchUserDetailsByEmail(String param) async {
    // Simulate a network call to fetch user details based on phone number
    await Future.delayed(const Duration(seconds: 1));

    final String baseUrl = ApiConfig.baseUrl;

    String apiUrl = '$baseUrl/customer/email-or-phone?email=$param';

    String? token = await secureStorage.read(key: 'accessToken') ?? '';
    try {
      // Replace with your actual API call using http or dio
      // Example using http package:
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data);
        print('fetchUserDetailsByEmail');

        // final phoneNumber = data['data']['phoneNumber'] ?? '';
        // final name = data['data']['fullName'] ?? '';

        // final namePhone = '$phoneNumber - $name';

        setState(() {
          // phoneSuggestions = [namePhone];

          rcptText.text = data['data']['fullName']; // Fetched recipient name
          rcptPhText.text = data['data']['phoneNumber'];

          rcptEmText.text = data['data']['email'];
          // golfCourseId = secureStorage.read(key: 'golfCourseId') as String;
          // phoneSuggestions =
          //     List<String>.from(data['data']['phoneNumber'] ?? []);
        });

        // print(phoneSuggestions);

        // print(giftCardObjects);

        // print('as');

        // print(tabs);
      }
    } catch (e) {
      // Handle error (show snackbar, etc.)
    }
  }

  @override
  void initState() {
    super.initState();

    selectedFinalAmount = amounts[0]["second"];
    // userName = 'arnab'; // Placeholder until async fetch completes
    // rcptFromText.text = userName ?? '';

    loadUserName();
    // Add listeners to controllers for instant validation updates and to clear error flags on typing
    rcptText.addListener(() {
      if (_showNameError && !_isFieldBlank(rcptText)) {
        setState(() {
          _showNameError = false;
        });
      }
      _validateForm();
    });

    rcptPhText.addListener(() {
      if (_showPhoneError && _isPhoneValid()) {
        setState(() {
          _showPhoneError = false;
        });
      }
      _validateForm();
    });

    rcptEmText.addListener(() {
      if (_showEmailError && _isEmailValid()) {
        setState(() {
          _showEmailError = false;
        });
      }
      _validateForm();
    });

    rcptFromText.addListener(() {
      if (_showFromError && !_isFieldBlank(rcptFromText)) {
        setState(() {
          _showFromError = false;
        });
      }
      _validateForm();
    });

    customAmountController.addListener(() {
      if (selectedIndex == amounts.length - 1 && isCustomEditing) {
        if (!_showValidationHint) return;
        setState(() {
          _showValidationHint = false;
        });
      }
      _validateForm();
    });

    // Initial validation check
    _isFormValid = _checkIfFormValid();
  }

  Future<void> loadUserName() async {
    String? name = await secureStorage.read(key: 'userName');
    setState(() {
      userName = name ?? '';
      rcptFromText.text = userName ?? '';
    });
  }

  List<String> backendData = [];

  @override
  void dispose() {
    rcptText.dispose();
    rcptPhText.dispose();
    rcptEmText.dispose();
    rcptFromText.dispose();
    customAmountController.dispose();

    rcptFocusNode.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    fromFocusNode.dispose();
    customAmountFocusNode.dispose();

    super.dispose();
  }

  Future<void> fetchPhoneFromBackend(String phone) async {
    debugPrint("📞 Checking phone in backend: $phone");
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/check-phone"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        debugPrint("✅ Backend response: ${response.body}");
        final data = jsonDecode(response.body);

        setState(() {
          backendData = List<String>.from(data);
        });

        // 🔽 Force dropdown to open by focusing the field
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(phoneFocusNode);
          }
        });
      } else {
        debugPrint("⚠️ Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❗ Error fetching phone: $e");
    }
  }

  Widget _buildErrorHint(String errorMessage, bool showError) {
    if (showError && errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 16.0),
        child: Text(
          errorMessage,
          style: GoogleFonts.poppins(
            color: Colors.red.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
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
        borderSide: BorderSide(
          color: Colors.grey.shade300,
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

  Widget _buildLabeledInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: const Color(0xFF9ECF9A),
      style: GoogleFonts.poppins(
        color: const Color(0xFF2A4768),
        fontSize: 14,
      ),
      decoration: _inputDecoration(hintText),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentImagePath = widget.selectedCardImage;
    const darkGreenColor = Color(0xFF669933);
    const lightGreenColor = Color(0xFF9ECF9A);
    final buttonColor = _isFormValid ? darkGreenColor : lightGreenColor;

    // Error messages
    final rcptNameError =
        _isFieldBlank(rcptText) ? "This field is required." : "";
    final rcptFromError =
        _isFieldBlank(rcptFromText) ? "This field is required." : "";
    String phoneError = "";
    if (_isFieldBlank(rcptPhText)) {
      phoneError = "This field is required.";
    } else if (!_isPhoneValid()) {
      phoneError = "Mobile number must be exactly 10 digits.";
    }
    String emailError = "";
    if (_isFieldBlank(rcptEmText)) {
      emailError = "This field is required.";
    } else if (!_isEmailValid()) {
      emailError =
          "Please enter a valid email address (must contain '@' and '.').";
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: '',
        showLeading: true,
        isOnProfilePage: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          // Your navigation logic here
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss keyboard on anywhere tap outside fields
        },
        child: Container(
          color: const Color(0xFFFAFCFA),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
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
                        SizedBox(
                          width: 210,
                          child: Text(
                            "ENTER RECEIPIENT DETAILS AND AMOUNT",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF244065),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
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
                  height: 25,
                ),
                // Amount Selection Container
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 38),
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE9EBEB),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose an amount *",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF404358),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 15,
                        childAspectRatio: 3.2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(amounts.length, (index) {
                          final isActive = selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              if (index == amounts.length - 1) {
                                // Custom amount selected
                                setState(() {
                                  isCustomEditing = true;
                                  selectedIndex = index;
                                  customAmountController.clear();
                                });

                                // ✅ Immediately focus the custom amount field
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  FocusScope.of(context)
                                      .requestFocus(customAmountFocusNode);
                                });
                              } else {
                                setState(() {
                                  selectedIndex = index;
                                  isCustomEditing = false;
                                  amounts[amounts.length - 1] = {
                                    "first": "Add",
                                    "second": "+"
                                  };
                                  customAmountController.clear();
                                  _validateForm();
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: isActive
                                    ? const Color(0xFF9ECF9A)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF9ECF9A),
                                  width: 1,
                                ),
                              ),
                              child: isCustomEditing &&
                                      index == amounts.length - 1
                                  ? TextField(
                                      controller: customAmountController,
                                      focusNode: customAmountFocusNode,
                                      autofocus: true,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF2A4768),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration:
                                          const InputDecoration.collapsed(
                                        hintText: "Enter amount",
                                      ),
                                      onSubmitted: (value) {
                                        _handleCustomAmountSubmit(value, index);
                                      },
                                      onTapOutside: (event) {
                                        _handleCustomAmountSubmit(
                                            customAmountController.text, index);
                                        FocusScope.of(context).unfocus();
                                      },
                                    )
                                  : Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: amounts[index]["first"]!,
                                            style: GoogleFonts.poppins(
                                              color: isActive
                                                  ? Colors.white
                                                  : const Color(0xFF2A4768),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: amounts[index]["second"]!,
                                            style: GoogleFonts.poppins(
                                              color: isActive
                                                  ? Colors.white
                                                  : const Color(0xFF2A4768),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          );
                        }),
                      ),
                      if (_showValidationHint && selectedFinalAmount == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, left: 5.0),
                          child: Center(
                            child: Text(
                              "Please select a valid amount (greater than \$0.00).",
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Recipient and Sender Details Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(38, 15, 38, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipient Phone
                      Text(
                        "Enter Recipient Mobile No*",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2A4768),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          return RawAutocomplete<String>(
                            textEditingController: rcptPhText,
                            focusNode: phoneFocusNode,
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              final input = textEditingValue.text.trim();
                              if (input.length == 10) {
                                if (backendData.isNotEmpty) {
                                  return backendData;
                                } else {
                                  // Show the entered phone number as a selectable suggestion
                                  return [input];
                                }
                              }
                              return const Iterable<String>.empty();
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  hintText: "Enter recipient's phone number",
                                  suffixIcon: const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFF6E7373)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF9ECF9A), width: 1),
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: const Color(0xFF6E7373),
                                    fontSize: 14,
                                  ),
                                ),
                                onChanged: (val) async {
                                  // Hide error if input is valid length
                                  if (_showPhoneError &&
                                      val.trim().length == 10) {
                                    setState(() => _showPhoneError = false);
                                  }

                                  // Call backend only if exactly 10 digits entered
                                  if (val.trim().length == 10) {
                                    await fetchPhoneFromBackend(val.trim());
                                    // 🔽 Force dropdown open after backendData populated
                                    if (backendData.isNotEmpty && mounted) {
                                      FocusScope.of(context)
                                          .requestFocus(phoneFocusNode);
                                      // Optionally, you might want to call setState(() {}); here if UI does not rebuild
                                    }
                                  } else {
                                    setState(() => backendData.clear());
                                  }
                                },
                                onFieldSubmitted: (_) => onFieldSubmitted(),
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              const double itemHeight = 40.0;
                              final double listHeight =
                                  (options.length * itemHeight)
                                      .clamp(0, 180)
                                      .toDouble();

                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(10),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: constraints.maxWidth,
                                      maxHeight: listHeight,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return SizedBox(
                                          height: itemHeight,
                                          child: ListTile(
                                            dense: true,
                                            title: Text(
                                              option,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: const Color(0xFF2A4768),
                                              ),
                                            ),
                                            onTap: () => onSelected(option),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // LayoutBuilder(
                      //   builder: (context, constraints) {
                      //     return RawAutocomplete<String>(
                      //       textEditingController: rcptPhText,
                      //       focusNode: phoneFocusNode,
                      //       optionsBuilder:
                      //           (TextEditingValue textEditingValue) {
                      //         final phoneSuggestions = this.phoneSuggestions;
                      //         final input = textEditingValue.text.trim();

                      //         // ✅ Do not show any dropdown when input is empty or < 3 digits
                      //         if (input.isEmpty || input.length < 10) {
                      //           return const Iterable<String>.empty();
                      //         }

                      //         // ✅ Filter list only if length >= 10
                      //         final matches = phoneSuggestions
                      //             .where((option) => option.contains(input));

                      //         // ✅ Only show if matches found
                      //         if (matches.isEmpty) {
                      //           return const Iterable<String>.empty();
                      //         }

                      //         return matches;

                      //         // if (input.isEmpty)
                      //         //   return const Iterable<String>.empty();

                      //         // if (input.length == 10) {
                      //         //   return phoneSuggestions
                      //         //       .where((option) => option.contains(input));
                      //         // }
                      //         // return const Iterable<String>.empty();
                      //       },
                      //       fieldViewBuilder: (context, textEditingController,
                      //           focusNode, onFieldSubmitted) {
                      //         return TextFormField(
                      //           controller: textEditingController,
                      //           focusNode: focusNode,
                      //           keyboardType: TextInputType.phone,
                      //           inputFormatters: [
                      //             FilteringTextInputFormatter.allow(
                      //                 RegExp(r'[0-9]')),
                      //             LengthLimitingTextInputFormatter(10),
                      //           ],
                      //           decoration: InputDecoration(
                      //             hintText: "Enter recipient's phone number",
                      //             suffixIcon: const Icon(Icons.arrow_drop_down,
                      //                 color: Color(0xFF6E7373)),
                      //             filled: true,
                      //             fillColor: Colors.white,
                      //             contentPadding: const EdgeInsets.symmetric(
                      //                 vertical: 10, horizontal: 20),
                      //             enabledBorder: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(50),
                      //               borderSide: BorderSide(
                      //                   color: Colors.grey.shade300, width: 1),
                      //             ),
                      //             focusedBorder: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(50),
                      //               borderSide: const BorderSide(
                      //                   color: Color(0xFF9ECF9A), width: 1),
                      //             ),
                      //             hintStyle: GoogleFonts.poppins(
                      //               color: const Color(0xFF6E7373),
                      //               fontSize: 14,
                      //             ),
                      //           ),
                      //           onChanged: (val) {
                      //             // print(val);
                      //             if (_showPhoneError &&
                      //                 val.trim().length == 10) {
                      //               setState(() => _showPhoneError = false);
                      //             }

                      //             if (val.trim().length == 10) {
                      //               // fetchUserDetailsByPhone(val.trim());
                      //               fetchUserPhoneSuggestions(val.trim());
                      //             }
                      //           },
                      //           onFieldSubmitted: (_) => onFieldSubmitted(),
                      //         );
                      //       },
                      //       optionsViewBuilder: (context, onSelected, options) {
                      //         const double itemHeight = 40.0;
                      //         final double listHeight =
                      //             (options.length * itemHeight)
                      //                 .clamp(0, 180)
                      //                 .toDouble();

                      //         return Align(
                      //           alignment: Alignment.topLeft,
                      //           child: Material(
                      //             elevation: 4,
                      //             borderRadius: BorderRadius.circular(10),
                      //             child: ConstrainedBox(
                      //               constraints: BoxConstraints(
                      //                 // ✅ constraints is now available from LayoutBuilder
                      //                 maxWidth: constraints.maxWidth,
                      //                 maxHeight: listHeight,
                      //               ),
                      //               child: ListView.builder(
                      //                 padding: EdgeInsets.zero,
                      //                 shrinkWrap: true,
                      //                 physics: const ClampingScrollPhysics(),
                      //                 itemCount: options.length,
                      //                 itemBuilder: (context, index) {
                      //                   final option = options.elementAt(index);
                      //                   return SizedBox(
                      //                     height: itemHeight,
                      //                     child: ListTile(
                      //                       dense: true,
                      //                       minVerticalPadding: 0,
                      //                       visualDensity:
                      //                           VisualDensity.compact,
                      //                       title: Text(
                      //                         option,
                      //                         style: GoogleFonts.poppins(
                      //                           fontSize: 14,
                      //                           color: const Color(0xFF2A4768),
                      //                         ),
                      //                       ),
                      //                       onTap: () {
                      //                         onSelected(
                      //                             option.split(' - ')[0]);
                      //                         fetchUserDetailsByPhone(
                      //                             option.split(' - ')[0]);
                      //                       },
                      //                     ),
                      //                   );
                      //                 },
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     );
                      //   },
                      // ),

                      _buildErrorHint(phoneError, _showPhoneError),
                      const SizedBox(height: 15),

                      // Recipient Email
                      Text(
                        "Enter Recipient Email*",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2A4768),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return RawAutocomplete<String>(
                            textEditingController: rcptEmText,
                            focusNode: emailFocusNode,
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              final emailSuggestions = this.emailSuggestions;
                              final input = textEditingValue.text.trim();
                              if (input.isEmpty)
                                return const Iterable<String>.empty();
                              return emailSuggestions.where((option) => option
                                  .toLowerCase()
                                  .contains(input.toLowerCase()));
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Enter recipient's email address",
                                  suffixIcon: const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFF6E7373)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF9ECF9A), width: 1),
                                  ),
                                  hintStyle: GoogleFonts.poppins(
                                    color: const Color(0xFF6E7373),
                                    fontSize: 14,
                                  ),
                                ),
                                onChanged: (val) {
                                  print(val);
                                  if (_showEmailError &&
                                      val.contains('@') &&
                                      val.contains('.') &&
                                      val.indexOf('@') < val.lastIndexOf('.')) {
                                    setState(() => _showEmailError = false);
                                  }

                                  if (val.contains('@') && val.contains('.')) {
                                    fetchUserEmailSuggestions(val.trim());
                                  }
                                },
                                onFieldSubmitted: (_) => onFieldSubmitted(),
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              const double itemHeight = 40.0;
                              final double listHeight =
                                  (options.length * itemHeight)
                                      .clamp(0, 180)
                                      .toDouble();

                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(10),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                      maxWidth: constraints.maxWidth,
                                      maxHeight: listHeight,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return SizedBox(
                                          height: itemHeight,
                                          child: ListTile(
                                            dense: true,
                                            minVerticalPadding: 0,
                                            visualDensity:
                                                VisualDensity.compact,
                                            title: Text(
                                              option,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: const Color(0xFF2A4768),
                                              ),
                                            ),
                                            onTap: () => {
                                              print('email option selected'),
                                              onSelected(option),
                                              fetchUserDetailsByEmail(option),
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      _buildErrorHint(emailError, _showEmailError),
                      const SizedBox(height: 15),

                      // Recipient Name
                      Text(
                        "Enter Recipient Name*",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2A4768),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLabeledInputField(
                        controller: rcptText,
                        focusNode: rcptFocusNode,
                        hintText: "Enter recipient's full name",
                        keyboardType: TextInputType.text,
                        onChanged: (_) {
                          if (_showNameError) {
                            setState(() => _showNameError = false);
                          }
                        },
                      ),
                      _buildErrorHint(rcptNameError, _showNameError),
                      const SizedBox(height: 15),

                      // From Name (Sender)
                      Text(
                        "From",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2A4768),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: rcptFromText,
                        focusNode: fromFocusNode,
                        readOnly: true,
                        decoration:
                            _inputDecoration("Your name or sender's name"),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2A4768),
                          fontSize: 14,
                        ),
                      ),
                      _buildErrorHint(rcptFromError, _showFromError),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),

                // Gift cards notes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PLEASE NOTE : ",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2A4768),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Bullet points scrollable horizontally

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(top: 4),
                                child: const Icon(Icons.circle,
                                    color: Color(0xFF2A4768), size: 10)),
                            const SizedBox(width: 7),
                            SizedBox(
                              width: 330,
                              child: Text(
                                "Gift cards are valid only at the listed locations.",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6E7373),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(top: 4),
                                child: const Icon(Icons.circle,
                                    color: Color(0xFF2A4768), size: 10)),
                            const SizedBox(width: 7),
                            SizedBox(
                              width: 330,
                              child: Text(
                                "They may be used for green fees, cart rentals, merchandise, or other purchases as allowed by each course.",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6E7373),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 4),
                              child: const Icon(Icons.circle,
                                  color: Color(0xFF2A4768), size: 10),
                            ),
                            const SizedBox(width: 7),
                            SizedBox(
                              width: 330,
                              child: Text(
                                "Gift cards are not redeemable for cash.",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6E7373),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Next Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(38, 20, 38, 20),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Show error states if invalid before proceeding
                            if (!_isFormValid) {
                              setState(() {
                                _showNameError = _isFieldBlank(rcptText);
                                _showPhoneError = !_isPhoneValid();
                                _showEmailError = !_isEmailValid();
                                _showFromError = _isFieldBlank(rcptFromText);
                                _showValidationHint =
                                    selectedFinalAmount == null;
                              });
                              return;
                            }

                            // Remove focus and dismiss keyboard
                            FocusScope.of(context).unfocus();

                            _validateForm();

                            if (!_isFormValid || selectedFinalAmount == null) {
                              setState(() {
                                _showValidationHint = true;
                              });
                              return;
                            }

                            setState(() {
                              _showValidationHint = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParchaseGiftCardThreePage(
                                  golfCourseId: widget.golfCourseId,
                                  giftCardId: widget.selectedCardId,
                                  selectedCardTrnsImage: currentImagePath,
                                  recipientName: rcptText.text,
                                  senderName: rcptFromText.text,
                                  amount: selectedFinalAmount!,
                                  recipientEmail: rcptEmText.text,
                                  recipientMobileNo: rcptPhText.text,
                                  giftMessage: widget.message,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 2,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            child: Center(
                              child: Text(
                                "Next",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
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
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }
}
