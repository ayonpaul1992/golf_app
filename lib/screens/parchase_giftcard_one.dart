// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import '/screens/parchase_giftcard_two.dart';

// Add a global RouteObserver for navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class ParchaseGiftCardOnePage extends StatefulWidget {
  final String pgCardId;

  const ParchaseGiftCardOnePage({super.key, required this.pgCardId});

  @override
  State<StatefulWidget> createState() => ParchaseGiftCardOnePageState();
}

class ParchaseGiftCardOnePageState extends State<ParchaseGiftCardOnePage>
    with RouteAware, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- STATE FOR SELECTION (DECOUPLED) ---
  int selectedTabIndex = 0;
  int selectedImageIndex = 0;
  // ----------------------------------------

  final List<String> tabs = [
    "Christmas",
    "New Year",
    "Birthday",
    "Anniversary",
    "Congratulations",
    "Thank you",
    "Best Wishes",
  ];

  final List<String> cardImages = [
    "assets/images/prcrd1.png", // Index 0
    "assets/images/prcrd2.png", // Index 1
    "assets/images/prcrd3.png", // Index 2
    "assets/images/prcrd4.png", // Index 3
    "assets/images/prcrd5.png", // Index 4
    "assets/images/prcrd6.png", // Index 5
    "assets/images/prcrd7.png", // Index 6
  ];

  final mssgText = TextEditingController();

  // Tracks if the message is valid (used for button color)
  bool _isMessageValid = false;

  // NEW: Tracks if the validation hint/error message should be displayed
  bool _showValidationHint = false;

  @override
  void initState() {
    super.initState();
    mssgText.addListener(_validateMessage);
    // Initial validation check
    _validateMessage();
  }

  @override
  void dispose() {
    mssgText.removeListener(_validateMessage);
    mssgText.dispose();
    super.dispose();
  }

  // UPDATED: Now includes a maximum length check (500 characters)
  void _validateMessage() {
    final trimmedText = mssgText.text.trim();
    // Message must be non-empty AND <= 500 characters
    final isValid = trimmedText.isNotEmpty && trimmedText.length <= 500;

    if (_isMessageValid != isValid) {
      setState(() {
        _isMessageValid = isValid;
      });
    }
    // If the message becomes valid while the error is showing, hide the error.
    if (isValid && _showValidationHint) {
      setState(() {
        _showValidationHint = false;
      });
    }
  }

  void _nextImage() {
    setState(() {
      selectedImageIndex = (selectedImageIndex + 1) % cardImages.length;
    });
  }

  void _previousImage() {
    setState(() {
      selectedImageIndex =
          (selectedImageIndex - 1 + cardImages.length) % cardImages.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentImagePath = cardImages[selectedImageIndex];

    final screenWidth = MediaQuery.of(context).size.width;
    final twoColumnWidth = (screenWidth - 30) / 2;
    final fullWidth = screenWidth - 20;

    const darkGreenColor = Color(0xFF669933);
    const lightGreenColor = Color(0xFF9ECF9A);

    final buttonColor = _isMessageValid ? darkGreenColor : lightGreenColor;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.pgCardId,
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
                            "SELECT GIFT CARD DESIGN FOR SPECIAL OCCASIONS",
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
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(tabs.length, (index) {
                        final isActive = selectedTabIndex == index;

                        final isLastTab = index == tabs.length - 1;
                        final buttonWidth =
                            isLastTab ? fullWidth - 20 : twoColumnWidth - 10;

                        return SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = index;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 12),
                              backgroundColor: isActive
                                  ? const Color(0xFF9ECF9A)
                                  : Colors.white,
                              foregroundColor: isActive
                                  ? Colors.white
                                  : const Color(0xFF2A4768),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: isActive
                                      ? const Color(0xFF9ECF9A)
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                            child: Text(
                              tabs[index],
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // START SLIDE WIDGET WRAPPER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Arrow Button (Outside Image)
                      GestureDetector(
                        onTap: _previousImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Color(0xFF6C8197), size: 18),
                        ),
                      ),

                      const SizedBox(width: 7),

                      // Dynamic Image Display Container (Expanded to take available space)
                      Expanded(
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          // Use AnimatedSwitcher for cross-fade transition
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            child: Container(
                              key: ValueKey<int>(selectedImageIndex),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: AssetImage(currentImagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 7),

                      // Right Arrow Button (Outside Image)
                      GestureDetector(
                        onTap: _nextImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.arrow_forward_ios,
                              color: Color(0xFF6C8197), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                // END SLIDE WIDGET WRAPPER
                Padding(
                  padding: const EdgeInsets.only(
                      left: 38, right: 38, bottom: 0, top: 25),
                  // IMPORTANT: Changed to start for left-aligned hint text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Write Your Message",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2A4768),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMessageTextField(mssgText),

                      // START VALIDATION HINT
                      if (!_isMessageValid && _showValidationHint)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 5.0),
                          child: Text(
                            "Please enter the message.",
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      // END VALIDATION HINT
                    ],
                  ),
                ),
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
                            _validateMessage();

                            // 3. Check for invalid state
                            if (!_isMessageValid) {
                              setState(() {
                                // Show validation hint if not valid
                                _showValidationHint = true;
                              });
                              return; // Stop navigation
                            }

                            // 4. If valid, proceed to next screen
                            setState(() {
                              _showValidationHint =
                                  false; // Hide hint if it was previously shown
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParchaseGiftCardTwoPage(
                                  pgCardTwoId: widget.pgCardId,
                                  selectedCardImage: currentImagePath,
                                  message: mssgText.text, giftMessage: '',
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

  InputDecoration _inputDecoration(String hintText, double radius) {
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

  Widget _buildMessageTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      cursorColor: const Color(0xFF9ECF9A),
      maxLines: 1,
      // Added max length property
      style: GoogleFonts.poppins(
        color: const Color(0xFF2A4768),
        fontSize: 14,
      ),
      decoration: _inputDecoration("Type your message here...", 10),
      keyboardType: TextInputType.multiline,
    );
  }
}
