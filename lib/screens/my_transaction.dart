import 'package:driver_pos/theme/app_theme.dart';
import '../models/history_page.dart';
import '../repositories/history_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
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

  Future<void> _handleRefresh() async {
    print("🔄 Refreshing bookings...");
    await Future.delayed(const Duration(seconds: 1)); // simulate network call
    final now = DateTime.now();
    _selectedFilter = "This month";
    _dateController.text = DateFormat("MMM dd, yyyy").format(now);
    fetchTransactions();
  }

  final _historyRepository = HistoryRepository();
  HistoryPage? _historyPage;
  bool _loadingMore = false;
  int _historyRequest = 0;

  Future<void> fetchTransactions({bool append = false}) async {
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
        'report/myTransactions',
        page: append ? _historyPage!.page + 1 : 1,
        filters: Map<String, String>.from(getDateRange(_selectedFilter)),
      );
      if (!mounted || request != _historyRequest) return;
      setState(() {
        transactions = append ? [...transactions, ...page.items] : page.items;
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
    _dropdownOverlay?.remove();
    super.dispose();
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
                  border: Border.all(color: AppColors.border),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !isLoading && _historyPage?.hasMore == true
          ? FloatingActionButton.extended(
              onPressed:
                  _loadingMore ? null : () => fetchTransactions(append: true),
              label: Text(_loadingMore ? 'Loading…' : 'Load more'),
              icon: const Icon(Icons.expand_more),
            )
          : null,
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
        activeTile: 'My Transactions',
        onTileTap: (selectedTile) {},
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  color: AppColors.pageBackground,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                            color: AppColors.textMuted),
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
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
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
                        ...transactions.map((transaction) {
                          final orderId = transaction['orderId'] ?? '';
                          final createdAt = transaction['createdAt'] ?? '';
                          final orderItems = List<Map<String, dynamic>>.from(
                              transaction['orderItems'] ?? []);
                          final paymentDetails =
                              transaction['paymentDetails'] ?? {};
                          final paymentType =
                              paymentDetails['paymentType'] ?? '';
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

                          // Find Tips and Fees

                          // Payment icon and label
                          String paymentIcon = 'assets/images/cashc.png';
                          String paymentLabel = 'Cash';
                          String paymentExtra = '';
                          if (paymentType.toString().toLowerCase() == 'card') {
                            paymentIcon = 'assets/images/ccard.png';
                            paymentLabel = 'Credit Card';
                            paymentExtra = lastFour.isNotEmpty
                                ? 'ending in $lastFour'
                                : '';
                          }

                          // Format date
                          String formattedDate = createdAt;
                          try {
                            final dt =
                                DateFormat('MM-dd-yyyy').parse(createdAt);
                            formattedDate =
                                DateFormat('MMM dd, yyyy').format(dt);
                          } catch (_) {}

                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: AppColors.disabled,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_month_outlined,
                                                      color: AppColors.textSubtle,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      formattedDate,
                                                      style:
                                                          GoogleFonts.poppins(
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
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: const Color(
                                                            0xFF244065),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      orderId,
                                                      style:
                                                          GoogleFonts.poppins(
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
                                            color: AppColors.disabled,
                                            thickness: 1.5,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7, horizontal: 12),
                                            child: Column(
                                              children: [
                                                // if (products.isNotEmpty)
                                                //   Row(
                                                //     mainAxisAlignment:
                                                //         MainAxisAlignment
                                                //             .spaceBetween,
                                                //     children: [
                                                //       Text(
                                                //         "${products['name'] ?? 'Products'}${products['quantity'] != null ? ' (${products['quantity']})' : ''}",
                                                //         style:
                                                //             GoogleFonts.poppins(
                                                //           fontSize: 13,
                                                //           fontWeight:
                                                //               FontWeight.w500,
                                                //           color: const Color(
                                                //               0xFF244065),
                                                //         ),
                                                //       ),
                                                //       Text(
                                                //         "\$${(products['amount'] ?? 0).toStringAsFixed(2)}",
                                                //         style:
                                                //             GoogleFonts.poppins(
                                                //           color: const Color(
                                                //               0xFF669933),
                                                //           fontSize: 13,
                                                //           fontWeight:
                                                //               FontWeight.w500,
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // if (tipsAndFees.isNotEmpty)
                                                //   Row(
                                                //     mainAxisAlignment:
                                                //         MainAxisAlignment
                                                //             .spaceBetween,
                                                //     children: [
                                                //       Text(
                                                //         tipsAndFees['name'] ??
                                                //             'Tips and Fees',
                                                //         style:
                                                //             GoogleFonts.poppins(
                                                //           fontSize: 13,
                                                //           fontWeight:
                                                //               FontWeight.w500,
                                                //           color: const Color(
                                                //               0xFF244065),
                                                //         ),
                                                //       ),
                                                //       Text(
                                                //         "\$${(tipsAndFees['amount'] ?? 0).toStringAsFixed(2)}",
                                                //         style:
                                                //             GoogleFonts.poppins(
                                                //           color: const Color(
                                                //               0xFF669933),
                                                //           fontSize: 13,
                                                //           fontWeight:
                                                //               FontWeight.w500,
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),

                                                if (orderItems.isNotEmpty)
                                                  ...orderItems
                                                      .map<Widget>((item) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "${item['name'] ?? 'Item'}${item['quantity'] != null ? ' (${item['quantity']})' : ''}",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                                0xFF244065),
                                                          ),
                                                        ),
                                                        Text(
                                                          "\$${(item['amount'] ?? 0).toStringAsFixed(2)}",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: const Color(
                                                                0xFF669933),
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                              ],
                                            ),
                                          ),
                                          const Divider(
                                            color: AppColors.disabled,
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
                                                      "\$${totalAmount.toStringAsFixed(2)}",
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
                                            color: AppColors.disabled,
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
                                                      style:
                                                          GoogleFonts.poppins(
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
                                                      style:
                                                          GoogleFonts.poppins(
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
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Text(
                                      "No Transactions Found",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.ink,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

      // body: isLoading
      //     ? const Center(
      //         child: CircularProgressIndicator(
      //           color: AppColors.primary,
      //         ),
      //       )
      //     : Container(
      //         color: AppColors.pageBackground,
      //         width: double.infinity,
      //         height: double.infinity,
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 15),
      //           child: SingleChildScrollView(
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 const SizedBox(
      //                   height: 15,
      //                 ),
      //                 CompositedTransformTarget(
      //                   link: _layerLink,
      //                   child: SizedBox(
      //                     width: double.infinity,
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text(
      //                           "My Transactions",
      //                           style: GoogleFonts.poppins(
      //                               color: AppColors.ink,
      //                               fontSize: 17,
      //                               fontWeight: FontWeight.w600),
      //                         ),
      //                         GestureDetector(
      //                           onTap: _toggleDropdown,
      //                           child: Row(
      //                             children: [
      //                               Text(
      //                                 "Filter by:",
      //                                 style: GoogleFonts.poppins(
      //                                     fontSize: 13,
      //                                     fontWeight: FontWeight.w500,
      //                                     color: AppColors.textMuted),
      //                               ),
      //                               const SizedBox(width: 5),
      //                               Text(
      //                                 _selectedFilter,
      //                                 style: GoogleFonts.poppins(
      //                                     fontSize: 13,
      //                                     fontWeight: FontWeight.w600,
      //                                     color: AppColors.ink),
      //                               ),
      //                               Icon(
      //                                 _dropdownOverlay == null
      //                                     ? Icons.keyboard_arrow_down_rounded
      //                                     : Icons.keyboard_arrow_up_rounded,
      //                                 size: 22,
      //                                 color: AppColors.accent,
      //                               )
      //                             ],
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 15,
      //                 ),
      //                 ...transactions.map((transaction) {
      //                   final orderId = transaction['orderId'] ?? '';
      //                   final createdAt = transaction['createdAt'] ?? '';
      //                   final orderItems = List<Map<String, dynamic>>.from(
      //                       transaction['orderItems'] ?? []);
      //                   final paymentDetails =
      //                       transaction['paymentDetails'] ?? {};
      //                   final paymentType = paymentDetails['paymentType'] ?? '';
      //                   final lastFour =
      //                       paymentDetails['lastFour']?.toString() ?? '';
      //                   final totalAmount = transaction['totalAmount'] ?? 0.0;

      //                   // Find Green Fees and Products
      //                   orderItems.firstWhere(
      //                     (item) => (item['name'] ?? '')
      //                         .toString()
      //                         .toLowerCase()
      //                         .contains('green'),
      //                     orElse: () => {},
      //                   );
      //                   final products = orderItems.firstWhere(
      //                     (item) => (item['name'] ?? '')
      //                         .toString()
      //                         .toLowerCase()
      //                         .contains('product'),
      //                     orElse: () => {},
      //                   );

      //                   // Find Tips and Fees
      //                   final tipsAndFees = orderItems.firstWhere(
      //                     (item) =>
      //                         (item['name'] ?? '')
      //                             .toString()
      //                             .toLowerCase()
      //                             .contains('tip') ||
      //                         (item['name'] ?? '')
      //                             .toString()
      //                             .toLowerCase()
      //                             .contains('fee'),
      //                     orElse: () => {},
      //                   );

      //                   // Payment icon and label
      //                   String paymentIcon = 'assets/images/cashc.png';
      //                   String paymentLabel = 'Cash';
      //                   String paymentExtra = '';
      //                   if (paymentType.toString().toLowerCase() == 'card') {
      //                     paymentIcon = 'assets/images/ccard.png';
      //                     paymentLabel = 'Credit Card';
      //                     paymentExtra =
      //                         lastFour.isNotEmpty ? 'ending in $lastFour' : '';
      //                   }

      //                   // Format date
      //                   String formattedDate = createdAt;
      //                   try {
      //                     final dt = DateFormat('MM-dd-yyyy').parse(createdAt);
      //                     formattedDate = DateFormat('MMM dd, yyyy').format(dt);
      //                   } catch (_) {}

      //                   return Column(
      //                     children: [
      //                       SizedBox(
      //                         width: double.infinity,
      //                         child: Column(
      //                           children: [
      //                             Container(
      //                               decoration: BoxDecoration(
      //                                 color: AppColors.surfaceMuted,
      //                                 borderRadius: BorderRadius.circular(15),
      //                                 border: Border.all(
      //                                   color: AppColors.disabled,
      //                                   width: 1,
      //                                 ),
      //                               ),
      //                               child: Column(
      //                                 children: [
      //                                   Container(
      //                                     padding: const EdgeInsets.symmetric(
      //                                         vertical: 7, horizontal: 12),
      //                                     child: Row(
      //                                       mainAxisAlignment:
      //                                           MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Row(
      //                                           children: [
      //                                             const Icon(
      //                                               Icons
      //                                                   .calendar_month_outlined,
      //                                               color: AppColors.textSubtle,
      //                                               size: 20,
      //                                             ),
      //                                             const SizedBox(width: 6),
      //                                             Text(
      //                                               formattedDate,
      //                                               style: GoogleFonts.poppins(
      //                                                 fontSize: 13,
      //                                                 fontWeight:
      //                                                     FontWeight.w500,
      //                                                 color: const Color(
      //                                                     0xFF6E7373),
      //                                               ),
      //                                             ),
      //                                           ],
      //                                         ),
      //                                         Row(
      //                                           children: [
      //                                             Text(
      //                                               "Sale ID: ",
      //                                               style: GoogleFonts.poppins(
      //                                                 color: const Color(
      //                                                     0xFF244065),
      //                                                 fontSize: 13,
      //                                                 fontWeight:
      //                                                     FontWeight.w600,
      //                                               ),
      //                                             ),
      //                                             Text(
      //                                               orderId,
      //                                               style: GoogleFonts.poppins(
      //                                                 color: const Color(
      //                                                     0xFF244065),
      //                                                 fontSize: 13,
      //                                                 fontWeight:
      //                                                     FontWeight.w600,
      //                                               ),
      //                                             ),
      //                                           ],
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                   const Divider(
      //                                     color: AppColors.disabled,
      //                                     thickness: 1.5,
      //                                   ),
      //                                   Container(
      //                                     padding: const EdgeInsets.symmetric(
      //                                         vertical: 7, horizontal: 12),
      //                                     child: Column(
      //                                       children: [
      //                                         if (products.isNotEmpty)
      //                                           Row(
      //                                             mainAxisAlignment:
      //                                                 MainAxisAlignment
      //                                                     .spaceBetween,
      //                                             children: [
      //                                               Text(
      //                                                 "${products['name'] ?? 'Products'}${products['quantity'] != null ? ' (${products['quantity']})' : ''}",
      //                                                 style:
      //                                                     GoogleFonts.poppins(
      //                                                   fontSize: 13,
      //                                                   fontWeight:
      //                                                       FontWeight.w500,
      //                                                   color: const Color(
      //                                                       0xFF244065),
      //                                                 ),
      //                                               ),
      //                                               Text(
      //                                                 "\$${(products['amount'] ?? 0).toStringAsFixed(2)}",
      //                                                 style:
      //                                                     GoogleFonts.poppins(
      //                                                   color: const Color(
      //                                                       0xFF669933),
      //                                                   fontSize: 13,
      //                                                   fontWeight:
      //                                                       FontWeight.w500,
      //                                                 ),
      //                                               ),
      //                                             ],
      //                                           ),
      //                                         if (tipsAndFees.isNotEmpty)
      //                                           Row(
      //                                             mainAxisAlignment:
      //                                                 MainAxisAlignment
      //                                                     .spaceBetween,
      //                                             children: [
      //                                               Text(
      //                                                 tipsAndFees['name'] ??
      //                                                     'Tips and Fees',
      //                                                 style:
      //                                                     GoogleFonts.poppins(
      //                                                   fontSize: 13,
      //                                                   fontWeight:
      //                                                       FontWeight.w500,
      //                                                   color: const Color(
      //                                                       0xFF244065),
      //                                                 ),
      //                                               ),
      //                                               Text(
      //                                                 "\$${(tipsAndFees['amount'] ?? 0).toStringAsFixed(2)}",
      //                                                 style:
      //                                                     GoogleFonts.poppins(
      //                                                   color: const Color(
      //                                                       0xFF669933),
      //                                                   fontSize: 13,
      //                                                   fontWeight:
      //                                                       FontWeight.w500,
      //                                                 ),
      //                                               ),
      //                                             ],
      //                                           ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                   const Divider(
      //                                     color: AppColors.disabled,
      //                                     thickness: 1.5,
      //                                   ),
      //                                   Container(
      //                                     padding: const EdgeInsets.symmetric(
      //                                         vertical: 7, horizontal: 12),
      //                                     child: Column(
      //                                       children: [
      //                                         Row(
      //                                           mainAxisAlignment:
      //                                               MainAxisAlignment
      //                                                   .spaceBetween,
      //                                           children: [
      //                                             Text(
      //                                               "Total",
      //                                               style: GoogleFonts.poppins(
      //                                                 fontSize: 13,
      //                                                 fontWeight:
      //                                                     FontWeight.w500,
      //                                                 color: const Color(
      //                                                     0xFF244065),
      //                                               ),
      //                                             ),
      //                                             Text(
      //                                               "\$${totalAmount.toStringAsFixed(2)}",
      //                                               style: GoogleFonts.poppins(
      //                                                 color: const Color(
      //                                                     0xFF669933),
      //                                                 fontSize: 13,
      //                                                 fontWeight:
      //                                                     FontWeight.w500,
      //                                               ),
      //                                             ),
      //                                           ],
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                   const Divider(
      //                                     color: AppColors.disabled,
      //                                     thickness: 1.5,
      //                                   ),
      //                                   Container(
      //                                     padding: const EdgeInsets.symmetric(
      //                                         vertical: 7, horizontal: 12),
      //                                     child: Column(
      //                                       children: [
      //                                         Row(
      //                                           children: [
      //                                             Text(
      //                                               "Payment type: ",
      //                                               style: GoogleFonts.poppins(
      //                                                 fontSize: 13,
      //                                                 fontWeight:
      //                                                     FontWeight.w600,
      //                                                 color: const Color(
      //                                                     0xFF6E7373),
      //                                               ),
      //                                             ),
      //                                             const SizedBox(width: 5),
      //                                             Image.asset(
      //                                               paymentIcon,
      //                                               width: paymentType
      //                                                           .toString()
      //                                                           .toLowerCase() ==
      //                                                       'card'
      //                                                   ? 17.88
      //                                                   : 23,
      //                                               height: paymentType
      //                                                           .toString()
      //                                                           .toLowerCase() ==
      //                                                       'card'
      //                                                   ? 13.75
      //                                                   : 23,
      //                                               fit: BoxFit.cover,
      //                                             ),
      //                                             const SizedBox(width: 5),
      //                                             Text(
      //                                               paymentLabel,
      //                                               style: GoogleFonts.poppins(
      //                                                 color: const Color(
      //                                                     0xFF244065),
      //                                                 fontSize: 13,
      //                                                 fontWeight:
      //                                                     FontWeight.w600,
      //                                               ),
      //                                             ),
      //                                             if (paymentExtra.isNotEmpty)
      //                                               Text(
      //                                                 " $paymentExtra",
      //                                                 style:
      //                                                     GoogleFonts.poppins(
      //                                                   color: const Color(
      //                                                       0xFF6E7373),
      //                                                   fontSize: 13,
      //                                                   fontWeight:
      //                                                       FontWeight.w600,
      //                                                 ),
      //                                               ),
      //                                           ],
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                       const SizedBox(height: 15),
      //                     ],
      //                   );
      //                 }),
      //                 transactions.isEmpty
      //                     ? Center(
      //                         child: Text(
      //                           'No transactions found',
      //                           style: GoogleFonts.poppins(
      //                             fontSize: 15,
      //                             color: AppColors.ink,
      //                           ),
      //                         ),
      //                       )
      //                     : const SizedBox.shrink(),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),

      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }
}
