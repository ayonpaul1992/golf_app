// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class MyReservationPage extends StatefulWidget {
  final String myRsvId;
  const MyReservationPage({super.key, required this.myRsvId});

  @override
  State<StatefulWidget> createState() => MyReservationPageState();
}

class MyReservationPageState extends State<MyReservationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  final searchBarText = TextEditingController();
  bool isLoading = true;
  String? nomineedobError;
  DateTime? _selectedDate;

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
    _selectedDate = now;
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
    fetchMyBookings();
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
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: const FractionalOffset(0.5, 0.42),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20), bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SfDateRangePicker(
                    initialSelectedDate: _selectedDate,
                    // <- ADD THIS LINE
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: Color(0xFF9ECF9A),
                    todayHighlightColor: Color(0xFF9ECF9A),
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: GoogleFonts.poppins(
                        color: Color(0xFF3F4B4B),
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
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          if (_selectedDate != null) {
                            final formattedDate = DateFormat("MMM dd, yyyy")
                                .format(_selectedDate!);
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF9ECF9A),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
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

  int? editingIndex;
  int selectedIndex = 0; // index 0 is "All"

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
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9ECF9A),
              ),
            )
          : reservations.isEmpty
              ? Center(
                  child: Text(
                    "No Reservations Found",
                    style: GoogleFonts.poppins(
                      color: Color(0xFF244065),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Container(
                  color: Color(0xFFFAFCFA),
                  width: double.infinity,
                  height: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
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
                                color: Color(0xFFB2C1C0),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "My Reservation",
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
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Color(0xFFB2C1C0),
                                            width: 1,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: searchBarText,
                                          decoration: InputDecoration(
                                            hintText: 'Search here',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF6E7373),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: InputBorder.none,
                                            prefixIcon: const Icon(Icons.search,
                                                color: Color(0xFF6E7373)),
                                            contentPadding: const EdgeInsets
                                                .symmetric(
                                                vertical:
                                                    14), // vertical centering
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF9ECF9A),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF244065),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (nomineedobError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 6.0, left: 12),
                                          child: Text(
                                            nomineedobError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: editingIndex == null
                                    ? () => _showDatePicker(context)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: Color(0xFF648683),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFF9ECF9A), width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10), // Correct usage
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "My Booking Details",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF244065),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              ...reservations.map((reservation) {
                                // Extract fields safely with fallback values
                                final courseName = reservation['golfCourse'] ??
                                    'Unknown Course';
                                final courseLogo =
                                    reservation['golfCourseLogo'];
                                final bookingDateRaw = reservation['date'];
                                final bookingTimeRaw =
                                    reservation['startingSlot'];
                                final amount = reservation['customer']['amount']
                                        ?.toString() ??
                                    '-';
                                final holes =
                                    reservation['holes']?.toString() ?? '-';
                                final players =
                                    reservation['persons']?.toString() ?? '-';
                                final carts =
                                    reservation['carts']?.toString() ?? '-';
                                final status = reservation['booking']
                                        ['status'] ??
                                    'Booked';
                                final slotId =
                                    reservation['slotId']?.toString() ?? '';

                                // Format date and time
                                String bookingDate = '';
                                if (bookingDateRaw != null) {
                                  try {
                                    final date = DateTime.parse(bookingDateRaw);
                                    bookingDate =
                                        DateFormat('EEE, MMM d').format(date);
                                  } catch (_) {
                                    bookingDate = bookingDateRaw.toString();
                                  }
                                }
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

                                // Choose image based on index or status if needed
                                final idx = reservations.indexOf(reservation);
                                final bgImage = idx % 2 == 0
                                    ? "assets/images/bkd1.png"
                                    : "assets/images/bkd2.png";
                                // final iconImage = courseLogo ?? "assets/images/bkdu1.png";

                                final iconImage = (courseLogo != null &&
                                        courseLogo
                                            .toString()
                                            .startsWith('http'))
                                    ? NetworkImage(courseLogo)
                                    : AssetImage('assets/images/bkdu1.png')
                                        as ImageProvider;

                                // Status color
                                // Color statusColor = Color(
                                //   reservation['booking']['bgColor'],
                                // );
                                Color statusColor = hexToColor(
                                  reservation['booking']['bgColor'] ??
                                      '#244065',
                                );
                                // Default color
                                // if (status.toLowerCase() == 'checked in') {
                                //   statusColor = Color(0xFF669933);
                                // } else if (status.toLowerCase() == 'booked') {
                                //   statusColor = Color(0xFFDB0606);
                                // } else {
                                //   statusColor = Color(0xFF244065);
                                // }

                                return Container(
                                  padding: EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Stack(
                                          children: [
                                            Image.asset(bgImage),
                                            Positioned(
                                              top: 9.5,
                                              left: 9.5,
                                              child: Container(
                                                width: 68,
                                                height: 68,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFFFFFF),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  // child: Image.asset(iconImage as String),
                                                  child: Image(
                                                    image: iconImage,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {},
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: statusColor,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      status,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // IconButton(
                                            //   onPressed: () {},
                                            //   icon: Icon(
                                            //     Icons.more_vert,
                                            //     size: 18,
                                            //     color: Color(0xFF6E7373),
                                            //   ),
                                            // )
                                            reservation['checkedIn'] == false &&
                                                    reservation['canceled'] ==
                                                        false
                                                ? ElevatedButton(
                                                    // onPressed: () {
                                                    //   // Add your cancel logic here
                                                    // },
                                                    onPressed: () async {
                                                      try {
                                                        final secureStorage =
                                                            FlutterSecureStorage();
                                                        final token =
                                                            await secureStorage
                                                                .read(
                                                                    key:
                                                                        'accessToken');

                                                        if (token == null) {
                                                          throw Exception(
                                                              'Access token not found');
                                                        }

                                                        // Replace this with your dynamic slot ID
                                                        // String slotId =
                                                        //     "20250423630AM9958"; // Example; should be dynamic

                                                        final uri = Uri.parse(
                                                          'https://api.dev.driverpos.io/api/v1/teesheet/myBookings/cancel/$slotId',
                                                        );

                                                        final response =
                                                            await http.delete(
                                                          uri,
                                                          headers: {
                                                            'Authorization':
                                                                'Bearer $token',
                                                            'Content-Type':
                                                                'application/json',
                                                          },
                                                          body: jsonEncode({
                                                            "process": "Cancel",
                                                          }),
                                                        );

                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          print(
                                                              '✅ Tee time cancelled successfully');

                                                          // Reload the screen
                                                          Navigator
                                                              .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyReservationPage(
                                                                myRsvId: '',
                                                              ),
                                                            ), // Replace with your screen widget
                                                          );
                                                        } else {
                                                          print(
                                                              '❌ Failed to cancel tee time: ${response.statusCode}');
                                                          // Optionally show a snackbar or alert
                                                        }
                                                      } catch (e) {
                                                        print(
                                                            '❗ Error cancelling tee time: $e');
                                                        // Optionally show a snackbar or alert
                                                      }
                                                    },

                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical:
                                                              5), // vertical padding
                                                      minimumSize: Size(0,
                                                          0), // disables default min height
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Golf Course: ",
                                              style: GoogleFonts.poppins(
                                                  color: Color(0xFF6E7373),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              courseName,
                                              style: GoogleFonts.poppins(
                                                  color: Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Booking Date: ",
                                              style: GoogleFonts.poppins(
                                                  color: Color(0xFF6E7373),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              bookingDate,
                                              style: GoogleFonts.poppins(
                                                  color: Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Booking Time: ",
                                              style: GoogleFonts.poppins(
                                                  color: Color(0xFF6E7373),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              bookingTime,
                                              style: GoogleFonts.poppins(
                                                  color: Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Amount: ",
                                              style: GoogleFonts.poppins(
                                                  color: Color(0xFF6E7373),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "\$$amount",
                                              style: GoogleFonts.poppins(
                                                color: Color(0xFF669933),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFF7FAF4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 6),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Holes: ",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xFF6E7373),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Text(
                                                        holes,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Color(
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
                                                  color: Color(0xFFF7FAF4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 6),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Players: ",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xFF6E7373),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Text(
                                                        players,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Color(
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
                                                  color: Color(0xFFF7FAF4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 6),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Carts: ",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xFF6E7373),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Text(
                                                        carts,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Color(
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
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
                  ),
                ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
