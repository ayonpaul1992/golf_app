import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';

class SelfCheckingPage extends StatefulWidget {
  final String selfChkId; // ✅ Add this
  const SelfCheckingPage(
      {super.key,
      required this.selfChkId,
      required String selfcheck}); // ✅ Fix constructor

  @override
  State<SelfCheckingPage> createState() => _SelfCheckingPageState();
}

class _SelfCheckingPageState extends State<SelfCheckingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.selfChkId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      drawer: CustomDrawer(
        activeTile: 'Home',
        onTileTap: (selectedTile) {
          //print("Navigating to $selectedTile");
          // Handle navigation logic
        },
      ),
      body: Container(),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
