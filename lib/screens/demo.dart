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
      