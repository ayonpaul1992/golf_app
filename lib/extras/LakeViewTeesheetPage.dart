import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/components/custom_app_bar.dart';

class LakeViewTeesheetPage extends StatefulWidget {
  final String lvSheetuserId; // ✅ Add this
  const LakeViewTeesheetPage({super.key, required this.lvSheetuserId});

  @override
  State<LakeViewTeesheetPage> createState() => _LakeViewTeesheetPageState();
}

class _LakeViewTeesheetPageState extends State<LakeViewTeesheetPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        userId: widget.lvSheetuserId, // ✅ Pass the correct userId
        showLeading: false, // ✅ This should prevent the back button
      ),
      body: const Center(child: Text("This is Lake View Teesheet Page")),
    );
  }
}
