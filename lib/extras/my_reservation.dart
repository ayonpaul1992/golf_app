import 'package:driver_pos/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class MyReservationPage extends StatefulWidget {
  final String myRsvId;
  const MyReservationPage({super.key, required this.myRsvId});

  @override
  State<StatefulWidget> createState() => MyReservationPageState();
}

class MyReservationPageState extends State<MyReservationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  final searchBarText = TextEditingController();
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
      barrierColor: Colors.black.withValues(alpha: 0.5),
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
                    color: Colors.black.withValues(alpha: 0.2),
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
                  //   selectionColor: AppColors.primary,
                  //   todayHighlightColor: AppColors.primary,
                  //   headerStyle: DateRangePickerHeaderStyle(
                  //     backgroundColor: Colors.transparent,
                  //     textStyle: GoogleFonts.poppins(
                  //         color: AppColors.textBody,
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
                    initialSelectedDate: _selectedDate,
                    // <- ADD THIS LINE
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: AppColors.primary,
                    todayHighlightColor: AppColors.primary,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: GoogleFonts.poppins(
                        color: AppColors.textBody,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: AppColors.primary),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: AppColors.ink,
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
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                width: 1.5, color: AppColors.primary),
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
  int selectedIndex = 0; // index 0 is "All"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myRsvId, // ✅ Pass the correct userId
        showLeading: true, // ✅ Set to true to show the back button
        onBackPressed: () {
          Navigator.pop(context); // Optional: customize back behavior if needed
        },
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
      ),
      body: Container(
        color: AppColors.pageBackground,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              // Container(
              //   child: SingleChildScrollView(
              //       scrollDirection: Axis.horizontal,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Container(
              //             width: 40,
              //             height: 1,
              //             color: AppColors.border,
              //           ),
              //           SizedBox(
              //             width: 10,
              //           ),
              //           Text(
              //             "My Reservation",
              //             style: GoogleFonts.poppins(
              //                 color: AppColors.ink,
              //                 fontSize: 17,
              //                 fontWeight: FontWeight.w600),
              //           ),
              //           SizedBox(
              //             width: 10,
              //           ),
              //           Container(
              //             width: 40,
              //             height: 1,
              //             color: AppColors.border,
              //           ),
              //         ],
              //       )),
              // ),
              // SizedBox(
              //   height: 15,
              // ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded(
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Container(
                    //           decoration: BoxDecoration(
                    //             color: Colors.white,
                    //             borderRadius: BorderRadius.circular(50),
                    //             boxShadow: [
                    //               BoxShadow(
                    //                 color: Colors.black.withValues(alpha: 0.1),
                    //                 blurRadius: 6,
                    //                 offset: Offset(0, 3),
                    //               ),
                    //             ],
                    //             border: Border.all(
                    //               color: AppColors.border,
                    //               width: 1,
                    //             ),
                    //           ),
                    //           child: TextField(
                    //             controller: searchBarText,
                    //             decoration: InputDecoration(
                    //               hintText: 'Search here',
                    //               hintStyle: const TextStyle(
                    //                 color: AppColors.textMuted,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //               border: InputBorder.none,
                    //               prefixIcon: const Icon(Icons.search,
                    //                   color: AppColors.textMuted),
                    //               contentPadding: const EdgeInsets.symmetric(
                    //                   vertical: 14), // vertical centering
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(50),
                    //                 borderSide: const BorderSide(
                    //                   color: AppColors.primary,
                    //                 ),
                    //               ),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(50),
                    //                 borderSide: const BorderSide(
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //               filled: true,
                    //               fillColor: Colors.white,
                    //             ),
                    //             style: GoogleFonts.poppins(
                    //               color: AppColors.ink,
                    //               fontWeight: FontWeight.w600,
                    //               fontSize: 14,
                    //             ),
                    //           ),
                    //         ),
                    //         if (nomineedobError != null)
                    //           Padding(
                    //             padding:
                    //                 const EdgeInsets.only(top: 6.0, left: 12),
                    //             child: Text(
                    //               nomineedobError!,
                    //               style: const TextStyle(
                    //                 color: Colors.red,
                    //                 fontSize: 12,
                    //               ),
                    //             ),
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Text(
                      "My Reservation",
                      style: GoogleFonts.poppins(
                          color: AppColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: editingIndex == null
                              ? () => _showDatePicker(context)
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.textSubtle,
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          "Filter by:",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "This month",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: AppColors.accent,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10), // Correct usage
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "My Booking Details",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 15),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Customize the color
                            width: 1.0, // Customize the width
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                Image.asset("assets/images/bkd1.png"),
                                Positioned(
                                  top: 9.5,
                                  left: 9.5,
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Image.asset(
                                          "assets/images/bkdu1.png"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
// Navigator.push(context, route)
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.surfaceTint,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Center(
                                        child: Text(
                                          "Checked In",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Add your cancel logic here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5), // vertical padding
                                    minimumSize: const Size(
                                        0, 0), // disables default min height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Golf Course: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Eden Gardens Golf Course",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Date: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Wed, Apr 16",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Time: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "6:30AM",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Amount: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "\$23.15",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Holes: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "18",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Players: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "1",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Carts: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "0",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 15, top: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Customize the color
                            width: 1.0, // Customize the width
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                Image.asset("assets/images/bkd2.png"),
                                Positioned(
                                  top: 9.5,
                                  left: 9.5,
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Image.asset(
                                          "assets/images/bkdu2.png"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
// Navigator.push(context, route)
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.errorSurface,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Center(
                                        child: Text(
                                          "Booked",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Add your cancel logic here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5), // vertical padding
                                    minimumSize: const Size(
                                        0, 0), // disables default min height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Golf Course: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Salt Lake Golf Course",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Date: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Wed, Apr 16",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Time: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "6:30AM",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Amount: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "\$48.15",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Holes: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "18",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Players: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "1",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Carts: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "0",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 15, top: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                Image.asset("assets/images/bkd3.png"),
                                Positioned(
                                  top: 9.5,
                                  left: 9.5,
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Image.asset(
                                          "assets/images/bkdu3.png"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
// Navigator.push(context, route)
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.errorSurface,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Center(
                                        child: Text(
                                          "Booked",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Add your cancel logic here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5), // vertical padding
                                    minimumSize: const Size(
                                        0, 0), // disables default min height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Golf Course: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Eden Gardens Golf Course",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Date: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Wed, Apr 16",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Time: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "6:30AM",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Amount: ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "\$23.15",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Holes: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "18",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Players: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "1",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Carts: ",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "0",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.ink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          )),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
