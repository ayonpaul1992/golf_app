import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extras/notification.dart';
import '../screens/my_profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    this.showLeading = true,
    required dshbId,
  });

  @override
  Widget build(BuildContext context) {
    final storage = const FlutterSecureStorage();

    return FutureBuilder<List<String?>>(
      future: Future.wait([
        storage.read(key: 'profilePic'),
      ]),
      builder: (context, snapshot) {
        String title = 'Dashboard';
        String? profilePic = snapshot.data?[0] ?? '';

        return AppBar(
          backgroundColor: Colors.white,
          leading: showLeading
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Color(0xFF9ECF9A)),
                  onPressed: onBackPressed ??
                      () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                )
              : IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xFF9ECF9A),
                  ),
                  onPressed: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
          centerTitle: true,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF244065),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(
                      myNtfId: '',
                    ),
                  ),
                );
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
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(20, 20),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: CircleAvatar(
                radius: 11.5,
                backgroundImage: profilePic.isNotEmpty
                    ? NetworkImage(profilePic)
                    : const AssetImage('assets/images/user-svgrepo-com.png')
                        as ImageProvider,
                backgroundColor: Colors.transparent,
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
