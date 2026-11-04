import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'socket_service.dart';
import 'session_refresh.dart';
import 'session_revoke.dart';

enum SessionDestination { welcome, login, dashboard }

/// Local expiry checks complement, but do not replace, server authorization.
class SessionService {
  SessionService(
      {FlutterSecureStorage? storage,
      Future<Map<String, dynamic>> Function(String)? refresh,
      Future<void> Function(String?, String?)? revoke})
      : storage = storage ?? const FlutterSecureStorage(),
        _refresh = refresh ?? requestSessionRefresh,
        _revoke = revoke ?? requestSessionRevocation;

  final FlutterSecureStorage storage;
  final Future<Map<String, dynamic>> Function(String) _refresh;
  final Future<void> Function(String?, String?) _revoke;
  static Future<bool>? _refreshing;
  static Future<void>? _mutation;

  Future<T> _mutate<T>(Future<T> Function() action) async {
    final previous = _mutation;
    final gate = Completer<void>();
    _mutation = gate.future;
    if (previous != null) await previous;
    try {
      return await action();
    } finally {
      if (identical(_mutation, gate.future)) _mutation = null;
      gate.complete();
    }
  }

  Future<void> logout({bool clearAll = true}) async {
    String? access;
    String? refresh;
    await _mutate(() async {
      access = await storage.read(key: 'accessToken');
      refresh = await storage.read(key: 'refreshToken');
      await _clear(clearAll: clearAll);
    });
    try {
      await _revoke(access, refresh);
    } catch (_) {/* Offline local logout remains available. */}
  }

  Future<void> saveSession(String accessToken, String? refreshToken) =>
      _mutate(() async {
        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'refreshToken', value: refreshToken);
        await storage.write(key: 'isLoggedIn', value: 'true');
      });

  Future<bool> refreshAccessToken() async {
    if (_refreshing != null) return _refreshing!;
    final operation = _renew();
    _refreshing = operation;
    try {
      return await operation;
    } finally {
      if (identical(_refreshing, operation)) _refreshing = null;
    }
  }

  Future<bool> _renew() async {
    await _mutation;
    final oldAccess = await storage.read(key: 'accessToken');
    final refresh = await storage.read(key: 'refreshToken');
    if (!isTokenValid(refresh)) return false;
    try {
      final data = await _refresh(refresh!);
      final access = data['accessToken'];
      if (data['success'] != true ||
          access is! String ||
          !isTokenValid(access)) {
        return false;
      }
      return _mutate(() async {
        // Credential writes and invalidation share one queue.
        if (await storage.read(key: 'refreshToken') != refresh ||
            await storage.read(key: 'accessToken') != oldAccess) {
          return false;
        }
        if (data['refreshToken'] is String) {
          await storage.write(
              key: 'refreshToken', value: data['refreshToken'] as String);
        }
        await storage.write(key: 'accessToken', value: access);
        SocketService().updateToken(access);
        return true;
      });
    } catch (_) {
      return false;
    }
  }

  static final _expired = StreamController<void>.broadcast();
  static Future<void>? _expiration;

  static Stream<void> get expired => _expired.stream;

  /// A late 401 from an old request must never clear a newly signed-in session.
  Future<void> expireAccessToken(String rejectedToken) async {
    if (_expiration != null) return _expiration;
    final operation = _expire(rejectedToken);
    _expiration = operation;
    try {
      await operation;
    } finally {
      if (identical(_expiration, operation)) _expiration = null;
    }
  }

  Future<void> _expire(String rejectedToken) => _mutate(() async {
        if (rejectedToken.isEmpty ||
            await storage.read(key: 'accessToken') != rejectedToken) {
          return;
        }
        await _clear();
        _expired.add(null);
      });

  static bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasValidSession() async {
    await _mutation;
    final loggedIn = await storage.read(key: 'isLoggedIn');
    final token = await storage.read(key: 'accessToken');
    if (loggedIn != 'true') return false;
    if (isTokenValid(token) || await refreshAccessToken()) return true;
    // A different login may have completed while the old refresh was pending.
    return await storage.read(key: 'isLoggedIn') == 'true' &&
        isTokenValid(await storage.read(key: 'accessToken'));
  }

  Future<void> clearSession({bool clearAll = false}) =>
      _mutate(() => _clear(clearAll: clearAll));

  Future<void> _clear({bool clearAll = false}) async {
    if (clearAll) {
      await storage.deleteAll();
      SocketService().dispose();
      return;
    }
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    await storage.delete(key: 'isLoggedIn');
    SocketService().dispose();
  }

  Future<SessionDestination> resolveStartup({
    required Future<bool> Function() isBiometricEnabled,
    required Future<bool> Function() authenticate,
  }) async {
    final loggedIn = await storage.read(key: 'isLoggedIn');
    if (loggedIn != 'true') return SessionDestination.welcome;
    if (!await hasValidSession()) {
      await clearSession();
      return SessionDestination.login;
    }
    if (await isBiometricEnabled() && !await authenticate()) {
      await clearSession();
      return SessionDestination.login;
    }
    return SessionDestination.dashboard;
  }
}
