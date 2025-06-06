// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'login.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/dashboard_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:gulf_app/screens/my_reservation.dart';
import 'package:gulf_app/screens/selcet_booking_class.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  // final String dshbId;

  const DashboardPage({
    super.key,
    // required this.dshbId,
  });

  @override
  State<StatefulWidget> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = true;
  String activeTile = 'Home';
  String selectedItem = "Select";
  String userName = ""; // Placeholder for user name
  String profilePic = ""; // Placeholder for profile picture URL
  String accountNumber = ""; // Placeholder for account number
  String membership = ""; // Placeholder for membership type
  String weatherDescription = '';
  num temperature = 0.0;

  IconData _getWeatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear sky':
        return WeatherIcons.day_sunny;
      case 'few clouds':
        return WeatherIcons.day_cloudy;
      case 'scattered clouds':
      case 'broken clouds':
        return WeatherIcons.cloud;
      case 'shower rain':
      case 'light rain':
      case 'moderate rain':
        return WeatherIcons.rain;
      case 'thunderstorm':
        return WeatherIcons.thunderstorm;
      case 'snow':
        return WeatherIcons.snow;
      case 'mist':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.na; // fallback icon
    }
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadWeather();
  }

  Future<void> _loadUserName() async {
    String? storedName = await secureStorage.read(key: 'userName');
    String? storedPic = await secureStorage.read(key: 'profilePic');
    String? storedAccountNumber =
        await secureStorage.read(key: 'accountNumber');
    String? storedMembership = await secureStorage.read(key: 'membership');

    if (storedName != null && mounted) {
      setState(() {
        userName = storedName;
        profilePic = storedPic!;
        accountNumber = storedAccountNumber ?? '';
        membership = storedMembership ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _loadWeather() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final weather = await WeatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        weatherDescription = toTitleCase(weather['weather'][0]['description']);
        temperature = weather['main']['temp'];
        isLoading = false;
      });
    } catch (e) {
      print("❗ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: DashboardAppBar(
        scaffoldKey: _scaffoldKey,
        // dshbId: widget.dshbId, // ✅ Pass the correct userId
        showLeading: false, // ✅ Set to true to show the back button
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9ECF9A),
              ),
            )
          : Container(
              color: const Color(0xFFFAFCFA),
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const SizedBox(
                    //   height: 25,
                    // ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9ECF9A)
                                    .withOpacity(0.15), // make it visible
                                blurRadius: 30, // soft edges
                                spreadRadius:
                                    1, // controls how far the shadow spreads
                                offset: const Offset(
                                    3, 0), // shift shadow down slightly
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: const Color(0xFF9ECF9A),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              // child: Image.asset(
                                              //   "assets/images/profile_prsn.jpg",
                                              //   width: 50,
                                              //   height: 50,
                                              //   fit: BoxFit.cover,
                                              // ),
                                              child: Image(
                                                image: profilePic.isNotEmpty
                                                    ? NetworkImage(profilePic)
                                                    : const AssetImage(
                                                            'assets/images/bkdu1.png')
                                                        as ImageProvider,
                                                fit: BoxFit.cover,
                                                width: 50,
                                                height: 50,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userName,
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF244065),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Row(spacing: 6, children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 7,
                                                            right: 7,
                                                            top: 5,
                                                            bottom: 5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF244065),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                            "assets/images/mmbr_arw.png"),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          membership.isNotEmpty
                                                              ? membership
                                                              : "Membership",
                                                          style: GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 11.5,
                                                              color: const Color(
                                                                  0xFFFFFFFF)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: const Color(
                                                          0xFFF7FAF4),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Text(
                                                      accountNumber.isNotEmpty
                                                          ? accountNumber
                                                          : "",
                                                      style: GoogleFonts.poppins(
                                                          color: const Color(
                                                              0xFF669933),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  )
                                                ]),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    spacing: 25,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getWeatherIcon(weatherDescription),
                                            color: const Color(0xFF669933),
                                            size: 40,
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                temperature % 1 == 0
                                                    ? temperature
                                                        .toInt()
                                                        .toString()
                                                    : temperature
                                                        .toStringAsFixed(1),
                                                style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF244065),
                                                    fontSize: 26,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                "°F",
                                                style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF244065),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            weatherDescription.isNotEmpty
                                                ? weatherDescription
                                                : "...",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF6E7373),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Row(
                                    spacing: 5,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.date_range,
                                            color: Color(0xFF669933),
                                            size: 40,
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat('MMMM d').format(
                                                  DateTime.now(),
                                                ),
                                                style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF244065),
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            DateFormat('EEEE').format(
                                              DateTime.now(),
                                            ),
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF6E7373),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Wrap(
                                spacing: 15,
                                runSpacing: 15,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // print("Book a New Tee Time tapped");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SelcetBookingClass(
                                                  userId: ''),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.1), // light shadow
                                            offset: const Offset(
                                                1, 1), // x: right, y: down
                                            blurRadius: 10, // soft blur
                                            spreadRadius: 1, // slight spread
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.edit_calendar,
                                            color: Color(0xFF669933),
                                            size: 36,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              "Book a New Tee Time",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.1), // light shadow
                                            offset: const Offset(
                                                1, 1), // x: right, y: down
                                            blurRadius: 10, // soft blur
                                            spreadRadius: 1, // slight spread
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.badge,
                                            color: Color(0xFF669933),
                                            size: 36,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              "Gift Card & Membership",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MyReservationPage(
                                                  myRsvId: ''),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.1), // light shadow
                                            offset: const Offset(
                                                1, 1), // x: right, y: down
                                            blurRadius: 10, // soft blur
                                            spreadRadius: 1, // slight spread
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.history,
                                            color: Color(0xFF669933),
                                            size: 36,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              "Booking History",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.1), // light shadow
                                            offset: const Offset(
                                                1, 1), // x: right, y: down
                                            blurRadius: 10, // soft blur
                                            spreadRadius: 1, // slight spread
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.group_add,
                                            color: Color(0xFF669933),
                                            size: 36,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              "Make a Group",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                        height: 1,
                                        color: const Color(0xFFB2C1C0),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Upcoming Tee Time",
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
                                        height: 1,
                                        color: const Color(0xFFB2C1C0),
                                      ),
                                    ],
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, left: 20, right: 20, bottom: 20),
                                child: Text(
                                  "No tee times coming up — book your next round now!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF6E7373),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20, left: 15, right: 15),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => LoginPage()),
                                    // );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9ECF9A)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 10.0),
                                    child: Center(
                                      child: Text(
                                        "Contact now",
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
                  ],
                )),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }
}
