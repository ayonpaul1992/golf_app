import 'dart:convert';

import 'package:driver_pos/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/member_app_bar.dart';
import 'package:http/http.dart' as http;

class MembershipScreen extends StatefulWidget {
  final String mmbspId;
  const MembershipScreen({super.key, required this.mmbspId});

  @override
  State<StatefulWidget> createState() => MembershipScreenState();
}

class MembershipScreenState extends State<MembershipScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = false; // For loading the dropdown items
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerTwo = ScrollController();
  final ScrollController _scrollControllerThree = ScrollController();
  final ScrollController _scrollControllerFour = ScrollController();
  bool showAll = false;
  bool showAllTwo = false;
  bool showAllThree = false;
  bool showAllFour = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _tabController.previousIndex) {
        setState(() {}); // rebuild to update active border color
      }
    });

    fetchCurrentMembership();
  }

  Future<Map<String, dynamic>?> fetchCurrentMembership() async {
    // setState(() {
    //   isLoading = true;
    // });
    try {
      final String baseUrl = ApiConfig.baseUrl;
      final String? token = await secureStorage.read(key: 'accessToken');
      final String? golfCourse =
          await secureStorage.read(key: 'golfCourseName');

      final response = Uri.parse(
        '$baseUrl/customer/myMembership?golfCourse=$golfCourse',
      ).resolveUri(Uri());

      // Example using http package:
      final httpResponse = await http.get(response, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(httpResponse.body) as Map<String, dynamic>;
        // print(data);
        // return data;
      } else {
        return null;
      }
      // return null; // Remove this and uncomment above for real API
    } catch (e) {
      // Handle error
      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _scrollControllerTwo.dispose();
    _scrollControllerThree.dispose();
    _scrollControllerFour.dispose();
    super.dispose();
  }

  Widget giftCard() {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E29D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Image.asset(
                "assets/images/ftr_teesheet.png",
                width: 15,
                height: 15,
                color: Colors.white,
              ),
              RichText(
                text: TextSpan(
                  text: "Gold Couples Membership - ", // 👈 first part
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF244065),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  children: const [
                    TextSpan(
                      text: "\$", // 👈 styled part
                    ),
                    TextSpan(
                      text: "1000", // 👈 last part
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.transparent, // 👈 keeps your table bg visible
              borderRadius: BorderRadius.circular(12), // 👈 Rounded corners
              border: Border.all(
                color: const Color(0xFFFFFFFF),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Table(
              border: const TableBorder(
                top: BorderSide(color: Color(0x000fffff), width: 0),
                bottom: BorderSide(color: Color(0x000fffff), width: 0),
                left: BorderSide(color: Color(0x000fffff), width: 0),
                right: BorderSide(color: Color(0x000fffff), width: 0),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                // Header Row
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Time/Day",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "9 Holes",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "18 Holes",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),

                // Row 1
                TableRow(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1), // 👈 bottom border
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Weekday",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF3F4B4B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Mon ",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                                children: const [
                                  TextSpan(text: "-"),
                                  TextSpan(text: "Thu"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Column 2
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFE8E8E8), width: 1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "18.00")],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "14.00")],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Column 3
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFE8E8E8), width: 1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "24.00")],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "17.00")],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Row 2
                TableRow(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1), // 👈 bottom border
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Weekday",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF3F4B4B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Fri ",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                                children: const [
                                  TextSpan(text: "-"),
                                  TextSpan(text: "Sun"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Column 2
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFE8E8E8), width: 1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "18.00")],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "14.00")],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Column 3
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFE8E8E8), width: 1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "24.00")],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F4B4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                                children: const [TextSpan(text: "17.00")],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Row 3
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Weekday",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF3F4B4B),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "Fri ",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF3F4B4B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                              children: const [
                                TextSpan(text: "-"),
                                TextSpan(text: "Sun"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Column 2
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "\$",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF3F4B4B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              children: const [TextSpan(text: "18.00")],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "\$",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF3F4B4B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              children: const [TextSpan(text: "14.00")],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Column 3
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "\$",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF3F4B4B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              children: const [TextSpan(text: "24.00")],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "\$",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF3F4B4B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              children: const [TextSpan(text: "17.00")],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabContentOne() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: (showAll ? 3 : 1) + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(left: 18, top: 20),
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

  Widget buildTabContentTwo() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Scrollbar(
        controller: _scrollControllerTwo,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollControllerTwo,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: (showAllTwo ? 3 : 1) + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(left: 18, top: 20),
                // child: Text(
                //   'My Gift Cards',
                //   style: GoogleFonts.nunito(
                //     color: const Color(0xFF244065),
                //     fontSize: 18,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
              );
            } else if (index <= (showAllTwo ? 3 : 1)) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: giftCard(),
              );
            } else {
              return IconButton(
                onPressed: () {
                  setState(() {
                    showAllTwo = !showAllTwo;
                  });
                  if (showAllTwo) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (_scrollControllerTwo.hasClients) {
                        _scrollControllerTwo.animateTo(
                          _scrollControllerTwo.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                },
                icon: Icon(
                  showAllTwo
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

  Widget buildTabContentThree() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Scrollbar(
        controller: _scrollControllerThree,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollControllerThree,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: (showAllThree ? 3 : 1) + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(left: 18, top: 20),
                // child: Text(
                //   'My Gift Cards',
                //   style: GoogleFonts.nunito(
                //     color: const Color(0xFF244065),
                //     fontSize: 18,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
              );
            } else if (index <= (showAllThree ? 3 : 1)) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: giftCard(),
              );
            } else {
              return IconButton(
                onPressed: () {
                  setState(() {
                    showAllThree = !showAllThree;
                  });
                  if (showAll) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (_scrollControllerThree.hasClients) {
                        _scrollControllerThree.animateTo(
                          _scrollControllerThree.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                },
                icon: Icon(
                  showAllThree
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

  Widget buildTabContentFour() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Scrollbar(
        controller: _scrollControllerFour,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollControllerFour,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: (showAllFour ? 3 : 1) + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(left: 18, top: 20),
                // child: Text(
                //   'My Gift Cards',
                //   style: GoogleFonts.nunito(
                //     color: const Color(0xFF244065),
                //     fontSize: 18,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
              );
            } else if (index <= (showAllFour ? 3 : 1)) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: giftCard(),
              );
            } else {
              return IconButton(
                onPressed: () {
                  setState(() {
                    showAllFour = !showAllFour;
                  });
                  if (showAll) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (_scrollControllerFour.hasClients) {
                        _scrollControllerFour.animateTo(
                          _scrollControllerFour.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                },
                icon: Icon(
                  showAllFour
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

  final tabs = ['Single', 'Senior', 'Couple', 'Others'];

  final List<Color> tabColors = [
    const Color(0xFFF4B285), // Color for inactive tabs
    const Color(0xFF998AC0), // Color for the active "Senior" tab
    const Color(0xFF91B0DB),
    const Color(0xFFC795BF),
  ];

  Future<void> _launchMailURL() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@wealthclockadvisors.com',
      // Optionally add query parameters like subject/body
      // queryParameters: {
      //   'subject': 'Your Subject Here',
      //   'body': 'Hello, I have a query...',
      // },
    );

    if (!await launchUrl(emailUri)) {
      throw 'Could not launch email app';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: MemberShipAppBar(
        scaffoldKey: _scaffoldKey,
        mmbspId: widget.mmbspId, // ✅ Pass the correct userId
        showLeading: true, // ✅ Set to true to show the back button

        onBackPressed: () {
          Navigator.pop(context); // Optional: customize back behavior if needed
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
              SingleChildScrollView(
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
                        "Current Membership Plan",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
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
              const SizedBox(
                height: 10,
              ),
              Stack(
                clipBehavior: Clip.none, // 👈 allows children to overflow
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9ECF9A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Image.asset(
                              "assets/images/ftr_teesheet.png",
                              width: 15,
                              height: 15,
                              color: Colors.white,
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Public Daily Fee - ", // 👈 first part
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                children: const [
                                  TextSpan(
                                    text: "\$", // 👈 styled part
                                  ),
                                  TextSpan(
                                    text: "0", // 👈 last part
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors
                                .transparent, // 👈 keeps your table bg visible
                            borderRadius:
                                BorderRadius.circular(12), // 👈 Rounded corners
                            border: Border.all(
                              color: const Color(0xFFE8E8E8),
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Table(
                            border: const TableBorder(
                              top: BorderSide(
                                  color: Color(0xFFE8E8E8), width: 0),
                              bottom: BorderSide(
                                  color: Color(0xFFE8E8E8), width: 0),
                              left: BorderSide(
                                  color: Color(0xFFE8E8E8), width: 0),
                              right: BorderSide(
                                  color: Color(0xFFE8E8E8), width: 0),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                            },
                            children: [
                              // Header Row
                              TableRow(
                                decoration: const BoxDecoration(
                                    color: Color(0xFFE8E8E8)),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Time/Day",
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "9 Holes",
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "18 Holes",
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFF244065),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),

                              // Row 1
                              TableRow(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFE8E8E8),
                                            width: 1), // 👈 bottom border
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Weekday",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Mon ",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500),
                                              children: const [
                                                TextSpan(text: "-"),
                                                TextSpan(text: "Thu"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Column 2
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFE8E8E8), width: 1),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "18.00")
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "14.00")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Column 3
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFE8E8E8), width: 1),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "24.00")
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "17.00")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Row 2
                              TableRow(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFE8E8E8),
                                            width: 1), // 👈 bottom border
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Weekday",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Fri ",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500),
                                              children: const [
                                                TextSpan(text: "-"),
                                                TextSpan(text: "Sun"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Column 2
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFE8E8E8), width: 1),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "18.00")
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "14.00")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Column 3
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFE8E8E8), width: 1),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "24.00")
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "\$",
                                              style: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                              children: const [
                                                TextSpan(text: "17.00")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Row 3
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Weekday",
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFFFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: "Fri ",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500),
                                            children: const [
                                              TextSpan(text: "-"),
                                              TextSpan(text: "Sun"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Column 2
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: "\$",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                            children: const [
                                              TextSpan(text: "18.00")
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: "\$",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                            children: const [
                                              TextSpan(text: "14.00")
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Column 3
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: "\$",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                            children: const [
                                              TextSpan(text: "24.00")
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: "\$",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xFFFFFFFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                            children: const [
                                              TextSpan(text: "17.00")
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -22,
                    left: 0,
                    right: 0, // ✅ makes it span full width
                    child: Center(
                      // ✅ centers the button horizontally
                      child: SizedBox(
                        width: 200, // button width
                        child: ElevatedButton(
                          onPressed: () {
                            // 👉 Put your logout logic here
                            _launchMailURL();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF244065),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // ✅ keeps content tight
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Upgrade Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                  width: 5), // spacing between text and icon
                              const Icon(
                                Icons.keyboard_arrow_right,
                                size: 22,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SingleChildScrollView(
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
                        "Other Membership Plans",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF244065),
                            fontSize: 14,
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
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity, // full width
                    child: TabBar(
                      tabAlignment: TabAlignment.start,
                      controller: _tabController,
                      isScrollable: true,
                      indicator: const BoxDecoration(),
                      indicatorPadding: EdgeInsets.zero,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(
                          horizontal: 5), // no extra padding
                      dividerColor: Colors.transparent,
                      labelColor: const Color(0xFF5E82B4),
                      unselectedLabelColor: Colors.white,
                      tabs: List.generate(tabs.length, (index) {
                        bool isSelected = _tabController.index == index;
                        return Tab(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: tabColors[index],
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF5E82B4),
                                      width: 1.5)
                                  : Border.all(color: Colors.transparent),
                            ),
                            child: Text(
                              tabs[index],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 450,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        buildTabContentOne(),
                        buildTabContentTwo(),
                        buildTabContentThree(),
                        buildTabContentFour(),
                      ],
                    ),
                  ),
                ],
              )
            ],
          )),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }
}
