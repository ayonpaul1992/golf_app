// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gulf_app/screens/edit_profile.dart';
import 'package:gulf_app/screens/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:gulf_app/screens/my_transaction.dart';

class MySettingPage extends StatefulWidget {
  final String myStngId;
  const MySettingPage({super.key, required this.myStngId});

  @override
  State<StatefulWidget> createState() => MySettingPageState();
}

class MySettingPageState extends State<MySettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? userName = '';
  String? accountNumber = '';
  String? userProfileImage = '';

  //get user name from secure storage
  Future<void> getUserName() async {
    String? fetchedUserName = await secureStorage.read(key: 'userName');
    String? fetchedAccountNumber =
        await secureStorage.read(key: 'accountNumber');
    String? storedUserProfileImage =
        await secureStorage.read(key: 'profilePic');
    setState(() {
      userName = fetchedUserName ?? 'Guest'; // Default to 'Guest' if not found
      accountNumber =
          fetchedAccountNumber ?? 'N/A'; // Default to 'N/A' if not found
      userProfileImage = storedUserProfileImage ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myStngId, // ✅ Pass the correct userId
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
        color: const Color(0xFFFAFCFA),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        "Settings",
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
              const SizedBox(
                height: 15,
              ),
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
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      // child: Image.asset(
                                      //   "assets/images/profile_prsn.jpg",
                                      //   width: 50,
                                      //   height: 50,
                                      //   fit: BoxFit.cover,
                                      // ),
                                      child: Image(
                                        image: userProfileImage!.isNotEmpty
                                            ? NetworkImage(userProfileImage!)
                                            : const AssetImage(
                                                    "assets/images/profile_prsn.jpg")
                                                as ImageProvider,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
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
                                          (userName != null &&
                                                  userName!.isNotEmpty)
                                              ? userName!
                                              : "Guest User",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF244065),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color(0xFFF7FAF4),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Text(
                                            accountNumber != null &&
                                                    accountNumber!.isNotEmpty
                                                ? "$accountNumber"
                                                : "Account: N/A",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFF669933),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // print("Edit Profile Tapped");
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
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF9ECF9A),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              100)), // Use Radius.circular
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.edit,
                                        size: 17,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Change Password",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Notification",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Membership",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "My Wallet",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "My Transactions",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "My Gift Cards",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "FAQs",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Term and Conditions",
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
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9ECF9A)
                              .withOpacity(0.15), // make it visible
                          blurRadius: 30, // soft edges
                          spreadRadius:
                              1, // controls how far the shadow spreads
                          offset:
                              const Offset(3, 0), // shift shadow down slightly
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Help and Support",
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
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
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
            ],
          )),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }
}
