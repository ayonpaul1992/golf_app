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
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _dropdownOverlay;
  String _selectedFilter = "This month";
  final List<String> _filterOptions = [
    "Today",
    "This week",
    "This month",
    "This year"
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  int? editingIndex;
  int selectedIndex = 0; // index 0 is "All"

  double _getDropdownOffset() {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero).dy ?? 100;
  }

  void _toggleDropdown() {
    if (_dropdownOverlay == null) {
      final overlay = Overlay.of(context);
      _dropdownOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: 10,
          right: 20,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, 30),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 0), // Adjust horizontal padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFB2C1C0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filterOptions.map((option) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = option;
                        });
                        _removeDropdown();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12),
                        child: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: option == _selectedFilter
                                ? Color(0xFF669933)
                                : Color(0xFF244065),
                            fontWeight: option == _selectedFilter
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );
      overlay.insert(_dropdownOverlay!);
      setState(() {}); // To refresh the icon
    } else {
      _removeDropdown();
    }
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    setState(() {}); // Refresh icon
  }

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
              CompositedTransformTarget(
                link: _layerLink,
                child: Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Transactions",
                        style: GoogleFonts.poppins(
                            color: Color(0xFF244065),
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: _toggleDropdown,
                        child: Row(
                          children: [
                            Text(
                              "Filter by:",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6E7373)),
                            ),
                            SizedBox(width: 5),
                            Text(
                              _selectedFilter,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF244065)),
                            ),
                            Icon(
                              _dropdownOverlay == null
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_up_rounded,
                              size: 22,
                              color: Color(0xFF669933),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
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
                                        width: 17.88, // optional
                                        height: 13.75, // optional
                                        fit: BoxFit.cover, // optional
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
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
                height: 15,
              ),
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
                                        width: 23, // optional
                                        height: 23, // optional
                                        fit: BoxFit.cover, // optional
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
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
              SizedBox(
                height: 15,
              ),
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
                                        width: 17.88, // optional
                                        height: 13.75, // optional
                                        fit: BoxFit.cover, // optional
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
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
