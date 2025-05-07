import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gulf_app/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'my_reservation.dart';
import 'my_transaction.dart';
import 'my_setting.dart';
import 'edit_profile.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class MyProfilePage extends StatefulWidget {
  final String myPfId;

  const MyProfilePage({super.key, required this.myPfId});

  @override
  State<StatefulWidget> createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myPfId, // ✅ Pass the correct userId
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
                          "My Profile",
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
              Container(
                width: double.infinity,
                margin:
                    EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 0),
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 30),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/particle.png'), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                top: 4, bottom: 4, right: 10, left: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "C7980",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF244065),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Center(
                                child: GestureDetector(
                              onTap: () {
                                print("Help button pressed!");
                              },
                              child: Text(
                                '?',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6E7373),
                                ),
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              color: Color(0xFFF8F8F8),
                              width: 90,
                              height: 90,
                            ),
                          ),
                          Positioned(
                              left: 5,
                              top: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  "assets/images/profile_prsn.jpg",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            "Koushik Datta",
                            style: GoogleFonts.poppins(
                                fontSize: 22,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "+91 8777794755",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "koushik@hih7.com",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 175,
                              padding: EdgeInsets.only(
                                  left: 7, right: 7, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF244065),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Center along the horizontal axis (for Row)
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment
                                        .centerLeft, // Align Stack content to the left
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/images/mmbr_arw.png",
                                            width: 25.5,
                                            height: 25.5,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "Platinum",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: const Color(0xFFFFFFFF),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    // Moved Icon outside the Stack and removed Container
                                    Icons.arrow_forward_ios_outlined,
                                    color: Color(0xFFFFFFFF),
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9ECF9A).withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius: 6, // controls how far the shadow spreads
                            offset: Offset(3, 0), // shift shadow down slightly
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyEditPage(myEdId: '',), // Replace with your target widget
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color(0xFF9ECF9A),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.edit,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "Edit Profile",
                                        style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 13,
                                    color: Color(0xFF9ECF9A),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9ECF9A).withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius: 6, // controls how far the shadow spreads
                            offset: Offset(3, 0), // shift shadow down slightly
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color(0xFF9ECF9A),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.card_giftcard,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "My Gift Card",
                                        style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 13,
                                    color: Color(0xFF9ECF9A),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9ECF9A).withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius: 6, // controls how far the shadow spreads
                            offset: Offset(3, 0), // shift shadow down slightly
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyTransactionPage(myTransId: '',), // Replace with your target widget
                                  ),
                                );
                              },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color(0xFF9ECF9A),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.fact_check,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "My Transaction",
                                        style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 13,
                                    color: Color(0xFF9ECF9A),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9ECF9A).withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius: 6, // controls how far the shadow spreads
                            offset: Offset(3, 0), // shift shadow down slightly
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyReservationPage(myRsvId: '',), // Replace with your target widget
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color(0xFF9ECF9A),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.date_range_outlined,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "My Reservation",
                                        style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 13,
                                    color: Color(0xFF9ECF9A),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9ECF9A).withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius: 6, // controls how far the shadow spreads
                            offset: Offset(3, 0), // shift shadow down slightly
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MySettingPage(myStngId: '',), // Replace with your target widget
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color(0xFF9ECF9A),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.settings,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "Settings",
                                        style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 13,
                                    color: Color(0xFF9ECF9A),
                                  )
                                ],
                              ),
                            ),
                          ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF9ECF9A)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                child: Center(
                                  child: Text(
                                    "Logout",
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
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
