// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';

import 'package:driver_pos/screens/new_test_cart.dart';
import 'package:driver_pos/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

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
    Key? key,
    required this.golfCourseId,
    required this.giftCardId,
    required this.selectedCardTrnsImage,
    required this.recipientName,
    required this.senderName,
    required this.amount, // NEW required parameter
    required this.recipientEmail, // NEW required parameter
    required this.recipientMobileNo, // NEW required parameter
    required this.giftMessage, // NEW required parameter
  }) : super(key: key);

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
    final String baseUrl = ApiConfig.baseUrl;

    final String apiUrl = '$baseUrl/giftCard/purchase';

    String? token = await secureStorage.read(key: 'accessToken') ?? '';

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

      // Encrypt the payload
      final secret =
          'course1999golf01'; // must match Node backend ENCRYPT_SECRET
      final keyHash = sha256.convert(utf8.encode(secret)).bytes;
      final secretKey = SecretKey(keyHash);
      final algorithm = AesGcm.with256bits();
      final iv = algorithm.newNonce();

      final secretBox = await algorithm.encrypt(
        utf8.encode(jsonEncode(payload)),
        secretKey: secretKey,
        nonce: iv,
      );

      final encryptedPayload = {
        'iv': base64Encode(iv),
        'data': base64Encode(secretBox.cipherText),
        'tag': base64Encode(secretBox.mac.bytes),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(encryptedPayload),
      );

      print('sendign');
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

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
        isOnProfilePage: true,
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
        color: const Color(0xFFFAFCFA),
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
                            color: const Color(0xFFB2C1C0),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 190,
                            child: Text(
                              "TAKE A FINAL LOOK",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF244065),
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
                            color: const Color(0xFFB2C1C0),
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
                      color: const Color(0xFF669933),
                      fontSize: 47,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // The Sender Name is displayed prominently
                  Text(
                    widget.senderName.toUpperCase(),
                    style: GoogleFonts.notoSerif(
                        color: const Color(0xFF244065),
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
                      color: const Color(0xFF2A4768),
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
                          color: Colors.black.withOpacity(0.1),
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
                      color: const Color(0xFF2A4768),
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
                          backgroundColor:
                              const Color(0xFF669933), // Dark green color
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
                            color: const Color(0xFFFFFFFF),
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
