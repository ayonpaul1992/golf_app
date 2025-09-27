// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
// import 'package:flutter/cupertino.dart';
import 'package:driver_pos/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/screens/my_reservation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

class MyCartPage extends StatefulWidget {
  final String myCartId;
  const MyCartPage({super.key, required this.myCartId});

  @override
  State<StatefulWidget> createState() => MyCartPageState();
}

class MyCartPageState extends State<MyCartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late Timer _timer;
  Duration _remaining = const Duration(minutes: 5);

  String bookingTime = '';
  String bookingDate = '';
  String fomattedBookingDate = '';
  String golfCourseName = '';
  String golfCourseCode = '';
  String rotation = '';
  int holes = 0;
  int players = 0;
  int carts = 0;

  num totalCartAmount = 0.0;
  num totalTaxAmount = 0.0;

  List<Map<String, dynamic>> customers = [];

  bool isBookButtonDisabled = false;

  bool isLoading = false;

  int playerCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCustomerCart();
    _startCountdown();
    // Fetch data or perform any initialization here
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds == 0) {
        timer.cancel();
        // Navigator.pop(context);
      } else {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  void _fetchCustomerCart() async {
    setState(() {
      isLoading = true;
    });
    try {
      String token = await secureStorage.read(key: 'accessToken') ?? '';

      final String baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse(
          '$baseUrl/sales/customer',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // if needed
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final responseData = data['data'];
        bookingDate = responseData['teesheet']['date'] ?? '';
        String bookingDateRaw = responseData['teesheet']['formattedDate'] ?? '';
        // print('Booking Date: $bookingDateRaw');
        // DateTime parsedDate =
        //     DateTime.parse(bookingDate).toLocal(); // Convert to local time

        fomattedBookingDate = bookingDateRaw;

        bookingTime = responseData['teesheet']['startingSlot'] ?? '';
        golfCourseName = responseData['golfCourse']['name'] ?? '';
        golfCourseCode = responseData['golfCourse']['golfCourseCode'] ?? '';
        holes = responseData['teesheet']['holes'] ?? 0;
        rotation = holes == 9 ? 'Front' : 'Front - Back';
        players = responseData['teesheet']['persons'] ?? 0;
        carts = responseData['teesheet']['carts'] ?? 0;

        totalCartAmount = responseData['totalCartAmount'] ?? 0.0;
        totalTaxAmount = responseData['totalTaxAmount'] ?? 0.0;

        customers = List<Map<String, dynamic>>.from(
            responseData['teesheet']['customers']);

        int count = 1;
        customers = customers.map((customer) {
          if (customer['isCart'] == false) {
            return {
              ...customer,
              'playerCount': count++,
            };
          }
          return customer;
        }).toList();

        // print('✅ Cart fetched successfully: $customers');
        setState(() {
          isLoading = false;
        });
      } else {
        // Handle API error
        print('❌ API Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch cart'),
          ),
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myCartId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF9ECF9A),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(),
              child: Container(
                color: const Color(0xFFFAFCFA),
                width: double.infinity,
                height: double.infinity,
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
                              height: 1.1,
                              color: const Color(0xFFB2C1C0),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "My Cart",
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
                              height: 1.1,
                              color: const Color(0xFFB2C1C0),
                            ),
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              border: Border.all(
                                  color: const Color(0xFF9ECF9A), width: 1.5),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9ECF9A)
                                      .withOpacity(0.2), // soft shadow
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8F8F8),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                      width: 200, // 👈 Give a fixed width
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Booking Details",
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(_remaining),
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFDB0606),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Date & Time:",
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF6E7373),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        "$fomattedBookingDate, $bookingTime",
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Golf Course:",
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF6E7373),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        golfCourseName,
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    spacing: 35,
                                    children: [
                                      Row(
                                        spacing: 5,
                                        children: [
                                          Text(
                                            "Rotation:",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF6E7373),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            rotation,
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        spacing: 5,
                                        children: [
                                          Text(
                                            "Holes",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF6E7373),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "$holes",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    spacing: 35,
                                    children: [
                                      // following first row will not show if customerId is repeated

                                      Row(
                                        spacing: 5,
                                        children: [
                                          Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: const Color(0xFF794EDA),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Players:",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF6E7373),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "$players",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        spacing: 5,
                                        children: [
                                          Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: const Color(0xFFF1AE24),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.flag,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Carts:",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF6E7373),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "$carts",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              border: Border.all(
                                  color: const Color(0xFF9ECF9A), width: 1.5),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9ECF9A)
                                      .withOpacity(0.2), // soft shadow
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8F8F8),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                      width: 200, // 👈 Give a fixed width
                                      child: Center(
                                        child: Text(
                                          "Booking Summary",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ...customers.map((customer) {
                                  final playerName =
                                      customer['fullName'] ?? 'Player';
                                  final feeLabel =
                                      customer['description'] ?? 'Player';
                                  final price = customer['amount'] ?? 0.0;
                                  final qty = 1;
                                  final amt = customer['amount'] ?? price * qty;
                                  final tax = customer['taxAmount'] ?? 0.0;

                                  // print('Customer: $customer');
                                  // Initialize playerIndex to 0
                                  return Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(
                                            12.0), // Added padding to the outer Container
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (!customer['isCart'])
                                                  Container(
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF9ECF9A),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 6),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "Player: ",
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 13,
                                                                color: const Color(
                                                                    0xFFFFFFFF)),
                                                          ),
                                                          Text(
                                                            '${customer['playerCount']}',
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                                color: const Color(
                                                                    0xFFFFFFFF)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                // Text(
                                                //   "\$${price.toStringAsFixed(2)}",
                                                //   style: GoogleFonts.poppins(
                                                //       fontSize: 14,
                                                //       fontWeight:
                                                //           FontWeight.w600,
                                                //       color: const Color(
                                                //           0xFF244065)),
                                                // ),
                                              ],
                                            ),
                                            const SizedBox(
                                                height:
                                                    15), // Added vertical spacing
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start, // Align inner Column to start
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      playerName,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: const Color(
                                                            0xFF244065),
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                            5), // Add some spacing
                                                    Text(
                                                      "($feeLabel)",
                                                      style: GoogleFonts.poppins(
                                                          color: const Color(
                                                              0xFF244065),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Qty:",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF6E7373),
                                                              fontSize: 13.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          "$qty",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF244065),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(width: 25),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Price:",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF6E7373),
                                                              fontSize: 13.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          "\$${amt.toStringAsFixed(2)}",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF244065),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(width: 25),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Tax:",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF6E7373),
                                                              fontSize: 13.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          "\$${tax.toStringAsFixed(2)}",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF244065),
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(width: 60),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          "\$${price.toStringAsFixed(2)}",
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color(
                                                                  0xFF244065)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      customers.last != customer
                                          ? const Divider(
                                              color: Color(0xFFE4E4E4),
                                              thickness: 1.15,
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  );
                                }),
                                Container(
                                  width: double.infinity,
                                  color: const Color(0xFFF8F8F8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total: ",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF6E7373),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              " \$${totalCartAmount - totalTaxAmount}",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Total tax: ",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF6E7373),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          " \$$totalTaxAmount",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEAB308),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Total payble: ",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            " \$$totalCartAmount",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 7,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Your onTap action here
                              try {
                                final token = await secureStorage.read(
                                    key: 'accessToken');

                                if (token == null) {
                                  throw Exception('Access token not found');
                                }

                                final String baseUrl = ApiConfig.baseUrl;

                                final uri = Uri.parse(
                                  '$baseUrl/sales/clear?cartState=customerCart',
                                );

                                final response = await http.delete(
                                  uri,
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Content-Type': 'application/json',
                                  },
                                );

                                if (response.statusCode == 200) {
                                  print('🧹 Cart cleared successfully');
                                  int count = 0;
                                  Navigator.popUntil(
                                      context, (_) => count++ == 3);

                                  // Optionally, show a success message or update UI
                                } else {
                                  print(
                                      '❌ Failed to clear cart: ${response.statusCode}');
                                  // Optionally handle different status codes
                                }
                              } catch (e) {
                                print('❗ Error clearing cart: $e');
                                // Optionally show an error message to the user
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
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
                                  "Cancel",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF244065),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: isBookButtonDisabled
                                ? null // 🔒 Disable tap when API call is successful
                                : () async {
                                    try {
                                      String token = await secureStorage.read(
                                              key: 'accessToken') ??
                                          '';

                                      final bookingPayload = {
                                        'golfCourseCode': golfCourseCode,
                                        'totalAmount': totalCartAmount,
                                        'amount': totalCartAmount,
                                        'paymentType': 'Book',
                                      };

                                      const secret =
                                          'course1999golf01'; // same as backend

                                      final keyHash = sha256
                                          .convert(utf8.encode(secret))
                                          .bytes;
                                      final secretKey = SecretKey(keyHash);
                                      final algorithm = AesGcm.with256bits();
                                      final iv = algorithm.newNonce();

                                      final secretBox = await algorithm.encrypt(
                                        utf8.encode(jsonEncode(bookingPayload)),
                                        secretKey: secretKey,
                                        nonce: iv,
                                      );

                                      final encryptedPayload = {
                                        'iv': base64Encode(iv),
                                        'data':
                                            base64Encode(secretBox.cipherText),
                                        'tag':
                                            base64Encode(secretBox.mac.bytes),
                                      };

                                      final String baseUrl = ApiConfig.baseUrl;

                                      final response = await http.post(
                                        Uri.parse(
                                          '$baseUrl/transaction/payment',
                                        ),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization':
                                              'Bearer $token', // if needed
                                        },
                                        body: jsonEncode(encryptedPayload),
                                      );

                                      if (response.statusCode == 200) {
                                        final data = jsonDecode(response.body);
                                        // print('✅ Booking API Response: $data');

                                        if (data['success'] == true) {
                                          // print('✅ Booking successful: $data');
                                          setState(() {
                                            isBookButtonDisabled =
                                                true; // ✅ Disable button
                                          });

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: const Text(
                                                  "Success",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: const Text(
                                                    "Your Tee Time has been booked successfully."),
                                                actions: [
                                                  TextButton(
                                                    child: const Text("OK"),
                                                    onPressed: () {
                                                      //go to reservation screen
                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const MyReservationPage(
                                                            myRsvId: '',
                                                          ),
                                                        ),
                                                        (route) => route
                                                            .isFirst, // This keeps only the first screen in the stack (e.g., home/dashboard)
                                                      );

                                                      // Navigator.pushReplacement(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //     builder: (context) =>
                                                      //         const MyReservationPage(
                                                      //       myRsvId: '',
                                                      //     ),

                                                      //   ),
                                                      // );
                                                      // int count = 0;
                                                      // Navigator.popUntil(
                                                      //   context,
                                                      //   (_) => count++ == 4,
                                                      // ); // Close the dialog
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          // Handle error
                                          print(
                                              '❌ Booking failed: ${data['message']}');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Payment failed'),
                                            ),
                                          );

                                          int count = 0;
                                          Navigator.popUntil(
                                            context,
                                            (_) => count++ == 4,
                                          );
                                        }
                                      } else {
                                        // Handle API error
                                        print('❌ API Error: ${response.body}');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to payment'),
                                          ),
                                        );

                                        int count = 0;
                                        Navigator.popUntil(
                                          context,
                                          (_) => count++ == 4,
                                        );
                                      }
                                    } catch (e) {
                                      print('❌ Exception: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Something went wrong'),
                                        ),
                                      );

                                      int count = 0;
                                      Navigator.popUntil(
                                        context,
                                        (_) => count++ == 4,
                                      );
                                    }
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
                                  "Book Now",
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
}
