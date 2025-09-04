// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gulf_app/main.dart';
import 'package:gulf_app/screens/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:gulf_app/screens/membership_screen.dart';
import 'package:gulf_app/screens/tab_card_screens.dart';
import 'my_reservation.dart';
import 'my_transaction.dart';
import 'my_setting.dart';
import 'edit_profile.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

// Add a global RouteObserver for navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyProfilePage extends StatefulWidget {
  final String myPfId;

  const MyProfilePage({super.key, required this.myPfId});

  @override
  State<StatefulWidget> createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String accountNumber = '';
  String userProfileImage = '';
  String userMembership = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      // debugPrint("✅ Subscribed to RouteObserver in MyProfilePage");
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    debugPrint("↩️ Returned to MyProfilePage from another route");
    _reloadData(); // This will re-trigger your reload logic
  }

  Future<void> _reloadData() async {
    // You can call your data fetching method here
    await _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    String? storedUserName = await secureStorage.read(key: 'userName');
    String? storedUserEmail = await secureStorage.read(key: 'userEmail');
    String? storedUserPhone = await secureStorage.read(key: 'userPhone');
    String? storedAccountNumber =
        await secureStorage.read(key: 'accountNumber');
    String? storedUserProfileImage =
        await secureStorage.read(key: 'profilePic');
    String? storedUserMembership = await secureStorage.read(key: 'membership');
    if (storedUserName != null && mounted) {
      setState(() {
        userName = storedUserName;
        userEmail = storedUserEmail ?? '';
        userPhone = storedUserPhone ?? '';
        accountNumber = storedAccountNumber ?? '';
        userProfileImage = storedUserProfileImage ?? '';
        userMembership = storedUserMembership ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myPfId, // ✅ Pass the correct userId
        showLeading: true, // ✅ Set to true to show the back button
        isOnProfilePage: true,
        onBackPressed: () {
          Navigator.pop(context); // Optional: customize back behavior if needed
        },
      ),
      drawer: CustomDrawer(
        activeTile: 'My Profile',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
      ),
      body: Container(
        color: const Color(0xFFFAFCFA),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
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
                        "My Profile",
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
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                    left: 15, right: 15, top: 10, bottom: 0),
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 30, bottom: 30),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/particle.png'), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              top: 4, bottom: 4, right: 10, left: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              accountNumber,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: const Color(0xFF244065),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
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
                                color: const Color(0xFF6E7373),
                              ),
                            ),
                          )),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            color: const Color(0xFFF8F8F8),
                            width: 90,
                            height: 90,
                          ),
                        ),
                        Positioned(
                          left: 5,
                          top: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image(
                              image: userProfileImage.isNotEmpty
                                  ? NetworkImage(userProfileImage)
                                  : const AssetImage(
                                          "assets/images/user-svgrepo-com.png")
                                      as ImageProvider,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "+1 $userPhone",
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          userEmail,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // GestureDetector(
                        //   onTap: () {},
                        //   child: Container(
                        //     width: 175,
                        //     padding: const EdgeInsets.only(
                        //         left: 7, right: 7, top: 5, bottom: 5),
                        //     decoration: BoxDecoration(
                        //       color: const Color(0xFF244065),
                        //       borderRadius: BorderRadius.circular(50),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment
                        //           .spaceBetween, // Center along the horizontal axis (for Row)
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Stack(
                        //           alignment: Alignment
                        //               .centerLeft, // Align Stack content to the left
                        //           children: [
                        //             Row(
                        //               children: [
                        //                 Image.asset(
                        //                   "assets/images/mmbr_arw.png",
                        //                   width: 25.5,
                        //                   height: 25.5,
                        //                 ),
                        //                 const SizedBox(
                        //                   width: 4,
                        //                 ),
                        //                 Text(
                        //                   userMembership,
                        //                   style: GoogleFonts.poppins(
                        //                     fontWeight: FontWeight.w500,
                        //                     fontSize: 14,
                        //                     color: const Color(0xFFFFFFFF),
                        //                   ),
                        //                 )
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //         const Icon(
                        //           // Moved Icon outside the Stack and removed Container
                        //           Icons.arrow_forward_ios_outlined,
                        //           color: Color(0xFFFFFFFF),
                        //           size: 13,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // )

                        GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const MembershipScreen(
                            //         mmbspId:
                            //             ''), // Replace with your target widget
                            //   ),
                            // );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF244065),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // <-- important: make Row size wrap content
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/mmbr_arw.png",
                                      width: 25.5,
                                      height: 25.5,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      userMembership,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 8,
                                ), // spacing between text and arrow icon
                                const Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9ECF9A)
                                .withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius:
                                6, // controls how far the shadow spreads
                            offset: const Offset(
                                3, 0), // shift shadow down slightly
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
                                  builder: (context) => const MyEditPage(
                                    myEdId: '',
                                  ), // Replace with your target widget
                                ),
                              );
                            },
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.edit,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "Edit Profile",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
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
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9ECF9A)
                                .withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius:
                                6, // controls how far the shadow spreads
                            offset: const Offset(
                                3, 0), // shift shadow down slightly
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
                                  builder: (context) => const TabCardScreenPage(
                                    tabcardId: '',
                                  ), // Replace with your target widget
                                ),
                              );
                            },
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.card_giftcard,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "My Gift Card",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
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
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9ECF9A)
                                .withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius:
                                6, // controls how far the shadow spreads
                            offset: const Offset(
                                3, 0), // shift shadow down slightly
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
                                  builder: (context) => const MyTransactionPage(
                                    myTransId: '',
                                  ), // Replace with your target widget
                                ),
                              );
                            },
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(100),
                                          ), // Use Radius.circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.fact_check,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "My Transaction",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
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
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9ECF9A)
                                .withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius:
                                6, // controls how far the shadow spreads
                            offset: const Offset(
                                3, 0), // shift shadow down slightly
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
                                  builder: (context) => const MyReservationPage(
                                    myRsvId: '',
                                  ), // Replace with your target widget
                                ),
                              );
                            },
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.date_range_outlined,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "My Reservation",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
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
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9ECF9A)
                                .withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius:
                                6, // controls how far the shadow spreads
                            offset: const Offset(
                                3, 0), // shift shadow down slightly
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
                                  builder: (context) => const MySettingPage(
                                    myStngId: '',
                                  ), // Replace with your target widget
                                ),
                              );
                            },
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  100)), // Use Radius.circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.settings,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "Settings",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
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
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9ECF9A)
                                .withOpacity(0.15), // make it visible
                            blurRadius: 20, // soft edges
                            spreadRadius:
                                6, // controls how far the shadow spreads
                            offset: const Offset(
                                3, 0), // shift shadow down slightly
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final parentContext =
                                  context; // ✅ Capture the page context (safe one)

                              showDialog(
                                context: parentContext,
                                builder: (BuildContext dialogContext) {
                                  final TextEditingController
                                      passwordController =
                                      TextEditingController();

                                  return AlertDialog(
                                    title: const Text('Delete Account'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            'Please enter your password to confirm account deletion:'),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: passwordController,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(); // ✅ close dialog safely
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final password =
                                              passwordController.text.trim();

                                          if (password.isEmpty) {
                                            rootScaffoldMessengerKey
                                                .currentState
                                                ?.showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Password cannot be empty')),
                                            );
                                            return;
                                          }

                                          // ✅ Close password dialog using dialogContext
                                          Navigator.of(dialogContext,
                                                  rootNavigator: true)
                                              .pop();

                                          // ✅ Show loading dialog using parentContext
                                          showDialog(
                                            context: parentContext,
                                            barrierDismissible: false,
                                            builder: (ctx) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                          );

                                          try {
                                            final token = await secureStorage
                                                .read(key: 'accessToken');

                                            // --- encryption logic (unchanged) ---
                                            final loginPayload = {
                                              'password': password
                                            };
                                            final secret = 'course1999golf01';
                                            final keyHash = sha256
                                                .convert(utf8.encode(secret))
                                                .bytes;
                                            final secretKey =
                                                SecretKey(keyHash);
                                            final algorithm =
                                                AesGcm.with256bits();
                                            final iv = algorithm.newNonce();

                                            final secretBox =
                                                await algorithm.encrypt(
                                              utf8.encode(
                                                  jsonEncode(loginPayload)),
                                              secretKey: secretKey,
                                              nonce: iv,
                                            );

                                            final encryptedPayload = {
                                              'iv': base64Encode(iv),
                                              'data': base64Encode(
                                                  secretBox.cipherText),
                                              'tag': base64Encode(
                                                  secretBox.mac.bytes),
                                            };

                                            final response = await http.delete(
                                              Uri.parse(
                                                  'https://api.dev.driverpos.io/api/v1/customer/delete'),
                                              headers: {
                                                'Authorization':
                                                    'Bearer $token',
                                                'Content-Type':
                                                    'application/json',
                                              },
                                              body:
                                                  jsonEncode(encryptedPayload),
                                            );

                                            // ✅ Close loading dialog using rootNavigator
                                            Navigator.of(parentContext,
                                                    rootNavigator: true)
                                                .pop();

                                            if (!parentContext.mounted) return;

                                            if (response.statusCode == 200) {
                                              await secureStorage.deleteAll();

                                              rootScaffoldMessengerKey
                                                  .currentState
                                                  ?.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Account deleted successfully.'),
                                                ),
                                              );
                                              Navigator.pushAndRemoveUntil(
                                                parentContext,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const LoginPage(),
                                                ),
                                                (route) => false,
                                              );
                                            } else {
                                              rootScaffoldMessengerKey
                                                  .currentState
                                                  ?.showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Failed to delete account.')),
                                              );
                                            }
                                          } catch (e) {
                                            Navigator.of(parentContext,
                                                    rootNavigator: true)
                                                .pop();

                                            if (parentContext.mounted) {
                                              rootScaffoldMessengerKey
                                                  .currentState
                                                  ?.showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error: ${e.toString()}')),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 5,
                              ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(100),
                                          ), // Use Radius.circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.delete_forever,
                                            size: 17,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        "Delete Account",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
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
                      padding: const EdgeInsets.only(
                        left: 38,
                        right: 38,
                        bottom: 20,
                      ),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Implement logout functionality here
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Logout'),
                                      content: const Text(
                                          'Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Logout'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm != true) {
                                  return;
                                }
                                await secureStorage.deleteAll();
                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false,
                                );
                                // Here you can call your logout function
                                // logout();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => const LoginPage()),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9ECF9A)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                child: Center(
                                  child: Text(
                                    "Logout",
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }
}
