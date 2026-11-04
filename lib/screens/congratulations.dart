import 'package:driver_pos/theme/app_theme.dart';
// ignore_for_file: deprecated_member_use, use_build_context_synchronously
// import 'package:flutter/cupertino.dart';
import 'package:driver_pos/screens/selcet_booking_class.dart';
import 'package:driver_pos/services/deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';

class CongratulationsPage extends StatefulWidget {
  final String cngsId;
  const CongratulationsPage({super.key, required this.cngsId});

  @override
  State<StatefulWidget> createState() => CongratulationsPageState();
}

class CongratulationsPageState extends State<CongratulationsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      DeepLinkService.clearCachedLink();
    });
    // DeepLinkService.clearCachedLink();

    // Add any initialization logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.cngsId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          // Handle navigation logic
        },
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(),
              child: Container(
                color: AppColors.pageBackground,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 80,
                        height: 80,
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Center(
                            child: Icon(
                              Icons.event_available,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Congratulations!",
                        style: GoogleFonts.poppins(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Your payment has been received",
                        style: GoogleFonts.poppins(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      const SizedBox(
                        height: 11,
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Book Now tapped!");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelcetBookingClass(
                                userId: '',
                              ),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 3,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 7),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Back to Teesheet",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }
}
