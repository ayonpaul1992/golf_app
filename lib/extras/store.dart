import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';
import '/components/custom_drawer.dart';
import '/components/custom_bottom_nav_bar.dart';

class StorePage extends StatefulWidget {
  final String storeId; // ✅ Add this
  const StorePage(
      {super.key,
      required this.storeId,
      required String storeName}); // ✅ Fix constructor

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.storeId, // ✅ Pass the correct userId
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
