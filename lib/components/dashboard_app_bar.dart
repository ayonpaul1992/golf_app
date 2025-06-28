import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extras/notification.dart';
import '../screens/my_profile.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onBackPressed;
  final VoidCallback? onTitleTapped;
  // final String dshbId;
  final bool showLeading;

  const DashboardAppBar({
    super.key,
    required this.scaffoldKey,
    // required this.dshbId,
    this.onBackPressed,
    this.onTitleTapped,
    this.showLeading = true, required dshbId,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: showLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9ECF9A)),
              onPressed: onBackPressed ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      // Optionally handle the case when there's nothing to pop
                    }
                  },
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
      centerTitle: true, // This centers the title
      title: Text(
        'Dashboard',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: const Color(0xFF244065),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      actions: [
        // Container(
        //   padding: EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
        //   decoration: BoxDecoration(
        //     color: Color(0xFF244065),
        //     borderRadius: BorderRadius.circular(50),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Image.asset("assets/images/mmbr_arw.png"),
        //       SizedBox(
        //         width: 5,
        //       ),
        //       Text(
        //         "Platinum",
        //         style: GoogleFonts.poppins(
        //             fontWeight: FontWeight.w500,
        //             fontSize: 11.5,
        //             color: Color(0xFFFFFFFF)),
        //       )
        //     ],
        //   ),
        // ),
        // const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage(
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
                    builder: (context) => const MyProfilePage(
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
