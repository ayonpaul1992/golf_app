import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gulf_app/extras/GardenSideTeesheetPage.dart';
import 'package:gulf_app/extras/history.dart';
import 'package:gulf_app/extras/self_checking.dart';
import 'package:gulf_app/extras/store.dart';
import 'package:gulf_app/extras/myKart.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const CustomBottomNavBar({super.key, required this.selectedIndex});

  @override
// ignore: library_private_types_in_public_api
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String memberName = '';
  int? hoverIndex;

  @override
  void initState() {
    super.initState();
    _loadMemberName();
  }

  Future<void> _loadMemberName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      memberName = prefs.getString('user_name') ?? 'Guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // Show nothing until SharedPreferences is loaded
        }

        List<Map<String, dynamic>> items = [
          {
            'icon': 'assets/images/ftr_teesheet.png',
            'label': 'Tee Sheet',
            'route': const GardenSideTeesheetPage(
              userId: '',
              gsTeeSheetuserId: '',
            )
          },
          {
            'icon': 'assets/images/ftr_hstry.png',
            'label': 'History',
            'route': const HistoryPage(
              history: '',
              historyId: '',
            )
          },
          {
            'icon': 'assets/images/self_chkng.png',
            'label': 'Self Checking',
            'route': const SelfCheckingPage(
              selfcheck: '',
              selfChkId: '',
            )
          },
          {
            'icon': 'assets/images/ftr_str.png',
            'label': 'Store',
            'route': const StorePage(
              storeName: '',
              storeId: '',
            )
          },
          {
            'icon': 'assets/images/ftr_kart.png',
            'label': 'Settings',
            'route': const MyKartPage(
              myCart: '',
              myKartId: '',
            )
          },
        ];

        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      hoverIndex = index;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      hoverIndex = null;
                    });
                  },
                  child: InkWell(
                    onTap: () {
                      if (widget.selectedIndex != index) {
                        if (items[index]['route'] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${items[index]['label']} screen is under development!",
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => items[index]['route']!,
                            ),
                          );
                        }
                      }
                    },
                    child: SizedBox(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                // Use AnimatedContainer for background and icon
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: hoverIndex == index
                                      ? Color(0xFF9ECF9A)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  items[index]['icon']!,
                                  fit: BoxFit.contain,
                                  width: 17,
                                  color: hoverIndex == index
                                      ? Colors.white
                                      : (widget.selectedIndex == index
                                          ? Color(0xFF244065)
                                          : const Color(0xFF244065)),
                                ),
                              ),
                            ],
                          ),
                          AnimatedOpacity(
                            // Use AnimatedOpacity for text fade
                            duration: const Duration(milliseconds: 200),
                            opacity: hoverIndex == index ? 0.0 : 1.0,
                            child: Text(
                              items[index]['label']!,
                              style: GoogleFonts.poppins(
                                color: widget.selectedIndex == index
                                    ? Color(0xFF648683)
                                    : const Color(0xFF648683),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
