// ignore_for_file: deprecated_member_use, library_prefixes, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:gulf_app/screens/tee_sheet_details.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TeesheetPage extends StatefulWidget {
  final String teesheetPageId;
  final String reservationGroupId;
  final dynamic id;
  final dynamic name;
  final dynamic logoUrl;
  final String userId;

  const TeesheetPage({
    super.key,
    required this.teesheetPageId,
    required this.reservationGroupId,
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.userId,
  });

  @override
  State<TeesheetPage> createState() => TeesheetPageState();
}

class TeesheetPageState extends State<TeesheetPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;
  String? nomineedobError;
  DateTime? _selectedDate;
  dynamic teesheetData;

  dynamic allTeeSheetData = [];

  List<int> teeSheetConfigHoles = [0, 0];
  bool onlineBookingStatus = false;
  int bookingWindowDays = 0;
  int maxPlayers = 0;
  bool allowName = false;
  int bookingsPerDay = 0;
  bool limitExistingGroup = false;

  // List<String> teeSheetConfigHoles = [];

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);

    final queryParameters = {
      'timeOfDay': 'all', // Assuming timeSlot is based on selectedIndex
      'teeSheet': widget.teesheetPageId,
      'reservationGroup': widget.reservationGroupId,
      'date': _selectedDate != null
          ? DateFormat("yyyy-MM-dd").format(_selectedDate!)
          : '',
      // 'holes': selectedHole,
      // 'players': selectedPlayer.toString(),
    };
    _fetchCustomerTeesheets(queryParameters); // Call the API on screen load
  }

  void setTeeSheetConfig(Map<String, dynamic> config) {
    setState(() {
      teeSheetConfigHoles = List<int>.from(config['holes']);
      onlineBookingStatus = config['onlineBookingStatus'];
      bookingWindowDays = config['bookingWindowDays'];
      maxPlayers = config['maxPlayers'];
      allowName = config['allowName'];
      bookingsPerDay = config['bookingsPerDay'];
      limitExistingGroup = config['limitExistingGroup'];
    });
  }

  void setTeeSheetData() {
    setState(() {
      allTeeSheetData = teesheetData;
    });
  }

  void printTeeSheetConfig() {
    print('--- Tee Sheet Config ---');
    print('holes: $teeSheetConfigHoles');
    print('onlineBookingStatus: $onlineBookingStatus');
    print('bookingWindowDays: $bookingWindowDays');
    print('maxPlayers: $maxPlayers');
    print('allowName: $allowName');
    print('bookingsPerDay: $bookingsPerDay');
    print('limitExistingGroup: $limitExistingGroup');
    print('-------------------------');
  }

  void printTeeSheet() {
    for (var slot in allTeeSheetData) {
      print('Time: ${slot['time']}, Players: ${slot['players']}, '
          'Holes: ${slot['holes']}, Green Fee: ${slot['greenFee']}, '
          'Cart Fee: ${slot['cartFee']}, Group Customers: ${slot['groupCustomers']}');
    }
  }

  Future<void> _fetchCustomerTeesheets(Map<String, dynamic> params) async {
    setState(() {
      isLoading = true;
    });
    // Always dispose the old one
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();

    String token = await secureStorage.read(key: 'accessToken') ?? '';

    socket?.clearListeners(); // ✅ clear all previous .on() handlers
    socket?.disconnect();
    socket?.destroy();
    socket = null;

    socket?.dispose();

    socket = IO.io('https://api.dev.driverpos.io', <String, dynamic>{
      'transports': ['websocket'],
      'timeout': 5000,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'auth': {
        'token': token, // ✅ this matches the React structure
      },
    });

    socket!.onConnect((_) {
      socket!.emit("/customerTeesheet", params);
    });

    socket!.off("/customerTeesheet");

    socket!.on("/customerTeesheet", (data) {
      final innerData = data['data']; // Extract the inner 'data' object
      final teeSheetConfig = data['teeSheetConfig']; // Get config

      setState(() {
        teesheetData = innerData;
        setTeeSheetConfig(teeSheetConfig);
        setTeeSheetData();
        isLoading = false;
      });
    });

    socket!.onConnectError((err) => print('❌ Connect error: $err'));
    socket!.onError((err) => print('❌ General error: $err'));
    socket!.onDisconnect((_) => print('🔌 Socket disconnected'));

    socket!.connect();
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
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
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
                  SfDateRangePicker(
                    initialSelectedDate: _selectedDate,
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: Color(0xFF9ECF9A),
                    todayHighlightColor: Color(0xFF9ECF9A),
                    minDate: DateTime.now(), // Set your desired start date
                    maxDate: DateTime.now().add(
                      Duration(days: bookingWindowDays - 1),
                    ), // Set your desired end date
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

  int? editingIndex;
  int selectedPlayer = 1;
  String selectedHole = "9";
  int selectedIndex = 0; // index 0 is "All"
  bool showDropdown = false;
  OverlayEntry? _dropdownOverlay;

  @override
  void dispose() {
    _dropdownOverlay?.remove();
    socket?.clearListeners();
    socket?.disconnect();
    socket?.destroy();
    socket = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.teesheetPageId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {},
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF9ECF9A),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                color: Color(0xFFFAFCFA),
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
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
                                    color: Color(0xFF6E7373),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Custom Date",
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFF6E7373),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 7),
                                    GestureDetector(
                                      onTap: editingIndex == null
                                          ? () => _showDatePicker(context)
                                          : null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            color: Color(0xFF648683),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (nomineedobError != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 6.0, left: 12),
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
                            children: List.generate(bookingWindowDays, (index) {
                              DateTime date =
                                  DateTime.now().add(Duration(days: index));
                              String label = index == 0
                                  ? "Today"
                                  : DateFormat("EEEE")
                                      .format(date); // "Today", "Tue", etc.
                              String formattedDate = DateFormat("MMM dd")
                                  .format(date); // e.g., Apr 21

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
                                          ? Color(0xFF9ECF9A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          label,
                                          style: GoogleFonts.poppins(
                                            color: isSelected
                                                ? Colors.white
                                                : Color(0xFF6E7373),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: GoogleFonts.poppins(
                                            color: isSelected
                                                ? Colors.white
                                                : Color(0xFF244065),
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
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Players",
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF6E7373),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        children: List.generate(
                                            maxPlayers > 5 ? 5 : maxPlayers,
                                            (index) {
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
                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Holes",
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF6E7373),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: teeSheetConfigHoles.map((hole) {
                                    return playerCircle(
                                      hole.toString(),
                                      // ignore: unrelated_type_equality_checks
                                      selectedHole == hole,
                                      () {
                                        setState(() {
                                          selectedHole = hole.toString();
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 1,
                              color: Color(0xFFB2C1C0),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              widget.name,
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF244065),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 40,
                              height: 1,
                              color: Color(0xFFB2C1C0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SingleChildScrollView(
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
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 15,
                            runSpacing: 15,
                            children: [
                              ...allTeeSheetData.map((slot) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TeeSheetDtls(
                                          date: '${_dateController.text}',
                                          time: slot['time'],
                                          players: slot['players'],
                                          holes: slot['holes'],
                                        ), // Replace with your target widget
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Container(
                                          width: 119,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF9ECF9A),
                                            borderRadius: BorderRadius.circular(
                                                50), // Optional
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 3,
                                                spreadRadius: 1,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              slot['time'] ?? '',
                                              style: GoogleFonts.poppins(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Icon(
                                                    Icons.flag,
                                                    size: 14,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        (slot['holes'] !=
                                                                    null &&
                                                                slot['holes']
                                                                    is List &&
                                                                slot['holes']
                                                                    .isNotEmpty)
                                                            ? (slot['holes']
                                                                    as List)
                                                                .join(' or ')
                                                            : '',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color:
                                                              Color(0xFF6E7373),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    size: 14,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        slot['players']
                                                                ?.toString() ??
                                                            '',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Color(
                                                                    0xFF6E7373),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),

                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     padding: EdgeInsets.symmetric(
                              //         horizontal: 20, vertical: 10),
                              //     decoration: BoxDecoration(
                              //       color: Color(0xFFFFFFFF),
                              //       borderRadius: BorderRadius.circular(15),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.1),
                              //           blurRadius: 3,
                              //           spreadRadius: 1,
                              //           offset: Offset(0, 0),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment.center,
                              //       children: [
                              //         // Text(
                              //         //   "Back",
                              //         //   style: GoogleFonts.poppins(
                              //         //       color: Color(0xFF244065),
                              //         //       fontSize: 13,
                              //         //       fontWeight: FontWeight.w500),
                              //         // ),
                              //         SizedBox(
                              //           height: 6,
                              //         ),
                              //         Container(
                              //             width: 119,
                              //             padding: EdgeInsets.symmetric(
                              //                 horizontal: 15, vertical: 7),
                              //             decoration: BoxDecoration(
                              //               color: Color(0xFF9ECF9A),
                              //               borderRadius:
                              //                   BorderRadius.circular(50), // Optional
                              //               boxShadow: [
                              //                 BoxShadow(
                              //                   color: Colors.black.withOpacity(0.1),
                              //                   blurRadius: 3,
                              //                   spreadRadius: 1,
                              //                   offset: Offset(0, 2),
                              //                 ),
                              //               ],
                              //             ),
                              //             child: Center(
                              //               child: Text(
                              //                 "6:30AM",
                              //                 style: GoogleFonts.poppins(
                              //                   color: Color(0xFFFFFFFF),
                              //                   fontSize: 13,
                              //                   fontWeight: FontWeight.w600,
                              //                 ),
                              //               ),
                              //             )),
                              //         SizedBox(
                              //           height: 6,
                              //         ),
                              //         Container(
                              //             child: SingleChildScrollView(
                              //           scrollDirection: Axis.horizontal,
                              //           child: Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.spaceBetween,
                              //             children: [
                              //               Container(
                              //                 child: Row(
                              //                   mainAxisAlignment:
                              //                       MainAxisAlignment.end,
                              //                   spacing: 3,
                              //                   children: [
                              //                     Icon(
                              //                       Icons.flag,
                              //                       size: 14,
                              //                       color: Color(0xFF6B7280),
                              //                     ),
                              //                     Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment.center,
                              //                       spacing: 3,
                              //                       children: [
                              //                         Text(
                              //                           "9",
                              //                           style: GoogleFonts.poppins(
                              //                               color: Color(0xFF6E7373),
                              //                               fontSize: 13,
                              //                               fontWeight:
                              //                                   FontWeight.w400),
                              //                         ),
                              //                         Text(
                              //                           "or",
                              //                           style: GoogleFonts.poppins(
                              //                               color: Color(0xFF6E7373),
                              //                               fontSize: 13,
                              //                               fontWeight:
                              //                                   FontWeight.w400),
                              //                         ),
                              //                         Text(
                              //                           "18",
                              //                           style: GoogleFonts.poppins(
                              //                               color: Color(0xFF6E7373),
                              //                               fontSize: 13,
                              //                               fontWeight:
                              //                                   FontWeight.w400),
                              //                         )
                              //                       ],
                              //                     )
                              //                   ],
                              //                 ),
                              //               ),
                              //               SizedBox(
                              //                 width: 20,
                              //               ),
                              //               Container(
                              //                 child: Row(
                              //                   mainAxisAlignment:
                              //                       MainAxisAlignment.end,
                              //                   spacing: 3,
                              //                   children: [
                              //                     Icon(
                              //                       Icons.person,
                              //                       size: 14,
                              //                       color: Color(0xFF6B7280),
                              //                     ),
                              //                     Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment.center,
                              //                       spacing: 3,
                              //                       children: [
                              //                         Text(
                              //                           "3",
                              //                           style: GoogleFonts.poppins(
                              //                               color: Color(0xFF6E7373),
                              //                               fontSize: 13,
                              //                               fontWeight:
                              //                                   FontWeight.w400),
                              //                         ),
                              //                       ],
                              //                     )
                              //                   ],
                              //                 ),
                              //               )
                              //             ],
                              //           ),
                              //         )),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }

  Widget playerCircle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF9ECF9A) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFF9ECF9A),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color:
                isSelected ? Colors.white : Color(0xFF244065), // 👈 Change here
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
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Color(0xFF9ECF9A) : Colors.white, // Red for active
          border: Border.all(color: Color(0xFF9ECF9A), width: 1),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 1,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Color(0xFF244065),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
