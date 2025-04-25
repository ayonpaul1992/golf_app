import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:gulf_app/extras/my_cart.dart';
import 'package:intl/intl.dart';

class teeSheetDtls extends StatefulWidget {
  final String teeSheetDtlsUsrId;
  const teeSheetDtls({super.key, required this.teeSheetDtlsUsrId});

  @override
  State<StatefulWidget> createState() => teeSheetDtlsState();
}

class teeSheetDtlsState extends State<teeSheetDtls> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool isYes = false;
  int? editingIndex;
  int selectedPlayer = 1;
  int selectedRidePlayer = 1;
  String selectedHole = "9";
  int selectedIndex = 0;
  bool showDropdown = false;
  bool showRideDropdown = false; // Added state for Riders dropdown visibility
  OverlayEntry? _dropdownOverlay;
  OverlayEntry? _dropdownRideOverlay;
  bool _isDropdownVisible = false;
  bool _isDropdownRideVisible = false;
  final GlobalKey _iconKey = GlobalKey(); // Key for Players dropdown
  final GlobalKey _iconKeySecond = GlobalKey(); // Key for Riders dropdown

  // Separate function for Players dropdown
  void _togglePlayerDropdown(BuildContext context) {
    if (_isDropdownVisible) {
      _dropdownOverlay?.remove();
      _dropdownOverlay = null;
      setState(() {
        _isDropdownVisible = false;
      });
      return;
    }

    final RenderBox renderBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFF9ECF9A), width: 1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up,
                      size: 20, color: Color(0xFF244065)),
                  onPressed: () => _togglePlayerDropdown(context),
                ),
                ...List.generate(6, (index) {
                  int playerNum = index + 5;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlayer = playerNum;
                      });
                      _togglePlayerDropdown(context);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: Text(
                        "$playerNum",
                        style: GoogleFonts.poppins(
                          color: selectedPlayer == playerNum
                              ? Color(0xFF9ECF9A)
                              : Color(0xFF244065),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_dropdownOverlay!);
    setState(() {
      _isDropdownVisible = true;
    });
  }

  // Separate function for Riders dropdown
  void _toggleRiderDropdown(BuildContext context) {
    if (_isDropdownRideVisible) {
      _dropdownRideOverlay?.remove();
      _dropdownRideOverlay = null;
      setState(() {
        _isDropdownRideVisible = false;
      });
      return;
    }

    final RenderBox renderRiderBox =
        _iconKeySecond.currentContext!.findRenderObject() as RenderBox;
    final Offset offsetRide = renderRiderBox.localToGlobal(Offset.zero);
    final Size sizeRide = renderRiderBox.size;

    _dropdownRideOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offsetRide.dx,
        top: offsetRide.dy,
        width: sizeRide.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFF9ECF9A), width: 1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up,
                      size: 20, color: Color(0xFF244065)),
                  onPressed: () => _toggleRiderDropdown(context),
                ),
                ...List.generate(6, (index) {
                  int riderNum = index + 5;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRidePlayer = riderNum;
                      });
                      _toggleRiderDropdown(context);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: Text(
                        "$riderNum",
                        style: GoogleFonts.poppins(
                          color: selectedRidePlayer == riderNum
                              ? Color(0xFF9ECF9A)
                              : Color(0xFF244065),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_dropdownRideOverlay!);
    setState(() {
      _isDropdownRideVisible = true;
    });
  }

  @override
  void dispose() {
    _dropdownOverlay?.remove();
    _dropdownRideOverlay?.remove(); // Dispose the second overlay as well
    for (var focusNode in _focusNodes) {
      focusNode.removeListener(_onFocusChange);
      focusNode.dispose();
    }
    super.dispose();
  }

  // Added FocusNode List
  final List<FocusNode> _focusNodes = List.generate(
    3,
    (index) => FocusNode(),
  );
  final List<TextEditingController> _controllers = List.generate(
    3,
    (index) => TextEditingController(text: index == 0 ? 'Koushik Datta' : ''),
  );
  @override
  void initState() {
    super.initState();
    // Attach listener to each FocusNode
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    setState(() {}); // Rebuild to update border color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.teeSheetDtlsUsrId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          color: Color(0xFFFAFCFA),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 15,
              ),
              Container(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 1.1,
                          color: Color(0xFFB2C1C0),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Tee Booking",
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
                          height: 1.1,
                          color: Color(0xFFB2C1C0),
                        ),
                      ],
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1FFF0),
                        border:
                            Border.all(color: Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            child: Image.asset(
                              "assets/images/ftr_hstry.png",
                              color: Color(0xFF6B7280),
                              width: 18,
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            // 👈 this ensures text wraps inside available width
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Your time, ",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "6:30AM",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF669933),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ", will be held for 5 minutes. You have ",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "00:00 ",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFFDB0606),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "remaining. Please complete the reservation process.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF1FFF0),
                        border:
                            Border.all(color: Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/solar_golf-bold.png",
                                              color: Color(0xFF6B7280),
                                              width: 18,
                                            ),
                                            SizedBox(
                                                width:
                                                    6), // 👈 replaces spacing
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                "Eden Gardens Golf Course",
                                                style: GoogleFonts.poppins(
                                                  color: Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 70,
                                      color: Color(0xFFB2C1C0),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "assets/images/lets-icons_date-fill.png",
                                                  color: Color(0xFF6B7280),
                                                  width: 18,
                                                ),
                                                SizedBox(
                                                    width:
                                                        6), // 👈 spacing between icon and text
                                                Text(
                                                  "2025-04-11",
                                                  style: GoogleFonts.poppins(
                                                    color: Color(0xFF244065),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    5), // 👈 spacing between rows
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "assets/images/ftr_hstry.png",
                                                  color: Color(0xFF6B7280),
                                                  width: 18,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  "6:30AM",
                                                  style: GoogleFonts.poppins(
                                                    color: Color(0xFF244065),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Players",
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF6E7373),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Wrap(
                                                spacing: 8,
                                                children:
                                                    List.generate(4, (index) {
                                                  int playerNum = index + 1;
                                                  return playerCircle(
                                                    "$playerNum",
                                                    selectedPlayer == playerNum,
                                                    () {
                                                      setState(() {
                                                        selectedPlayer =
                                                            playerNum;
                                                      });
                                                    },
                                                  );
                                                }),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    key: _iconKey,
                                                    onPressed: () =>
                                                        _togglePlayerDropdown(
                                                            context),
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Color(0xFF244065),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Holes",
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF6E7373),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Wrap(
                                          spacing: 8,
                                          children: ["9", "18"].map((hole) {
                                            return playerCircle(
                                              hole,
                                              selectedHole == hole,
                                              () {
                                                setState(() {
                                                  selectedHole = hole;
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Riders",
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF6E7373),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Wrap(
                                                spacing: 8,
                                                children:
                                                    List.generate(4, (index) {
                                                  int riderNum = index + 1;
                                                  return playerCircle(
                                                    "$riderNum",
                                                    selectedRidePlayer ==
                                                        riderNum,
                                                    () {
                                                      setState(() {
                                                        selectedRidePlayer =
                                                            riderNum;
                                                      });
                                                    },
                                                  );
                                                }),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    key: _iconKeySecond,
                                                    onPressed: () =>
                                                        _toggleRiderDropdown(
                                                            context),
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Color(0xFF244065),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rental set of clubs",
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF6E7373),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isYes = !isYes;
                                            });
                                          },
                                          child: Container(
                                            width: 95,
                                            height: 31,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Color(0xFF9ECF9A)),
                                            ),
                                            child: Stack(
                                              children: [
                                                AnimatedAlign(
                                                  alignment: isYes
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  curve: Curves.easeInOut,
                                                  child: Container(
                                                    width: 50,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF9ECF9A),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Center(
                                                        child: Text(
                                                          'NO',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: isYes
                                                                ? Color(
                                                                    0xFF244065)
                                                                : Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Center(
                                                        child: Text(
                                                          'YES',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: isYes
                                                                ? Colors.white
                                                                : Color(
                                                                    0xFF244065),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ... other UI elements
                              _buildPlayerNameFields(), //call the function
                              // ... other UI elements
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 7,
                        children: [
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                // Your onTap action here
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Color(0xFF9ECF9A), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 7),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => myCartPage(myCartId: ''), // Replace with your target widget
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF9ECF9A),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Color(0xFF9ECF9A), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 7),
                                child: Center(
                                  child: Text(
                                    "Next",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }

  Widget playerCircle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF9ECF9A) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFF9ECF9A),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color:
                isSelected ? Colors.white : Color(0xFF244065), // 👈 Change here
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Color(0xFF9ECF9A) : Colors.white, // Red for active
          border: Border.all(color: Color(0xFF9ECF9A), width: 1),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 1,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Color(0xFF244065),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerNameFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8, top: 0),
          child: Text(
            "Player's Name",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...List.generate(_controllers.length, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _focusNodes[index].hasFocus
                    ? Color(0xFF9ECF9A)
                    : Colors.transparent, // Use focus to change color
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border:
                        Border.all(color: const Color(0xFF80C783), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF669933),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index], // Assign FocusNode
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3552),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Guest Customer',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
