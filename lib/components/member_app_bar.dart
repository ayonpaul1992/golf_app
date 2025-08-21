import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String golfCourseName = '';
  String golfCourseLogo = '';

  bool isLoading = false;

  // store all golf courses
  List<Map<String, dynamic>> allGolfCourses = [];

  @override
  void initState() {
    super.initState();
    _fetchGolfCourse();
    _fetchAllGolfCourses(); // Uncomment if you want to fetch membership on init
  }

  Future<void> _fetchGolfCourse() async {
    final String? name = await secureStorage.read(key: 'golfCourseName');
    final String? logo = await secureStorage.read(key: 'golfCourseLogo');

    if (name != null) {
      setState(() {
        golfCourseName = name;
        golfCourseLogo = logo ?? '';
      });
    } else {
      setState(() {
        golfCourseName = '';
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchAllGolfCourses() async {
    // setState(() {
    //   isLoading = true;
    // });
    try {
      final String baseUrl = 'https://api.dev.driverpos.io/api/v1';
      final String? token = await secureStorage.read(key: 'accessToken');

      final response = Uri.parse(
        '$baseUrl/golfCourse/business-golfcourses/eHIq4K',
      ).resolveUri(Uri());

      // Example using http package:
      final httpResponse = await http.get(response, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(httpResponse.body) as Map<String, dynamic>;
        setState(() {
          allGolfCourses = List<Map<String, dynamic>>.from(data['data']);
        });
        print(data);
        // return data;
      } else {
        return null;
      }
      // return null; // Remove this and uncomment above for real API
    } catch (e) {
      // Handle error
      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return null;
  }

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
                            color:
                                const Color(0xFFE2E4E4), // 👈 your border color
                            width: 1.5, // 👈 border width
                          ),
                        ),
                        child: Center(
                          child: Image.network(
                            golfCourseLogo.isNotEmpty
                                ? golfCourseLogo
                                : 'assets/images/mmbr_poplogo.png',
                            width: 15,
                            height: 15,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/ftr_teesheet.png",
                                width: 15,
                                height: 15,
                              );
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        golfCourseName,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF244065),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        debugPrint("$golfCourseName selected");
                        _removeDropdown();
                      },
                    ),
                    const Divider(
                      color: Color(0xFFE2E4E4),
                    ),
                    ...allGolfCourses.map((course) {
                      if (course['name'] == golfCourseName) {
                        return const SizedBox.shrink();
                      }
                      final String name = course['name'] ?? '';
                      final String logo = course['logo'] ?? '';
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: const Color(0xFFE2E4E4),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: logo.isNotEmpty
                                    ? Image.network(
                                        logo,
                                        width: 15,
                                        height: 15,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            "assets/images/ftr_teesheet.png",
                                            width: 15,
                                            height: 15,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        "assets/images/ftr_teesheet.png",
                                        width: 15,
                                        height: 15,
                                      ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF244065),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              debugPrint("$name selected");
                              _removeDropdown();
                            },
                          ),
                          const Divider(
                            color: Color(0xFFE2E4E4),
                          ),
                        ],
                      );
                    }),
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
            golfCourseName,
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
                child: golfCourseLogo.isNotEmpty
                    ? Image.network(
                        golfCourseLogo,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/mmbr_poplogo.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          );
                        },
                      )
                    : Image.asset(
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
