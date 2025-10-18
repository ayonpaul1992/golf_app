// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

import 'package:url_launcher/url_launcher.dart';

class NewTestCartPage extends StatefulWidget {
  final String nwTstId;
  const NewTestCartPage({super.key, required this.nwTstId});

  @override
  State<StatefulWidget> createState() => NewTestCartPageState();
}

class NewTestCartPageState extends State<NewTestCartPage> {
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

  List<Map<String, dynamic>> savedCards = [];
  List<Map<String, dynamic>> giftCards = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomerCart();
    // _startCountdown();
    // Fetch data or perform any initialization here
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _openInAppBrowser(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView, // opens inside app
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true, // optional: enable JS
      ),
    )) {
      throw 'Could not launch $url';
    }
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

      final response = await http.get(
        Uri.parse(
          'https://api.dev.driverpos.io/api/v1/sales/customer',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // if needed
        },
      );

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('✅ Cart Data: $data');

        // final responseData = data['data'];
        savedCards = List<Map<String, dynamic>>.from(data['savedCards'] ?? []);
        giftCards =
            List<Map<String, dynamic>>.from(data['data']['giftCards'] ?? []);
        print('✅ Saved Cards fetched successfully: $savedCards');
        print('✅ Gift Cards fetched successfully: $giftCards');

        // bookingDate = responseData['teesheet']['date'] ?? '';
        // DateTime parsedDate =
        //     DateTime.parse(bookingDate).toLocal(); // Convert to local time

        // fomattedBookingDate = DateFormat('EEE, MMM d').format(parsedDate);

        // bookingTime = responseData['teesheet']['startingSlot'] ?? '';
        // golfCourseName = responseData['golfCourse']['name'] ?? '';
        // golfCourseCode = responseData['golfCourse']['golfCourseCode'] ?? '';
        // holes = responseData['teesheet']['holes'] ?? 0;
        // rotation = holes == 9 ? 'Front' : 'Front - Back';
        // players = responseData['teesheet']['persons'] ?? 0;
        // carts = responseData['teesheet']['carts'] ?? 0;

        totalCartAmount = data['data']['totalCartAmount'] ?? 0.0;
        totalTaxAmount = data['data']['totalTaxAmount'] ?? 0.0;

        // customers = List<Map<String, dynamic>>.from(
        //     responseData['teesheet']['customers']);

        // savedCards = List<Map<String, dynamic>>.from(data['savedCards'] ?? []);

        // print('✅ Saved Cards fetched successfully: $savedCards');
        // int count = 1;

        // customers = customers.map((customer) {
        //   if (customer['isCart'] == false) {
        //     return {
        //       ...customer,
        //       'playerCount': count++,
        //     };
        //   }
        //   return customer;
        // }).toList();

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

  String selectedOption = "A"; // Default selected radio
  bool isChecked = false; // Default checkbox state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.nwTstId, // ✅ Pass the correct userId
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
                              "Cart",
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
                      height: 20,
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
                                          "Gift Card Details",
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
                                ...giftCards.map((giftCard) {
                                  final playerName = giftCard['customer'] ?? '';
                                  final feeLabel = giftCard['item'] ?? '';
                                  final price = giftCard['baseAmount'] ?? 0.0;
                                  final qty = 1;
                                  final amt = giftCard['amount'] ?? price * qty;
                                  final tax = giftCard['taxAmount'] ?? 0.0;

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
                                      giftCards.last != giftCard
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
                                          "Cards",
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
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Select your preference",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF244065),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // ===== RADIO BUTTONS =====
                                      Column(
                                        children: [
                                          RadioListTile<String>(
                                            title: Text(
                                              "New Card",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF244065),
                                              ),
                                            ),
                                            value: "A",
                                            groupValue: selectedOption,
                                            activeColor:
                                                const Color(0xFF669933),
                                            visualDensity: const VisualDensity(
                                                horizontal: -4, vertical: -4),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            contentPadding: EdgeInsets.zero,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedOption = value!;
                                              });
                                            },
                                          ),

                                          // Dynamically generate RadioListTile for each saved card
                                          ...savedCards.map((card) {
                                            final cardLabel =
                                                "${card['first4Digit'] ?? ''} ${card['last4Digit'] ?? ''}";
                                            final cardId =
                                                card['cardId']?.toString() ??
                                                    '';
                                            return RadioListTile<String>(
                                              title: Text(
                                                cardLabel,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFF244065),
                                                ),
                                              ),
                                              value: cardId,
                                              groupValue: selectedOption,
                                              activeColor:
                                                  const Color(0xFF669933),
                                              visualDensity:
                                                  const VisualDensity(
                                                      horizontal: -4,
                                                      vertical: -4),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              contentPadding: EdgeInsets.zero,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedOption = value!;
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 25, right: 10, bottom: 10),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              CheckboxListTile(
                                title: Text(
                                  "Agree Terms and Conditions",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF244065),
                                  ),
                                ),
                                value: isChecked,
                                activeColor: const Color(0xFF669933),
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                              ),
                            ],
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
                            onTap: (!isChecked || isBookButtonDisabled)
                                ? null // 🔒 disabled when unchecked or already booked
                                : () async {
                                    // setState(() {
                                    //   isBookButtonDisabled =
                                    //       true; // Disable button
                                    // });

                                    _openInAppBrowser(
                                      "https://flutter.dev",
                                    ); // Your URL here

                                    print(
                                        '✅ Proceeding to payment with option: $selectedOption');

                                    // 👉 your existing booking logic here
                                    // (omitted for brevity)
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: !isChecked
                                    ? const Color(
                                        0xFFB0B0B0) // 🔸 Disabled grey color
                                    : const Color(0xFF669933), // ✅ Active green
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: !isChecked
                                      ? const Color(0xFFB0B0B0)
                                      : const Color(0xFF669933),
                                  width: 1,
                                ),
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
                                  "Pay Now \$${totalCartAmount.toStringAsFixed(2)}",
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
