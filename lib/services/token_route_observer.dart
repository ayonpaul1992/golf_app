import 'package:flutter/material.dart';

import '../screens/login.dart';
import 'session_service.dart';

class TokenRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  TokenRouteObserver({SessionService? session, WidgetBuilder? loginBuilder})
      : _session = session ?? SessionService(),
        _loginBuilder = loginBuilder ?? ((_) => const LoginPage());

  final SessionService _session;
  final WidgetBuilder _loginBuilder;
  bool _isChecking = false;
  NavigatorState? _pendingCheck;

  Future<void> _checkToken(NavigatorState navigator) async {
    if (!navigator.mounted) return;
    if (_isChecking) {
      _pendingCheck = navigator;
      return;
    }
    _isChecking = true;
    try {
      final token = await _session.storage.read(key: 'accessToken');
      final loggedIn = await _session.storage.read(key: 'isLoggedIn');
      // Public sign-in and registration routes must remain available.
      if (token == null && loggedIn != 'true') return;
      if (SessionService.isTokenValid(token) ||
          (loggedIn == 'true' && await _session.hasValidSession())) {
        return;
      }

      await _session.clearSession();
      if (!navigator.mounted) return;
      ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
        const SnackBar(content: Text('Session expired, please log in again.')),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: _loginBuilder),
        (_) => false,
      );
    } catch (e) {
      debugPrint('Token check error: $e');
    } finally {
      _isChecking = false;
      final pending = _pendingCheck;
      _pendingCheck = null;
      if (pending != null && pending.mounted) _checkToken(pending);
    }
  }

  void _scheduleCheck(Route? route) {
    if (route is! PageRoute) return;
    final navigator = route.navigator;
    if (navigator == null) return;
    // Navigator is locked during observer notifications, including replacement.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkToken(navigator));
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _scheduleCheck(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _scheduleCheck(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _scheduleCheck(newRoute);
  }
}
