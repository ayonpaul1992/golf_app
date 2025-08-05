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
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
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

  String timeOfDay = 'all'; // Default time slot

  // List<String> teeSheetConfigHoles = [];

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);

    final queryParameters = {
      'timeOfDay': timeOfDay, // Assuming timeSlot is based on selectedIndex
      'teeSheet': widget.teesheetPageId,
      'reservationGroup': widget.reservationGroupId,
      'date': _selectedDate != null
          ? DateFormat("yyyy-MM-dd").format(_selectedDate!)
          : '',
      // 'holes': selectedHole,
      // 'players': selectedPlayer.toString(),
    };
    _fetchCustomerTeesheets(queryParameters); // Call the API on screen load

    // _fetchPendingReservation();
  }

  Future<void> _handleRefresh() async {
    final now = DateTime.now();
    _selectedDate = now;
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
    timeOfDay = 'all'; // Reset timeOfDay to 'all'
    selectedIndex = 0; // Reset selectedIndex to 0 (All)
    final queryParameters = {
      'timeOfDay': timeOfDay, // Reset to 'all' time slot
      'teeSheet': widget.teesheetPageId,
      'reservationGroup': widget.reservationGroupId,
      'date': DateFormat("yyyy-MM-dd").format(_selectedDate!),
      // 'holes': selectedHole,
      // 'players': selectedPlayer.toString(),
    };
    await _fetchCustomerTeesheets(queryParameters);
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

  // Future<void> _fetchCustomerTeesheets(Map<String, dynamic> params) async {
  //   // setState(() {
  //   //   isLoading = true;
  //   // });
  //   // Always dispose the old one
  //   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  //   String token = await secureStorage.read(key: 'accessToken') ?? '';

  //   socket?.clearListeners(); // ✅ clear all previous .on() handlers
  //   socket?.disconnect();
  //   socket?.destroy();
  //   socket = null;

  //   socket?.dispose();

  //   socket = IO.io('https://api.dev.driverpos.io', <String, dynamic>{
  //     'transports': ['websocket'],
  //     'timeout': 5000,
  //     'reconnection': true,
  //     'reconnectionAttempts': 5,
  //     'auth': {
  //       'token': token, // ✅ this matches the React structure
  //     },
  //   });

  //   socket!.onConnect((_) {
  //     socket!.emit("/customerTeesheet", params);
  //   });

  //   socket!.off("/customerTeesheet");

  //   socket!.on(
  //       "/customerTeesheet?teesheetId=${widget.teesheetPageId}&date=${DateFormat("yyyy-MM-dd").format(_selectedDate!)}",
  //       (data) {
  //     final innerData = data['data']; // Extract the inner 'data' object
  //     final teeSheetConfig = data['teeSheetConfig']; // Get config

  //     print("📦 Received data: $data");
  //     setState(() {
  //       teesheetData = innerData;
  //       setTeeSheetConfig(teeSheetConfig);
  //       setTeeSheetData();
  //       isLoading = false;
  //     });
  //   });

  //   socket!.onConnectError((err) => print('❌ Connect error: $err'));
  //   socket!.onError((err) => print('❌ General error: $err'));
  //   socket!.onDisconnect((_) => print('🔌 Socket disconnected'));

  //   socket!.connect();
  // }

  Future<void> _fetchCustomerTeesheets(Map<String, dynamic> params) async {
    setState(() {
      isLoading = true;
    });

    // Get token
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    String token = await secureStorage.read(key: 'accessToken') ?? '';

    // Clean up old socket if exists
    if (socket != null) {
      socket!.clearListeners();
      socket!.disconnect();
      socket!.destroy();
      socket = null;
    }

    // Create new socket instance
    socket = IO.io(
      'https://api.dev.driverpos.io',
      <String, dynamic>{
        'transports': ['websocket'],
        'timeout': 5000,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'auth': {'token': token},
      },
    );

    // Extract dynamic event key from params
    final String teesheetId = params['teeSheet'];
    final String date = params['date']; // should be in "yyyy-MM-dd" format
    final String eventName =
        "/customerTeesheet?teesheetId=$teesheetId&date=$date";

    // Setup socket event listeners
    socket!.onConnect((_) {
      print("✅ Socket connected");
      // Remove any old listener for the same event
      socket!.off(eventName);

      // Listen for the new data
      socket!.on(eventName, (data) {
        print("📦 Received data: $data");

        final innerData = data['data'];
        final teeSheetConfig = data['teeSheetConfig'];

        setState(() {
          teesheetData = innerData;
          setTeeSheetConfig(teeSheetConfig);
          setTeeSheetData();
          // selectedIndex = 0; // Reset selectedIndex to 0 (All)
          timeOfDay = "all"; // Reset timeOfDay to 'all'
          isLoading = false;
        });
      });

      // Emit after listener is set
      socket!.emit("/customerTeesheet", params);
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
                  SfDateRangePicker(
                    initialSelectedDate: _selectedDate,
                    selectionMode: DateRangePickerSelectionMode.single,
                    backgroundColor: Colors.white,
                    selectionColor: const Color(0xFF9ECF9A),
                    todayHighlightColor: const Color(0xFF9ECF9A),
                    minDate: DateTime.now(), // Set your desired start date
                    maxDate: DateTime.now().add(
                      Duration(days: bookingWindowDays - 1),
                    ), // Set your desired end date
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
                        // print('_selectedDate: ${_selectedDate.toString()}');
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
                              selectedIndex =
                                  0; // Reset selectedIndex to 0 (All)
                              selectedHole = ""; // Reset selectedHole
                              selectedPlayer = 0;
                              print(
                                  '_dateController.text: ${_dateController.text}');
                              timeOfDay = 'all'; // Reset timeOfDay to 'all'
                              final queryParameters = {
                                'timeOfDay': timeOfDay,
                                'teeSheet': widget.teesheetPageId,
                                'reservationGroup': widget.reservationGroupId,
                                'date': DateFormat("yyyy-MM-dd")
                                    .format(_selectedDate!),
                                // 'holes': selectedHole,
                                // 'players': selectedPlayer.toString(),
                              };
                              _fetchCustomerTeesheets(queryParameters);
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF9ECF9A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
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
  int selectedPlayer = 0;
  String selectedHole = "";
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
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF9ECF9A),
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Container(
                        color: const Color(0xFFFAFCFA),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                color: const Color(0xFFFAFCFA),
                                width: double.infinity,
                                // Remove the inner SingleChildScrollView to avoid nested scroll views
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Date",
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF6E7373),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Custom Date",
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                          0xFF6E7373),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 7),
                                                  GestureDetector(
                                                    onTap: editingIndex == null
                                                        ? () => _showDatePicker(
                                                            context)
                                                        : null,
                                                    child: const Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calendar_month_outlined,
                                                          color:
                                                              Color(0xFF648683),
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
                                              padding: const EdgeInsets.only(
                                                  top: 6.0, left: 12),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                              bookingWindowDays, (index) {
                                            DateTime date = DateTime.now()
                                                .add(Duration(days: index));
                                            String label = index == 0
                                                ? "Today"
                                                : DateFormat("EEEE").format(
                                                    date); // "Today", "Tue", etc.
                                            String formattedDate =
                                                DateFormat("MMM dd").format(
                                                    date); // e.g., Apr 21

                                            bool isSelected =
                                                _dateController.text ==
                                                    DateFormat("MMM dd, yyyy")
                                                        .format(date);

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  timeOfDay =
                                                      'all'; // Reset timeOfDay to 'all'
                                                  selectedIndex =
                                                      0; // Reset selectedIndex to 0 (All)
                                                  selectedHole =
                                                      ""; // Reset selectedHole
                                                  selectedPlayer =
                                                      0; // Reset selectedPlayer
                                                  _selectedDate = date;
                                                  _dateController.text =
                                                      DateFormat("MMM dd, yyyy")
                                                          .format(date);
                                                  _fetchCustomerTeesheets({
                                                    'timeOfDay': timeOfDay,
                                                    'teeSheet':
                                                        widget.teesheetPageId,
                                                    'reservationGroup': widget
                                                        .reservationGroupId,
                                                    'date':
                                                        DateFormat("yyyy-MM-dd")
                                                            .format(date),
                                                    // 'holes': selectedHole,
                                                    // 'players': selectedPlayer.toString(),
                                                  });
                                                });

                                                print(
                                                    '_dateController.text: ${_dateController.text}');
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 15,
                                                    left: 6,
                                                    right: 6),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF9ECF9A)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 3,
                                                        spreadRadius: 1,
                                                        offset:
                                                            const Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 10),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        label,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: isSelected
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF6E7373),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        formattedDate,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: isSelected
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF244065),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Players",
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF6E7373),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Center(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Wrap(
                                                      spacing: 8,
                                                      children: List.generate(
                                                          maxPlayers > 5
                                                              ? 5
                                                              : maxPlayers,
                                                          (index) {
                                                        int playerNum =
                                                            index + 1;
                                                        return playerCircle(
                                                          "$playerNum",
                                                          selectedPlayer ==
                                                              playerNum,
                                                          () {
                                                            print(
                                                                'Selected player: $playerNum');
                                                            setState(() {
                                                              selectedPlayer =
                                                                  playerNum;
                                                              final queryParameters =
                                                                  {
                                                                'timeOfDay':
                                                                    timeOfDay,
                                                                'teeSheet': widget
                                                                    .teesheetPageId,
                                                                'reservationGroup':
                                                                    widget
                                                                        .reservationGroupId,
                                                                'date': DateFormat(
                                                                        "yyyy-MM-dd")
                                                                    .format(
                                                                        _selectedDate!),
                                                                'players':
                                                                    selectedPlayer
                                                                        .toString(),
                                                                // 'holes': selectedHole,
                                                              };
                                                              _fetchCustomerTeesheets(
                                                                  queryParameters);
                                                            });
                                                          },
                                                        );
                                                      }),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Holes",
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF6E7373),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Wrap(
                                                spacing: 8,
                                                children: teeSheetConfigHoles
                                                    .map((hole) {
                                                  return playerCircle(
                                                    hole.toString(),
                                                    // ignore: unrelated_type_equality_checks
                                                    selectedHole ==
                                                        hole.toString(),
                                                    () {
                                                      setState(() {
                                                        selectedHole =
                                                            hole.toString();
                                                        final queryParameters =
                                                            {
                                                          'timeOfDay':
                                                              timeOfDay,
                                                          'teeSheet': widget
                                                              .teesheetPageId,
                                                          'reservationGroup': widget
                                                              .reservationGroupId,
                                                          'date': DateFormat(
                                                                  "yyyy-MM-dd")
                                                              .format(
                                                                  _selectedDate!),
                                                          'holes': selectedHole,
                                                          // 'players':
                                                          //     selectedPlayer.toString(),
                                                        };
                                                        _fetchCustomerTeesheets(
                                                            queryParameters);
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
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            widget.name,
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
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        spacing: 7,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildButton(
                                              label: "All",
                                              index: 0,
                                              selectedIndex: selectedIndex,
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = 0;
                                                  // Reset timeOfDay to 'all'
                                                  timeOfDay = 'all';
                                                  final queryParameters = {
                                                    'timeOfDay': timeOfDay,
                                                    'teeSheet':
                                                        widget.teesheetPageId,
                                                    'reservationGroup': widget
                                                        .reservationGroupId,
                                                    'date': DateFormat(
                                                            "yyyy-MM-dd")
                                                        .format(_selectedDate!),
                                                    // 'holes': selectedHole,
                                                    // 'players': selectedPlayer.toString(),
                                                  };
                                                  print(
                                                      'queryParameters: $queryParameters');
                                                  _fetchCustomerTeesheets(
                                                      queryParameters);
                                                });
                                              }),
                                          _buildButton(
                                              label: "Morning",
                                              index: 1,
                                              selectedIndex: selectedIndex,
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = 1;
                                                  timeOfDay = 'morning';

                                                  final queryParameters = {
                                                    'timeOfDay': timeOfDay,
                                                    'teeSheet':
                                                        widget.teesheetPageId,
                                                    'reservationGroup': widget
                                                        .reservationGroupId,
                                                    'date': DateFormat(
                                                            "yyyy-MM-dd")
                                                        .format(_selectedDate!),
                                                    // 'holes': selectedHole,
                                                    // 'players': selectedPlayer.toString(),
                                                  };
                                                  _fetchCustomerTeesheets(
                                                      queryParameters);
                                                });
                                              }),
                                          _buildButton(
                                              label: "Midday",
                                              index: 2,
                                              selectedIndex: selectedIndex,
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = 2;
                                                  timeOfDay = 'midday';
                                                  final queryParameters = {
                                                    'timeOfDay': timeOfDay,
                                                    'teeSheet':
                                                        widget.teesheetPageId,
                                                    'reservationGroup': widget
                                                        .reservationGroupId,
                                                    'date': DateFormat(
                                                            "yyyy-MM-dd")
                                                        .format(_selectedDate!),
                                                    // 'holes': selectedHole,
                                                    // 'players': selectedPlayer.toString(),
                                                  };
                                                  _fetchCustomerTeesheets(
                                                      queryParameters);
                                                });
                                              }),
                                          _buildButton(
                                              label: "Evening",
                                              index: 3,
                                              selectedIndex: selectedIndex,
                                              onTap: () {
                                                setState(() {
                                                  selectedIndex = 3;
                                                  timeOfDay = 'evening';
                                                  final queryParameters = {
                                                    'timeOfDay': timeOfDay,
                                                    'teeSheet':
                                                        widget.teesheetPageId,
                                                    'reservationGroup': widget
                                                        .reservationGroupId,
                                                    'date': DateFormat(
                                                            "yyyy-MM-dd")
                                                        .format(_selectedDate!),
                                                    // 'holes': selectedHole,
                                                    // 'players': selectedPlayer.toString(),
                                                  };
                                                  _fetchCustomerTeesheets(
                                                      queryParameters);
                                                });
                                              }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
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
                                              // return GestureDetector(
                                              //   onTap: () {
                                              //     print(
                                              //         '_dateController.text: ${_dateController.text}');
                                              //     Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             TeeSheetDtls(
                                              //           teesheetPageId: widget
                                              //               .teesheetPageId,
                                              //           reservationGroupId: widget
                                              //               .reservationGroupId,
                                              //           date:
                                              //               '${_dateController.text}',
                                              //           time: slot['time'],
                                              //           players:
                                              //               slot['players'],
                                              //           holes: slot['holes'],
                                              //           allowName: allowName,
                                              //           socket: socket!,
                                              //         ), // Replace with your target widget
                                              //       ),
                                              //     );
                                              //   },
                                              //   child: Container(
                                              //     padding: const EdgeInsets
                                              //         .symmetric(
                                              //       horizontal: 20,
                                              //       vertical: 10,
                                              //     ),
                                              //     decoration: BoxDecoration(
                                              //       color:
                                              //           const Color(0xFFFFFFFF),
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               15),
                                              //       boxShadow: [
                                              //         BoxShadow(
                                              //           color: Colors.black
                                              //               .withOpacity(0.1),
                                              //           blurRadius: 3,
                                              //           spreadRadius: 1,
                                              //           offset:
                                              //               const Offset(0, 0),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //     child: Column(
                                              //       crossAxisAlignment:
                                              //           CrossAxisAlignment
                                              //               .center,
                                              //       children: [
                                              //         const SizedBox(
                                              //           height: 6,
                                              //         ),
                                              //         Container(
                                              //           width: 119,
                                              //           padding:
                                              //               const EdgeInsets
                                              //                   .symmetric(
                                              //                   horizontal: 15,
                                              //                   vertical: 7),
                                              //           decoration:
                                              //               BoxDecoration(
                                              //             color: const Color(
                                              //                 0xFF9ECF9A),
                                              //             borderRadius:
                                              //                 BorderRadius.circular(
                                              //                     50), // Optional
                                              //             boxShadow: [
                                              //               BoxShadow(
                                              //                 color: Colors
                                              //                     .black
                                              //                     .withOpacity(
                                              //                         0.1),
                                              //                 blurRadius: 3,
                                              //                 spreadRadius: 1,
                                              //                 offset:
                                              //                     const Offset(
                                              //                         0, 2),
                                              //               ),
                                              //             ],
                                              //           ),
                                              //           child: Center(
                                              //             child: Text(
                                              //               slot['time'] ?? '',
                                              //               style: GoogleFonts
                                              //                   .poppins(
                                              //                 color: const Color(
                                              //                     0xFFFFFFFF),
                                              //                 fontSize: 13,
                                              //                 fontWeight:
                                              //                     FontWeight
                                              //                         .w600,
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ),
                                              //         const SizedBox(
                                              //           height: 6,
                                              //         ),
                                              //         SingleChildScrollView(
                                              //           scrollDirection:
                                              //               Axis.horizontal,
                                              //           child: Row(
                                              //             mainAxisAlignment:
                                              //                 MainAxisAlignment
                                              //                     .spaceBetween,
                                              //             children: [
                                              //               Row(
                                              //                 mainAxisAlignment:
                                              //                     MainAxisAlignment
                                              //                         .end,
                                              //                 children: [
                                              //                   const Icon(
                                              //                     Icons.flag,
                                              //                     size: 14,
                                              //                     color: Color(
                                              //                         0xFF6B7280),
                                              //                   ),
                                              //                   Row(
                                              //                     mainAxisAlignment:
                                              //                         MainAxisAlignment
                                              //                             .center,
                                              //                     children: [
                                              //                       Text(
                                              //                         (slot['holes'] != null &&
                                              //                                 slot['holes'] is List &&
                                              //                                 slot['holes'].isNotEmpty)
                                              //                             ? (slot['holes'] as List).join(' or ')
                                              //                             : '',
                                              //                         style: GoogleFonts
                                              //                             .poppins(
                                              //                           color: const Color(
                                              //                               0xFF6E7373),
                                              //                           fontSize:
                                              //                               13,
                                              //                           fontWeight:
                                              //                               FontWeight.w400,
                                              //                         ),
                                              //                       )
                                              //                     ],
                                              //                   )
                                              //                 ],
                                              //               ),
                                              //               const SizedBox(
                                              //                 width: 20,
                                              //               ),
                                              //               Row(
                                              //                 mainAxisAlignment:
                                              //                     MainAxisAlignment
                                              //                         .end,
                                              //                 children: [
                                              //                   const Icon(
                                              //                     Icons.person,
                                              //                     size: 14,
                                              //                     color: Color(
                                              //                         0xFF6B7280),
                                              //                   ),
                                              //                   Row(
                                              //                     mainAxisAlignment:
                                              //                         MainAxisAlignment
                                              //                             .center,
                                              //                     children: [
                                              //                       Text(
                                              //                         slot['players']
                                              //                                 ?.toString() ??
                                              //                             '',
                                              //                         style: GoogleFonts.poppins(
                                              //                             color: const Color(
                                              //                                 0xFF6E7373),
                                              //                             fontSize:
                                              //                                 13,
                                              //                             fontWeight:
                                              //                                 FontWeight.w400),
                                              //                       ),
                                              //                     ],
                                              //                   )
                                              //                 ],
                                              //               )
                                              //             ],
                                              //           ),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ),
                                              // );

                                              return SizedBox(
                                                width: 170,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    print(
                                                        '_dateController.text: ${_dateController.text}');
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TeeSheetDtls(
                                                          teesheetPageId: widget
                                                              .teesheetPageId,
                                                          reservationGroupId: widget
                                                              .reservationGroupId,
                                                          date:
                                                              '${_dateController.text}',
                                                          time: slot['time'],
                                                          players:
                                                              slot['players'],
                                                          holes: slot['holes'],
                                                          allowName: allowName,
                                                          socket: socket!,
                                                        ), // Replace with your target widget
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 0,
                                                      bottom: 7,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFFFFFFF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 3,
                                                          spreadRadius: 1,
                                                          offset: const Offset(
                                                              0, 0),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  bottom: 10,
                                                                  left: 10,
                                                                  right: 20),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xFF9ECF9A),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              topRight: Radius
                                                                  .circular(15),
                                                              bottomLeft: Radius
                                                                  .circular(0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          0),
                                                            ),
                                                          ),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Color(
                                                                        0xFF9ECF9A),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      slot['time'] ??
                                                                          '',
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        color: const Color(
                                                                            0xFFFFFFFF),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .person,
                                                                      size: 15,
                                                                      color: Color(
                                                                          0xFFFFFFFF),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 1,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          slot['players']?.toString() ??
                                                                              '',
                                                                          style: GoogleFonts.poppins(
                                                                              color: const Color(0xFFFFFFFF),
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ]),
                                                        ),
                                                        SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start, // optional
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                color: const Color(
                                                                    0xFFF8F8F8),
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width: 20,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .flag,
                                                                        size:
                                                                            16,
                                                                        color: Color(
                                                                            0xFF669933),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    const SizedBox(
                                                                      width: 50,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.directions_walk,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                Color(0xFF669933),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    SizedBox(
                                                                      width: 50,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            'assets/images/golf_car.png',
                                                                            width:
                                                                                16,
                                                                            height:
                                                                                16,
                                                                            color:
                                                                                const Color(0xFF669933),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            8,
                                                                        top: 8,
                                                                        bottom:
                                                                            8),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 20,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: (slot['holes'] != null &&
                                                                                slot['holes'] is List &&
                                                                                slot['holes'].isNotEmpty)
                                                                            ? (slot['holes'] as List)
                                                                                .map<Widget>((hole) => Text(
                                                                                      hole.toString(),
                                                                                      style: GoogleFonts.poppins(
                                                                                        color: const Color(0xFF244065),
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.w400,
                                                                                      ),
                                                                                    ))
                                                                                .toList()
                                                                            : [
                                                                                Text(
                                                                                  '',
                                                                                  style: GoogleFonts.poppins(
                                                                                    color: const Color(0xFF244065),
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: (slot['holes'] != null &&
                                                                                slot['holes'] is List &&
                                                                                slot['holes'].isNotEmpty)
                                                                            ? (slot['holes'] as List)
                                                                                .map<Widget>(
                                                                                  (hole) => Text(
                                                                                    hole == 9 ? '\$${((slot['fees']['nineHole']['greenFee']).toStringAsFixed(2) ?? '0.00')}' : '\$${(slot['fees']['eighteenHole']['greenFee'].toStringAsFixed(2) ?? '0.00')}',
                                                                                    style: GoogleFonts.poppins(
                                                                                      color: const Color(0xFF244065),
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.w400,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                                .toList()
                                                                            : [
                                                                                Text(
                                                                                  '',
                                                                                  style: GoogleFonts.poppins(
                                                                                    color: const Color(0xFF244065),
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 50,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: (slot['holes'] != null &&
                                                                                slot['holes'] is List &&
                                                                                slot['holes'].isNotEmpty)
                                                                            ? (slot['holes'] as List)
                                                                                .map<Widget>((hole) => Text(
                                                                                      hole == 9 ? '\$${((slot['fees']['nineHole']['cartFee']).toStringAsFixed(2) ?? '0.00')}' : '\$${(slot['fees']['eighteenHole']['cartFee'].toStringAsFixed(2) ?? '0.00')}',
                                                                                      style: GoogleFonts.poppins(
                                                                                        color: const Color(0xFF244065),
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.w400,
                                                                                      ),
                                                                                    ))
                                                                                .toList()
                                                                            : [
                                                                                Text(
                                                                                  '',
                                                                                  style: GoogleFonts.poppins(
                                                                                    color: const Color(0xFF244065),
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              // First Column
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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
          color: isSelected
              ? const Color(0xFF9ECF9A)
              : Colors.white, // Red for active
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
