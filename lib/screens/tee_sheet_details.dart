// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:gulf_app/screens/my_cart.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class TeeSheetDtls extends StatefulWidget {
  // final String TeeSheetDtlsUsrId;
  final String teesheetPageId;
  final String reservationGroupId;

  final String date;
  final String time;
  final int players;
  final List<dynamic> holes;
  final bool allowName;

  final IO.Socket socket;
  // const TeeSheetDtls({super.key, required this.TeeSheetDtlsUsrId});
  const TeeSheetDtls({
    super.key,
    required this.teesheetPageId,
    required this.reservationGroupId,
    required this.date,
    required this.time,
    required this.players,
    required this.holes,
    required this.allowName,
    // required this.teesheetData,
    required this.socket,
  });

  @override
  State<StatefulWidget> createState() => TeeSheetDtlsState();
}

class TeeSheetDtlsState extends State<TeeSheetDtls> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  late Timer _timer;
  Duration _remaining = const Duration(minutes: 5);

  bool isYes = false;
  int? editingIndex;
  int selectedPlayer = 1;
  int selectedRidePlayer = 0;
  String selectedHole = "9";
  int selectedIndex = 0;
  bool showDropdown = false;
  bool showRideDropdown = false; // Added state for Riders dropdown visibility
  OverlayEntry? _dropdownOverlay;
  OverlayEntry? _dropdownRideOverlay;

  final GlobalKey _iconKey = GlobalKey(); // Key for Players dropdown
  final GlobalKey _iconKeySecond = GlobalKey(); // Key for Riders dropdown
  String userName = '';
  int selectedPlayerCount = 1;

  //need array of objects for suggestions

  List<Map<String, dynamic>> playerSuggestions = [];

  // List<String> suggestions = []; // Holds your fetched suggestions
  // List<String> suggestionsEmail = []; // Holds your fetched suggestions
  Future<void>? fetchSuggestionsFuture; // To ensure fetch runs once

  IO.Socket? socket;

  String? pendingSlotId;

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds == 0) {
        timer.cancel();
        cancelPendingReservation();
        Navigator.pop(context);
      } else {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    _dropdownOverlay?.remove();
    _dropdownRideOverlay?.remove(); // Dispose the second overlay as well
    for (var focusNode in _focusNodes) {
      focusNode.removeListener(_onFocusChange);
      focusNode.dispose();
    }

    _timer.cancel();

    widget.socket.off("/pendingReservation");

    super.dispose();
  }

  // Added FocusNode List
  // List<FocusNode> _focusNodes = List.generate(
  //   3,
  //   (index) => FocusNode(),
  // );
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  late List<LayerLink> _layerLinks;

  // List<TextEditingController> _controllers = List.generate(
  //   3,
  //   (index) => TextEditingController(text: index == 0 ? 'Koushik Datta' : ''),
  // );
  @override
  void initState() {
    super.initState();
    _startCountdown();
    _loadUserName();

    _controllers = List.generate(
      selectedPlayerCount,
      (index) => TextEditingController(),
    );

    _focusNodes = List.generate(
      selectedPlayerCount,
      (index) => FocusNode(),
    );

    _layerLinks = List.generate(
      selectedPlayerCount,
      (index) => LayerLink(),
    );
    // Attach listener to each FocusNode
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(_onFocusChange);
    }

    _createPendingReservation();

    fetchSuggestionsFuture = fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    try {
      print('Fetching suggestions from API...');
      String token = await secureStorage.read(key: 'accessToken') ?? '';
      // golfCourse, date, and time will come from secure storage or widget properties

      String golfCourse = await secureStorage.read(key: 'golfCourseName') ??
          ''; // Replace with actual value
      String date = DateFormat("yyyy-MM-dd").format(DateFormat("MMM dd, yyyy")
          .parse(widget.date)); // Replace with actual value

      String time = widget.time; // Replace with actual value

      print(
          'Fetching suggestions for golfCourse: $golfCourse, date: $date, time: $time');

      final response = await http.get(
        Uri.parse(
          'https://api.dev.driverpos.io/api/v1/customer/players?golfCourse=$golfCourse&date=$date&time=$time',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          if (mounted) {
            setState(() {
              playerSuggestions = (data['data'] as List)
                  .map((item) => {
                        'id': item['_id']?.toString() ?? '',
                        'fullName': item['fullName']?.toString() ?? '',
                        'email': item['email']?.toString() ?? '',
                      })
                  .where((item) =>
                      item['fullName']!.isNotEmpty && item['email']!.isNotEmpty)
                  .toList();
            });
          }

          // print('✅ Suggestions fetched: $suggestions');
          // print('✅ Email suggestions fetched: $suggestionsEmail');
        }
      }
    } catch (e) {
      print('❌ Error fetching suggestions: $e');
    }
  }

  Future<void> _loadUserName() async {
    String? name = await secureStorage.read(key: 'userName');
    // print(name);
    setState(() {
      userName = name ?? '';

      // Update controller text for the first field
      if (_controllers.isNotEmpty) {
        _controllers[0].text = userName;
      }
    });

    // print(userName);
  }

  void _onFocusChange() {
    setState(() {}); // Rebuild to update border color
  }

  void _createPendingReservation() {
    final payload = {
      "teeSheetId": widget.teesheetPageId,
      "date": DateFormat('yyyy-MM-dd').format(
        DateFormat('MMM dd, yyyy').parse(widget.date),
      ),
      "startingSlot": widget.time,
      "slotCustomer": 5 - widget.players,
      "isPending": true,
      // "pendingSlotId": "20250522630AM1860",
      // "pendingSlotId": "20250522630AM1860"
    };

    print("📤 Emitting /pendingReservation");
    widget.socket.emit("/pendingReservation", payload);

    widget.socket.on("/pendingReservation", (data) {
      print("📥 Received reservation data: $data");

      setState(() {
        pendingSlotId = data['slotId'];
      });

      // Handle UI update here
    });
  }

  void cancelPendingReservation() {
    if (pendingSlotId == null) {
      print("⚠️ Cannot cancel — pendingSlotId is null");
      return;
    }

    final cancelPayload = {
      "teeSheetId": widget.teesheetPageId,
      "date": DateFormat('yyyy-MM-dd').format(
        DateFormat('MMM dd, yyyy').parse(widget.date),
      ),
      "startingSlot": widget.time,
      "pendingSlotId": pendingSlotId,
      "isPending": false,
    };

    print("📤 Emitting /pendingReservation (cancel)");
    widget.socket.emit("/pendingReservation", cancelPayload);

    widget.socket.on("/pendingReservation", (data) {
      print("📥 Cancel response: $data");

      // Optional: reset state if needed
      if (data['success'] == true && mounted) {
        setState(() {
          pendingSlotId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: '', // ✅ Pass the correct userId
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
              Container(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 1.1,
                          color: const Color(0xFFB2C1C0),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Tee Booking",
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
                          height: 1.1,
                          color: const Color(0xFFB2C1C0),
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FFF0),
                        border: Border.all(
                            color: const Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Image.asset(
                              "assets/images/ftr_hstry.png",
                              color: const Color(0xFF6B7280),
                              width: 18,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            // 👈 this ensures text wraps inside available width
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Your time, ",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: widget.time,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF669933),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ", will be held for 5 minutes. You have ",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _formatDuration(_remaining),
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFDB0606),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " remaining. Please complete the reservation process.",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF244065),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FFF0),
                        border: Border.all(
                            color: const Color(0xFF9ECF9A), width: 1.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/images/solar_golf-bold.png",
                                            color: const Color(0xFF6B7280),
                                            width: 18,
                                          ),
                                          const SizedBox(
                                              width: 6), // 👈 replaces spacing
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              "Eden Gardens Golf Course",
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF244065),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 70,
                                      color: const Color(0xFFB2C1C0),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/images/lets-icons_date-fill.png",
                                                color: const Color(0xFF6B7280),
                                                width: 18,
                                              ),
                                              const SizedBox(
                                                  width:
                                                      6), // 👈 spacing between icon and text
                                              Text(
                                                DateFormat('yyyy-MM-dd').format(
                                                  DateFormat('MMM dd, yyyy')
                                                      .parse(widget.date),
                                                ),
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              height:
                                                  5), // 👈 spacing between rows
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/images/ftr_hstry.png",
                                                color: const Color(0xFF6B7280),
                                                width: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                widget.time,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF244065),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Players",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF6E7373),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Wrap(
                                            //   spacing: 8,
                                            //   children:
                                            //       List.generate(4, (index) {
                                            //     int playerNum = index + 1;
                                            //     return playerCircle(
                                            //       "$playerNum",
                                            //       selectedPlayer == playerNum,
                                            //       () {
                                            //         setState(() {
                                            //           selectedPlayer =
                                            //               playerNum;
                                            //         });
                                            //       },
                                            //     );
                                            //   }),
                                            // ),

                                            Wrap(
                                              spacing: 8,
                                              children: List.generate(
                                                  widget.players > 5
                                                      ? 5
                                                      : widget.players,
                                                  (index) {
                                                int playerNum = index + 1;
                                                return playerCircle(
                                                  "$playerNum",
                                                  selectedPlayer == playerNum,
                                                  () {
                                                    setState(() {
                                                      selectedPlayer =
                                                          playerNum;
                                                      selectedPlayerCount =
                                                          playerNum;
                                                      _controllers =
                                                          List.generate(
                                                        selectedPlayerCount,
                                                        (index) => index <
                                                                _controllers
                                                                    .length
                                                            ? _controllers[
                                                                index] // reuse existing controllers if possible
                                                            : TextEditingController(),
                                                      );
                                                      _focusNodes =
                                                          List.generate(
                                                        selectedPlayerCount,
                                                        (index) => index <
                                                                _focusNodes
                                                                    .length
                                                            ? _focusNodes[
                                                                index] // reuse existing focus nodes if possible
                                                            : FocusNode(),
                                                      );
                                                      _layerLinks =
                                                          List.generate(
                                                        selectedPlayerCount,
                                                        (index) => index <
                                                                _layerLinks
                                                                    .length
                                                            ? _layerLinks[
                                                                index] // reuse existing layer links if possible
                                                            : LayerLink(),
                                                      );
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
                                                Opacity(
                                                  opacity: 0.0,
                                                  child: IconButton(
                                                    key: _iconKey,
                                                    onPressed: null,
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Color(0xFF244065),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Holes",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF6E7373),
                                          fontSize: 12,
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
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Riders",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF6E7373),
                                          fontSize: 12,
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
                                                  widget.players + 1, (index) {
                                                int riderNum = index;
                                                return playerCircle(
                                                  "$riderNum",
                                                  selectedRidePlayer ==
                                                      riderNum,
                                                  () {
                                                    setState(() {
                                                      selectedRidePlayer =
                                                          riderNum;
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
                                                Opacity(
                                                  opacity: 0.0,
                                                  child: IconButton(
                                                    key: _iconKeySecond,
                                                    onPressed: null,
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Color(0xFF244065),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rental set of clubs",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF6E7373),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isYes = !isYes;
                                          });
                                        },
                                        child: Container(
                                          width: 95,
                                          height: 31,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: const Color(0xFF9ECF9A)),
                                          ),
                                          child: Stack(
                                            children: [
                                              AnimatedAlign(
                                                alignment: isYes
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                curve: Curves.easeInOut,
                                                child: Container(
                                                  width: 50,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF9ECF9A),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'NO',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: isYes
                                                              ? const Color(
                                                                  0xFF244065)
                                                              : Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'YES',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: isYes
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF244065),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ... other UI elements
                                  _buildPlayerNameFields(), //call the function
                                  // ... other UI elements
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 7,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Your onTap action here
                              cancelPendingReservation();
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: const Color(0xFF9ECF9A), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF244065),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const MyCartPage(
                            //           myCartId:
                            //               ''), // Replace with your target widget
                            //     ),
                            //   );
                            // },
                            onTap: () async {
                              cancelPendingReservation();
                              try {
                                List<String> playerNames = _controllers
                                    .skip(1)
                                    .map((controller) => controller.text)
                                    .toList();

                                List<String> selectedPlayerIds =
                                    playerSuggestions
                                        .where((player) => playerNames
                                            .contains(player['fullName']))
                                        .map((player) => player['id'] as String)
                                        .toList();

                                List<Map<String, String>>
                                    selectedPlayersIdsObjects = [];
                                for (int i = 0;
                                    i < selectedPlayerIds.length;
                                    i++) {
                                  if (selectedPlayerIds[i].isNotEmpty) {
                                    selectedPlayersIdsObjects.add(
                                        {"customerId": selectedPlayerIds[i]});
                                  }
                                }

                                String token = await secureStorage.read(
                                        key: 'accessToken') ??
                                    '';

                                final response = await http.post(
                                  Uri.parse(
                                    'https://api.dev.driverpos.io/api/v1/teesheet/book-teesheet',
                                  ),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization':
                                        'Bearer $token', // if needed
                                  },
                                  body: jsonEncode({
                                    "teeSheetId": widget.teesheetPageId,
                                    "onlineReservationGroupId":
                                        widget.reservationGroupId,
                                    "date": DateFormat('yyyy-MM-dd').format(
                                      DateFormat('MMM dd, yyyy')
                                          .parse(widget.date),
                                    ),
                                    "startingSlot": widget.time,
                                    "persons": selectedPlayerCount,
                                    "holes": selectedHole,
                                    "carts": selectedRidePlayer,
                                    "rentalClubs": isYes,
                                    "customers": selectedPlayersIdsObjects,
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  final data = jsonDecode(response.body);
                                  print('✅ Booking API Response: $data');

                                  if (data['success'] == true) {
                                    // Handle success
                                    // print('✅ Booking successful');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MyCartPage(myCartId: ''),
                                      ),
                                    );
                                  } else {
                                    // Handle error
                                    print(
                                        '❌ Booking failed: ${data['message']}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Booking failed'),
                                      ),
                                    );
                                  }
                                } else {
                                  print('❌ API Error: ${response.body}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        jsonDecode(response.body)['message'],
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('❌ Exception: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Something went wrong'),
                                  ),
                                );
                              }
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF9ECF9A),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: const Color(0xFF9ECF9A), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              child: Center(
                                child: Text(
                                  "Next",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

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
            color: isSelected
                ? Colors.white
                : const Color(0xFF244065), // 👈 Change here
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerNameFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8),
          child: Text(
            "Player's Name",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...List.generate(_controllers.length, (index) {
          final isSuggestionField = index != 0;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _focusNodes[index].hasFocus
                    ? const Color(0xFF9ECF9A)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border:
                        Border.all(color: const Color(0xFF80C783), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF669933),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isSuggestionField
                      ? Stack(
                          children: [
                            CompositedTransformTarget(
                              link: _layerLinks[index],
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: 'Guest Customer',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E3552),
                                ),
                              ),
                            ),
                            RawAutocomplete<String>(
                              textEditingController: _controllers[index],
                              focusNode: _focusNodes[index],

                              // ✅ Show suggestions only when input is not empty
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                print(
                                    'OptionsBuilder called with: ${textEditingValue.text}');

                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return playerSuggestions
                                    .where((option) => option['fullName']
                                        .toLowerCase()
                                        .contains(
                                          textEditingValue.text.toLowerCase(),
                                        ))
                                    .map((option) =>
                                        option['fullName'] as String);
                              },

                              fieldViewBuilder: (context, controller, focusNode,
                                  onFieldSubmitted) {
                                return const SizedBox
                                    .shrink(); // Already rendered TextField above
                              },

                              // ✅ This stays exactly as you already have it
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: CompositedTransformFollower(
                                    link: _layerLinks[index],
                                    showWhenUnlinked: false,
                                    offset: const Offset(
                                        -50, 31), // Match TextField height
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: MediaQuery.of(context).size.width -
                                          71,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            offset: const Offset(0, 3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(8),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 72,
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (context, i) {
                                              final option =
                                                  options.elementAt(i);
                                              return ListTile(
                                                dense: true,
                                                title: Text(
                                                  option,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                onTap: () => onSelected(option),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3552),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Guest Customer',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
