import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class MyTransactionPage extends StatefulWidget {
  final String myTransId;
  const MyTransactionPage({super.key, required this.myTransId});

  @override
  State<StatefulWidget> createState() => MyTransactionPageState();
}

class MyTransactionPageState extends State<MyTransactionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
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
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20), bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
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
                    initialSelectedDate: _selectedDate,
                    // <- ADD THIS LINE
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: Color(0xFF9ECF9A),
                    todayHighlightColor: Color(0xFF9ECF9A),
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: GoogleFonts.poppins(
                        color: Color(0xFF3F4B4B),
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
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                width: 1.5, color: Color(0xFF9ECF9A)),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: Color(0xFF244065),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
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
                          backgroundColor: Color(0xFF9ECF9A),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  int? editingIndex;
  int selectedIndex = 0; // index 0 is "All"
  String _activeLabel = "All"; // "All" is active by default
  final List<String> filters = ["All", "Completed", "Cancelled", "Failed"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.myTransId, // ✅ Pass the correct userId
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
        color: Color(0xFFFAFCFA),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
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
              //             color: Color(0xFFB2C1C0),
              //           ),
              //           SizedBox(
              //             width: 10,
              //           ),
              //           Text(
              //             "My Transaction",
              //             style: GoogleFonts.poppins(
              //                 color: Color(0xFF244065),
              //                 fontSize: 22,
              //                 fontWeight: FontWeight.w600),
              //           ),
              //           SizedBox(
              //             width: 10,
              //           ),
              //           Container(
              //             width: 40,
              //             height: 1,
              //             color: Color(0xFFB2C1C0),
              //           ),
              //         ],
              //       )),
              // ),
              // SizedBox(
              //   height: 15,
              // ),
              Container(
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
                    //                 color: Colors.black.withOpacity(0.1),
                    //                 blurRadius: 6,
                    //                 offset: Offset(0, 3),
                    //               ),
                    //             ],
                    //             border: Border.all(
                    //               color: Color(0xFFB2C1C0),
                    //               width: 1,
                    //             ),
                    //           ),
                    //           child: TextField(
                    //             controller: searchBarText,
                    //             decoration: InputDecoration(
                    //               hintText: 'Search here',
                    //               hintStyle: const TextStyle(
                    //                 color: Color(0xFF6E7373),
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //               border: InputBorder.none,
                    //               prefixIcon: const Icon(Icons.search,
                    //                   color: Color(0xFF6E7373)),
                    //               contentPadding: const EdgeInsets.symmetric(
                    //                   vertical: 14), // vertical centering
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(50),
                    //                 borderSide: const BorderSide(
                    //                   color: Color(0xFF9ECF9A),
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
                    //               color: Color(0xFF244065),
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
                          color: Color(0xFF244065),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: editingIndex == null
                              ? () => _showDatePicker(context)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              color: Color(0xFF648683),
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          "Filter by:",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6E7373)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "This month",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF244065)),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: Color(0xFF669933),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              // Container(
              //   width: double.infinity,
              //   child: Center(
              //     child: Wrap(
              //       alignment: WrapAlignment.center,
              //       spacing: 8,
              //       runSpacing: 8,
              //       children: filters.map((label) {
              //         final bool isActive = _activeLabel == label;
              //         return InkWell(
              //           onTap: () {
              //             setState(() {
              //               _activeLabel = label;
              //             });
              //           },
              //           child: Container(
              //             decoration: BoxDecoration(
              //               color: isActive ? Color(0xFF9ECF9A) : Colors.white,
              //               borderRadius: BorderRadius.circular(20),
              //               border: Border.all(
              //                 color: Color(0xFF9ECF9A),
              //                 width: 1,
              //               ),
              //             ),
              //             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              //             child: Text(
              //               label,
              //               style: GoogleFonts.poppins(
              //                 color: isActive ? Colors.white : Color(0xFF244065),
              //                 fontWeight: FontWeight.w600,
              //                 fontSize: 13,
              //               ),
              //             ),
              //           ),
              //         );
              //       }).toList(),
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 15,
              // ),
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Color(0xFFE9EBEB), width: 1)),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF648683),
                                      size: 20,
                                    ),
                                    Text(
                                      _dateController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6E7373),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Sale ID: ",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "PO-503",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                                1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Green Fees",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$119.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Products (10)",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$29.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Total",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$148.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                spacing: 5,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Payment type: ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6E7373),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/ccard.png',
                                        width: 17.88,          // optional
                                        height: 13.75,         // optional
                                        fit: BoxFit.cover,   // optional
                                      ),
                                      SizedBox(width: 5,),
                                      Text(
                                        "Credit Card ",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF244065),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "ending in 5858",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF6E7373),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(15),
                          border:
                          Border.all(color: Color(0xFFE9EBEB), width: 1)),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF648683),
                                      size: 20,
                                    ),
                                    Text(
                                      _dateController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6E7373),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Sale ID: ",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "PO-503",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Green Fees",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$119.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Products (10)",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$29.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Total",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$148.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                spacing: 5,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Payment type: ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6E7373),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/cashc.png',
                                        width: 23,          // optional
                                        height: 23,         // optional
                                        fit: BoxFit.cover,   // optional
                                      ),
                                      SizedBox(width: 5,),
                                      Text(
                                        "Cash ",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF244065),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(15),
                          border:
                          Border.all(color: Color(0xFFE9EBEB), width: 1)),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF648683),
                                      size: 20,
                                    ),
                                    Text(
                                      _dateController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6E7373),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Sale ID: ",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "PO-503",
                                      style: GoogleFonts.poppins(
                                          color: Color(0xFF244065),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Green Fees",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$119.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Products (10)",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$29.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Total",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF244065),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$148.00",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF669933),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Divider(
                            color: Color(0xFFE9EBEB), // Set your desired color
                            thickness:
                            1.5, // Optional: controls the line thickness
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 12),
                            child: Column(children: [
                              Row(
                                spacing: 5,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Payment type: ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6E7373),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/ccard.png',
                                        width: 17.88,          // optional
                                        height: 13.75,         // optional
                                        fit: BoxFit.cover,   // optional
                                      ),
                                      SizedBox(width: 5,),
                                      Text(
                                        "Credit Card ",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF244065),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "ending in 5858",
                                        style: GoogleFonts.poppins(
                                            color: Color(0xFF6E7373),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          )),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Color(0xFF9ECF9A),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 1,
        ),
      ),
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFF6E7373),
        fontSize: 14,
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF9ECF9A), width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: Color(0xFF244065),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
