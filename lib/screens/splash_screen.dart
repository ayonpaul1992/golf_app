import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<StatefulWidget> createState() => splashScreenState();
}

class splashScreenState extends State<splashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                  children: [
                Container(child: Image.asset('assets/images/spls_bnnr.jpg')),
                Positioned(
                  bottom: 0,
                  child: Image.asset('assets/images/drvrio.png'),
                )
              ]),
              SizedBox(height: 40,),
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
                    SizedBox(width: 10,),
                    Text('Your Tee Time, Your Way',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF244065),
                        fontSize: 17.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      width: 40,
                      height: 1,
                      color: Color(0xFFB2C1C0),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Text(
                    "Whether you're planning a solo round, a friendly foursome, or a tournament warm-up, booking has never been easier.",
                    textAlign: TextAlign.center, // ✅ Set text alignment here
                    style: GoogleFonts.poppins(
                      color: Color(0xFF6E7373),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 38,right: 38,bottom: 40),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => loginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9ECF9A)
                        ),

                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
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
                      child: Icon(Icons.arrow_forward,color: Color(0xFFFFFFFF),size: 18,),
                    )
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
