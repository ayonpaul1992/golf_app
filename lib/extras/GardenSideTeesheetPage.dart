import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import '/screens/tee_sheet_details.dart';
import 'package:intl/intl.dart';

class GardenSideTeesheetPage extends StatefulWidget {
  final String gsTeeSheetuserId; // ✅ Add this
  const GardenSideTeesheetPage(
      {super.key,
      required this.gsTeeSheetuserId,
      required String userId}); // ✅ Fix constructor

  @override
  State<GardenSideTeesheetPage> createState() => _GardenSideTeesheetPageState();
}

class _GardenSideTeesheetPageState extends State<GardenSideTeesheetPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;
  String? nomineedobError;
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
  }

  void _showDatePicker(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: const FractionalOffset(0.5, 0.42),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20), bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SfDateRangePicker(
                  //   selectionMode: DateRangePickerSelectionMode.single,
                  //   backgroundColor: Colors.white,
                  //   selectionColor: Color(0xFF9ECF9A),
                  //   todayHighlightColor: Color(0xFF9ECF9A),
                  //   headerStyle: DateRangePickerHeaderStyle(
                  //     backgroundColor: Colors.transparent,
                  //     textStyle: GoogleFonts.poppins(
                  //         color: Color(0xFF3F4B4B),
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.w600),
                  //   ),
                  //   onSelectionChanged:
                  //       (DateRangePickerSelectionChangedArgs args) {
                  //     setState(() {
                  //       _selectedDate = args.value;
                  //     });
                  //   },
                  // ),
                  SfDateRangePicker(
                    initialSelectedDate: _selectedDate, // <- ADD THIS LINE
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: const Color(0xFF9ECF9A),
                    todayHighlightColor: const Color(0xFF9ECF9A),
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: GoogleFonts.poppins(
                        color: const Color(0xFF3F4B4B),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      setState(() {
                        _selectedDate = args.value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          if (_selectedDate != null) {
                            final formattedDate = DateFormat("MMM dd, yyyy")
                                .format(_selectedDate!);
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF9ECF9A),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "OK",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int? editingIndex;
  int selectedPlayer = 1;
  String selectedHole = "9";
  int selectedIndex = 0; // index 0 is "All"
  bool showDropdown = false;
  OverlayEntry? _dropdownOverlay;
  bool _isDropdownVisible = false;
  final GlobalKey _iconKey = GlobalKey();
  void _toggleDropdown(BuildContext context) {
    if (_isDropdownVisible) {
      _dropdownOverlay?.remove();
      _dropdownOverlay = null;
      setState(() {
        _isDropdownVisible = false;
      });
      return;
    }

    final RenderBox renderBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF9ECF9A), width: 1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up,
                      size: 20, color: Color(0xFF244065)),
                  onPressed: () => _toggleDropdown(context),
                ),
                ...List.generate(6, (index) {
                  int playerNum = index + 5;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlayer = playerNum;
                      });
                      _toggleDropdown(context);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: Text(
                        "$playerNum",
                        style: GoogleFonts.poppins(
                          color: selectedPlayer == playerNum
                              ? const Color(0xFF9ECF9A)
                              : const Color(0xFF244065),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    setState(() {
      _isDropdownVisible = true;
    });
  }

  @override
  void dispose() {
    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.gsTeeSheetuserId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          color: const Color(0xFFFAFCFA),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Date",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6E7373),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Custom Date",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6E7373),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 7),
                              GestureDetector(
                                onTap: editingIndex == null
                                    ? () => _showDatePicker(context)
                                    : null,
                                child: Container(
                                  child: const Row(
                                    children: [
                                      // Text(
                                      //   _dateController.text.isNotEmpty
                                      //       ? _dateController.text
                                      //       : "",
                                      //   style: TextStyle(color: Color(0xFF648683), fontSize: 14),
                                      // ),
                                      Icon(Icons.calendar_month_outlined,
                                          color: Color(0xFF648683), size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (nomineedobError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, left: 12),
                          child: Text(
                            nomineedobError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        DateTime date =
                            DateTime.now().add(Duration(days: index));
                        String label = index == 0
                            ? "Today"
                            : DateFormat("EEEE")
                                .format(date); // "Today", "Tue", etc.
                        String formattedDate =
                            DateFormat("MMM dd").format(date); // e.g., Apr 21

                        bool isSelected = _dateController.text ==
                            DateFormat("MMM dd, yyyy").format(date);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                              _dateController.text =
                                  DateFormat("MMM dd, yyyy").format(date);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 15, left: 6, right: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF9ECF9A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Column(
                                children: [
                                  Text(
                                    label,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6E7373),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Players",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF6E7373),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    children: List.generate(4, (index) {
                                      int playerNum = index + 1;
                                      return playerCircle(
                                        "$playerNum",
                                        selectedPlayer == playerNum,
                                        () {
                                          setState(() {
                                            selectedPlayer = playerNum;
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        key: _iconKey,
                                        onPressed: () =>
                                            _toggleDropdown(context),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF244065),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Holes",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF6E7373),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Wrap(
                              spacing: 8,
                              children: ["9", "18"].map((hole) {
                                return playerCircle(
                                  hole,
                                  selectedHole == hole,
                                  () {
                                    setState(() {
                                      selectedHole = hole;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 1,
                            color: const Color(0xFFB2C1C0),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Garden Side Teesheet",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF244065),
                                fontSize: 22,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 40,
                            height: 1,
                            color: const Color(0xFFB2C1C0),
                          ),
                        ],
                      )),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 7,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildButton(
                            label: "All",
                            index: 0,
                            selectedIndex: selectedIndex,
                            onTap: () {
                              setState(() {
                                selectedIndex = 0;
                              });
                            }),
                        _buildButton(
                            label: "Morning",
                            index: 1,
                            selectedIndex: selectedIndex,
                            onTap: () {
                              setState(() {
                                selectedIndex = 1;
                              });
                            }),
                        _buildButton(
                            label: "Midday",
                            index: 2,
                            selectedIndex: selectedIndex,
                            onTap: () {
                              setState(() {
                                selectedIndex = 2;
                              });
                            }),
                        _buildButton(
                            label: "Evening",
                            index: 3,
                            selectedIndex: selectedIndex,
                            onTap: () {
                              setState(() {
                                selectedIndex = 3;
                              });
                            }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Scaffold(
                                    body: Center(child: Text('Demo Page')),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Front",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF244065),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      width: 119,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9ECF9A),
                                        borderRadius: BorderRadius.circular(
                                            50), // Optional
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "6:30AM",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.flag,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "9",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "or",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "18",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "3",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Back",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF244065),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      width: 119,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9ECF9A),
                                        borderRadius: BorderRadius.circular(
                                            50), // Optional
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "6:30AM",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.flag,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "9",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "or",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "18",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "3",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Front",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF244065),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      width: 119,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9ECF9A),
                                        borderRadius: BorderRadius.circular(
                                            50), // Optional
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "6:30AM",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.flag,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "9",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "or",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "18",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "3",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Back",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF244065),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      width: 119,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9ECF9A),
                                        borderRadius: BorderRadius.circular(
                                            50), // Optional
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "6:30AM",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.flag,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "9",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "or",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "18",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "3",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Front",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF244065),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      width: 119,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9ECF9A),
                                        borderRadius: BorderRadius.circular(
                                            50), // Optional
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "6:30AM",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.flag,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "9",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "or",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "18",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "3",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Back",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF244065),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      width: 119,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9ECF9A),
                                        borderRadius: BorderRadius.circular(
                                            50), // Optional
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "6:30AM",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                      child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.flag,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "9",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "or",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    "18",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            spacing: 3,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                spacing: 3,
                                                children: [
                                                  Text(
                                                    "3",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            const Color(0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  // Widget playerCircle(String label, bool isSelected, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 30,
  //       height: 30,
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? Color(0xFF9ECF9A)
  //             : Colors.white, // Active background
  //         borderRadius: BorderRadius.circular(50),
  //         border: Border.all(
  //           color: Color(0xFF9ECF9A),
  //           width: 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 3,
  //             spreadRadius: 1,
  //             offset: Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Center(
  //         child: Text(
  //           label,
  //           style: GoogleFonts.poppins(
  //             color: isSelected
  //                 ? Colors.white
  //                 : Color(0xFF244065), // 👈 Change here
  //             fontWeight: FontWeight.w600,
  //             fontSize: 13,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget playerCircle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9ECF9A) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF9ECF9A),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color:
                isSelected ? Colors.white : const Color(0xFF244065), // 👈 Change here
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF9ECF9A) : Colors.white, // Red for active
          border: Border.all(color: const Color(0xFF9ECF9A), width: 1),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : const Color(0xFF244065),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
