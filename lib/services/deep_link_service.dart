// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void initDeepLinks(BuildContext context) async {
    _appLinks = AppLinks();

    // 1️⃣ Handle initial link if app opened from a cold start
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLink(context, initialLink);
    }

    // 2️⃣ Listen for links while the app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleLink(context, uri),
      onError: (err) => debugPrint("Deep link error: $err"),
    );
  }

  void _handleLink(BuildContext context, Uri uri) {
    debugPrint("🔗 Received deep link: $uri");

    // Example: driverpos://payment-success?status=ok
    if (uri.host == 'payment-success') {
      final status = uri.queryParameters['status'] ?? 'unknown';
      debugPrint('Payment status: $status');

      Navigator.pushNamed(context, '/payment-success');
    } else if (uri.host == 'cancel') {
      Navigator.pushNamed(context, '/payment-cancel');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
