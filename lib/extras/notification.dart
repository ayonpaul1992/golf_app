import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class notificationPage extends StatefulWidget {
  final String myNtfId;

  const notificationPage({super.key, required this.myNtfId});

  @override
  State<StatefulWidget> createState() => notificationPageState();
}

class notificationPageState extends State<notificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myNtfId, // ✅ Pass the correct userId
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
                          "Notification",
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
                padding: EdgeInsets.only(left: 10, right: 10, top: 15,bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10,left: 10,right: 30,bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 3),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(0xFF9ECF9A),
                                border: Border.all(
                                    color: Color(0xFF9ECF9A), width: 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Icon(Icons.campaign,color: Color(0xFFFFFFFF),size: 20,),
                              ),
                            ),
                            SizedBox(width: 7,),
                            Column(
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: Text("Please complete the reservation process today.",
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF244065),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Text("Your time, 6:30AM, will be held for 5 minutes. You have 00:00 remaining.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Wrap(
                                    children: [
                                      Icon(Icons.access_time_sharp,color: Color(0xFF6E7373),size: 17),
                                      SizedBox(width: 1.5,),
                                      Text("10 min ago",style: GoogleFonts.poppins(
                                        color: Color(0xFF6E7373),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600
                                      ),)
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10,left: 10,right: 30,bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 3),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(0xFFEAB308),
                                border: Border.all(
                                    color: Color(0xFFEAB308), width: 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Icon(Icons.campaign,color: Color(0xFFFFFFFF),size: 20,),
                              ),
                            ),
                            SizedBox(width: 7,),
                            Column(
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: Text("Please arrive 15 minutes early to check in.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Text("Cart and range balls are included.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Wrap(
                                    children: [
                                      Icon(Icons.access_time_sharp,color: Color(0xFF6E7373),size: 17),
                                      SizedBox(width: 1.5,),
                                      Text("1 hour 15 min ago",style: GoogleFonts.poppins(
                                          color: Color(0xFF6E7373),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600
                                      ),)
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10,left: 10,right: 30,bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFFFFF)
                                .withOpacity(0.2), // soft shadow
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 3),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(0xFFDB0606),
                                border: Border.all(
                                    color: Color(0xFFDB0606), width: 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Icon(Icons.campaign,color: Color(0xFFFFFFFF),size: 20,),
                              ),
                            ),
                            SizedBox(width: 7,),
                            Column(
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: Text("Please complete the reservation process today.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Text("Your time, 6:30AM, will be held for 5 minutes. You have 00:00 remaining.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Wrap(
                                    children: [
                                      Icon(Icons.access_time_sharp,color: Color(0xFF6E7373),size: 17),
                                      SizedBox(width: 1.5,),
                                      Text("10 min ago",style: GoogleFonts.poppins(
                                          color: Color(0xFF6E7373),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600
                                      ),)
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10,left: 10,right: 30,bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFFFFF)
                                .withOpacity(0.2), // soft shadow
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 3),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(0xFF9ECF9A),
                                border: Border.all(
                                    color: Color(0xFF9ECF9A), width: 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Icon(Icons.campaign,color: Color(0xFFFFFFFF),size: 20,),
                              ),
                            ),
                            SizedBox(width: 7,),
                            Column(
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: Text("Please arrive 15 minutes early to check in.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Text("Cart and range balls are included.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Wrap(
                                    children: [
                                      Icon(Icons.access_time_sharp,color: Color(0xFF6E7373),size: 17),
                                      SizedBox(width: 1.5,),
                                      Text("1 hour 15 min ago",style: GoogleFonts.poppins(
                                          color: Color(0xFF6E7373),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600
                                      ),)
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10,left: 10,right: 30,bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFFFFF)
                                .withOpacity(0.2), // soft shadow
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 3),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(0xFFDB0606),
                                border: Border.all(
                                    color: Color(0xFFDB0606), width: 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Icon(Icons.campaign,color: Color(0xFFFFFFFF),size: 20,),
                              ),
                            ),
                            SizedBox(width: 7,),
                            Column(
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: Text("Please complete the reservation process today.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Text("Your time, 6:30AM, will be held for 5 minutes. You have 00:00 remaining.",
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  width: 270,
                                  child: Wrap(
                                    children: [
                                      Icon(Icons.access_time_sharp,color: Color(0xFF6E7373),size: 17),
                                      SizedBox(width: 1.5,),
                                      Text("10 min ago",style: GoogleFonts.poppins(
                                          color: Color(0xFF6E7373),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600
                                      ),)
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
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
