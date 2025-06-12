import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class MyReservationPage extends StatefulWidget {
  final String myRsvId;
  const MyReservationPage({super.key, required this.myRsvId});

  @override
  State<StatefulWidget> createState() => MyReservationPageState();
}

class MyReservationPageState extends State<MyReservationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  final searchBarText = TextEditingController();
  bool isLoading = true;
  String? nomineedobError;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _dropdownOverlay;
  String _selectedFilter = "This month";
  final List<String> _filterOptions = [
    "Today",
    "This week",
    "This month",
    "This year"
  ];

  List<Map<String, dynamic>> reservations = [];

  Future<void> fetchMyBookings() async {
    try {
      // Read the access token
      final token = await secureStorage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Access token not found');
      }

      // Construct the URL
      final Uri uri =
          Uri.parse('https://api.dev.driverpos.io/api/v1/teesheet/myBookings');

      // Send GET request with Authorization header
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);
        final reservationsList = data['data'] as List<dynamic>;

        setState(() {
          reservations = reservationsList
              .map((reservation) => reservation as Map<String, dynamic>)
              .toList();
          isLoading = false; // Set loading to false after fetching
        });
        // print('📦 Bookings data: $reservations');
      } else {
        print('❌ Failed to fetch bookings: ${response.statusCode}');
        // Optionally show an error message to the user
      }
    } catch (e) {
      print('❗ Error fetching bookings: $e');
      // Optionally handle error gracefully
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
    fetchMyBookings();
  }

  int? editingIndex;
  int selectedIndex = 0;
  // index 0 is "All"
  double _getDropdownOffset() {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero).dy ?? 100;
  }

  void _toggleDropdown() {
    if (_dropdownOverlay == null) {
      final overlay = Overlay.of(context);
      _dropdownOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: 10,
          right: 20,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 30),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 0), // Adjust horizontal padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFB2C1C0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filterOptions.map((option) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = option;
                        });
                        _removeDropdown();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12),
                        child: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: option == _selectedFilter
                                ? const Color(0xFF669933)
                                : const Color(0xFF244065),
                            fontWeight: option == _selectedFilter
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );
      overlay.insert(_dropdownOverlay!);
      setState(() {}); // To refresh the icon
    } else {
      _removeDropdown();
    }
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    setState(() {}); // Refresh icon
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.startsWith('#')) hexString = hexString.substring(1);
    if (hexString.length == 6) buffer.write('ff'); // default opacity
    buffer.write(hexString);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myRsvId, // ✅ Pass the correct userId
        showLeading: true, // ✅ Set to true to show the back button
        onBackPressed: () {
          Navigator.pop(context); // Optional: customize back behavior if needed
        },
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
          // : reservations.isEmpty
          //     ? Center(
          //         child: Text(
          //           "No Reservations Found",
          //           style: GoogleFonts.poppins(
          //             color: Color(0xFF244065),
          //             fontSize: 18,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       )
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
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "My Reservation",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF244065),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                              ),
                              GestureDetector(
                                onTap: _toggleDropdown,
                                child: Row(
                                  children: [
                                    Text(
                                      "Filter by:",
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF6E7373)),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _selectedFilter,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF244065)),
                                    ),
                                    Icon(
                                      _dropdownOverlay == null
                                          ? Icons.keyboard_arrow_down_rounded
                                          : Icons.keyboard_arrow_up_rounded,
                                      size: 22,
                                      color: const Color(0xFF669933),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF9ECF9A), width: 1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10), // Correct usage
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "My Booking Summary",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF244065),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            ...reservations.map((reservation) {
                              final courseName =
                                  reservation['golfCourse'] ?? 'Unknown Course';
                              final courseLogo = reservation['golfCourseLogo'];
                              final bookingDateRaw = reservation['date'];
                              final bookingTimeRaw =
                                  reservation['startingSlot'];

                              final holes =
                                  reservation['holes']?.toString() ?? '-';
                              final players =
                                  reservation['persons']?.toString() ?? '-';
                              final carts =
                                  reservation['carts']?.toString() ?? '-';
                              final status =
                                  reservation['booking']['status'] ?? 'Booked';
                              final slotId =
                                  reservation['slotId']?.toString() ?? '';

                              Color statusColor = hexToColor(
                                reservation['booking']['bgColor'] ?? '#244065',
                              );

                              String bookingTime = '';
                              if (bookingTimeRaw != null) {
                                try {
                                  final time = DateFormat('HH:mm:ss')
                                      .parse(bookingTimeRaw);
                                  bookingTime =
                                      DateFormat('h:mma').format(time);
                                } catch (_) {
                                  bookingTime = bookingTimeRaw.toString();
                                }
                              }

                              return Container(
                                padding:
                                    const EdgeInsets.only(bottom: 5, top: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(
                                          0xFFE8E8E8), // Customize the color
                                      width: 1.0, // Customize the width
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 75,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  border: Border.all(
                                                      width: 1.2,
                                                      color: const Color(
                                                          0xFFE8E8E8)),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Image(
                                                    image: courseLogo != null
                                                        ? NetworkImage(
                                                            courseLogo,
                                                          )
                                                        : const AssetImage(
                                                            "assets/images/bkdu2.png",
                                                          ) as ImageProvider,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10), // 👈 Space between items
                                              SizedBox(
                                                width: 250,
                                                // Optional padding
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFF7FAF4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: Text(
                                                            status,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 12,
                                                              color:
                                                                  statusColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {},
                                                              child: Container(
                                                                width: 25,
                                                                height: 25,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: const Color(
                                                                      0xFFF8F8F8),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50),
                                                                ),
                                                                child:
                                                                    const Center(
                                                                  child: Icon(
                                                                    Icons.edit,
                                                                    size: 16,
                                                                    color: Color(
                                                                        0xFF669933),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),

                                                            reservation['checkedIn'] ==
                                                                        false &&
                                                                    reservation[
                                                                            'canceled'] ==
                                                                        false
                                                                ? ElevatedButton(
                                                                    // onPressed: () {
                                                                    //   // Add your cancel logic here
                                                                    // },
                                                                    onPressed:
                                                                        () async {
                                                                      // A pop up dialog to confirm cancellation
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return AlertDialog(
                                                                              title: const Text('Confirm Cancellation'),
                                                                              content: const Text('Are you sure you want to cancel this tee time?'),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(); // Close the dialog
                                                                                  },
                                                                                  child: const Text('No'),
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () async {
                                                                                    Navigator.of(context).pop(); // Close the dialog
                                                                                    // await _cancelTeeTime(slotId);
                                                                                    try {
                                                                                      final secureStorage = const FlutterSecureStorage();
                                                                                      final token = await secureStorage.read(key: 'accessToken');

                                                                                      if (token == null) {
                                                                                        throw Exception('Access token not found');
                                                                                      }

                                                                                      // Replace this with your dynamic slot ID
                                                                                      // String slotId =
                                                                                      //     "20250423630AM9958"; // Example; should be dynamic

                                                                                      final uri = Uri.parse(
                                                                                        'https://api.dev.driverpos.io/api/v1/teesheet/myBookings/cancel/$slotId',
                                                                                      );

                                                                                      final response = await http.delete(
                                                                                        uri,
                                                                                        headers: {
                                                                                          'Authorization': 'Bearer $token',
                                                                                          'Content-Type': 'application/json',
                                                                                        },
                                                                                        body: jsonEncode({
                                                                                          "process": "Cancel",
                                                                                        }),
                                                                                      );

                                                                                      if (response.statusCode == 200) {
                                                                                        print('✅ Tee time cancelled successfully');

                                                                                        // Reload the screen
                                                                                        Navigator.pushReplacement(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => const MyReservationPage(
                                                                                              myRsvId: '',
                                                                                            ),
                                                                                          ), // Replace with your screen widget
                                                                                        );
                                                                                      } else {
                                                                                        print('❌ Failed to cancel tee time: ${response.statusCode}');
                                                                                        // Optionally show a snackbar or alert
                                                                                      }
                                                                                    } catch (e) {
                                                                                      print('❗ Error cancelling tee time: $e');
                                                                                      // Optionally show a snackbar or alert
                                                                                    }
                                                                                  },
                                                                                  child: const Text('Yes'),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          });
                                                                    },

                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          const Color(
                                                                              0xFF9ECF9A),
                                                                      foregroundColor:
                                                                          Colors
                                                                              .white,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5), // vertical padding
                                                                      minimumSize:
                                                                          const Size(
                                                                              0,
                                                                              0), // disables default min height
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink(),

                                                            // InkWell(
                                                            //   onTap: () {},
                                                            //   child: Container(
                                                            //     width: 25,
                                                            //     height: 25,
                                                            //     decoration:
                                                            //         BoxDecoration(
                                                            //       color: Color(
                                                            //           0xFFF8F8F8),
                                                            //       borderRadius:
                                                            //           BorderRadius
                                                            //               .circular(
                                                            //                   50),
                                                            //     ),
                                                            //     child: Center(
                                                            //       child: Icon(
                                                            //         Icons
                                                            //             .delete,
                                                            //         size: 16,
                                                            //         color: Color(
                                                            //             0xFFDB0606),
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      courseName,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: const Color(
                                                            0xFF244065),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      spacing: 6,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .calendar_month_outlined,
                                                          color:
                                                              Color(0xFF6B7280),
                                                          size: 18,
                                                        ),
                                                        Text(
                                                          bookingTime,
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF6E7373),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Container(
                                                          color: const Color(
                                                              0xFF6E7373),
                                                          width: 1,
                                                          height: 15,
                                                        ),
                                                        Text(
                                                          bookingDateRaw != null
                                                              ? DateFormat(
                                                                      'EEE, MMM d')
                                                                  .format(DateTime
                                                                      .parse(
                                                                          bookingDateRaw))
                                                              : "Unknown Date",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF6E7373),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF7FAF4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 6),
                                                    child: Center(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Holes: ",
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: const Color(
                                                                    0xFF6E7373),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Text(
                                                            holes,
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: const Color(
                                                                    0xFF244065),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF7FAF4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 6),
                                                    child: Center(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Players: ",
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: const Color(
                                                                    0xFF6E7373),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Text(
                                                            players,
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: const Color(
                                                                    0xFF244065),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF7FAF4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 6),
                                                    child: Center(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Carts: ",
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: const Color(
                                                                    0xFF6E7373),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Text(
                                                            carts,
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: const Color(
                                                                    0xFF244065),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
                              );
                              // Make box dynamic
                            }),
                            // Container(
                            //   padding: EdgeInsets.only(bottom: 5, top: 5),
                            //   decoration: BoxDecoration(
                            //     border: Border(
                            //       bottom: BorderSide(
                            //         color: Color(
                            //             0xFFE8E8E8), // Customize the color
                            //         width: 1.0, // Customize the width
                            //       ),
                            //     ),
                            //   ),
                            //   child: Column(
                            //     children: [
                            //       Padding(
                            //         padding: EdgeInsets.all(10),
                            //         child: Column(
                            //           children: [
                            //             Row(
                            //               crossAxisAlignment:
                            //                   CrossAxisAlignment.start,
                            //               children: [
                            //                 Container(
                            //                   width: 75,
                            //                   height: 75,
                            //                   decoration: BoxDecoration(
                            //                     color: Color(0xFFFFFFFF),
                            //                     border: Border.all(
                            //                         width: 1.2,
                            //                         color: Color(0xFFE8E8E8)),
                            //                     borderRadius:
                            //                         BorderRadius.circular(10),
                            //                   ),
                            //                   child: Center(
                            //                     child: Image.asset(
                            //                         "assets/images/bkdu2.png"),
                            //                   ),
                            //                 ),
                            //                 SizedBox(
                            //                     width:
                            //                         10), // 👈 Space between items
                            //                 SizedBox(
                            //                   width: 250,
                            //                   // Optional padding
                            //                   child: Column(
                            //                     crossAxisAlignment:
                            //                         CrossAxisAlignment.start,
                            //                     children: [
                            //                       Row(
                            //                         mainAxisAlignment:
                            //                             MainAxisAlignment
                            //                                 .spaceBetween,
                            //                         children: [
                            //                           Container(
                            //                             decoration:
                            //                                 BoxDecoration(
                            //                               color:
                            //                                   Color(0xFFFDF2F2),
                            //                               borderRadius:
                            //                                   BorderRadius
                            //                                       .circular(50),
                            //                             ),
                            //                             padding: EdgeInsets
                            //                                 .symmetric(
                            //                                     horizontal: 10,
                            //                                     vertical: 5),
                            //                             child: Text(
                            //                               "Booked",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                 fontSize: 12,
                            //                                 color: Color(
                            //                                     0xFFDB0606),
                            //                                 fontWeight:
                            //                                     FontWeight.w600,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           Row(
                            //                             children: [
                            //                               InkWell(
                            //                                 onTap: () {},
                            //                                 child: Container(
                            //                                   width: 25,
                            //                                   height: 25,
                            //                                   decoration:
                            //                                       BoxDecoration(
                            //                                     color: Color(
                            //                                         0xFFF8F8F8),
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(
                            //                                                 50),
                            //                                   ),
                            //                                   child: Center(
                            //                                     child: Icon(
                            //                                       Icons.edit,
                            //                                       size: 16,
                            //                                       color: Color(
                            //                                           0xFF669933),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                               SizedBox(width: 6),
                            //                               InkWell(
                            //                                 onTap: () {},
                            //                                 child: Container(
                            //                                   width: 25,
                            //                                   height: 25,
                            //                                   decoration:
                            //                                       BoxDecoration(
                            //                                     color: Color(
                            //                                         0xFFF8F8F8),
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(
                            //                                                 50),
                            //                                   ),
                            //                                   child: Center(
                            //                                     child: Icon(
                            //                                       Icons.delete,
                            //                                       size: 16,
                            //                                       color: Color(
                            //                                           0xFFDB0606),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ],
                            //                       ),
                            //                       SizedBox(height: 5),
                            //                       Text(
                            //                         "Salt Lake Golf Course",
                            //                         style: GoogleFonts.poppins(
                            //                           color: Color(0xFF244065),
                            //                           fontSize: 13,
                            //                           fontWeight:
                            //                               FontWeight.w600,
                            //                         ),
                            //                       ),
                            //                       SizedBox(height: 5),
                            //                       Row(
                            //                         spacing: 6,
                            //                         children: [
                            //                           Icon(
                            //                             Icons
                            //                                 .calendar_month_outlined,
                            //                             color:
                            //                                 Color(0xFF6B7280),
                            //                             size: 18,
                            //                           ),
                            //                           Text(
                            //                             "6:30AM",
                            //                             style:
                            //                                 GoogleFonts.poppins(
                            //                                     color: Color(
                            //                                         0xFF6E7373),
                            //                                     fontSize: 13,
                            //                                     fontWeight:
                            //                                         FontWeight
                            //                                             .w500),
                            //                           ),
                            //                           Container(
                            //                             color:
                            //                                 Color(0xFF6E7373),
                            //                             width: 1,
                            //                             height: 15,
                            //                           ),
                            //                           Text(
                            //                             "Wed, Apr 16",
                            //                             style:
                            //                                 GoogleFonts.poppins(
                            //                                     color: Color(
                            //                                         0xFF6E7373),
                            //                                     fontSize: 13,
                            //                                     fontWeight:
                            //                                         FontWeight
                            //                                             .w500),
                            //                           ),
                            //                         ],
                            //                       )
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //             SizedBox(
                            //               height: 10,
                            //             ),
                            //             Padding(
                            //               padding: EdgeInsets.only(
                            //                 left: 10,
                            //                 right: 10,
                            //               ),
                            //               child: Row(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.spaceBetween,
                            //                 children: [
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Holes: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "18",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Players: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "1",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Carts: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "0",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // Container(
                            //   padding: EdgeInsets.only(bottom: 5, top: 5),
                            //   decoration: BoxDecoration(
                            //     border: Border(
                            //       bottom: BorderSide(
                            //         color: Color(
                            //             0xFFE8E8E8), // Customize the color
                            //         width: 1.0, // Customize the width
                            //       ),
                            //     ),
                            //   ),
                            //   child: Column(
                            //     children: [
                            //       Padding(
                            //         padding: EdgeInsets.all(10),
                            //         child: Column(
                            //           children: [
                            //             Row(
                            //               crossAxisAlignment:
                            //                   CrossAxisAlignment.start,
                            //               children: [
                            //                 Container(
                            //                   width: 75,
                            //                   height: 75,
                            //                   decoration: BoxDecoration(
                            //                     color: Color(0xFFFFFFFF),
                            //                     border: Border.all(
                            //                         width: 1.2,
                            //                         color: Color(0xFFE8E8E8)),
                            //                     borderRadius:
                            //                         BorderRadius.circular(10),
                            //                   ),
                            //                   child: Center(
                            //                     child: Image.asset(
                            //                         "assets/images/bkdu3.png"),
                            //                   ),
                            //                 ),
                            //                 SizedBox(
                            //                     width:
                            //                         10), // 👈 Space between items
                            //                 SizedBox(
                            //                   width: 250,
                            //                   // Optional padding
                            //                   child: Column(
                            //                     crossAxisAlignment:
                            //                         CrossAxisAlignment.start,
                            //                     children: [
                            //                       Row(
                            //                         mainAxisAlignment:
                            //                             MainAxisAlignment
                            //                                 .spaceBetween,
                            //                         children: [
                            //                           Container(
                            //                             decoration:
                            //                                 BoxDecoration(
                            //                               color:
                            //                                   Color(0xFFFDF2F2),
                            //                               borderRadius:
                            //                                   BorderRadius
                            //                                       .circular(50),
                            //                             ),
                            //                             padding: EdgeInsets
                            //                                 .symmetric(
                            //                                     horizontal: 10,
                            //                                     vertical: 5),
                            //                             child: Text(
                            //                               "Booked",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                 fontSize: 12,
                            //                                 color: Color(
                            //                                     0xFFDB0606),
                            //                                 fontWeight:
                            //                                     FontWeight.w600,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           Row(
                            //                             children: [
                            //                               InkWell(
                            //                                 onTap: () {},
                            //                                 child: Container(
                            //                                   width: 25,
                            //                                   height: 25,
                            //                                   decoration:
                            //                                       BoxDecoration(
                            //                                     color: Color(
                            //                                         0xFFF8F8F8),
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(
                            //                                                 50),
                            //                                   ),
                            //                                   child: Center(
                            //                                     child: Icon(
                            //                                       Icons.edit,
                            //                                       size: 16,
                            //                                       color: Color(
                            //                                           0xFF669933),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                               SizedBox(width: 6),
                            //                               InkWell(
                            //                                 onTap: () {},
                            //                                 child: Container(
                            //                                   width: 25,
                            //                                   height: 25,
                            //                                   decoration:
                            //                                       BoxDecoration(
                            //                                     color: Color(
                            //                                         0xFFF8F8F8),
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(
                            //                                                 50),
                            //                                   ),
                            //                                   child: Center(
                            //                                     child: Icon(
                            //                                       Icons.delete,
                            //                                       size: 16,
                            //                                       color: Color(
                            //                                           0xFFDB0606),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ],
                            //                       ),
                            //                       SizedBox(height: 5),
                            //                       Text(
                            //                         "Eden Gardens Golf Course",
                            //                         style: GoogleFonts.poppins(
                            //                           color: Color(0xFF244065),
                            //                           fontSize: 13,
                            //                           fontWeight:
                            //                               FontWeight.w600,
                            //                         ),
                            //                       ),
                            //                       SizedBox(height: 5),
                            //                       Row(
                            //                         spacing: 6,
                            //                         children: [
                            //                           Icon(
                            //                             Icons
                            //                                 .calendar_month_outlined,
                            //                             color:
                            //                                 Color(0xFF6B7280),
                            //                             size: 18,
                            //                           ),
                            //                           Text(
                            //                             "6:30AM",
                            //                             style:
                            //                                 GoogleFonts.poppins(
                            //                                     color: Color(
                            //                                         0xFF6E7373),
                            //                                     fontSize: 13,
                            //                                     fontWeight:
                            //                                         FontWeight
                            //                                             .w500),
                            //                           ),
                            //                           Container(
                            //                             color:
                            //                                 Color(0xFF6E7373),
                            //                             width: 1,
                            //                             height: 15,
                            //                           ),
                            //                           Text(
                            //                             "Wed, Apr 16",
                            //                             style:
                            //                                 GoogleFonts.poppins(
                            //                                     color: Color(
                            //                                         0xFF6E7373),
                            //                                     fontSize: 13,
                            //                                     fontWeight:
                            //                                         FontWeight
                            //                                             .w500),
                            //                           ),
                            //                         ],
                            //                       )
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //             SizedBox(
                            //               height: 10,
                            //             ),
                            //             Padding(
                            //               padding: EdgeInsets.only(
                            //                 left: 10,
                            //                 right: 10,
                            //               ),
                            //               child: Row(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.spaceBetween,
                            //                 children: [
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Holes: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "18",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Players: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "1",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Carts: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "0",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // Container(
                            //   padding: EdgeInsets.only(bottom: 5, top: 5),
                            //   decoration: BoxDecoration(
                            //     border: Border(
                            //       bottom: BorderSide(
                            //         color: Color(
                            //             0xFFE8E8E8), // Customize the color
                            //         width: 1.0, // Customize the width
                            //       ),
                            //     ),
                            //   ),
                            //   child: Column(
                            //     children: [
                            //       Padding(
                            //         padding: EdgeInsets.all(10),
                            //         child: Column(
                            //           children: [
                            //             Row(
                            //               crossAxisAlignment:
                            //                   CrossAxisAlignment.start,
                            //               children: [
                            //                 Container(
                            //                   width: 75,
                            //                   height: 75,
                            //                   decoration: BoxDecoration(
                            //                     color: Color(0xFFFFFFFF),
                            //                     border: Border.all(
                            //                         width: 1.2,
                            //                         color: Color(0xFFE8E8E8)),
                            //                     borderRadius:
                            //                         BorderRadius.circular(10),
                            //                   ),
                            //                   child: Center(
                            //                     child: Image.asset(
                            //                         "assets/images/bkdu3.png"),
                            //                   ),
                            //                 ),
                            //                 SizedBox(
                            //                     width:
                            //                         10), // 👈 Space between items
                            //                 SizedBox(
                            //                   width: 250,
                            //                   // Optional padding
                            //                   child: Column(
                            //                     crossAxisAlignment:
                            //                         CrossAxisAlignment.start,
                            //                     children: [
                            //                       Row(
                            //                         mainAxisAlignment:
                            //                             MainAxisAlignment
                            //                                 .spaceBetween,
                            //                         children: [
                            //                           Container(
                            //                             decoration:
                            //                                 BoxDecoration(
                            //                               color:
                            //                                   Color(0xFFFDF2F2),
                            //                               borderRadius:
                            //                                   BorderRadius
                            //                                       .circular(50),
                            //                             ),
                            //                             padding: EdgeInsets
                            //                                 .symmetric(
                            //                                     horizontal: 10,
                            //                                     vertical: 5),
                            //                             child: Text(
                            //                               "Booked",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                 fontSize: 12,
                            //                                 color: Color(
                            //                                     0xFFDB0606),
                            //                                 fontWeight:
                            //                                     FontWeight.w600,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           Row(
                            //                             children: [
                            //                               InkWell(
                            //                                 onTap: () {},
                            //                                 child: Container(
                            //                                   width: 25,
                            //                                   height: 25,
                            //                                   decoration:
                            //                                       BoxDecoration(
                            //                                     color: Color(
                            //                                         0xFFF8F8F8),
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(
                            //                                                 50),
                            //                                   ),
                            //                                   child: Center(
                            //                                     child: Icon(
                            //                                       Icons.edit,
                            //                                       size: 16,
                            //                                       color: Color(
                            //                                           0xFF669933),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                               SizedBox(width: 6),
                            //                               InkWell(
                            //                                 onTap: () {},
                            //                                 child: Container(
                            //                                   width: 25,
                            //                                   height: 25,
                            //                                   decoration:
                            //                                       BoxDecoration(
                            //                                     color: Color(
                            //                                         0xFFF8F8F8),
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(
                            //                                                 50),
                            //                                   ),
                            //                                   child: Center(
                            //                                     child: Icon(
                            //                                       Icons.delete,
                            //                                       size: 16,
                            //                                       color: Color(
                            //                                           0xFFDB0606),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ],
                            //                       ),
                            //                       SizedBox(height: 5),
                            //                       Text(
                            //                         "Eden Gardens Golf Course",
                            //                         style: GoogleFonts.poppins(
                            //                           color: Color(0xFF244065),
                            //                           fontSize: 13,
                            //                           fontWeight:
                            //                               FontWeight.w600,
                            //                         ),
                            //                       ),
                            //                       SizedBox(height: 5),
                            //                       Row(
                            //                         spacing: 6,
                            //                         children: [
                            //                           Icon(
                            //                             Icons
                            //                                 .calendar_month_outlined,
                            //                             color:
                            //                                 Color(0xFF6B7280),
                            //                             size: 18,
                            //                           ),
                            //                           Text(
                            //                             "6:30AM",
                            //                             style:
                            //                                 GoogleFonts.poppins(
                            //                                     color: Color(
                            //                                         0xFF6E7373),
                            //                                     fontSize: 13,
                            //                                     fontWeight:
                            //                                         FontWeight
                            //                                             .w500),
                            //                           ),
                            //                           Container(
                            //                             color:
                            //                                 Color(0xFF6E7373),
                            //                             width: 1,
                            //                             height: 15,
                            //                           ),
                            //                           Text(
                            //                             "Wed, Apr 16",
                            //                             style:
                            //                                 GoogleFonts.poppins(
                            //                                     color: Color(
                            //                                         0xFF6E7373),
                            //                                     fontSize: 13,
                            //                                     fontWeight:
                            //                                         FontWeight
                            //                                             .w500),
                            //                           ),
                            //                         ],
                            //                       )
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //             SizedBox(
                            //               height: 10,
                            //             ),
                            //             Padding(
                            //               padding: EdgeInsets.only(
                            //                 left: 10,
                            //                 right: 10,
                            //               ),
                            //               child: Row(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.spaceBetween,
                            //                 children: [
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Holes: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "18",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Players: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "1",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Container(
                            //                     decoration: BoxDecoration(
                            //                         color: Color(0xFFF7FAF4),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 50)),
                            //                     child: Padding(
                            //                       padding: EdgeInsets.symmetric(
                            //                           horizontal: 15,
                            //                           vertical: 6),
                            //                       child: Center(
                            //                         child: Row(
                            //                           children: [
                            //                             Text(
                            //                               "Carts: ",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF6E7373),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w500),
                            //                             ),
                            //                             Text(
                            //                               "0",
                            //                               style: GoogleFonts
                            //                                   .poppins(
                            //                                       fontSize: 14,
                            //                                       color: Color(
                            //                                           0xFF244065),
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w600),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}
