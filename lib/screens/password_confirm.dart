import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:gulf_app/components/userentry_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "login.dart";

class PasswordConfirmPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>PasswordConfirmPageState();

}
class PasswordConfirmPageState extends State<PasswordConfirmPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
return Scaffold(
  key: _scaffoldKey,
  appBar: UserentryAppbar(
    scaffoldKey: _scaffoldKey,
    userId: '',
    showLeading: false,
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
            child: Image.asset("assets/images/drvrio.png"),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Quick. Simple. Secure.",
            style: GoogleFonts.poppins(
              color: Color(0xFF669933),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
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
                      "Thank you for register",
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
          Padding(
            padding:
            EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 30),
            child: Text(
              "Your account has been created. Now you can login and join with us.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Color(0xFF6E7373),
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

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
                                "Proceed",
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
);
  }

}
