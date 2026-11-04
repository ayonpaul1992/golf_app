import 'package:driver_pos/repositories/feature_repositories.dart';
import 'package:driver_pos/theme/app_theme.dart';
import '../models/history_page.dart';
import '../repositories/history_repository.dart';
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
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
  bool isLoading = true;
  String? nomineedobError;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _dropdownOverlay;
  String _selectedFilter = "Upcoming";
  final List<String> _filterOptions = [
    "Upcoming",
    "Past",
    // "This week",
    // "This month",
    // "This year"
  ];

  List<Map<String, dynamic>> reservations = [];

  Map<String, String> getDateRange(String filter) {
    final now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;

    switch (filter) {
      case 'Upcoming':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year + 5); // Arbitrary future date
        break;

      case 'Past':
        startDate = DateTime(2000); // Arbitrary past date
        endDate = DateTime(now.year, now.month, now.day - 1);
        break;

      case 'This week':
        final int weekday = now.weekday; // Monday = 1, Sunday = 7
        startDate = now.subtract(Duration(days: weekday - 1));
        endDate = now.add(Duration(days: 7 - weekday));
        break;

      case 'This month':
        startDate = DateTime(now.year, now.month, 1);
        endDate =
            DateTime(now.year, now.month + 1, 0); // Last day of this month
        break;

      case 'This year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;

      default:
        startDate = now;
        endDate = now;
    }

    final formatter = DateFormat('yyyy-MM-dd');
    return {
      'startDate': formatter.format(startDate),
      'endDate': formatter.format(endDate),
    };
  }

  final _historyRepository = HistoryRepository();
  HistoryPage? _historyPage;
  bool _loadingMore = false;
  int _historyRequest = 0;

  Future<void> fetchMyBookings({bool append = false}) async {
    if (append && (_loadingMore || _historyPage?.hasMore != true)) return;
    final request = ++_historyRequest;
    if (mounted) {
      setState(() {
        if (append) {
          _loadingMore = true;
        } else {
          isLoading = true;
        }
      });
    }
    try {
      final page = await _historyRepository.fetch(
        'teesheet/myBookings',
        page: append ? _historyPage!.page + 1 : 1,
        filters: Map<String, String>.from(getDateRange(_selectedFilter)),
      );
      if (!mounted || request != _historyRequest) return;
      setState(() {
        reservations = append ? [...reservations, ...page.items] : page.items;
        _historyPage = page;
      });
    } catch (_) {
      if (mounted && request == _historyRequest) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to load history. Please retry.')),
        );
      }
    } finally {
      if (mounted && request == _historyRequest) {
        setState(() {
          isLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _historyRequest++;
    _historyRepository.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    print("🔄 Refreshing bookings...");
    await Future.delayed(const Duration(seconds: 1)); // simulate network call
    final now = DateTime.now();
    _selectedFilter = "Upcoming";
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
    fetchMyBookings();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
    fetchMyBookings();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   fetchMyBookings(); // Safe place to trigger load
  // }

  int? editingIndex;
  int selectedIndex = 0;
  // index 0 is "All"

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
            offset: const Offset(0, 30),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 0,
                ), // Adjust horizontal padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filterOptions.map((option) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = option;
                          // Call fetchMyBookings with the selected date range
                          fetchMyBookings();
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
                                ? AppColors.accent
                                : AppColors.ink,
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

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.startsWith('#')) hexString = hexString.substring(1);
    if (hexString.length == 6) buffer.write('ff'); // default opacity
    buffer.write(hexString);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !isLoading && _historyPage?.hasMore == true
          ? FloatingActionButton.extended(
              onPressed:
                  _loadingMore ? null : () => fetchMyBookings(append: true),
              label: Text(_loadingMore ? 'Loading…' : 'Load more'),
              icon: const Icon(Icons.expand_more),
            )
          : null,
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
        activeTile: 'My Reservations',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            // Use AlwaysScrollableScrollPhysics to ensure the pull-to-refresh
            // gesture is always available, even if the content is not overflowing.
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceMuted,
                        width: double.infinity,
                        // ⚠️ Removed the fixed height to allow the content to determine the height
                        // and become scrollable.
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          // ⚠️ Removed the nested SingleChildScrollView.
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              CompositedTransformTarget(
                                link: _layerLink,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "My Reservation",
                                        style: GoogleFonts.poppins(
                                            color: AppColors.ink,
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
                                                  color:
                                                      AppColors.textMuted),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              _selectedFilter,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.ink),
                                            ),
                                            Icon(
                                              _dropdownOverlay == null
                                                  ? Icons
                                                      .keyboard_arrow_down_rounded
                                                  : Icons
                                                      .keyboard_arrow_up_rounded,
                                              size: 22,
                                              color: AppColors.accent,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.primary, width: 1),
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
                                        "My Booking Summary",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.ink,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    if (reservations.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Text(
                                          "No Reservations Found",
                                          style: GoogleFonts.poppins(
                                            color: AppColors.ink,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    else
                                      ...reservations.map((reservation) {
                                        final courseName =
                                            reservation['golfCourse']['name'] ??
                                                'Unknown Course';
                                        final courseLogo =
                                            reservation['golfCourse']['logo'];
                                        final bookingDateRaw =
                                            reservation['date'];
                                        final bookingTimeRaw =
                                            reservation['startingSlot'];

                                        final holes =
                                            reservation['holes']?.toString() ??
                                                '-';
                                        final players = reservation['persons']
                                                ?.toString() ??
                                            '-';
                                        final carts =
                                            reservation['carts']?.toString() ??
                                                '-';
                                        final status = reservation['booking']
                                                ['status'] ??
                                            'Booked';
                                        final slotId =
                                            reservation['slotId']?.toString() ??
                                                '';

                                        Color statusColor = hexToColor(
                                          reservation['booking']['bgColor'] ??
                                              '#244065',
                                        );

                                        String bookingTime = '';
                                        if (bookingTimeRaw != null) {
                                          try {
                                            final time = DateFormat('HH:mm:ss')
                                                .parse(bookingTimeRaw);
                                            bookingTime = DateFormat('h:mma')
                                                .format(time);
                                          } catch (_) {
                                            bookingTime =
                                                bookingTimeRaw.toString();
                                          }
                                        }

                                        return Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 5, top: 5),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color(
                                                    0xFFE8E8E8), // Customize the color
                                                width:
                                                    1.0, // Customize the width
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: 75,
                                                          height: 75,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFFFFFFF),
                                                            border: Border.all(
                                                              width: 1.2,
                                                              color:
                                                                  const Color(
                                                                0xFFE8E8E8,
                                                              ),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Center(
                                                            child: Image(
                                                              image: courseLogo !=
                                                                      null
                                                                  ? NetworkImage(
                                                                      courseLogo,
                                                                    )
                                                                  : const AssetImage(
                                                                      "assets/images/bkdu2.png",
                                                                    ) as ImageProvider,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width:
                                                                10), // 👈 Space between items
                                                        SizedBox(
                                                          width: 250,
                                                          // Optional padding
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                          0xFFF7FAF4),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                    ),
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            5),
                                                                    child: Text(
                                                                      status,
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            statusColor,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      // Only show edit button if status is not 'Canceled'
                                                                      if (!reservation[
                                                                          'canceled'])
                                                                        InkWell(
                                                                          onTap:
                                                                              () {},
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                25,
                                                                            height:
                                                                                25,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: AppColors.surfaceMuted,
                                                                              borderRadius: BorderRadius.circular(50),
                                                                            ),
                                                                            child:
                                                                                const Center(
                                                                              child: Icon(
                                                                                Icons.edit,
                                                                                size: 16,
                                                                                color: AppColors.accent,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      const SizedBox(
                                                                          width:
                                                                              6),
                                                                      // reservation['checkedIn'] == false &&
                                                                      //         reservation['canceled'] ==
                                                                      //             false
                                                                      reservation[
                                                                              'isCancelable']
                                                                          ? ElevatedButton(
                                                                              // onPressed: () {
                                                                              //   // Add your cancel logic here
                                                                              // },
                                                                              onPressed: () async {
                                                                                // A pop up dialog to confirm cancellation
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text('Confirm Cancellation'),
                                                                                        content: const Text('Are you sure you want to cancel this tee time?'),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop(); // Close the dialog
                                                                                            },
                                                                                            child: const Text('No'),
                                                                                          ),
                                                                                          TextButton(
                                                                                            onPressed: () async {
                                                                                              final messenger = ScaffoldMessenger.of(context);
                                                                                              Navigator.of(context).pop(); // Close dialog

                                                                                              try {
                                                                                                final secureStorage = const FlutterSecureStorage();
                                                                                                final token = await secureStorage.read(key: 'accessToken');
                                                                                                if (token == null) throw Exception('Access token not found');


                                                                                                final payload = {
                                                                                                  "process": "Cancel"
                                                                                                };
                                                                                                final requestPayload = Map<String, dynamic>.from(payload);

                                                                                                final response = await bookingRepository.cancel(slotId, requestPayload);

                                                                                                if (response.statusCode == 200) {
                                                                                                  messenger.showSnackBar(
                                                                                                    const SnackBar(
                                                                                                      content: Text('Tee time cancelled successfully'),
                                                                                                      backgroundColor: AppColors.primary,
                                                                                                    ),
                                                                                                  );

                                                                                                  await Future.delayed(const Duration(milliseconds: 300));

                                                                                                  if (!mounted) return; // ✅ prevent setState after dispose
                                                                                                  setState(() {
                                                                                                    isLoading = true;
                                                                                                  });

                                                                                                  if (mounted) {
                                                                                                    await fetchMyBookings(); // ✅ safe call
                                                                                                  }
                                                                                                } else {
                                                                                                  print('❌ Failed to cancel tee time: ${response.statusCode}');
                                                                                                }
                                                                                              } catch (e) {
                                                                                                print('❗ Error cancelling tee time: $e');
                                                                                              }
                                                                                            },
                                                                                            child: const Text('Yes'),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                              },

                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: AppColors.primary,
                                                                                foregroundColor: Colors.white,
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // vertical padding
                                                                                minimumSize: const Size(0, 0), // disables default min height
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              child: const Text(
                                                                                "Cancel",
                                                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                                                              ),
                                                                            )
                                                                          : const SizedBox
                                                                              .shrink(),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              Text(
                                                                courseName,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: const Color(
                                                                      0xFF244065),
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                spacing: 6,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .calendar_month_outlined,
                                                                    color: Color(
                                                                        0xFF6B7280),
                                                                    size: 18,
                                                                  ),
                                                                  Text(
                                                                    bookingTime,
                                                                    style: GoogleFonts.poppins(
                                                                        color: const Color(
                                                                            0xFF6E7373),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Container(
                                                                    color: const Color(
                                                                        0xFF6E7373),
                                                                    width: 1,
                                                                    height: 15,
                                                                  ),
                                                                  Text(
                                                                    bookingDateRaw !=
                                                                            null
                                                                        ? DateFormat('EEE, MMM d')
                                                                            .format(DateFormat('EEEE dd, MMMM, yyyy').parse(bookingDateRaw))
                                                                        : "Unknown Date",
                                                                    style: GoogleFonts.poppins(
                                                                        color: const Color(
                                                                            0xFF6E7373),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xFFF7FAF4),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          6),
                                                              child: Center(
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      "Holes: ",
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color: const Color(
                                                                              0xFF6E7373),
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    Text(
                                                                      holes,
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color: const Color(
                                                                              0xFF244065),
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xFFF7FAF4),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          6),
                                                              child: Center(
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      "Players: ",
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color: const Color(
                                                                              0xFF6E7373),
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    Text(
                                                                      players,
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color: const Color(
                                                                              0xFF244065),
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xFFF7FAF4),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          6),
                                                              child: Center(
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      "Carts: ",
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color: const Color(
                                                                              0xFF6E7373),
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    Text(
                                                                      carts,
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              14,
                                                                          color: const Color(
                                                                              0xFF244065),
                                                                          fontWeight:
                                                                              FontWeight.w600),
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
                                        );
                                        // Make box dynamic
                                      }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                SizedBox(
                  height: MediaQuery.of(context).size.height -
                      15, // A bit of padding
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}
