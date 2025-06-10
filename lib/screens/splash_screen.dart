import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(alignment: Alignment.center, children: [
                Image.asset('assets/images/spls_bnnr.jpg'),
                Positioned(
                  bottom: 0,
                  child: Image.asset('assets/images/drvrio.png'),
                )
              ]),
              const SizedBox(
                height: 40,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: const Color(0xFFB2C1C0),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Your Tee Time, Your Way',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF244065),
                        fontSize: 17.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 40,
                      height: 1,
                      color: const Color(0xFFB2C1C0),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Text(
                    "Whether you're planning a solo round, a friendly foursome, or a tournament warm-up, booking has never been easier.",
                    textAlign: TextAlign.center, // ✅ Set text alignment here
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6E7373),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 38, right: 38, bottom: 40),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9ECF9A)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                          child: Center(
                            child: Text(
                              "Proceed",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
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
      ),
    
    
    );
  }
}
