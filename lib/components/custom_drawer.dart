// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gulf_app/screens/dashboard.dart';
import 'package:gulf_app/screens/login.dart';
import 'package:gulf_app/screens/my_profile.dart';
import 'package:gulf_app/screens/my_reservation.dart';
import 'package:gulf_app/screens/my_transaction.dart';
import 'package:gulf_app/screens/selcet_booking_class.dart';
import 'package:gulf_app/screens/tab_card_screens.dart';

class CustomDrawer extends StatefulWidget {
  final String activeTile;
  final Function(String) onTileTap;

  const CustomDrawer({
    super.key,
    required this.activeTile,
    required this.onTileTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String activeTile = '';
  String loggedInUserName = '';
  String loggedInUserPhone = '';
  String loggedInGolfCourse = '';
  String profilePic = ""; // Placeholder for profile picture URL

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    activeTile = widget.activeTile;
    _loadUserName(); // Load the user name when the widget is initialized
  }

  void _loadUserName() async {
    String? userName = await secureStorage.read(key: 'userName');
    String? userPhone = await secureStorage.read(key: 'userPhone');
    String? golfCourseName = await secureStorage.read(key: 'golfCourseName');
    String? storedPic = await secureStorage.read(key: 'profilePic');

    // print('User Name: $userName');
    setState(() {
      loggedInUserName = userName ?? ""; // Provide a fallback value
      loggedInUserPhone = userPhone ?? ""; // Provide a fallback value
      loggedInGolfCourse = golfCourseName ?? ""; // Static value for now
      profilePic = storedPic ?? ""; // Provide a fallback value
    });
  }

  Widget _buildDrawerTile({
    required String title,
    required IconData icon,
    Widget? destinationScreen,
  }) {
    bool isActive = activeTile == title;

    // print('Active tile before tap: $activeTile');
    // print('Building tile for: $title, isActive: $isActive');

    return InkWell(
      onTap: () {
        // // Close drawer

        if (activeTile == title) {
          // ✅ Don't navigate if already on this screen
          Navigator.pop(context);
          return;
        }

        setState(() {
          activeTile = title;
          isActive = true;
        });

        widget.onTileTap(title);

        // print('Active tile after tap: $activeTile');

        if (destinationScreen != null) {
          Navigator.pop(context);

          // print('Navigating to $title screen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title screen is under development!')),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7DB778) : Colors.transparent,
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFFBFEBBC),
              width: 1.0,
            ),
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: isActive
                      ? const Color(0xFF669933)
                      : const Color(0xFF9ECF9A),
                  width: 1),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isActive
                    ? const Color(0xFFffffff)
                    : const Color(0xFFffffff),
                size: 22, // Slightly increased for better visibility
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color:
                  isActive ? const Color(0xFFffffff) : const Color(0xFFffffff),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF9ECF9A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF9ECF9A)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_sharp,
                            size: 19,
                            color: Color(0xFFffffff),
                          ),
                          Text(
                            loggedInGolfCourse.isNotEmpty
                                ? loggedInGolfCourse
                                : 'Golf Course',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        ClipOval(
                          child: Image(
                            image: profilePic.isNotEmpty
                                ? NetworkImage(profilePic)
                                : const AssetImage('assets/images/bkdu1.png')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),

                          // Image.asset(
                          //   'assets/images/menu_ppl.png',
                          //   fit: BoxFit.cover,
                          //   width: 64,
                          //   height: 64,
                          // ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                loggedInUserName,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFFFFF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5),
                              width: 200,
                              child: Text(
                                '+1 ${loggedInUserPhone.replaceFirstMapped(RegExp(r'^(\d{5})(\d+)'), (m) => '${m[1]} ${m[2]}')}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFFFFF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Drawer Items
            _buildDrawerTile(
              title: 'Home',
              icon: Icons.home,
              destinationScreen: const DashboardPage(),
            ),
            _buildDrawerTile(
              title: 'My Profile',
              icon: Icons.person_outline_sharp,
              destinationScreen: const MyProfilePage(myPfId: ''),
            ),
            _buildDrawerTile(
              title: 'Tee Times',
              icon: Icons.golf_course_outlined,
              destinationScreen: const SelcetBookingClass(
                userId: '',
              ),
            ),
            _buildDrawerTile(
              title: 'My Transactions',
              icon: Icons.receipt_long,
              destinationScreen: const MyTransactionPage(
                myTransId: '',
              ), // Placeholder
            ),
            _buildDrawerTile(
              title: 'My Reservations',
              icon: Icons.calendar_month_sharp,
              destinationScreen: const MyReservationPage(
                myRsvId: '',
              ), // Placeholder
            ),
            _buildDrawerTile(
              title: 'My Wallet',
              icon: Icons.shopping_cart,
              destinationScreen: const TabCardScreenPage(
                tabcardId: '',
              ), // Placeholder
            ),
            _buildDrawerTile(
              title: 'Gift Card',
              icon: Icons.card_giftcard,
              destinationScreen: const TabCardScreenPage(
                tabcardId: '',
              ), // Placeholder
            ),

            // Logout Button
            Container(
              margin: const EdgeInsets.only(top: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Stack(children: [
                      SizedBox(
                        width: 260,
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
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF244065),
                            elevation: 5,
                          ),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                          top: 14,
                          right: 12,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFffffff),
                            size: 20,
                          )),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
