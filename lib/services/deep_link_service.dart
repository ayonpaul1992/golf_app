import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isInitialized = false;
  static bool _hasCheckedInitialLink = false;

  // static String? _cachedInitialTargetRoute;
  // static bool get isLinkPending => _cachedInitialTargetRoute != null;

  // 💡 FIX: This static variable will store the initial link only once
  // during the first run of the process.
  static Uri? _cachedInitialUri;

  // 💡 NEW STATIC METHOD: Checks and caches the initial link on cold start
  static Future<void> checkInitialLink() async {
    if (_hasCheckedInitialLink) return;
    _hasCheckedInitialLink = true;

    try {
      // Use a fresh instance of AppLinks here if needed, or rely on the class property
      // being initialized later. To ensure full compatibility with the async nature,
      // we'll check it here using a temporary instance if the main one isn't ready.
      final appLinks = AppLinks();
      _cachedInitialUri = await appLinks.getInitialLink();

      // If a cached link is found, print it for debugging.
      if (_cachedInitialUri != null) {
        debugPrint(
            "✅ DeepLinkService found cached initial URI: $_cachedInitialUri");
      }
    } catch (e) {
      debugPrint("Error checking initial link: $e");
    }
  }

  // 💡 NEW STATIC GETTER: Allows MyApp to quickly check if a link is pending
  static bool get isLinkPending =>
      _cachedInitialUri != null &&
      paymentRouteForUri(_cachedInitialUri!) != null;

  static String? paymentRouteForUri(Uri uri) {
    final target = uri.host == 'payment-success' || uri.host == 'payment-failed'
        ? uri.host
        : (uri.pathSegments.isEmpty ? '' : uri.pathSegments.last);
    return switch (target) {
      'payment-success' => '/payment-success',
      'payment-failed' => '/payment-failed',
      _ => null,
    };
  }

  /// Initializes deep link handling. Must be called once.
  Future<void> initDeepLinks() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await checkInitialLink();

    // 1. Handle initial link (cold start) using the cached URI
    if (_cachedInitialUri != null) {
      _handleLink(_cachedInitialUri!, isInitial: true);
      _cachedInitialUri = null;
    }

    // 2. Listen for links while the app is running (hot start, background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleLink(uri, isInitial: false),
      onError: (err) => debugPrint("Deep link stream error: $err"),
    );
  }

  /// Handles navigation based on the received URI.
  void _handleLink(Uri uri, {required bool isInitial}) async {
    // --- START: Wait for Navigator to be ready (Existing Fix) ---
    final targetRoute = paymentRouteForUri(uri);
    final isLinkRoute = targetRoute != null;

    // Only wait aggressively if this is a route that needs to replace the stack
    if (isInitial || isLinkRoute) {
      int checks = 0;
      while (navigatorKey.currentState == null ||
          !navigatorKey.currentState!.mounted) {
        if (checks > 100) {
          debugPrint("❌ Timeout waiting for Navigator to mount for deep link.");
          return;
        }
        await Future.delayed(const Duration(milliseconds: 50));
        checks++;
      }
    }
    // --- END: Wait for Navigator to be ready ---

    debugPrint("🔗 Received deep link: $uri (Is Initial: $isInitial)");

    final navigatorState = navigatorKey.currentState;

    if (navigatorState == null || !navigatorState.mounted) {
      debugPrint("❌ Navigator is not mounted. Cannot process deep link: $uri");
      return;
    }

    if (targetRoute != null) {
      // 💡 FINAL FIX: Use aggressive navigation if it's the initial link, OR
      // if it's a hot link but the current route is still the root (Dashboard).
      final shouldReplaceStack =
          isInitial || (isLinkRoute && !navigatorState.canPop());

      if (shouldReplaceStack) {
        // If we are replacing the stack, we use pushNamedAndRemoveUntil.
        // The explicit pop logic is removed as RANU is superior for clearing.
        navigatorState.pushNamedAndRemoveUntil(
          targetRoute,
          (Route<dynamic> route) => false,
        );
        debugPrint(
            "✅ Deep Link handled by replacing all routes with: $targetRoute");
      } else {
        // Hot link, and there are already other routes on the stack (e.g., user is
        // in a sub-page of the app). Just push normally.
        navigatorState.pushNamed(targetRoute);
        debugPrint("✅ Deep Link handled by pushing screen: $targetRoute");
      }
    } else {
      debugPrint("ℹ️ Deep Link URI ignored (no matching route): $uri");
    }
  }

  static Future<void> clearCachedLink() async {
    _cachedInitialUri = null;
    _hasCheckedInitialLink =
        true; // ✅ mark as already checked so we don't re-fetch
    debugPrint(
        "🧹 DeepLinkService: Cleared cached initial route and marked as checked.");
  }

  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
  }
}
