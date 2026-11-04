import 'package:driver_pos/repositories/feature_repositories.dart';
import 'package:driver_pos/theme/app_theme.dart';
// ignore_for_file: deprecated_member_use, use_build_context_synchronously


import 'package:driver_pos/screens/new_test_cart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';

// Add a global RouteObserver for navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class ParchaseGiftCardThreePage extends StatefulWidget {
  final String golfCourseId;
  final String giftCardId;

  final String selectedCardTrnsImage;
  final String recipientName; // Recipient Name
  final String senderName; // From Name (Sender)
  final String amount; // NEW: Gift Card Value
  final String recipientEmail; // NEW
  final String recipientMobileNo; // NEW
  final String
      giftMessage; // NEW: The actual message accompanying the gift card

  const ParchaseGiftCardThreePage({
    super.key,
    required this.golfCourseId,
    required this.giftCardId,
    required this.selectedCardTrnsImage,
    required this.recipientName,
    required this.senderName,
    required this.amount, // NEW required parameter
    required this.recipientEmail, // NEW required parameter
    required this.recipientMobileNo, // NEW required parameter
    required this.giftMessage, // NEW required parameter
  });

  @override
  State<StatefulWidget> createState() => ParchaseGiftCardThreePageState();
}

class ParchaseGiftCardThreePageState extends State<ParchaseGiftCardThreePage>
    with RouteAware, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  purchaseGiftCard() async {



    try {
      final postData = {
        "golfCourseId": widget.golfCourseId,
        "amount": widget.amount,
        "recipient": {
          "name": widget.recipientName,
          "email": widget.recipientEmail,
          "phoneNumber": widget.recipientMobileNo,
        },
        "giftCard": widget.giftCardId,
        "message": widget.giftMessage,
      };

      final payload = postData;

      // Prepare the request payload
      final requestPayload =
          Map<String, dynamic>.from(payload);

      final response = await giftCardRepository.purchase(requestPayload);

      print('sendign');
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.json;

        print('Response data: $data');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewTestCartPage(
              nwTstId: '',
            ),
          ),
        );

        // if (data['success'] == true) {
        //   _showMessage(data['message'] ?? 'Logged in successfully');
        // } else {
        //   _showMessage(data['message'] ?? 'Login failed');
        // }
      } else {}
    } catch (error) {
      _showMessage('Unexpected error: $error');
      print('Unexpected error: $error');
    } finally {}

    // print("POST Data: $postData");
  }

  @override
  void initState() {
    super.initState();
    // purchaseGiftCard();
    // Any additional initialization if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.golfCourseId,
        showLeading: true,
        isOnProfilePage: false,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: CustomDrawer(
        activeTile: 'Purchase Gift Card',
        onTileTap: (selectedTile) {
          // Handle navigation logic
        },
      ),
      body: Container(
        color: AppColors.pageBackground,
        width: double.infinity,
        height: double.infinity,
        child: GestureDetector(
            onTap: () {
              // Dismiss the keyboard and remove focus from any text field
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                            height: 1,
                            color: AppColors.border,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 190,
                            child: Text(
                              "TAKE A FINAL LOOK",
                              style: GoogleFonts.poppins(
                                  color: AppColors.ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 40,
                            height: 1,
                            color: AppColors.border,
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 25,
                  ),
                  // The Recipient Name is displayed prominently
                  Text(
                    widget.recipientName.toUpperCase(),
                    style: GoogleFonts.greatVibes(
                      color: AppColors.accent,
                      fontSize: 47,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // The Sender Name is displayed prominently
                  Text(
                    widget.senderName.toUpperCase(),
                    style: GoogleFonts.notoSerif(
                        color: AppColors.ink,
                        fontSize: 35,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset('assets/images/flktop.png'),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.giftMessage.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: AppColors.heading,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // The redundant Text widget for giftMessage has been removed here.
                  const SizedBox(height: 30),

                  // Placeholder for the card image (using the passed path)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: widget.selectedCardTrnsImage.startsWith('http')
                          ? Image.network(
                              widget.selectedCardTrnsImage,
                              fit: BoxFit.cover,
                              height: 180,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: Text(
                                  "Card Image Placeholder\n(${widget.selectedCardTrnsImage})",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Image.asset(
                              widget.selectedCardTrnsImage,
                              fit: BoxFit.cover,
                              height: 180,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: Text(
                                  "Card Image Placeholder\n(${widget.selectedCardTrnsImage})",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Add more confirmation details (e.g., amount, sender name, etc.) here
                  const SizedBox(height: 30),
                  Text(
                    "\$ ${widget.amount}",
                    style: GoogleFonts.poppins(
                      color: AppColors.heading,
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 38.0),
                  //   child: Column(
                  //     children: [
                  //       // UPDATED to use the actual 'amount' parameter
                  //       _buildDetailRow(context, "Gift Card Value:", widget.amount),
                  //       _buildDetailRow(context, "Sending To:", widget.message),
                  //       // UPDATED to use the actual 'recipientEmail' parameter
                  //       _buildDetailRow(context, "Recipient Email:", widget.recipientEmail),
                  //       // ADDED Recipient Mobile Number
                  //       _buildDetailRow(context, "Recipient Mobile:", widget.recipientMobileNo),
                  //       _buildDetailRow(context, "Sending From:", widget.senderName),
                  //       // NEW: Display the custom message (CORRECT PLACEMENT)
                  //       _buildDetailRow(context, "Custom Message:", widget.giftMessage),
                  //     ],
                  //   ),
                  // ),

                  // Purchase Button Placeholder
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          purchaseGiftCard();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent, // Dark green color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 5,
                        ),
                        // child: Text(
                        //   "Confirm Purchase",
                        //   style: GoogleFonts.poppins(
                        //     color: Colors.white,
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        child: Text(
                          "\$ ${widget.amount}",
                          style: GoogleFonts.poppins(
                            color: AppColors.surface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: -1),
    );
  }

  // Helper widget for displaying key/value pairs
}
