import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/screens/teesheet_page.dart'; // Import generic page

class SelcetBookingClass extends StatefulWidget {
  final String userId; // ✅ Add this

  const SelcetBookingClass(
      {super.key, required this.userId}); // ✅ Fix constructor

  @override
  State<SelcetBookingClass> createState() => SelcetBookingClassState();
}

class SelcetBookingClassState extends State<SelcetBookingClass> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController holdingNtrText = TextEditingController();
  String activeTile = 'Home';
  bool isDropdownOpen = false;
  OverlayEntry? dropdownOverlay;
  final LayerLink _layerLink = LayerLink();
  List<String> dropdownItems = []; // Initialize as empty
  String selectedItem = "Select";
  String? holdingNtrError;
  bool isLoading = false; // For loading the dropdown items
  List<dynamic> _fetchedTeesheets = []; // Store the raw fetched data
  Map<String, dynamic>? _selectedTeesheet;

  @override
  void initState() {
    super.initState();
    _fetchTeesheets(); // Fetch teesheets when the page loads
  }

  @override
  void dispose() {
    holdingNtrText.dispose();
    super.dispose();
  }

  Future<void> _fetchTeesheets() async {
    setState(() => isLoading = true);

    const String apiUrl =
        'https://api.dev.driverpos.io/api/v1/teesheet/customer-facility?golfCourseCode=YdTIjvWB';

    String? token = await secureStorage.read(key: 'accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data['data'] is List) {
          setState(() {
            _fetchedTeesheets = data['data'];
            dropdownItems = _fetchedTeesheets
                .map<String>((t) => t['name']?.toString() ?? 'Unnamed Teesheet')
                .toList();
          });
        } else {
          _showMessage('Invalid response structure');
        }
      } else {
        _showMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error fetching data: $e');
    } finally {
      setState(() => isLoading = false);
    }
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
      builder: (context) => Positioned(
        width: 318,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-2, 50),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3),
              child: ListView.separated(
                padding: EdgeInsets.zero, // ✅ Remove top space
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
                      final selectedObject = _fetchedTeesheets.firstWhere(
                        (element) => element['name'] == item,
                        orElse: () => null,
                      );
                      //change sec to the selected teesheet logo
                      secureStorage.write(
                          key: 'golfCourseLogo',
                          value: selectedObject?['golfCourseLogo'] ?? '');
                      secureStorage.write(
                          key: 'golfCourseName',
                          value: selectedObject?['name'] ?? '');
                      secureStorage.write(
                          key: 'golfCourseSmallLogo',
                          value: selectedObject?['golfCourseSmallLogo'] ?? '');

                      navigateToDynamicPage(item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF244065),
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
    );

    overlay.insert(dropdownOverlay!);
    setState(() => isDropdownOpen = true);
  }

  void closeDropdown() {
    dropdownOverlay?.remove();
    dropdownOverlay = null;
    setState(() => isDropdownOpen = false);
  }

  List<Map<String, dynamic>> _reservationGroups = [];
  void navigateToDynamicPage(String itemName) {
    final selected = _fetchedTeesheets.firstWhere((e) => e['name'] == itemName,
        orElse: () => null);

    if (selected == null) {
      _showMessage('No matching data found.');
      return;
    }

    setState(() {
      _selectedTeesheet = selected;
    });

    final String teeSheetId = selected['_id'];
    _fetchReservationGroups(teeSheetId);
  }

  Future<void> _fetchReservationGroups(String teeSheetId) async {
    String? token = await secureStorage.read(key: 'accessToken') ?? '';
    final String url =
        'https://api.dev.driverpos.io/api/v1/reservationGroup/customer?teeSheet=$teeSheetId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _reservationGroups = List<Map<String, dynamic>>.from(body['data']);
        });
      } else {
        _showMessage('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // @override
  // void dispose() {
  //   holdingNtrText.dispose();
  //   super.dispose();
  // }

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
                              "Select a Tee sheet",
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
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 20, right: 20, bottom: 20),
                      child: Text(
                        "Select a tee sheet to book a tee time or enjoy other activities.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6E7373),
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    FutureBuilder<String?>(
                      future: secureStorage.read(key: 'golfCourseLogo'),
                      builder: (context, snapshot) {
                        final url = snapshot.data ?? '';
                        if (url.isNotEmpty) {
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          );
                        } else {
                          return Image.asset(
                            'assets/images/golf_ground.png',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 38.0),
                              child: CompositedTransformTarget(
                                link: _layerLink,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: toggleDropdown,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isDropdownOpen
                                                ? const Color(
                                                    0xFF9ECF9A) // Focused/Open border color
                                                : const Color(
                                                    0xFFB2C1C0), // Enabled border color
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              selectedItem,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: const Color(0xFF244065),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Icon(isDropdownOpen
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // ✅ Show error below the field — NOT inside Stack
                            if (holdingNtrError != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12.0, top: 6),
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
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          children: _reservationGroups.map((group) {
                            final String label =
                                group['name']?.toString() ?? 'Unnamed';
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 38, right: 38, bottom: 15),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_selectedTeesheet == null) return;

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TeesheetPage(
                                              id: _selectedTeesheet!['_id']
                                                      ?.toString() ??
                                                  '',
                                              name: _selectedTeesheet!['name']
                                                      ?.toString() ??
                                                  '',
                                              logoUrl: _selectedTeesheet![
                                                          'golfCourseLogo']
                                                      ?.toString() ??
                                                  '',
                                              userId: widget.userId,
                                              teesheetPageId:
                                                  _selectedTeesheet?['_id']
                                                          ?.toString() ??
                                                      '',
                                              reservationGroupId:
                                                  group['_id']?.toString() ??
                                                      '',
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF9ECF9A),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 10.0),
                                        child: Center(
                                          child: Text(
                                            label,
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
                                    child: Icon(Icons.arrow_forward,
                                        color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ), // temporary body
    );
  }
}
