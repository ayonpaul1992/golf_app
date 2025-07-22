// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:http/http.dart' as http;

class TabCardScreenPage extends StatefulWidget {
  final String tabcardId;

  const TabCardScreenPage({super.key, required this.tabcardId});

  @override
  State<StatefulWidget> createState() => _TabCardScreenPageState();
}

class _TabCardScreenPageState extends State<TabCardScreenPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool showAll = false;
  bool showAllRchk = false;
  bool showAllGCrd = false;
  bool isLoading = true;

  final ScrollController _scrollController = ScrollController();
  final List<double> amounts = List.generate(10, (index) {
    return index.isEven ? 100.00 + index : -50.00 - index;
  });
  final List<String> imagePaths = [
    'assets/images/bkdu1.png',
    'assets/images/bkdu2.png',
    'assets/images/bkdu3.png',
  ];

  late TabController _tabController;
  String userName = "";
  num totalStoreCredits = 0.00; // Example value, replace with actual data
  num totalRainchecks = 0.00; // Example value, replace with actual data
  num totalGiftCards = 0.00; // Example value, replace with actual data
  List<Map<String, dynamic>> history = [];
  List<Map<String, dynamic>> rainChecks = [];
  List<Map<String, dynamic>> giftCards = [];

  @override
  void initState() {
    super.initState();
    fetchStoreCredits();
    fetchRainchecks();
    fetchGiftCards();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // so our custom tab updates when selected tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchStoreCredits() async {
    const String apiUrl =
        'https://api.dev.driverpos.io/api/v1/storecredit/myStoreCredit?limit=20&page=1';
    final String? token = await secureStorage.read(key: 'accessToken');

    try {
      final response = Uri.parse(apiUrl).resolveUri(Uri());

      final httpResponse = await http.get(
        response,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (httpResponse.statusCode == 200) {
        final responseData =
            jsonDecode(httpResponse.body) as Map<String, dynamic>;
        print('Store Credits: $responseData');

        // ✅ Get stored name BEFORE setState
        String? storedName = await secureStorage.read(key: 'userName');

        setState(() {
          userName = storedName ?? '';
          totalStoreCredits = responseData['data']['credit'];

          history = List<Map<String, dynamic>>.from(
              responseData['data']['history'] ?? []);
          isLoading = false; // Set loading to false after fetching data
        });

        print('User Name: $userName');
      }
    } catch (e) {
      debugPrint('Error fetching store credits: $e');
    }
  }

  Future<void> fetchRainchecks() async {
    const String apiUrl =
        'https://api.dev.driverpos.io/api/v1/raincheck/myRainChecks?limit=20&page=1';
    final String? token = await secureStorage.read(key: 'accessToken');

    try {
      final response = Uri.parse(apiUrl).resolveUri(Uri());

      final httpResponse = await http.get(
        response,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (httpResponse.statusCode == 200) {
        final responseData =
            jsonDecode(httpResponse.body) as Map<String, dynamic>;

        totalRainchecks = responseData['amount']['totalAmount'] ?? 0.00;
        rainChecks =
            List<Map<String, dynamic>>.from(responseData['data'] ?? []);

        print('Rainchecks data : $responseData');
        print('Total Rainchecks: $totalRainchecks');

        // ✅ Get stored name BEFORE setState

        // setState(() {
        //   userName = storedName ?? '';
        //   totalStoreCredits = responseData['data']['credit'];

        //   history = List<Map<String, dynamic>>.from(
        //       responseData['data']['history'] ?? []);
        //   isLoading = false; // Set loading to false after fetching data
        // });
      }
    } catch (e) {
      debugPrint('Error fetching store credits: $e');
    }
  }

  Future<void> fetchGiftCards() async {
    const String apiUrl =
        'https://api.dev.driverpos.io/api/v1/giftCard/myGiftCards?limit=20&page=1';
    final String? token = await secureStorage.read(key: 'accessToken');

    try {
      final response = Uri.parse(apiUrl).resolveUri(Uri());

      final httpResponse = await http.get(
        response,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (httpResponse.statusCode == 200) {
        final responseData =
            jsonDecode(httpResponse.body) as Map<String, dynamic>;

        totalGiftCards =
            responseData['amount']['totalRemainingBalance'] ?? 0.00;

        giftCards = List<Map<String, dynamic>>.from(responseData['data']);

        print('Gift Cards data : ${giftCards.length}');

        print('Giftcards data : $responseData');
        print('Total Giftcards: $totalGiftCards');

        // ✅ Get stored name BEFORE setState

        // setState(() {
        //   userName = storedName ?? '';
        //   totalStoreCredits = responseData['data']['credit'];

        //   history = List<Map<String, dynamic>>.from(
        //       responseData['data']['history'] ?? []);
        //   isLoading = false; // Set loading to false after fetching data
        // });
      }
    } catch (e) {
      debugPrint('Error fetching store credits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.tabcardId,
        showLeading: true,
        isOnProfilePage: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {},
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: _tabController.index,
                      children: [
                        _buildStoreCredits(),
                        _buildRainchecks(),
                        _buildGiftCards(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 310, // adjust if needed
                left: 0,
                right: 0,
                child: _buildCustomTabBar(),
              ),
            ]),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }

  Widget _buildCustomTabBar() {
    final tabs = ['Store Credits', 'Rainchecks', 'Gift Cards'];

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = _tabController.index == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                print('Selected tab: ${tabs[index]}');

                if (tabs[index] == 'Store Credits') {
                  // _scrollController.jumpTo(0); // Scroll to top for Store Credits
                } else if (tabs[index] == 'Rainchecks') {
                  // _scrollController.jumpTo(0); // Scroll to top for Rainchecks
                  print('Jumping to top for Rainchecks');
                } else if (tabs[index] == 'Gift Cards') {
                  // _scrollController.jumpTo(0); // Scroll to top for Gift Cards
                }

                _tabController.animateTo(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF9ECF9A)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // subtle shadow
                      blurRadius: 6,
                      offset: const Offset(0, 3), // horizontal: 0, vertical: 3
                    ),
                  ],
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF244065),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStoreCredits() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 0),
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 30),
            color: const Color(0xFF244065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF5F6FB),
                          radius: 25,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF9ECF9A),
                            radius: 16,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $userName',
                              style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Welcome to your wallet',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFFEDEFFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     _circleButton(Icons.notifications),
                    //     const SizedBox(width: 8),
                    //     _circleButton(Icons.settings,
                    //         color: const Color(0xFF9ECF9A)),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/images/str_cdt_scrn.png',
                      ), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Store Credits',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                            text: '\$',
                            style: GoogleFonts.nunito(
                                fontSize: 34,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w800),
                            children: [
                              TextSpan(
                                text: totalStoreCredits.toStringAsFixed(2),
                              )
                            ]),
                      ),
                      Text(
                        '',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildStoreCreditGroup(),
        ],
      ),
    );
  }

  Widget _buildRainchecks() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 0),
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 30),
            color: const Color(0xFF244065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF5F6FB),
                          radius: 25,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF9ECF9A),
                            radius: 16,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $userName',
                              style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Welcome to your wallet',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFFEDEFFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     _circleButton(Icons.notifications),
                    //     const SizedBox(width: 8),
                    //     _circleButton(Icons.settings,
                    //         color: const Color(0xFF9ECF9A)),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/rainchecks_scrn.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Rainchecks',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                            text: '\$',
                            style: GoogleFonts.nunito(
                                fontSize: 34,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w800),
                            children: [
                              TextSpan(
                                text: totalRainchecks.toStringAsFixed(2),
                              )
                            ]),
                      ),
                      Text('You available earned',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      Text('',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildRainchecksList(),
        ],
      ),
    );
  }

  Widget _buildGiftCards() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 0),
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 30),
            color: const Color(0xFF244065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF5F6FB),
                          radius: 25,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF9ECF9A),
                            radius: 16,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $userName',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Welcome to your wallet',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFFEDEFFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     _circleButton(Icons.notifications),
                    //     const SizedBox(width: 8),
                    //     _circleButton(Icons.settings,
                    //         color: const Color(0xFF9ECF9A)),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/gft_scrn.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '\$',
                          style: GoogleFonts.nunito(
                              fontSize: 34,
                              color: const Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w800),
                          children: [
                            TextSpan(
                              text: totalGiftCards.toStringAsFixed(2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'For purchases in store.',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildGiftCardList(),
        ],
      ),
    );
  }

  Widget _buildGiftCardList() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        interactive: true,
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: giftCards.isNotEmpty
              ? giftCards.length + 1 // header + gift cards
              : 1, // only header if no gift cards
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 18, top: 30),
                child: Text(
                  'My Gift Cards',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF244065),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            } else {
              // Transaction items
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: giftCard(giftCards[index - 1]),
              );
            }

            // if (index == 0) {
            //   return Padding(
            //     padding: const EdgeInsets.only(left: 18, top: 30),
            //     child: Text(
            //       'My Gift Cards',
            //       style: GoogleFonts.nunito(
            //         color: const Color(0xFF244065),
            //         fontSize: 18,
            //         fontWeight: FontWeight.w700,
            //       ),
            //     ),
            //   );
            // } else if (index <= (giftCards.length)) {
            //   return Padding(
            //     padding: const EdgeInsets.only(top: 10),
            //     child: giftCard(giftCards[index]),
            //   );
            // } else {
            //   return IconButton(
            //     onPressed: () {
            //       setState(() {
            //         showAllGCrd = !showAllGCrd;
            //       });
            //       if (showAllGCrd) {
            //         Future.delayed(const Duration(milliseconds: 100), () {
            //           if (_scrollController.hasClients) {
            //             _scrollController.animateTo(
            //               _scrollController.position.maxScrollExtent,
            //               duration: const Duration(milliseconds: 300),
            //               curve: Curves.easeOut,
            //             );
            //           }
            //         });
            //       }
            //     },
            //     icon: Icon(
            //       showAllGCrd
            //           ? Icons.keyboard_arrow_up_sharp
            //           : Icons.keyboard_arrow_down_sharp,
            //       color: const Color(0xFF244065),
            //       size: 30,
            //     ),
            //   );
            // }
          },
        ),
      ),
    );
  }

  Widget _buildStoreCreditGroup() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        interactive: true,
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: false, // ✅ FIXED: allow scrolling
          itemCount: history.isNotEmpty
              ? history.length + 1
              : 1, // header + transactions
          itemBuilder: (context, index) {
            if (index == 0) {
              // Header
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 18,
                      top: 30,
                    ),
                    child: Text(
                      'Recent Transactions',
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF244065),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Transaction items
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: recentTransactionGroup(history[index - 1]),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildRainchecksList() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 300, // or whatever max you want
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        interactive: true,
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: rainChecks.isNotEmpty
              ? rainChecks.length + 1
              : 1, // header + cards + button
          itemBuilder: (context, index) {
            if (index == 0) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18, top: 30),
                    child: Text(
                      'Available Rainchecks',
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF244065),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Transaction items
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: raincheckCard(rainChecks[index - 1]),
              );
            }

            // if (index == 0) {
            //   return Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.only(left: 18, top: 30),
            //         child: Text(
            //           'Available Rainchecks',
            //           style: GoogleFonts.nunito(
            //             color: const Color(0xFF244065),
            //             fontSize: 18,
            //             fontWeight: FontWeight.w700,
            //           ),
            //         ),
            //       ),
            //     ],
            //   );
            // } else if (index <= (rainChecks.length)) {
            //   // index-1 because index=0 is header
            //   // final imagePath = imagePaths[(index - 1) % imagePaths.length];
            //   return Padding(
            //     padding: const EdgeInsets.only(top: 10),
            //     child: raincheckCard(rainChecks[index]),
            //   );
            // }
            // return null;
            // else {
            //   return IconButton(
            //     onPressed: () {
            //       setState(() {
            //         showAllRchk = !showAllRchk;
            //       });
            //       if (showAllRchk) {
            //         Future.delayed(const Duration(milliseconds: 100), () {
            //           if (_scrollController.hasClients) {
            //             _scrollController.animateTo(
            //               _scrollController.position.maxScrollExtent,
            //               duration: const Duration(milliseconds: 300),
            //               curve: Curves.easeOut,
            //             );
            //           }
            //         });
            //       }
            //     },
            //     icon: Icon(
            //       showAllRchk
            //           ? Icons.keyboard_arrow_up_sharp
            //           : Icons.keyboard_arrow_down_sharp,
            //       color: const Color(0xFF244065),
            //       size: 30,
            //     ),
            //   );
            // }
          },
        ),
      ),
    );
  }

  Widget giftCard(giftCards) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gift Cards',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF9D9FB2),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  giftCards['golfCourse']['name'],
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF244065),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            giftCards['number'],
            style: GoogleFonts.nunito(
              color: const Color(0xFF244065),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Divider(
            color: Color(0xFFD4D4D4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${giftCards['remainingBalance'].toStringAsFixed(2)}',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF669933),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                    'Purchased At: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(giftCards['createdAt']))}',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF244065),
                        fontSize: 13,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget recentTransactionGroup(history) {
    // final isNegative = amount < 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        history['operation'] == 'Sub'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: history['operation'] == 'Sub'
                            ? const Color(0xFFE53935) // red
                            : const Color(0xFF669933), // green
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '${history['paymentType']} ',
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF244065),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          children: const [
                            TextSpan(
                              text: '',
                            )
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('d MMM yyyy').format(
                          DateTime.parse(history['usedAt']),
                        ),
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF9D9FB2),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '\$',
                      style: GoogleFonts.nunito(
                        color: history['operation'] == 'Sub'
                            ? const Color(0xFFE53935) // red
                            : const Color(0xFF669933), // green
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: history['amount'].abs().toStringAsFixed(2),
                        )
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Bal. ',
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF244065),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                      children: [
                        const TextSpan(text: '\$'),
                        TextSpan(
                          text: history['remainingBalance'].toStringAsFixed(2),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xFFD4D4D4),
          ),
        ],
      ),
    );
  }

  Widget raincheckCard(rainCheck) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 0),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDDECDC), // left
            Color(0xFFFFFFFF), // right
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.1), // light gray shadow
                        blurRadius: 6,
                        offset:
                            const Offset(0, 3), // horizontal: 0, vertical: 3
                      ),
                    ],
                  ),
                  child: Center(
                    // child: Image.asset(
                    //   rainCheck['golfCourse']['logo'],
                    //   width: 35,
                    //   height: 35,
                    // ),

                    child: Image(
                      image: rainCheck['golfCourse']['logo'].isNotEmpty
                          ? NetworkImage(rainCheck['golfCourse']['logo'])
                          : const AssetImage("assets/images/profile_prsn.jpg")
                              as ImageProvider,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rainCheck['rainCheckNumber'],
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF244065),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text.rich(TextSpan(
                        text: 'Issued on ',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9D9FB2)),
                        children: [
                          TextSpan(
                            text: DateFormat('yyyy-MM-dd').format(
                              DateTime.parse(rainCheck['issuedAt']),
                            ),
                          ),
                        ]))
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Color(0xFFD4D4D4)),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Available: ',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF244065),
                          fontSize: 13),
                    ),
                    Text.rich(
                      TextSpan(
                        text: '\$',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF669933),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        children: [
                          TextSpan(
                            text: rainCheck['amount'].toStringAsFixed(2),
                            style: GoogleFonts.nunito(
                              color: const Color(0xFF669933),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    text: 'Expire on: ',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF244065),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF244065),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, {Color? color}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(width: 1, color: const Color(0xFF949FD5)),
      ),
      child: Icon(icon, size: 17, color: color ?? const Color(0xFFA5A5A5)),
    );
  }
}
