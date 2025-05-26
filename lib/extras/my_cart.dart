import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class MyCartPage extends StatefulWidget {
  final String myCartId;
  const MyCartPage({super.key, required this.myCartId});

  @override
  State<StatefulWidget> createState() => MyCartPageState();
}

class MyCartPageState extends State<MyCartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
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
        userId: widget.myCartId, // ✅ Pass the correct userId
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
        padding: EdgeInsets.symmetric(),
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
                          "My Cart",
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
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        border:
                            Border.all(color: Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9ECF9A)
                                .withOpacity(0.2), // soft shadow
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                width: 200, // 👈 Give a fixed width
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Booking Details",
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFF244065),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "01:21",
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFFDB0606),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Date & Time:",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Wed, Apr 16, 6:30AM",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Golf Course:",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Eden Gardens Golf Course",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
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
                                          color: Color(0xFF6E7373),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      "Front",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
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
                                          color: Color(0xFF6E7373),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      "9",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
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
                                Row(
                                  spacing: 5,
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Color(0xFF794EDA),
                                      ),
                                      child: Center(
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
                                          color: Color(0xFF6E7373),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      "1",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
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
                                        borderRadius: BorderRadius.circular(50),
                                        color: Color(0xFFF1AE24),
                                      ),
                                      child: Center(
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
                                          color: Color(0xFF6E7373),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      "0",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
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
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        border:
                            Border.all(color: Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9ECF9A)
                                .withOpacity(0.2), // soft shadow
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                width: 200, // 👈 Give a fixed width
                                child: Center(
                                  child: Text(
                                    "Booking Summary",
                                    textAlign: TextAlign.center,
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
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0), // Added padding to the outer Container
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.circular(10)),
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Players: ",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: const Color(0xFF6E7373)),
                                            ),
                                            Text(
                                              "1",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: const Color(0xFF669933)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$20.00',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF244065)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15), // Added vertical spacing
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Align inner Column to start
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Koushik Dutta",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 5), // Add some spacing
                                        Text(
                                          "(Green Fee 18 Holes)",
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
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
                                                  color: const Color(0xFF6E7373),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "1",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 25),
                                        Row(
                                          children: [
                                            Text(
                                              "Price:",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF6E7373),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "\$20.00",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 25),
                                        Row(
                                          children: [
                                            Text(
                                              "Tax:",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF6E7373),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "0.49",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Color(0xFFE4E4E4),
                            thickness: 1.15,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0), // Added padding to the outer Container
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.circular(10)),
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Players: ",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: const Color(0xFF6E7373)),
                                            ),
                                            Text(
                                              "2",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: const Color(0xFF669933)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$7.49',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF244065)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15), // Added vertical spacing
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Align inner Column to start
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Rabindra Nathgsf Customer",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 5), // Add some spacing
                                        Text(
                                          "(Green Fee 18 Holes)",
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
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
                                                  color: const Color(0xFF6E7373),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "1",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 25),
                                        Row(
                                          children: [
                                            Text(
                                              "Price:",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF6E7373),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "\$20.00",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 25),
                                        Row(
                                          children: [
                                            Text(
                                              "Tax:",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF6E7373),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "0.49",
                                              style: GoogleFonts.poppins(
                                                  color: const Color(0xFF244065),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: Color(0xFFF8F8F8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total: ",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF6E7373),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        " \$27.49 ",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF244065),
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
                                    "Total amt: ",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    " \$27.49",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
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
                                      color: Color(0xFF6E7373),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    " \$1.89",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
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
                            decoration: BoxDecoration(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total payble: ",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        " \$29.38 ",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
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
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
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
                            border:
                                Border.all(color: Color(0xFF9ECF9A), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 7),
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
                              builder: (context) => MyCartPage(
                                  myCartId:
                                      ''), // Replace with your target widget
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF9ECF9A),
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Color(0xFF9ECF9A), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 7),
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
                    ),
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
