// // ignore_for_file: deprecated_member_use, use_build_context_synchronously

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// // import 'login.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:gulf_app/components/dashboard_app_bar.dart';
// import 'package:gulf_app/components/custom_drawer.dart';
// import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
// import 'package:gulf_app/screens/my_reservation.dart';
// import 'package:gulf_app/screens/selcet_booking_class.dart';
// import 'package:weather_icons/weather_icons.dart';
// import '../services/location_service.dart';
// import '../services/weather_service.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';

// class DashboardPage extends StatefulWidget {
//   // final String dshbId;

//   const DashboardPage({
//     super.key,
//     // required this.dshbId,
//   });

//   @override
//   State<StatefulWidget> createState() => DashboardPageState();
// }

// class DashboardPageState extends State<DashboardPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//   bool isLoading = true;
//   String activeTile = 'Home';
//   String selectedItem = "Select";
//   String userName = ""; // Placeholder for user name
//   String profilePic = ""; // Placeholder for profile picture URL
//   String accountNumber = ""; // Placeholder for account number
//   String membership = ""; // Placeholder for membership type
//   String weatherDescription = '';
//   num temperature = 0.0;

//   // variable to store the upcoming tee time details
//   Map<String, dynamic>? upcomingTeeTime;

//   IconData _getWeatherIcon(String description) {
//     switch (description.toLowerCase()) {
//       case 'clear sky':
//         return WeatherIcons.day_sunny;
//       case 'few clouds':
//         return WeatherIcons.day_cloudy;
//       case 'scattered clouds':
//       case 'broken clouds':
//         return WeatherIcons.cloud;
//       case 'overcast clouds':
//         return WeatherIcons.cloudy;
//       case 'shower rain':
//       case 'light rain':
//       case 'moderate rain':
//         return WeatherIcons.rain;
//       case 'thunderstorm':
//         return WeatherIcons.thunderstorm;
//       case 'snow':
//         return WeatherIcons.snow;
//       case 'mist':
//         return WeatherIcons.fog;
//       default:
//         return WeatherIcons.na; // fallback icon
//     }
//   }

//   String toTitleCase(String text) {
//     if (text.isEmpty) return text;
//     return text.split(' ').map((word) {
//       if (word.isEmpty) return word;
//       return word[0].toUpperCase() + word.substring(1).toLowerCase();
//     }).join(' ');
//   }

//   Future<Map<String, dynamic>?> fetchUpcomingTeeTime() async {
//     try {
//       // Replace with your actual API call logic
//       // Example using http package:
//       final response = await http.get(
//         Uri.parse(
//             'https://api.dev.driverpos.io/api/v1/teesheet/myBookings?bookingStatus=Booked&page=1&limit=1&isDashboard=true'),
//         headers: {
//           'Authorization':
//               'Bearer ${await secureStorage.read(key: "accessToken")}'
//         },
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['data'] != null && data['data'].isNotEmpty) {
//           print("Upcoming Tee Time: ${data['data'][0]}");
//           return data['data'][0];
//         }
//       }
//       return null;

//       // Placeholder for demonstration:
//       // return null;
//     } catch (e) {
//       print('Error fetching upcoming tee time: $e');
//       return null;
//     }
//   }

//   Color hexToColor(String hexString) {
//     final buffer = StringBuffer();
//     if (hexString.startsWith('#')) hexString = hexString.substring(1);
//     if (hexString.length == 6) buffer.write('ff'); // default opacity
//     buffer.write(hexString);
//     return Color(int.parse(buffer.toString(), radix: 16));
//   }

//   @override
//   void initState() {
//     super.initState();
//     isLoading = true; // Set loading state to true initially
//     _loadUserName();
//     _loadWeather();
//     fetchUpcomingTeeTime().then((teeTime) {
//       if (teeTime != null) {
//         // Handle the fetched tee time if needed
//         setState(() {
//           upcomingTeeTime = teeTime;
//         });
//         print("Upcoming Tee Time: $teeTime");
//       } else {
//         print("No upcoming tee time found.");
//       }

//       setState(() {
//         isLoading = false; // Set loading state to false after fetching
//       });
//     });
//   }

//   Future<void> _loadUserName() async {
//     String? storedName = await secureStorage.read(key: 'userName');
//     String? storedPic = await secureStorage.read(key: 'profilePic');
//     String? storedAccountNumber =
//         await secureStorage.read(key: 'accountNumber');
//     String? storedMembership = await secureStorage.read(key: 'membership');

//     if (storedName != null && mounted) {
//       setState(() {
//         userName = storedName;
//         profilePic = storedPic!;
//         accountNumber = storedAccountNumber ?? '';
//         membership = storedMembership ?? '';
//       });
//     }
//   }

//   Future<void> _loadWeather() async {
//     try {
//       final position = await LocationService.getCurrentLocation();
//       final weather = await WeatherService.fetchWeather(
//         position.latitude,
//         position.longitude,
//       );

//       setState(() {
//         weatherDescription = toTitleCase(weather['weather'][0]['description']);
//         temperature = weather['main']['temp'];
//       });
//     } catch (e) {
//       print("❗ Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: DashboardAppBar(
//         scaffoldKey: _scaffoldKey,
//         // dshbId: widget.dshbId, // ✅ Pass the correct userId
//         showLeading: false, // ✅ Set to true to show the back button
//         onBackPressed: () {
//           Navigator.pop(context); // Optional: customize back behavior if needed
//         },
//       ),
//       drawer: CustomDrawer(
//         activeTile: 'Home',
//         onTileTap: (selectedTile) {
//           //print("Navigating to $selectedTile");
//           // Handle navigation logic
//         },
//       ),
      
      
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             setState(() {
//               isLoading = true; // Set loading state to true while refreshing
//             });
//             await fetchBookings();
//           },
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: SizedBox(
//                 height: MediaQuery.of(context).size.height,
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     minHeight: MediaQuery.of(context).size.height,
//                   ),
//                   child: IntrinsicHeight(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [


                       
                       
//                        Container(
//                           color: const Color(0xFFFAFCFA),
//                           width: double.infinity,
//                           height: double.infinity,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   const SizedBox(
//                                     height: 15,
//                                   ),
//                                   CompositedTransformTarget(
//                                     link: _layerLink,
//                                     child: SizedBox(
//                                       width: double.infinity,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             "My Reservation",
//                                             style: GoogleFonts.poppins(
//                                                 color: const Color(0xFF244065),
//                                                 fontSize: 17,
//                                                 fontWeight: FontWeight.w600),
//                                           ),
//                                           GestureDetector(
//                                             onTap: _toggleDropdown,
//                                             child: Row(
//                                               children: [
//                                                 Text(
//                                                   "Filter by:",
//                                                   style: GoogleFonts.poppins(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                       color: const Color(
//                                                           0xFF6E7373)),
//                                                 ),
//                                                 const SizedBox(width: 5),
//                                                 Text(
//                                                   _selectedFilter,
//                                                   style: GoogleFonts.poppins(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       color: const Color(
//                                                           0xFF244065)),
//                                                 ),
//                                                 Icon(
//                                                   _dropdownOverlay == null
//                                                       ? Icons
//                                                           .keyboard_arrow_down_rounded
//                                                       : Icons
//                                                           .keyboard_arrow_up_rounded,
//                                                   size: 22,
//                                                   color:
//                                                       const Color(0xFF669933),
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 15,
//                                   ),
//                                   Container(
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                           color: const Color(0xFF9ECF9A),
//                                           width: 1),
//                                       borderRadius: const BorderRadius.all(
//                                         Radius.circular(10), // Correct usage
//                                       ),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Container(
//                                           width: double.infinity,
//                                           decoration: const BoxDecoration(
//                                             color: Color(0xFFF8F8F8),
//                                             borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(10),
//                                               topRight: Radius.circular(10),
//                                             ),
//                                           ),
//                                           padding: const EdgeInsets.all(10),
//                                           child: Text(
//                                             "My Booking Summary",
//                                             textAlign: TextAlign.center,
//                                             style: GoogleFonts.poppins(
//                                               color: const Color(0xFF244065),
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 13,
//                                             ),
//                                           ),
//                                         ),
//                                         ...reservations.map((reservation) {
//                                           final courseName =
//                                               reservation['golfCourse'] ??
//                                                   'Unknown Course';
//                                           final courseLogo =
//                                               reservation['golfCourseLogo'];
//                                           final bookingDateRaw =
//                                               reservation['date'];
//                                           final bookingTimeRaw =
//                                               reservation['startingSlot'];

//                                           final holes = reservation['holes']
//                                                   ?.toString() ??
//                                               '-';
//                                           final players = reservation['persons']
//                                                   ?.toString() ??
//                                               '-';
//                                           final carts = reservation['carts']
//                                                   ?.toString() ??
//                                               '-';
//                                           final status = reservation['booking']
//                                                   ['status'] ??
//                                               'Booked';
//                                           final slotId = reservation['slotId']
//                                                   ?.toString() ??
//                                               '';

//                                           Color statusColor = hexToColor(
//                                             reservation['booking']['bgColor'] ??
//                                                 '#244065',
//                                           );

//                                           String bookingTime = '';
//                                           if (bookingTimeRaw != null) {
//                                             try {
//                                               final time =
//                                                   DateFormat('HH:mm:ss')
//                                                       .parse(bookingTimeRaw);
//                                               bookingTime = DateFormat('h:mma')
//                                                   .format(time);
//                                             } catch (_) {
//                                               bookingTime =
//                                                   bookingTimeRaw.toString();
//                                             }
//                                           }

//                                           return Container(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 5, top: 5),
//                                             decoration: const BoxDecoration(
//                                               border: Border(
//                                                 bottom: BorderSide(
//                                                   color: Color(
//                                                       0xFFE8E8E8), // Customize the color
//                                                   width:
//                                                       1.0, // Customize the width
//                                                 ),
//                                               ),
//                                             ),
//                                             child: Column(
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(10),
//                                                   child: Column(
//                                                     children: [
//                                                       Row(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Container(
//                                                             width: 75,
//                                                             height: 75,
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               color: const Color(
//                                                                   0xFFFFFFFF),
//                                                               border: Border.all(
//                                                                   width: 1.2,
//                                                                   color: const Color(
//                                                                       0xFFE8E8E8)),
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           10),
//                                                             ),
//                                                             child: Center(
//                                                               child: Image(
//                                                                 image: courseLogo !=
//                                                                         null
//                                                                     ? NetworkImage(
//                                                                         courseLogo,
//                                                                       )
//                                                                     : const AssetImage(
//                                                                         "assets/images/bkdu2.png",
//                                                                       ) as ImageProvider,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                               width:
//                                                                   10), // 👈 Space between items
//                                                           SizedBox(
//                                                             width: 250,
//                                                             // Optional padding
//                                                             child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceBetween,
//                                                                   children: [
//                                                                     Container(
//                                                                       decoration:
//                                                                           BoxDecoration(
//                                                                         color: const Color(
//                                                                             0xFFF7FAF4),
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(50),
//                                                                       ),
//                                                                       padding: const EdgeInsets
//                                                                           .symmetric(
//                                                                           horizontal:
//                                                                               10,
//                                                                           vertical:
//                                                                               5),
//                                                                       child:
//                                                                           Text(
//                                                                         status,
//                                                                         style: GoogleFonts
//                                                                             .poppins(
//                                                                           fontSize:
//                                                                               12,
//                                                                           color:
//                                                                               statusColor,
//                                                                           fontWeight:
//                                                                               FontWeight.w600,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                     Row(
//                                                                       children: [
//                                                                         InkWell(
//                                                                           onTap:
//                                                                               () {},
//                                                                           child:
//                                                                               Container(
//                                                                             width:
//                                                                                 25,
//                                                                             height:
//                                                                                 25,
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               color: const Color(0xFFF8F8F8),
//                                                                               borderRadius: BorderRadius.circular(50),
//                                                                             ),
//                                                                             child:
//                                                                                 const Center(
//                                                                               child: Icon(
//                                                                                 Icons.edit,
//                                                                                 size: 16,
//                                                                                 color: Color(0xFF669933),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             width:
//                                                                                 6),

//                                                                         reservation['checkedIn'] == false &&
//                                                                                 reservation['canceled'] == false
//                                                                             ? ElevatedButton(
//                                                                                 // onPressed: () {
//                                                                                 //   // Add your cancel logic here
//                                                                                 // },
//                                                                                 onPressed: () async {
//                                                                                   // A pop up dialog to confirm cancellation
//                                                                                   showDialog(
//                                                                                       context: context,
//                                                                                       builder: (BuildContext context) {
//                                                                                         return AlertDialog(
//                                                                                           title: const Text('Confirm Cancellation'),
//                                                                                           content: const Text('Are you sure you want to cancel this tee time?'),
//                                                                                           actions: [
//                                                                                             TextButton(
//                                                                                               onPressed: () {
//                                                                                                 Navigator.of(context).pop(); // Close the dialog
//                                                                                               },
//                                                                                               child: const Text('No'),
//                                                                                             ),
//                                                                                             TextButton(
//                                                                                               onPressed: () async {
//                                                                                                 // ✅ Save a valid context reference BEFORE popping
//                                                                                                 final messenger = ScaffoldMessenger.of(context);

//                                                                                                 Navigator.of(context).pop(); // Now safe to close the dialog

//                                                                                                 try {
//                                                                                                   final secureStorage = const FlutterSecureStorage();
//                                                                                                   final token = await secureStorage.read(key: 'accessToken');

//                                                                                                   if (token == null) {
//                                                                                                     throw Exception('Access token not found');
//                                                                                                   }

//                                                                                                   final uri = Uri.parse(
//                                                                                                     'https://api.dev.driverpos.io/api/v1/teesheet/myBookings/cancel/$slotId',
//                                                                                                   );

//                                                                                                   final response = await http.delete(
//                                                                                                     uri,
//                                                                                                     headers: {
//                                                                                                       'Authorization': 'Bearer $token',
//                                                                                                       'Content-Type': 'application/json',
//                                                                                                     },
//                                                                                                     body: jsonEncode({
//                                                                                                       "process": "Cancel",
//                                                                                                     }),
//                                                                                                   );

//                                                                                                   if (response.statusCode == 200) {
//                                                                                                     // ✅ Use the stored reference — not ScaffoldMessenger.of(context)
//                                                                                                     messenger.showSnackBar(
//                                                                                                       const SnackBar(
//                                                                                                         content: Text('Tee time cancelled successfully'),
//                                                                                                         backgroundColor: Color(0xFF9ECF9A),
//                                                                                                       ),
//                                                                                                     );

//                                                                                                     await Future.delayed(const Duration(milliseconds: 300));

//                                                                                                     if (context.mounted) {
//                                                                                                       Navigator.pushReplacement(
//                                                                                                         context,
//                                                                                                         MaterialPageRoute(
//                                                                                                           builder: (context) => MyReservationPage(
//                                                                                                               key: UniqueKey(), // Ensure a new key to rebuild the widget
//                                                                                                               myRsvId: ''),
//                                                                                                         ),
//                                                                                                       );
//                                                                                                     }
//                                                                                                   } else {
//                                                                                                     print('❌ Failed to cancel tee time: ${response.statusCode}');
//                                                                                                   }
//                                                                                                 } catch (e) {
//                                                                                                   print('❗ Error cancelling tee time: $e');
//                                                                                                 }
//                                                                                               },
//                                                                                               child: const Text('Yes'),
//                                                                                             ),
//                                                                                           ],
//                                                                                         );
//                                                                                       });
//                                                                                 },

//                                                                                 style: ElevatedButton.styleFrom(
//                                                                                   backgroundColor: const Color(0xFF9ECF9A),
//                                                                                   foregroundColor: Colors.white,
//                                                                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // vertical padding
//                                                                                   minimumSize: const Size(0, 0), // disables default min height
//                                                                                   shape: RoundedRectangleBorder(
//                                                                                     borderRadius: BorderRadius.circular(8),
//                                                                                   ),
//                                                                                 ),
//                                                                                 child: const Text(
//                                                                                   "Cancel",
//                                                                                   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
//                                                                                 ),
//                                                                               )
//                                                                             : const SizedBox.shrink(),

//                                                                         // InkWell(
//                                                                         //   onTap: () {},
//                                                                         //   child: Container(
//                                                                         //     width: 25,
//                                                                         //     height: 25,
//                                                                         //     decoration:
//                                                                         //         BoxDecoration(
//                                                                         //       color: Color(
//                                                                         //           0xFFF8F8F8),
//                                                                         //       borderRadius:
//                                                                         //           BorderRadius
//                                                                         //               .circular(
//                                                                         //                   50),
//                                                                         //     ),
//                                                                         //     child: Center(
//                                                                         //       child: Icon(
//                                                                         //         Icons
//                                                                         //             .delete,
//                                                                         //         size: 16,
//                                                                         //         color: Color(
//                                                                         //             0xFFDB0606),
//                                                                         //       ),
//                                                                         //     ),
//                                                                         //   ),
//                                                                         // ),
//                                                                       ],
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     height: 5),
//                                                                 Text(
//                                                                   courseName,
//                                                                   style: GoogleFonts
//                                                                       .poppins(
//                                                                     color: const Color(
//                                                                         0xFF244065),
//                                                                     fontSize:
//                                                                         13,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600,
//                                                                   ),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     height: 5),
//                                                                 Row(
//                                                                   spacing: 6,
//                                                                   children: [
//                                                                     const Icon(
//                                                                       Icons
//                                                                           .calendar_month_outlined,
//                                                                       color: Color(
//                                                                           0xFF6B7280),
//                                                                       size: 18,
//                                                                     ),
//                                                                     Text(
//                                                                       bookingTime,
//                                                                       style: GoogleFonts.poppins(
//                                                                           color: const Color(
//                                                                               0xFF6E7373),
//                                                                           fontSize:
//                                                                               13,
//                                                                           fontWeight:
//                                                                               FontWeight.w500),
//                                                                     ),
//                                                                     Container(
//                                                                       color: const Color(
//                                                                           0xFF6E7373),
//                                                                       width: 1,
//                                                                       height:
//                                                                           15,
//                                                                     ),
//                                                                     Text(
//                                                                       bookingDateRaw !=
//                                                                               null
//                                                                           ? DateFormat('EEE, MMM d')
//                                                                               .format(DateFormat('EEEE dd, MMMM, yyyy').parse(bookingDateRaw))
//                                                                           : "Unknown Date",
//                                                                       style: GoogleFonts.poppins(
//                                                                           color: const Color(
//                                                                               0xFF6E7373),
//                                                                           fontSize:
//                                                                               13,
//                                                                           fontWeight:
//                                                                               FontWeight.w500),
//                                                                     ),
//                                                                   ],
//                                                                 )
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       const SizedBox(
//                                                         height: 10,
//                                                       ),
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(
//                                                           left: 10,
//                                                           right: 10,
//                                                         ),
//                                                         child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Container(
//                                                               decoration: BoxDecoration(
//                                                                   color: const Color(
//                                                                       0xFFF7FAF4),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               50)),
//                                                               child: Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         15,
//                                                                     vertical:
//                                                                         6),
//                                                                 child: Center(
//                                                                   child: Row(
//                                                                     children: [
//                                                                       Text(
//                                                                         "Holes: ",
//                                                                         style: GoogleFonts.poppins(
//                                                                             fontSize:
//                                                                                 14,
//                                                                             color:
//                                                                                 const Color(0xFF6E7373),
//                                                                             fontWeight: FontWeight.w500),
//                                                                       ),
//                                                                       Text(
//                                                                         holes,
//                                                                         style: GoogleFonts.poppins(
//                                                                             fontSize:
//                                                                                 14,
//                                                                             color:
//                                                                                 const Color(0xFF244065),
//                                                                             fontWeight: FontWeight.w600),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Container(
//                                                               decoration: BoxDecoration(
//                                                                   color: const Color(
//                                                                       0xFFF7FAF4),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               50)),
//                                                               child: Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         15,
//                                                                     vertical:
//                                                                         6),
//                                                                 child: Center(
//                                                                   child: Row(
//                                                                     children: [
//                                                                       Text(
//                                                                         "Players: ",
//                                                                         style: GoogleFonts.poppins(
//                                                                             fontSize:
//                                                                                 14,
//                                                                             color:
//                                                                                 const Color(0xFF6E7373),
//                                                                             fontWeight: FontWeight.w500),
//                                                                       ),
//                                                                       Text(
//                                                                         players,
//                                                                         style: GoogleFonts.poppins(
//                                                                             fontSize:
//                                                                                 14,
//                                                                             color:
//                                                                                 const Color(0xFF244065),
//                                                                             fontWeight: FontWeight.w600),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Container(
//                                                               decoration: BoxDecoration(
//                                                                   color: const Color(
//                                                                       0xFFF7FAF4),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               50)),
//                                                               child: Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         15,
//                                                                     vertical:
//                                                                         6),
//                                                                 child: Center(
//                                                                   child: Row(
//                                                                     children: [
//                                                                       Text(
//                                                                         "Carts: ",
//                                                                         style: GoogleFonts.poppins(
//                                                                             fontSize:
//                                                                                 14,
//                                                                             color:
//                                                                                 const Color(0xFF6E7373),
//                                                                             fontWeight: FontWeight.w500),
//                                                                       ),
//                                                                       Text(
//                                                                         carts,
//                                                                         style: GoogleFonts.poppins(
//                                                                             fontSize:
//                                                                                 14,
//                                                                             color:
//                                                                                 const Color(0xFF244065),
//                                                                             fontWeight: FontWeight.w600),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           );
//                                           // Make box dynamic
//                                         }),
//                                         reservations.isEmpty
//                                             ? Center(
//                                                 child: Text(
//                                                   "No Reservations Found",
//                                                   style: GoogleFonts.poppins(
//                                                     color:
//                                                         const Color(0xFF244065),
//                                                     fontSize: 15,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               )
//                                             : const SizedBox.shrink(),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 20,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
      
      
      
                      
//                       ],
//                     ),
//                   ),
//                 )),
//           ),
//         ),
//       ),
      
      
//       bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// You need to define these functions and variables from your original code
// For this example, I'm using placeholder data
final _layerLink = LayerLink();
String _selectedFilter = "All";
OverlayEntry? _dropdownOverlay;
List<Map<String, dynamic>> reservations = []; // Placeholder list
Color hexToColor(String hexCode) {
  return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
}

// You will need to implement this page in your project
class MyReservationPage extends StatefulWidget {
  final String myRsvId;
  const MyReservationPage({Key? key, required this.myRsvId}) : super(key: key);

  @override
  State<MyReservationPage> createState() => _MyReservationPageState();
}

class _MyReservationPageState extends State<MyReservationPage> {
  // Placeholder function for refresh
  Future<void> _handleRefresh() async {
    // Simulate a network call
    await Future.delayed(const Duration(seconds: 2));
    // Here you would reload your reservation data
    setState(() {
      reservations = [
        {
          'golfCourse': 'Placeholder Course 1',
          'golfCourseLogo': null,
          'date': '2025-06-27',
          'startingSlot': '10:00:00',
          'holes': 18,
          'persons': 2,
          'carts': 1,
          'slotId': '12345',
          'checkedIn': false,
          'canceled': false,
          'booking': {
            'status': 'Booked',
            'bgColor': '#669933',
          },
        },
        {
          'golfCourse': 'Placeholder Course 2',
          'golfCourseLogo': 'https://picsum.photos/200', // Example image URL
          'date': '2025-06-28',
          'startingSlot': '11:30:00',
          'holes': 9,
          'persons': 4,
          'carts': 2,
          'slotId': '67890',
          'checkedIn': true,
          'canceled': false,
          'booking': {
            'status': 'Checked In',
            'bgColor': '#244065',
          },
        }
      ];
    });
  }

  void _toggleDropdown() {
    // Your dropdown logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          // ⚠️ The key change is here. Use a SingleChildScrollView directly
          // as the child of the RefreshIndicator and remove the unnecessary
          // nesting with LayoutBuilder, ConstrainedBox, and IntrinsicHeight.
          
          
          child: SingleChildScrollView(
            // Use AlwaysScrollableScrollPhysics to ensure the pull-to-refresh
            // gesture is always available, even if the content is not overflowing.
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFFF8F8F8),
                  width: double.infinity,
                  // ⚠️ Removed the fixed height to allow the content to determine the height
                  // and become scrollable.
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    // ⚠️ Removed the nested SingleChildScrollView.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "My Reservation",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF244065),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600),
                                ),
                                GestureDetector(
                                  onTap: _toggleDropdown,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Filter by:",
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF6E7373)),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _selectedFilter,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF244065)),
                                      ),
                                      Icon(
                                        _dropdownOverlay == null
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                        size: 22,
                                        color: const Color(0xFF669933),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF9ECF9A), width: 1),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10), // Correct usage
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "My Booking Summary",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF244065),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              ...reservations.map((reservation) {
                                final courseName = reservation['golfCourse'] ??
                                    'Unknown Course';
                                final courseLogo =
                                    reservation['golfCourseLogo'];
                                final status = reservation['booking']
                                        ['status'] ??
                                    'Booked';
                                final slotId =
                                    reservation['slotId']?.toString() ?? '';
                                Color statusColor = hexToColor(
                                  reservation['booking']['bgColor'] ??
                                      '#244065',
                                );
                                return Container(
                                  padding:
                                      const EdgeInsets.only(bottom: 5, top: 5),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFE8E8E8),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 75,
                                                  height: 75,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFFFFFFF),
                                                    border: Border.all(
                                                        width: 1.2,
                                                        color: const Color(
                                                            0xFFE8E8E8)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Center(
                                                    child: Image(
                                                      image: courseLogo != null
                                                          ? NetworkImage(
                                                              courseLogo,
                                                            )
                                                          : const AssetImage(
                                                              "assets/images/bkdu2.png",
                                                            ) as ImageProvider,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  width: 250,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF7FAF4),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            child: Text(
                                                              status,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 12,
                                                                color:
                                                                    statusColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {},
                                                                child:
                                                                    Container(
                                                                  width: 25,
                                                                  height: 25,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFF8F8F8),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50),
                                                                  ),
                                                                  child:
                                                                      const Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .edit,
                                                                      size: 16,
                                                                      color: Color(
                                                                          0xFF669933),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 6),
                                                              reservation['checkedIn'] ==
                                                                          false &&
                                                                      reservation[
                                                                              'canceled'] ==
                                                                          false
                                                                  ? ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                title: const Text('Confirm Cancellation'),
                                                                                content: const Text('Are you sure you want to cancel this tee time?'),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('No'),
                                                                                  ),
                                                                                  TextButton(
                                                                                    onPressed: () async {
                                                                                      final messenger = ScaffoldMessenger.of(context);
                                                                                      Navigator.of(context).pop();
                                                                                      try {
                                                                                        final secureStorage = const FlutterSecureStorage();
                                                                                        final token = await secureStorage.read(key: 'accessToken');
                                                                                        if (token == null) {
                                                                                          throw Exception('Access token not found');
                                                                                        }
                                                                                        final uri = Uri.parse(
                                                                                          'https://api.dev.driverpos.io/api/v1/teesheet/myBookings/cancel/$slotId',
                                                                                        );
                                                                                        final response = await http.delete(
                                                                                          uri,
                                                                                          headers: {
                                                                                            'Authorization': 'Bearer $token',
                                                                                            'Content-Type': 'application/json',
                                                                                          },
                                                                                          body: jsonEncode({
                                                                                            "process": "Cancel",
                                                                                          }),
                                                                                        );
                                                                                        if (response.statusCode == 200) {
                                                                                          messenger.showSnackBar(
                                                                                            const SnackBar(
                                                                                              content: Text('Tee time cancelled successfully'),
                                                                                              backgroundColor: Color(0xFF9ECF9A),
                                                                                            ),
                                                                                          );
                                                                                          await Future.delayed(const Duration(milliseconds: 300));
                                                                                          if (context.mounted) {
                                                                                            Navigator.pushReplacement(
                                                                                              context,
                                                                                              MaterialPageRoute(
                                                                                                builder: (context) => MyReservationPage(key: UniqueKey(), myRsvId: ''),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                        } else {
                                                                                          print('❌ Failed to cancel tee time: ${response.statusCode}');
                                                                                        }
                                                                                      } catch (e) {
                                                                                        print('❗ Error cancelling tee time: $e');
                                                                                      }
                                                                                    },
                                                                                    child: const Text('Yes'),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            });
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            const Color(0xFF9ECF9A),
                                                                        foregroundColor:
                                                                            Colors.white,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                5),
                                                                        minimumSize: const Size(
                                                                            0,
                                                                            0),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        courseName,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: const Color(
                                                              0xFF244065),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // This sized box is necessary to ensure the RefreshIndicator
                // has something to "pull down" on if the content is not filling the screen.
                SizedBox(
                  height: MediaQuery.of(context).size.height -
                      15, // A bit of padding
                ),
              ],
            ),
          ),
        
        
        
        ),
      ),
    );
  }
}

LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: const Color(0xFFF8F8F8),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  CompositedTransformTarget(
                                    link: _layerLink,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "My Reservation",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          GestureDetector(
                                            onTap: _toggleDropdown,
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Filter by:",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xFF6E7373)),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  _selectedFilter,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF244065)),
                                                ),
                                                Icon(
                                                  _dropdownOverlay == null
                                                      ? Icons
                                                          .keyboard_arrow_down_rounded
                                                      : Icons
                                                          .keyboard_arrow_up_rounded,
                                                  size: 22,
                                                  color:
                                                      const Color(0xFF669933),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF9ECF9A),
                                          width: 1),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10), // Correct usage
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF8F8F8),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            "My Booking Summary",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF244065),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        
                                        ...reservations.map((reservation) {
                                          final courseName =
                                              reservation['golfCourse'] ??
                                                  'Unknown Course';
                                          final courseLogo =
                                              reservation['golfCourseLogo'];
                                          final bookingDateRaw =
                                              reservation['date'];
                                          final bookingTimeRaw =
                                              reservation['startingSlot'];

                                          final holes = reservation['holes']
                                                  ?.toString() ??
                                              '-';
                                          final players = reservation['persons']
                                                  ?.toString() ??
                                              '-';
                                          final carts = reservation['carts']
                                                  ?.toString() ??
                                              '-';
                                          final status = reservation['booking']
                                                  ['status'] ??
                                              'Booked';
                                          final slotId = reservation['slotId']
                                                  ?.toString() ??
                                              '';

                                          Color statusColor = hexToColor(
                                            reservation['booking']['bgColor'] ??
                                                '#244065',
                                          );

                                          String bookingTime = '';
                                          if (bookingTimeRaw != null) {
                                            try {
                                              final time =
                                                  DateFormat('HH:mm:ss')
                                                      .parse(bookingTimeRaw);
                                              bookingTime = DateFormat('h:mma')
                                                  .format(time);
                                            } catch (_) {
                                              bookingTime =
                                                  bookingTimeRaw.toString();
                                            }
                                          }

                                          return Container(
                                            padding: const EdgeInsets.only(
                                                bottom: 5, top: 5),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color(
                                                      0xFFE8E8E8), // Customize the color
                                                  width:
                                                      1.0, // Customize the width
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: 75,
                                                            height: 75,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFFFFFFF),
                                                              border: Border.all(
                                                                  width: 1.2,
                                                                  color: const Color(
                                                                      0xFFE8E8E8)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Center(
                                                              child: Image(
                                                                image: courseLogo !=
                                                                        null
                                                                    ? NetworkImage(
                                                                        courseLogo,
                                                                      )
                                                                    : const AssetImage(
                                                                        "assets/images/bkdu2.png",
                                                                      ) as ImageProvider,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                                  10), // 👈 Space between items
                                                          SizedBox(
                                                            width: 250,
                                                            // Optional padding
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: const Color(
                                                                            0xFFF7FAF4),
                                                                        borderRadius:
                                                                            BorderRadius.circular(50),
                                                                      ),
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        status,
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              statusColor,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {},
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                25,
                                                                            height:
                                                                                25,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: const Color(0xFFF8F8F8),
                                                                              borderRadius: BorderRadius.circular(50),
                                                                            ),
                                                                            child:
                                                                                const Center(
                                                                              child: Icon(
                                                                                Icons.edit,
                                                                                size: 16,
                                                                                color: Color(0xFF669933),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                6),
                                                                        reservation['checkedIn'] == false &&
                                                                                reservation['canceled'] == false
                                                                            ? ElevatedButton(
                                                                                // onPressed: () {
                                                                                //   // Add your cancel logic here
                                                                                // },
                                                                                onPressed: () async {
                                                                                  // A pop up dialog to confirm cancellation
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return AlertDialog(
                                                                                          title: const Text('Confirm Cancellation'),
                                                                                          content: const Text('Are you sure you want to cancel this tee time?'),
                                                                                          actions: [
                                                                                            TextButton(
                                                                                              onPressed: () {
                                                                                                Navigator.of(context).pop(); // Close the dialog
                                                                                              },
                                                                                              child: const Text('No'),
                                                                                            ),
                                                                                            TextButton(
                                                                                              onPressed: () async {
                                                                                                // ✅ Save a valid context reference BEFORE popping
                                                                                                final messenger = ScaffoldMessenger.of(context);

                                                                                                Navigator.of(context).pop(); // Now safe to close the dialog

                                                                                                try {
                                                                                                  final secureStorage = const FlutterSecureStorage();
                                                                                                  final token = await secureStorage.read(key: 'accessToken');

                                                                                                  if (token == null) {
                                                                                                    throw Exception('Access token not found');
                                                                                                  }

                                                                                                  final uri = Uri.parse(
                                                                                                    'https://api.dev.driverpos.io/api/v1/teesheet/myBookings/cancel/$slotId',
                                                                                                  );

                                                                                                  final response = await http.delete(
                                                                                                    uri,
                                                                                                    headers: {
                                                                                                      'Authorization': 'Bearer $token',
                                                                                                      'Content-Type': 'application/json',
                                                                                                    },
                                                                                                    body: jsonEncode({
                                                                                                      "process": "Cancel",
                                                                                                    }),
                                                                                                  );

                                                                                                  if (response.statusCode == 200) {
                                                                                                    // ✅ Use the stored reference — not ScaffoldMessenger.of(context)
                                                                                                    messenger.showSnackBar(
                                                                                                      const SnackBar(
                                                                                                        content: Text('Tee time cancelled successfully'),
                                                                                                        backgroundColor: Color(0xFF9ECF9A),
                                                                                                      ),
                                                                                                    );

                                                                                                    await Future.delayed(const Duration(milliseconds: 300));

                                                                                                    if (context.mounted) {
                                                                                                      Navigator.pushReplacement(
                                                                                                        context,
                                                                                                        MaterialPageRoute(
                                                                                                          builder: (context) => MyReservationPage(
                                                                                                              key: UniqueKey(), // Ensure a new key to rebuild the widget
                                                                                                              myRsvId: ''),
                                                                                                        ),
                                                                                                      );
                                                                                                    }
                                                                                                  } else {
                                                                                                    print('❌ Failed to cancel tee time: ${response.statusCode}');
                                                                                                  }
                                                                                                } catch (e) {
                                                                                                  print('❗ Error cancelling tee time: $e');
                                                                                                }
                                                                                              },
                                                                                              child: const Text('Yes'),
                                                                                            ),
                                                                                          ],
                                                                                        );
                                                                                      });
                                                                                },

                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: const Color(0xFF9ECF9A),
                                                                                  foregroundColor: Colors.white,
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // vertical padding
                                                                                  minimumSize: const Size(0, 0), // disables default min height
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                  ),
                                                                                ),
                                                                                child: const Text(
                                                                                  "Cancel",
                                                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                                                                ),
                                                                              )
                                                                            : const SizedBox.shrink(),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  courseName,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    color: const Color(
                                                                        0xFF244065),
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Row(
                                                                  spacing: 6,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_month_outlined,
                                                                      color: Color(
                                                                          0xFF6B7280),
                                                                      size: 18,
                                                                    ),
                                                                    Text(
                                                                      bookingTime,
                                                                      style: GoogleFonts.poppins(
                                                                          color: const Color(
                                                                              0xFF6E7373),
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    Container(
                                                                      color: const Color(
                                                                          0xFF6E7373),
                                                                      width: 1,
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Text(
                                                                      bookingDateRaw !=
                                                                              null
                                                                          ? DateFormat('EEE, MMM d')
                                                                              .format(DateFormat('EEEE dd, MMMM, yyyy').parse(bookingDateRaw))
                                                                          : "Unknown Date",
                                                                      style: GoogleFonts.poppins(
                                                                          color: const Color(
                                                                              0xFF6E7373),
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: const Color(
                                                                      0xFFF7FAF4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50)),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        6),
                                                                child: Center(
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Holes: ",
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                const Color(0xFF6E7373),
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        holes,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                const Color(0xFF244065),
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: const Color(
                                                                      0xFFF7FAF4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50)),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        6),
                                                                child: Center(
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Players: ",
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                const Color(0xFF6E7373),
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        players,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                const Color(0xFF244065),
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: const Color(
                                                                      0xFFF7FAF4),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50)),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        6),
                                                                child: Center(
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "Carts: ",
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                const Color(0xFF6E7373),
                                                                            fontWeight: FontWeight.w500),
                                                                      ),
                                                                      Text(
                                                                        carts,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                const Color(0xFF244065),
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          // Make box dynamic
                                        }),
                                        
                                        
                                        
                                        reservations.isEmpty
                                            ? Center(
                                                child: Text(
                                                  "No Reservations Found",
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF244065),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // child: SizedBox(
                //   height: MediaQuery.of(context).size.height,

                // ),
              );
            },
          ),
