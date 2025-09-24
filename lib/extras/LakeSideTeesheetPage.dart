import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';

class LakeSideTeesheetPage extends StatefulWidget {
  final String lsSheetuserId; // ✅ Add this
  const LakeSideTeesheetPage({super.key, required this.lsSheetuserId});

  @override
  State<LakeSideTeesheetPage> createState() => _LakeSideTeesheetPageState();
}

class _LakeSideTeesheetPageState extends State<LakeSideTeesheetPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.lsSheetuserId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      body: const Center(child: Text("This is Lake Side Teesheet Page")),
    );
  }
}
