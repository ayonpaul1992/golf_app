import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberShipAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onBackPressed;
  final VoidCallback? onTitleTapped;
  final String mmbspId;
  final bool showLeading;

  const MemberShipAppBar({
    super.key,
    required this.scaffoldKey,
    required this.mmbspId,
    this.onBackPressed,
    this.onTitleTapped,
    this.showLeading = true,
  });

  @override
  State<MemberShipAppBar> createState() => _MemberShipAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MemberShipAppBarState extends State<MemberShipAppBar> {
  bool _isExpanded = false;
  OverlayEntry? _dropdownOverlay;

  void _toggleDropdown(BuildContext context) {
    if (_isExpanded) {
      _removeDropdown();
    } else {
      _showDropdown(context);
    }
  }

  void _showDropdown(BuildContext context) {
    final RenderBox appBarBox = context.findRenderObject() as RenderBox;
    appBarBox.localToGlobal(Offset.zero);

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 🔹 Background overlay to detect taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeDropdown(); // close dropdown if tap outside
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

          // 🔹 Your dropdown
          Positioned(
            top: 107,
            left: 10,
            right: 10,
            child: Material(
              elevation: 4,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // 👈 Rounded corners
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(
                                  0xFFE2E4E4), // 👈 your border color
                              width: 1.5, // 👈 border width
                            ),
                          ),
                          child: Center(
                              child: Image.asset(
                                  "assets/images/ftr_teesheet.png",
                                  width: 15,
                                  height: 15))),
                      title: Text("Plan 1",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )),
                      onTap: () {
                        debugPrint("Plan 1 selected");
                        _removeDropdown();
                      },
                    ),
                    const Divider(color: Color(0xFFE2E4E4)),
                    ListTile(
                      leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(
                                  0xFFE2E4E4), // 👈 your border color
                              width: 1.5, // 👈 border width
                            ),
                          ),
                          child: Center(
                              child: Image.asset(
                                  "assets/images/ftr_teesheet.png",
                                  width: 15,
                                  height: 15))),
                      title: Text("Plan 2",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )),
                      onTap: () {
                        debugPrint("Plan 2 selected");
                        _removeDropdown();
                      },
                    ),
                    const Divider(color: Color(0xFFE2E4E4)),
                    ListTile(
                      leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(
                                  0xFFE2E4E4), // 👈 your border color
                              width: 1.5, // 👈 border width
                            ),
                          ),
                          child: Center(
                              child: Image.asset(
                                  "assets/images/ftr_teesheet.png",
                                  width: 15,
                                  height: 15))),
                      title: Text("Plan 3",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )),
                      onTap: () {
                        debugPrint("Plan 3 selected");
                        _removeDropdown();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    setState(() => _isExpanded = true);
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: widget.showLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9ECF9A)),
              onPressed: widget.onBackPressed ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF9ECF9A)),
              onPressed: () {
                widget.scaffoldKey.currentState?.openDrawer();
              },
            ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'Jester Park Golf Course',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF244065),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Membership Plans',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6E7373),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => _toggleDropdown(context),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: Image.asset(
                  'assets/images/mmbr_poplogo.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_sharp
                    : Icons.keyboard_arrow_down_sharp,
                size: 20,
                color: const Color(0xFF669933),
              ),
              const SizedBox(width: 10),
            ],
          ),
        )
      ],
    );
  }
}
