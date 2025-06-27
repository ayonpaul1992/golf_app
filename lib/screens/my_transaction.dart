import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulf_app/components/custom_app_bar.dart';
import 'package:gulf_app/components/custom_drawer.dart';
import 'package:gulf_app/components/custom_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class MyTransactionPage extends StatefulWidget {
  final String myTransId;
  const MyTransactionPage({super.key, required this.myTransId});

  @override
  State<StatefulWidget> createState() => MyTransactionPageState();
}

class MyTransactionPageState extends State<MyTransactionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _dateController = TextEditingController();
  final searchBarText = TextEditingController();
  bool isLoading = false;
  String? nomineedobError;
  final LayerLink _layerLink = LayerLink();

  List<Map<String, dynamic>> transactions = [];

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

    fetchTransactions(); // Fetch transactions when the page loads
  }

  Map<String, String> getDateRange(String filter) {
    final now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;

    switch (filter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate;
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

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
    });
    try {
      final token = await secureStorage.read(key: 'accessToken');
      final response = await http.get(
        Uri.parse(
            'https://api.dev.driverpos.io/api/v1/report/myTransactions?startDate=${getDateRange(_selectedFilter)['startDate']}&endDate=${getDateRange(_selectedFilter)['endDate']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          transactions = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
        // return data['transactions'] ?? [];
        // return data['data'] ?? []; // Replace with actual data when ready
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      // Handle error as needed
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  int? editingIndex;
  int selectedIndex = 0; // index 0 is "All"

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
                    horizontal: 0), // Adjust horizontal padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFB2C1C0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filterOptions.map((option) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = option;
                          print("Selected filter: $_selectedFilter");
                          fetchTransactions(); // Fetch transactions with the new filter
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
                                ? const Color(0xFF669933)
                                : const Color(0xFF244065),
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
        onTileTap: (selectedTile) {},
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9ECF9A),
              ),
            )
          : Container(
              color: const Color(0xFFFAFCFA),
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
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "My Transactions",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF244065),
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
                                          color: const Color(0xFF6E7373)),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _selectedFilter,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF244065)),
                                    ),
                                    Icon(
                                      _dropdownOverlay == null
                                          ? Icons.keyboard_arrow_down_rounded
                                          : Icons.keyboard_arrow_up_rounded,
                                      size: 22,
                                      color: const Color(0xFF669933),
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
                      ...transactions.map((transaction) {
                        final orderId = transaction['orderId'] ?? '';
                        final createdAt = transaction['createdAt'] ?? '';
                        final orderItems = List<Map<String, dynamic>>.from(
                            transaction['orderItems'] ?? []);
                        final paymentDetails =
                            transaction['paymentDetails'] ?? {};
                        final paymentType = paymentDetails['paymentType'] ?? '';
                        final lastFour =
                            paymentDetails['lastFour']?.toString() ?? '';
                        final totalAmount = transaction['totalAmount'] ?? 0.0;

                        // Find Green Fees and Products
                        orderItems.firstWhere(
                          (item) => (item['name'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains('green'),
                          orElse: () => {},
                        );
                        final products = orderItems.firstWhere(
                          (item) => (item['name'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains('product'),
                          orElse: () => {},
                        );

                        // Find Tips and Fees
                        final tipsAndFees = orderItems.firstWhere(
                          (item) =>
                              (item['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains('tip') ||
                              (item['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains('fee'),
                          orElse: () => {},
                        );

                        // Payment icon and label
                        String paymentIcon = 'assets/images/cashc.png';
                        String paymentLabel = 'Cash';
                        String paymentExtra = '';
                        if (paymentType.toString().toLowerCase() == 'card') {
                          paymentIcon = 'assets/images/ccard.png';
                          paymentLabel = 'Credit Card';
                          paymentExtra =
                              lastFour.isNotEmpty ? 'ending in $lastFour' : '';
                        }

                        // Format date
                        String formattedDate = createdAt;
                        try {
                          final dt = DateFormat('MM-dd-yyyy').parse(createdAt);
                          formattedDate = DateFormat('MMM dd, yyyy').format(dt);
                        } catch (_) {}

                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xFFE9EBEB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .calendar_month_outlined,
                                                    color: Color(0xFF648683),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    formattedDate,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xFF6E7373),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Sale ID: ",
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                          0xFF244065),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    orderId,
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                          0xFF244065),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          color: Color(0xFFE9EBEB),
                                          thickness: 1.5,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 12),
                                          child: Column(
                                            children: [
                                              if (products.isNotEmpty)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${products['name'] ?? 'Products'}${products['quantity'] != null ? ' (${products['quantity']})' : ''}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF244065),
                                                      ),
                                                    ),
                                                    Text(
                                                      "\$${(products['amount'] ?? 0).toStringAsFixed(2)}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: const Color(
                                                            0xFF669933),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (tipsAndFees.isNotEmpty)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      tipsAndFees['name'] ??
                                                          'Tips and Fees',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF244065),
                                                      ),
                                                    ),
                                                    Text(
                                                      "\$${(tipsAndFees['amount'] ?? 0).toStringAsFixed(2)}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: const Color(
                                                            0xFF669933),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          color: Color(0xFFE9EBEB),
                                          thickness: 1.5,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 12),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Total",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xFF244065),
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$${totalAmount.toStringAsFixed(2)}",
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                          0xFF669933),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          color: Color(0xFFE9EBEB),
                                          thickness: 1.5,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 12),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Payment type: ",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF6E7373),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Image.asset(
                                                    paymentIcon,
                                                    width: paymentType
                                                                .toString()
                                                                .toLowerCase() ==
                                                            'card'
                                                        ? 17.88
                                                        : 23,
                                                    height: paymentType
                                                                .toString()
                                                                .toLowerCase() ==
                                                            'card'
                                                        ? 13.75
                                                        : 23,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    paymentLabel,
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                          0xFF244065),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (paymentExtra.isNotEmpty)
                                                    Text(
                                                      " $paymentExtra",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: const Color(
                                                            0xFF6E7373),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        );
                      }),
                      transactions.isEmpty
                          ? Center(
                              child: Text(
                                'No transactions found',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: const Color(0xFF244065),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }
}
