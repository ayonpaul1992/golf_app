import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gulf_app/screens/membership_screen.dart';
import '../extras/notification.dart';
import '../screens/my_profile.dart';
import '../screens/selcet_booking_class.dart'; // Adjust the path as needed

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onBackPressed;
  final VoidCallback? onTitleTapped;
  final String userId;
  final bool showLeading;
  final bool isOnProfilePage; // Add this if you want to check the current page

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.userId,
    this.onBackPressed,
    this.onTitleTapped,
    this.showLeading = true,
    this.isOnProfilePage = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final storage = const FlutterSecureStorage();

    return FutureBuilder<List<String?>>(
      future: Future.wait([
        storage.read(key: 'golfCourseLogo'),
        storage.read(key: 'membership'),
        storage.read(key: 'profilePic'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // or a loading indicator
        }

        String logoUrl = snapshot.data![0] ?? '';
        String membershipType = snapshot.data![1] ?? 'Platinum'; // fallback
        String profilePic = snapshot.data![2] ?? '';

        return AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading:
              false, // Prevent default single leading button
          titleSpacing: 0, // Remove extra padding before title

          title: Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back_ios, color: Color(0xFF9ECF9A)),
                onPressed: onBackPressed ??
                    () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFF9ECF9A)),
                onPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                },
              ),
              Expanded(
                child: InkWell(
                  onTap: onTitleTapped ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SelcetBookingClass(userId: ''),
                          ),
                        );
                      },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 41),
                    child: Image(
                      image: logoUrl.isNotEmpty
                          ? NetworkImage(logoUrl)
                          : const AssetImage('assets/images/main_logo.png')
                              as ImageProvider,
                      width: 41,
                      height: 41,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),

          actions: [
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const MembershipScreen(mmbspId: ''),
                //   ),
                // );
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF244065),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: FittedBox(
                  child: Row(
                    children: [
                      Image.asset("assets/images/mmbr_arw.png"),
                      const SizedBox(width: 5),
                      Text(
                        membershipType,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 11.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(myNtfId: ''),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(20, 20),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Image.asset(
                'assets/images/bell-svgrepo-com.png',
                height: 20,
                width: 20,
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                if (!isOnProfilePage) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfilePage(myPfId: ''),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(20, 20),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: CircleAvatar(
                radius: 11.5,
                backgroundColor: Colors.transparent,
                backgroundImage: profilePic.isNotEmpty
                    ? NetworkImage(profilePic)
                    : const AssetImage('assets/images/user-svgrepo-com.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(width: 20),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
