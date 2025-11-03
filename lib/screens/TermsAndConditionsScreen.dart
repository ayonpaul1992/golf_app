// ignore_for_file: deprecated_member_use, use_build_context_synchronously
// import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final String tncId;
  const TermsAndConditionsScreen({super.key, required this.tncId});

  @override
  State<StatefulWidget> createState() => TermsAndConditionsScreenState();
}

class TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.tncId, // ✅ Pass the correct userId
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
                              "Terms & Conditions",
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
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                      width: 200, // 👈 Give a fixed width
                                      child: Column(
                                        children: [
                                          Wrap(
                                            runSpacing:
                                                10, // 👈 Adds vertical space between items
                                            children: [
                                              Text(
                                                "Disclaimer for Non-Refundable Booking Fee",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    buildBullet(
                                                      "I acknowledge and agree that the booking fee I am paying is non-refundable. "
                                                      "This fee secures my reservation and will not be returned under any circumstances, "
                                                      "including cancellations or changes to the booking.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "By submitting this payment, I confirm that I have read, understood, and accepted these terms.",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Wrap(
                                            runSpacing:
                                                10, // 👈 Adds vertical space between items
                                            children: [
                                              Text(
                                                "Tee Time Policies",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Golf Course Booking & Cancellation Policies',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                          0xFF244065),
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'We appreciate your cooperation in following these policies to ensure a smooth and fair reservation process for all golfers. By making a reservation, you acknowledge that you have read, understood, and agreed to the following terms:',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                          0xFF244065),
                                                      height: 1.5,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Wrap(
                                            runSpacing:
                                                10, // 👈 Adds vertical space between items
                                            children: [
                                              Text(
                                                "Booking Window",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    buildBullet(
                                                      "No booking fee is applied when tee times are reserved within the 7-day booking window.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "•  ", // 👈 must be 'text:' not just a string
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              color: const Color(
                                                                  0xFF244065),
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 310,
                                                            child: RichText(
                                                                text: TextSpan(
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: const Color(
                                                                    0xFF244065),
                                                                height: 1.5,
                                                              ),
                                                              children: [
                                                                const TextSpan(
                                                                  text: "A ",
                                                                ),
                                                                const TextSpan(
                                                                  text:
                                                                      "\$20.00",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600, // slightly bold
                                                                    color: Color(
                                                                        0xFF12284C), // darker navy color
                                                                  ),
                                                                ),
                                                                const TextSpan(
                                                                  text:
                                                                      " non-refundable booking fee per tee time is charged for reservations made outside the 7-day window.",
                                                                ),
                                                              ],
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Wrap(
                                            runSpacing:
                                                10, // 👈 Adds vertical space between items
                                            children: [
                                              Text(
                                                "Advance Booking (Outside 7-Day Window)",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    buildBullet(
                                                      "Tee times may be booked more than 7 days in advance.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "•  ", // 👈 must be 'text:' not just a string
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              color: const Color(
                                                                  0xFF244065),
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 310,
                                                            child: RichText(
                                                                text: TextSpan(
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: const Color(
                                                                    0xFF244065),
                                                                height: 1.5,
                                                              ),
                                                              children: [
                                                                const TextSpan(
                                                                  text: "A ",
                                                                ),
                                                                const TextSpan(
                                                                  text:
                                                                      "\$20.00",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600, // slightly bold
                                                                    color: Color(
                                                                        0xFF12284C), // darker navy color
                                                                  ),
                                                                ),
                                                                const TextSpan(
                                                                  text:
                                                                      " non-refundable advance booking fee per tee time is required at the time of booking.",
                                                                ),
                                                              ],
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "This fee is non-refundable under any circumstances, including changes, cancellations, or no-shows.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Advance bookings can only be made online through our official reservation system.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Phone or in-person requests for advance tee times will not be accepted.",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Wrap(
                                            runSpacing:
                                                10, // 👈 Adds vertical space between items
                                            children: [
                                              Text(
                                                "Captain’s Responsibility",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    buildBullet(
                                                      "The individual who makes the tee time reservation is referred to as the Captain.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "The Captain assumes full responsibility for all terms and conditions of the tee time(s) reserved.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Only the Captain may make changes to the reservation, including adding or reducing players.",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Wrap(
                                            runSpacing:
                                                10, // 👈 Adds vertical space between items
                                            children: [
                                              Text(
                                                "Cancellation & No-Show Policy",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    buildBullet(
                                                      "Adjustments or cancellations must be made at least 24 hours in advance via our reservation line.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Failure to cancel within this timeframe means you’ll be charged for the number of players booked.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Credit card on file will be charged the full amount for each player who does not show.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Refunds are not offered for reservations made for an incorrect date or time.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Single-player reservations are subject to the same policies.",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Wrap(
                                            runSpacing:
                                                10, // 👈 Adds vertical space between items
                                            children: [
                                              Text(
                                                "Gift Card Policies",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    buildBullet(
                                                      "Accepted Locations: Gift cards may be redeemed at AH Blank, Bright-Grandview, Jester Park, and Waveland Golf Courses.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Purchase Options: Available in set increments of \$25, \$50, \$75, or custom amounts between \$25–\$500.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Types: Physical or Virtual Gift Cards (must be presented at time of purchase).",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Redemption: Must present the card (or proof of purchase). Lost or deleted cards cannot be replaced.",
                                                    ),
                                                    const SizedBox(height: 8),
                                                    buildBullet(
                                                      "Notes: Valid only at listed locations. May be used for green fees, carts, merchandise, or other purchases. Not redeemable for cash.",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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

  Widget buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "•  ",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Color(0xFF244065),
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF244065),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
