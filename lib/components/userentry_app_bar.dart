import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class UserentryAppbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onBackPressed;
  final String userId;
  final bool showLeading;

  const UserentryAppbar({
    super.key,
    required this.userId,
    this.onBackPressed,
    this.showLeading = true, required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: showLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      centerTitle: true, // ✅ Correct placement and spelling
      title: Text(
        'driver.io',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Color(0xFF244065),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
