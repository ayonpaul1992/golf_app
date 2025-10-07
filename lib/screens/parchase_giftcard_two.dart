// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import '/screens/parchase_giftcard_three.dart'; // Import for next page

// Add a global RouteObserver for navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class ParchaseGiftCardTwoPage extends StatefulWidget {
  final String pgCardTwoId;
  final String selectedCardImage;
  // NOTE: 'message' is the Recipient Name from Step 1, but we collect Recipient Name here (rcptText).
  // I will use 'message' to pass the Recipient Name collected here for Step 3,
  // and 'giftMessage' remains the custom note from Step 1.
  final String
      message; // Currently unused, was Recipient Name in Step 1, now collected here.
  final String giftMessage; // Message from Step 1

  const ParchaseGiftCardTwoPage({
    super.key,
    required this.pgCardTwoId,
    required this.selectedCardImage,
    required this.message,
    required this.giftMessage,
  });

  @override
  State<StatefulWidget> createState() => ParchaseGiftCardTwoPageState();
}

class ParchaseGiftCardTwoPageState extends State<ParchaseGiftCardTwoPage>
    with RouteAware, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Controllers for recipient details
  final rcptText = TextEditingController(); // Recipient Name
  final rcptPhText = TextEditingController(); // Recipient Mobile No
  final rcptEmText = TextEditingController(); // Recipient Email
  final rcptFromText = TextEditingController(); // From Name (Sender)

  // State variables for form management
  bool _isFormValid = false;
  bool _showValidationHint = false;

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
  int selectedImageIndex = 0; // Not used on this page, but kept for context.

  // --- START of the core validation logic ---

  bool _isFieldBlank(TextEditingController controller) {
    return controller.text.trim().isEmpty;
  }

  bool _isEmailValid() {
    if (_isFieldBlank(rcptEmText)) return false;
    // Simple check: must contain '@' and '.'
    return rcptEmText.text.trim().contains('@') &&
        rcptEmText.text.trim().contains('.');
  }

  bool _isPhoneValid() {
    final phone = rcptPhText.text.trim();
    if (phone.isEmpty) return false;
    // Regex checks for exactly 10 digits
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  // Helper function to check if ALL required fields and the amount are valid
  bool _checkIfFormValid() {
    // 1. Check all recipient/sender text fields AND their formats
    final isRecipientInfoFilledAndValid = !_isFieldBlank(rcptText) &&
        !_isFieldBlank(rcptFromText) &&
        _isEmailValid() &&
        _isPhoneValid();

    // 2. Check if the amount is selected and valid (selectedFinalAmount should be set and > 0)
    final isAmountSelectedAndValid = selectedFinalAmount != null &&
        double.tryParse(selectedFinalAmount!) != null &&
        double.tryParse(selectedFinalAmount!)! > 0;

    // The entire form is valid only if BOTH are true
    return isRecipientInfoFilledAndValid && isAmountSelectedAndValid;
  }

  void _validateForm() {
    // 1. Determine the selected amount string
    String? currentAmountString;

    // If a predefined index is selected (0 to length-2)
    if (selectedIndex >= 0 && selectedIndex < amounts.length - 1) {
      currentAmountString = amounts[selectedIndex]["second"];
    }
    // If the custom index is selected (last index)
    else if (selectedIndex == amounts.length - 1) {
      // If user is currently typing, use controller text for validation
      if (isCustomEditing) {
        currentAmountString = customAmountController.text.trim();
      } else {
        // Use the last saved value in the amounts list (e.g., "$120.00")
        currentAmountString = amounts[selectedIndex]["second"];
      }
    }

    // 2. Validate and set the final amount
    final double? parsedAmount =
        double.tryParse(currentAmountString?.replaceAll(r'$', '') ?? '');

    if (parsedAmount != null && parsedAmount > 0) {
      // Valid amount found, update the final state
      // Ensure it is formatted with two decimal places
      selectedFinalAmount = parsedAmount.toStringAsFixed(2);
    } else {
      // Invalid or missing amount
      selectedFinalAmount = null;
    }

    // 3. Update the overall form validity state
    final newIsValid = _checkIfFormValid();
    if (_isFormValid != newIsValid) {
      setState(() {
        _isFormValid = newIsValid;
      });
    }
  }

  // Centralized function to handle custom amount submission (via Enter/Done or clicking away)
  void _handleCustomAmountSubmit(String value, int index) {
    // Only process for the custom index
    if (index != amounts.length - 1) return;

    final amountValue = double.tryParse(value.trim());

    setState(() {
      isCustomEditing = false; // Always exit editing mode

      if (amountValue != null && amountValue > 0) {
        // Valid submission: Update the list structure and selection
        amounts[index] = {
          "first": "\$",
          "second": amountValue.toStringAsFixed(2), // Store fixed decimal value
        };
        selectedIndex = index; // Keep it selected
      } else {
        // Invalid or empty submission: revert tile appearance and deselect
        amounts[index] = {"first": "Add", "second": "+"};

        // Only deselect if the custom field was the *only* thing selected.
        if (selectedIndex == index) {
          selectedIndex = -1; // Deselect to force user to choose or re-enter
        }
      }
      customAmountController.clear();
      _validateForm(); // Re-validate to update selectedFinalAmount and button color
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize with the first amount selected
    selectedFinalAmount = amounts[0]["second"];

    // Add listeners to all four controllers to update the button color instantly
    rcptText.addListener(_validateForm);
    rcptPhText.addListener(_validateForm);
    rcptEmText.addListener(_validateForm);
    rcptFromText.addListener(_validateForm);
    customAmountController
        .addListener(_validateForm); // Listen for live custom input

    // Perform initial validation check for all fields
    _isFormValid = _checkIfFormValid();
  }

  @override
  void dispose() {
    // Remove listeners
    rcptText.removeListener(_validateForm);
    rcptPhText.removeListener(_validateForm);
    rcptEmText.removeListener(_validateForm);
    rcptFromText.removeListener(_validateForm);
    customAmountController.removeListener(_validateForm);

    // Dispose controllers
    rcptText.dispose();
    rcptPhText.dispose();
    rcptEmText.dispose();
    rcptFromText.dispose();
    customAmountController.dispose();

    super.dispose();
  }

  // Widget to display field-specific error hint
  Widget _buildErrorHint(String errorMessage) {
    if (_showValidationHint && errorMessage.isNotEmpty) {
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

  // --- END of the core validation logic ---

  @override
  Widget build(BuildContext context) {
    final currentImagePath = cardImages[selectedImageIndex];

    const darkGreenColor = Color(0xFF669933);
    const lightGreenColor = Color(0xFF9ECF9A);
    final buttonColor = _isFormValid ? darkGreenColor : lightGreenColor;

    // --- Dynamic Error Message Calculation ---
    String rcptNameError =
        _isFieldBlank(rcptText) ? "This field is required." : "";
    String rcptFromError =
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
        userId: widget.pgCardTwoId,
        showLeading: true,
        isOnProfilePage: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          // Handle navigation logic
        },
      ),
      body: Container(
        color: const Color(0xFFFAFCFA),
        width: double.infinity,
        height: double.infinity,
        child: GestureDetector(
          onTap: () {
            // Dismiss the keyboard
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
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
                        SizedBox(
                          width: 240,
                          child: Text(
                            "ENTER RECIPIENT DETAILS AND AMOUNT",
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
                  height: 15,
                ),
                // --- Amount Selection Card ---
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 38, right: 38),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
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
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 15,
                        childAspectRatio: 3.2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(amounts.length, (index) {
                          // The isActive state applies the green background.
                          final isActive = selectedIndex == index;

                          return GestureDetector(
                            onTap: () {
                              if (index == amounts.length - 1) {
                                // Last item: enter input mode
                                setState(() {
                                  isCustomEditing = true;
                                  // Set the custom index as selected IMMEDIATELY upon tap
                                  selectedIndex = index;
                                  customAmountController.clear();
                                  _validateForm();
                                });
                              } else {
                                setState(() {
                                  selectedIndex = index;
                                  isCustomEditing = false;
                                  // Reset custom tile's appearance if a predefined amount is selected
                                  amounts[amounts.length - 1] = {
                                    "first": "Add",
                                    "second": "+"
                                  };
                                  customAmountController.clear();
                                  _validateForm(); // Update selection and validate
                                });
                              }
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  // Use the updated isActive variable here
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
                                        autofocus: true,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
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
                                          // Use the centralized handler for submission
                                          _handleCustomAmountSubmit(
                                              value, index);
                                        },
                                        onTapOutside: (event) {
                                          // Use the centralized handler for tapping outside (losing focus)
                                          _handleCustomAmountSubmit(
                                              customAmountController.text,
                                              index);
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
                                      )),
                          );
                        }),
                      ),
                      // Amount Validation Hint (Shows only on failed 'Next' press and if amount is missing)
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
                // --- Recipient and Sender Details Section ---
                Padding(
                  padding: const EdgeInsets.only(
                      left: 38, right: 38, bottom: 20, top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Recipient Name ---
                      Text(
                        "Enter Recipient Name*",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A4768),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _buildLabeledInputField(
                        controller: rcptText,
                        label: "Recipient Name",
                        hintText: "Enter recipient's full name",
                        keyboardType: TextInputType.text,
                      ),
                      _buildErrorHint(rcptNameError), // Field-specific error
                      const SizedBox(height: 15),

                      // --- Recipient Phone ---
                      Text(
                        "Enter Recipient Mobile No*",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A4768),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _buildPhAutocompleteField(
                        controller: rcptPhText,
                        label: "Recipient Phone",
                        hintText: "Enter recipient's phone number",
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      _buildErrorHint(phoneError), // Field-specific error
                      const SizedBox(height: 15),

                      // --- Recipient Email ---
                      Text(
                        "Enter Recipient Email*",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A4768),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _buildEmailAutocompleteField(
                        controller: rcptEmText,
                        label: "Recipient Email",
                        hintText: "Enter recipient's email address",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildErrorHint(emailError), // Field-specific error
                      const SizedBox(height: 15),

                      // --- From Name (Sender) ---
                      Text(
                        "From",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A4768),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _buildLabeledInputField(
                        controller: rcptFromText,
                        label: "From Name (Sender)",
                        hintText: "Your name or sender's name",
                        keyboardType: TextInputType.text,
                      ),
                      _buildErrorHint(rcptFromError), // Field-specific error
                      const SizedBox(height: 15),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 38, right: 38, bottom: 0, top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PLEASE NOTE : ",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A4768),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 4.5),
                                child: const Icon(
                                  Icons.circle,
                                  color: Color(0xFF2A4768),
                                  size: 10,
                                )),
                            const SizedBox(
                              width: 7,
                            ),
                            SizedBox(
                                width: 330,
                                child: Text(
                                  "Gift cards are valid only at the listed locations.",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400),
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 4.5),
                                child: const Icon(
                                  Icons.circle,
                                  color: Color(0xFF2A4768),
                                  size: 10,
                                )),
                            const SizedBox(
                              width: 7,
                            ),
                            SizedBox(
                                width: 330,
                                child: Text(
                                  "They may be used for green fees, cart rentals, merchandise, or other purchases as allowed by each course.",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400),
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 4.5),
                                child: const Icon(
                                  Icons.circle,
                                  color: Color(0xFF2A4768),
                                  size: 10,
                                )),
                            const SizedBox(
                              width: 7,
                            ),
                            SizedBox(
                                width: 330,
                                child: Text(
                                  "Gift cards are not redeemable for cash.",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Next Button ---
                Padding(
                  padding: const EdgeInsets.only(
                      left: 38, right: 38, bottom: 20, top: 20),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // 1. Ensure focus is removed
                            FocusScope.of(context).unfocus();

                            // 2. Re-run validation on button press
                            _validateForm();

                            // 3. Check for invalid state
                            if (!_isFormValid || selectedFinalAmount == null) {
                              setState(() {
                                // Show validation hint if not valid
                                _showValidationHint = true;
                              });
                              return; // Stop navigation
                            }

                            // 4. If valid, proceed to next screen
                            setState(() {
                              // Hide hint if it was previously shown
                              _showValidationHint = false;
                            });

                            // --- CRITICAL FIX: Pass all collected data and the final amount ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParchaseGiftCardThreePage(
                                  pgCardThreeId: widget.pgCardTwoId,
                                  selectedCardTrnsImage: currentImagePath,
                                  message: rcptText.text, // Recipient Name
                                  senderName: rcptFromText.text, // Sender Name
                                  amount:
                                      selectedFinalAmount!, // **PASS THE CORRECT, VALIDATED AMOUNT**
                                  recipientEmail: rcptEmText.text,
                                  recipientMobileNo: rcptPhText.text,
                                  giftMessage:
                                      widget.giftMessage, // Message from Step 1
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            // Conditional background color based on form validity
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
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }

  // Generic input decoration for rounded fields
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

  // Component to build a single labeled input field
  Widget _buildLabeledInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters, // Added optional formatters
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: const Color(0xFF9ECF9A),
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        color: const Color(0xFF2A4768),
        fontSize: 14,
      ),
      decoration: _inputDecoration(hintText),
      keyboardType: keyboardType,
      // Apply formatters if provided (used for phone number)
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildEmailAutocompleteField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    final List<String> emailSuggestions = [
      "example@gmail.com",
      "john.doe@yahoo.com",
      "jane.smith@hotmail.com",
      "contact@company.com",
    ];

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty)
          return const Iterable<String>.empty();
        return emailSuggestions.where(
          (option) => option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return ListenableBuilder(
          listenable: focusNode,
          builder: (context, child) {
            final bool isFocused = focusNode.hasFocus;
            final IconData suffixIcon =
                isFocused ? Icons.arrow_drop_up : Icons.arrow_drop_down;

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              cursorColor: const Color(0xFF9ECF9A),
              style: GoogleFonts.poppins(
                color: const Color(0xFF2A4768),
                fontSize: 14,
              ),
              decoration: _inputDecoration(hintText).copyWith(
                suffixIcon: Icon(
                  suffixIcon,
                  color: const Color(0xFF6E7373),
                ),
              ),
              onFieldSubmitted: (value) => onFieldSubmitted(),
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        // Calculate dynamic height: each item 48px tall, max height 200
        final double itemHeight = 48.0;
        final double maxHeight = 200.0;
        final double height = (options.length * itemHeight).clamp(0, maxHeight);

        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height, maxWidth: 350),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return SizedBox(
                    height: itemHeight,
                    child: ListTile(
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: const Color(0xFF2A4768)),
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
  }

  Widget _buildPhAutocompleteField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    final List<String> phoneSuggestions = [
      "1234567891",
      "2234567891",
      "3234567891",
      "4234567891",
      "5234567891",
      "6234567891",
    ];

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty)
          return const Iterable<String>.empty();
        return phoneSuggestions.where(
          (option) => option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return ListenableBuilder(
          listenable: focusNode,
          builder: (context, child) {
            final bool isFocused = focusNode.hasFocus;
            final IconData suffixIcon =
                isFocused ? Icons.arrow_drop_up : Icons.arrow_drop_down;

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              cursorColor: const Color(0xFF9ECF9A),
              style: GoogleFonts.poppins(
                color: const Color(0xFF2A4768),
                fontSize: 14,
              ),
              decoration: _inputDecoration(hintText).copyWith(
                suffixIcon: Icon(
                  suffixIcon,
                  color: const Color(0xFF6E7373),
                ),
              ),
              onFieldSubmitted: (value) => onFieldSubmitted(),
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        // Calculate dynamic height: each item 48px tall, max height 200
        final double itemHeight = 48.0;
        final double maxHeight = 200.0;
        final double height = (options.length * itemHeight).clamp(0, maxHeight);

        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height, maxWidth: 350),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return SizedBox(
                    height: itemHeight,
                    child: ListTile(
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: const Color(0xFF2A4768)),
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
  }
}
