import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:gulf_app/components/userentry_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'reset_password.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Create a storage instance
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  // Function to show the error or success messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
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
                        "Forgot Password",
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
                "Enter your mobile number to reset new password.",
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
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 100,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 4,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
                        enableActiveFill: true,
                        mainAxisAlignment: MainAxisAlignment.center,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          fieldHeight: 35,
                          fieldWidth: 35,
                          activeColor: Colors.transparent,
                          selectedColor: Colors.transparent,
                          inactiveColor: Colors.transparent,
                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          // Add this property to create spacing around each pin box
                          fieldOuterPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                          // Adjust the horizontal value as needed
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Color(0xFF244065),
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (value) {
                          print(value);
                        },
                        onCompleted: (value) {
                          print("Completed: $value");
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            "Dont receive the OTP?",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6E7373)),
                          ),
                          SizedBox(width: 4,),
                          InkWell(
                            onTap: (){
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context)=> loginPage()
                              //     ));
                            },
                            child: Text(
                              "RESEND OTP",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF669933),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: EdgeInsets.only(left: 38, right: 38, bottom: 20),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => resetPasswordPage(userId: null,)),
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF9ECF9A)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10.0),
                              child: Center(
                                child: Text(
                                  "Verify",
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