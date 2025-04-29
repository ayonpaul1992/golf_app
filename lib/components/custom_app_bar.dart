import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extras/notification.dart';
import '../extras/my_profile.dart';
import '../screens/selcet_booking_class.dart'; // Adjust the path as needed

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onBackPressed;
  final VoidCallback? onTitleTapped;
  final String userId;
  final bool showLeading;

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.userId,
    this.onBackPressed,
    this.onTitleTapped,
    this.showLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: showLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9ECF9A)),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : IconButton(
              // Display the menu icon when showLeading is false
              icon: const Icon(Icons.menu,
                  color: Color(
                      0xFF9ECF9A)), // Use the menu icon and set its color to red
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
      title: InkWell(
        onTap: onTitleTapped ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => selcetBookingClass(
                      userId: userId), // Corrected class name
                ),
              );
            },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 41),
          child: Image.asset(
            "assets/images/main_logo.png",
            width: 41,
            height: 41,
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        Container(
          padding: EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
          decoration: BoxDecoration(
            color: Color(0xFF244065),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/mmbr_arw.png"),
              SizedBox(
                width: 5,
              ),
              Text(
                "Platinum",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 11.5,
                    color: Color(0xFFFFFFFF)),
              )
            ],
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => notificationPage(
                          myNtfId: '',
                        )));
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(20, 20),
            padding: EdgeInsets.zero,
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => myProfilePage(
                      myPfId: '',
                    )));
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(20, 20),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Image.asset(
            'assets/images/user-svgrepo-com.png',
            height: 20,
            width: 20,
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
