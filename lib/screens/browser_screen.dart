import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  // Function to open URL in in-app browser
  void _openInAppBrowser(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView, // opens inside app
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true, // optional: enable JS
      ),
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open In-App Browser')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _openInAppBrowser("https://flutter.dev"); // Your URL here
          },
          child: const Text('Open Flutter Website'),
        ),
      ),
    );
  }
}
