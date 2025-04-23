import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/extras/GardenSideTeesheetPage.dart';
import 'package:gulf_app/extras/GreaterTeesheetPage.dart';
import 'package:gulf_app/extras/GreaterParTeesheetPage.dart';
import 'package:gulf_app/extras/LakeSideTeesheetPage.dart';
import 'package:gulf_app/extras/LakeViewTeesheetPage.dart';

class selcetBookingClass extends StatefulWidget {
  final String userId; // ✅ Add this

  const selcetBookingClass({super.key, required this.userId}); // ✅ Fix constructor

  @override
  State<selcetBookingClass> createState() => selcetBookingClassState();
}

class selcetBookingClassState extends State<selcetBookingClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final TextEditingController holdingNtrText = TextEditingController();
  String activeTile = 'Home';
  bool isDropdownOpen = false;
  OverlayEntry? dropdownOverlay;
  final LayerLink _layerLink = LayerLink();
  List<String> dropdownItems = ["Garden Side Teesheet", "Lake Side Teesheet", "Lake View Teesheet","Greater Teesheet","Greater Par Teesheet"];
  String selectedItem = "Select";
  String? holdingNtrError;

  @override
  void dispose() {
    holdingNtrText.dispose();
    super.dispose();
  }

  void toggleDropdown() {
    if (isDropdownOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  void openDropdown() {
    closeDropdown();
    final overlay = Overlay.of(context);
    dropdownOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => closeDropdown(),
        child: Stack(
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width - 70,
              left: 20,
              top: getDropdownTopOffset(),
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(36.5, 50),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: dropdownItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = dropdownItems[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedItem = item;
                              holdingNtrText.text = item;
                              closeDropdown();
                            });
                            navigateToPage(item);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text(
                              item,
                              style:  GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFF244065),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(dropdownOverlay!);
    setState(() {
      isDropdownOpen = true;
    });
  }

  double getDropdownTopOffset() {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero).dy ?? 100;
  }

  void closeDropdown() {
    dropdownOverlay?.remove();
    dropdownOverlay = null;
    setState(() {
      isDropdownOpen = false;
    });
  }

  void navigateToPage(String item) {
    Widget? targetPage;
    switch (item) {
      case "Garden Side Teesheet":
        targetPage = const GardenSideTeesheetPage(gsTeeSheetuserId: '', userId: '',);
        break;
      case "Lake Side Teesheet":
        targetPage = const LakeSideTeesheetPage(lsSheetuserId: '',);
        break;
      case "Lake View Teesheet":
        targetPage = const LakeViewTeesheetPage(lvSheetuserId: '',);
        break;
      case "Greater Teesheet":
        targetPage = const GreaterTeesheetPage(gTeeSheetuserId: '',);
        break;
      case "Greater Par Teesheet":
        targetPage = const GreaterParTeesheetPage(gpTeeSheetuserId: '',);
        break;
    }

    if (targetPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage!),
      );
    }
  }

  bool isLoading = false; // For showing a loading spinner

  // Function to show the error or success messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.userId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
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
              Container(
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
                          "Select a Golf Course",
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
                  "Select a golf course to book a tee time or enjoy other activities.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF6E7373),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                child: Image.asset("assets/images/golf_ground.png"),
              ),
              SizedBox(height: 30,),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Select Facility',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6E7373),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 38),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: 0,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: 171,
                                child: TextField(
                                  controller: holdingNtrText,
                                  readOnly: true,
                                  onTap: toggleDropdown,
                                  decoration: InputDecoration(
                                    hintText: 'Select',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                    suffixIcon: Icon(
                                      isDropdownOpen
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Color(0xFF244065),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: const BorderSide(color: Colors.white, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: const BorderSide(color: Color(0xFF9ECF9A), width: 1),
                                    ),
                                  ),
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF244065),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ✅ Show error below the field — NOT inside Stack
                        if (holdingNtrError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, top: 6),
                            child: Text(
                              holdingNtrError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
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
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => selcetBookingClass(userId: '',)),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF9ECF9A)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                child: Center(
                                  child: Text(
                                    "Public",
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
                    Padding(
                      padding: EdgeInsets.only(left: 38, right: 38, bottom: 20),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => selcetBookingClass(userId: '',)),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF9ECF9A)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                child: Center(
                                  child: Text(
                                    "Test garden",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ), // temporary body
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

