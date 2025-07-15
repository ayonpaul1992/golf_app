// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';

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

  @override
  void initState() {
    super.initState();
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
      body: Stack(
        children:[
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
        ]
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }

  Widget _buildCustomTabBar() {
    final tabs = ['Store Credits', 'Rainchecks', 'Gift Cards'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = _tabController.index == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
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
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF244065),
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
            padding: const EdgeInsets.only(
                left: 15, right: 15, top: 30, bottom: 30),
            color: const Color(0xFF244065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF5F6FB),
                          radius: 25,
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF9ECF9A),
                            radius: 16,
                            child: const Icon(Icons.person,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Maulik',
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
                    Row(
                      children: [
                        _circleButton(Icons.notifications),
                        const SizedBox(width: 8),
                        _circleButton(Icons.settings, color: const Color(0xFF9ECF9A)),
                      ],
                    ),
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
                          'assets/images/str_cdt_scrn.png'), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Store Credits',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      Text.rich(
                        TextSpan(
                            text: '\$',
                            style: GoogleFonts.nunito(
                                fontSize: 34,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w800),
                            children: const [
                              TextSpan(text: '5870.00')
                            ]),
                      ),
                      Text(
                        '',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFFFFFFFF)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Maulik Seith',
                        style: GoogleFonts.nunito(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
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
            padding: const EdgeInsets.only(
                left: 15, right: 15, top: 30, bottom: 30),
            color: const Color(0xFF244065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF5F6FB),
                          radius: 25,
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF9ECF9A),
                            radius: 16,
                            child: const Icon(Icons.person,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Maulik',
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
                    Row(
                      children: [
                        _circleButton(Icons.notifications),
                        const SizedBox(width: 8),
                        _circleButton(Icons.settings, color: const Color(0xFF9ECF9A)),
                      ],
                    ),
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
                      Text('Total Rainchecks',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      Text.rich(
                        TextSpan(
                            text: '\$',
                            style: GoogleFonts.nunito(
                                fontSize: 34,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w800),
                            children: const [
                              TextSpan(text: '1899.00')
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
            padding: const EdgeInsets.only(
                left: 15, right: 15, top: 30, bottom: 30),
            color: const Color(0xFF244065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF5F6FB),
                          radius: 25,
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF9ECF9A),
                            radius: 16,
                            child: const Icon(Icons.person,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Maulik',
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
                    Row(
                      children: [
                        _circleButton(Icons.notifications),
                        const SizedBox(width: 8),
                        _circleButton(Icons.settings, color: const Color(0xFF9ECF9A)),
                      ],
                    ),
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
                      Text('Available Balance',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      Text.rich(
                        TextSpan(
                            text: '\$',
                            style: GoogleFonts.nunito(
                                fontSize: 34,
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w800),
                            children: const [
                              TextSpan(text: '2450.00')
                            ]),
                      ),
                      Text('For purchases in store.',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      Text('Maulik Seith',
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
          itemCount: (showAll ? 3 : 1) + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 18, top: 30),
                child: Text('My Gift Cards',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF244065),
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              );
            } else if (index <= (showAll ? 3 : 1)) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: giftCard(),
              );
            } else {
              return IconButton(
                onPressed: () {
                  setState(() {
                    showAll = !showAll;
                  });
                  if (showAll) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                },
                icon: Icon(
                  showAll
                      ? Icons.keyboard_arrow_up_sharp
                      : Icons.keyboard_arrow_down_sharp,
                  color: const Color(0xFF244065),
                  size: 30,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStoreCreditGroup(){
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
  itemCount: (showAll ? 10 : 1) + 2,
  itemBuilder: (context, index) {
  if (index == 0) {
  return Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
  Padding(
  padding: const EdgeInsets.only(left: 18, top: 30),
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
  }else if (index <= (showAll ? 10 : 1)) {
  return Padding(
  padding: const EdgeInsets.only(top: 10),
  child: recentTransactionGroup(amounts[index - 1]),
  );
  }
  else {
  return IconButton(
  onPressed: () {
  setState(() {
  showAll = !showAll;
  });
  if (showAll) {
  Future.delayed(const Duration(milliseconds: 100), () {
  if (_scrollController.hasClients) {
  _scrollController.animateTo(
  _scrollController.position.maxScrollExtent,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
  );
  }
  });
  }
  },
  icon: Icon(
  showAll
  ? Icons.keyboard_arrow_up_sharp
      : Icons.keyboard_arrow_down_sharp,
  color: const Color(0xFF244065),
  size: 30,
  ),
  );
  }
  },
  ),
  ),
  );
}

  Widget _buildRainchecksList(){
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
      itemCount: (showAll ? 3 : 1) + 2, // header + cards + button
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
        }else if (index <= (showAll ? 3 : 1)) {
          // index-1 because index=0 is header
          final imagePath = imagePaths[(index - 1) % imagePaths.length];
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: raincheckCard(imagePath),
          );
        } else {
          return IconButton(
            onPressed: () {
              setState(() {
                showAll = !showAll;
              });
              if (showAll) {
                Future.delayed(const Duration(milliseconds: 100),
                        () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
              }
            },
            icon: Icon(
              showAll
                  ? Icons.keyboard_arrow_up_sharp
                  : Icons.keyboard_arrow_down_sharp,
              color: const Color(0xFF244065),
              size: 30,
            ),
          );
        }
      },
    ),
  ),
);
}

  Widget giftCard() {
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
                Text('Gift Cards',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF9D9FB2),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('Driverpos.io',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF244065),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text('7000 3494 0946 2702',
              style: GoogleFonts.nunito(
                  color: const Color(0xFF244065),
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 15),
          const Divider(color: Color(0xFFD4D4D4)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$350.00',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF669933),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                Text('Purchased At: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
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

  Widget recentTransactionGroup(double amount) {
    final isNegative = amount < 0;

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
                        isNegative
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: isNegative
                            ? const Color(0xFFE53935) // red
                            : const Color(0xFF669933), // green
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Credits issued for PO ',
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF244065),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          children: const [
                            TextSpan(
                              text: '25475',
                            )
                          ],
                        ),
                      ),
                      Text(
                        'June 16, 2025',
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
                        color: isNegative
                            ? const Color(0xFFE53935) // red
                            : const Color(0xFF669933), // green
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: amount.abs().toStringAsFixed(2),
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
                      children: const [
                        TextSpan(text: '\$'),
                        TextSpan(text: '6905.00'),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFD4D4D4)),
        ],
      ),
    );
  }

  Widget raincheckCard(String imagePath) {
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
                    child: Image.asset(
                      imagePath,
                      width: 35,
                      height: 35,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7000 3494 0946 2702',
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
                            color: Color(0xFF9D9FB2)),
                        children: [
                          TextSpan(
                            text:
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
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
                          color: Color(0xFF244065),
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
                            text: '350.00',
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
