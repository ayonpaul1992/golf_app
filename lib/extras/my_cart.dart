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
                                child: Center(
                                  child: Text(
                                    "Booking Date and Time",
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Date:",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Wed, Apr 16",
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
                                  "Booking Time:",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "6:30AM",
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
                                  "Remaining Time:",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "01:21",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFFDB0606),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
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
                                    "Tee Time Details",
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Image.asset(
                                      "assets/images/mycrtgland.png"),
                                )
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rotation:",
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Front - Back",
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
                                Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 6),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Holes: ",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF6E7373)),
                                        ),
                                        Text(
                                          "18",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Color(0xFF244065)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  color: Color(0xFFF8F8F8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 6),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Players: ",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF6E7373)),
                                        ),
                                        Text(
                                          "1",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Color(0xFF244065)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  color: Color(0xFFF8F8F8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 6),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Carts: ",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF6E7373)),
                                        ),
                                        Text(
                                          "0",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Color(0xFF244065)),
                                        ),
                                      ],
                                    ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 15,
                                  children: [
                                    Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 6),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Players: ",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Color(0xFF6E7373)),
                                            ),
                                            Text(
                                              "1",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: Color(0xFF669933)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Koushik Dutta",style: GoogleFonts.poppins(
                                            color: Color(0xFF244065),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600
                                          ),),
                                          Text("(Green Fee 18 Holes)",style: GoogleFonts.poppins(
                                              color: Color(0xFF244065),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400
                                          ),)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  width: 120,
                                  child: Column(
                                    spacing: 15,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Price: ",style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            color: Color(0xFF6E7373)
                                          ),),
                                          Text("\$20.00",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Qty: ",style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            color: Color(0xFF6E7373)
                                          ),),
                                          Text("1",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Amt: ",style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            color: Color(0xFF6E7373)
                                          ),),
                                          Text("\$20.00",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Tax: ",style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            color: Color(0xFF6E7373)
                                          ),),
                                          Text("\$1.40",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total: ",style: GoogleFonts.poppins(
                                        color: Color(0xFF6E7373),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                      ),),
                                      Text(" \$21.40 ",style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600
                                      ),),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 15,
                                  children: [
                                    Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 6),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Players: ",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Color(0xFF6E7373)),
                                            ),
                                            Text(
                                              "2",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: Color(0xFF669933)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Guest Customer",style: GoogleFonts.poppins(
                                              color: Color(0xFF244065),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600
                                          ),),
                                          Text("(Green Fee 18 Holes)",style: GoogleFonts.poppins(
                                              color: Color(0xFF244065),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400
                                          ),)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  width: 120,
                                  child: Column(
                                    spacing: 15,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Price: ",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Color(0xFF6E7373)
                                          ),),
                                          Text("\$7.00",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Qty: ",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Color(0xFF6E7373)
                                          ),),
                                          Text("1",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                      Row (
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Amt: ",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Color(0xFF6E7373)
                                          ),),
                                          Text("\$7.00",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Tax: ",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Color(0xFF6E7373)
                                          ),),
                                          Text("\$0.49",style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xFF244065)
                                          ),),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total: ",style: GoogleFonts.poppins(
                                          color: Color(0xFF6E7373),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500
                                      ),),
                                      Text(" \$7.49 ",style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600
                                      ),),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                    " \$27.00",
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total payble: ",style: GoogleFonts.poppins(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500
                                      ),),
                                      Text(" \$28.89 ",style: GoogleFonts.poppins(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600
                                      ),),
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
                              builder: (context) => MyCartPage(myCartId: ''), // Replace with your target widget
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
              SizedBox(height: 20,),
            ],
          )),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
