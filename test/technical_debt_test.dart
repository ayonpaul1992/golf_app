import 'dart:convert';
import 'dart:async';

import 'package:driver_pos/models/history_page.dart';
import 'package:driver_pos/repositories/history_repository.dart';
import 'package:driver_pos/services/api_http.dart';
import 'package:driver_pos/services/session_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String jwt(Duration duration) {
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({
        'exp': DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000,
      })))
      .replaceAll('=', '');
  return 'eyJhbGciOiJIUzI1NiJ9.$payload.signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<void> signIn(String token, {String? refresh}) async {
    await storage.write(key: 'accessToken', value: token);
    await storage.write(key: 'isLoggedIn', value: 'true');
    if (refresh != null) {
      await storage.write(key: 'refreshToken', value: refresh);
    }
  }

  test('401 clears a current backend session and preserves the response',
      () async {
    final token = jwt(const Duration(hours: 1));
    await signIn(token);
    var notifications = 0;
    final subscription = SessionService.expired.listen((_) => notifications++);
    final client = ApiHttpClient(
      inner:
          MockClient((_) async => http.Response('{"message":"revoked"}', 401)),
      baseUrl: () => 'https://api.example/v1',
    );
    final response = await client.get(
        Uri.parse('https://api.example/v1/customer/myProfile'),
        headers: {'Authorization': 'Bearer $token'});
    await Future<void>.delayed(Duration.zero);
    expect(response.statusCode, 401);
    expect(response.body, contains('revoked'));
    expect(await storage.read(key: 'accessToken'), isNull);
    expect(notifications, 1);
    client.close();
    await subscription.cancel();
  });

  test(
      'public login and external 401 responses never clear customer credentials',
      () async {
    final token = jwt(const Duration(hours: 1));
    await signIn(token);
    final client = ApiHttpClient(
      inner: MockClient((_) async => http.Response('denied', 401)),
      baseUrl: () => 'https://api.example/v1',
    );
    for (final url in [
      'https://api.example/v1/auth/login',
      'https://weather.example/v1/weather'
    ]) {
      await client
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      expect(await storage.read(key: 'accessToken'), token);
    }
    client.close();
  });

  test('a delayed 401 cannot clear a new sign-in', () async {
    final old = jwt(const Duration(hours: 1));
    final fresh = jwt(const Duration(days: 1));
    await signIn(old);
    final client = ApiHttpClient(
        inner: MockClient((_) async {
          await signIn(fresh);
          return http.Response('old response', 401);
        }),
        baseUrl: () => 'https://api.example/v1');
    await client.get(Uri.parse('https://api.example/v1/customer/myProfile'),
        headers: {'Authorization': 'Bearer $old'});
    expect(await storage.read(key: 'accessToken'), fresh);
    client.close();
  });

  test('concurrent expiry invalidation emits once', () async {
    final token = jwt(const Duration(hours: 1));
    await signIn(token);
    var notifications = 0;
    final sub = SessionService.expired.listen((_) => notifications++);
    final session = SessionService();
    await Future.wait(
        List.generate(5, (_) => session.expireAccessToken(token)));
    await Future<void>.delayed(Duration.zero);
    expect(notifications, 1);
    await sub.cancel();
  });

  test('refresh is single-flight and stores rotated credentials', () async {
    final expired = jwt(const Duration(hours: -1));
    final refresh = jwt(const Duration(days: 2));
    final fresh = jwt(const Duration(hours: 1));
    final rotated = jwt(const Duration(days: 3));
    await signIn(expired, refresh: refresh);
    var calls = 0;
    final session = SessionService(refresh: (token) async {
      calls++;
      expect(token, refresh);
      await Future<void>.delayed(Duration.zero);
      return {'success': true, 'accessToken': fresh, 'refreshToken': rotated};
    });
    expect(
        await Future.wait(
            List.generate(4, (_) => session.refreshAccessToken())),
        everyElement(isTrue));
    expect(calls, 1);
    expect(await storage.read(key: 'accessToken'), fresh);
    expect(await storage.read(key: 'refreshToken'), rotated);
  });

  test('expired writes refresh before sending and are never replayed',
      () async {
    final expired = jwt(const Duration(hours: -1));
    final fresh = jwt(const Duration(hours: 1));
    await signIn(expired, refresh: jwt(const Duration(days: 2)));
    final session = SessionService(
        refresh: (_) async => {'success': true, 'accessToken': fresh});
    var writes = 0;
    final client = ApiHttpClient(
        session: session,
        baseUrl: () => 'https://api.example/v1',
        inner: MockClient((request) async {
          writes++;
          expect(request.headers['Authorization'], 'Bearer $fresh');
          expect(request.body,
              '{"iv":"unchanged","data":"unchanged","tag":"unchanged"}');
          return http.Response('ok', 200);
        }));
    await client.post(Uri.parse('https://api.example/v1/transaction/payment'),
        headers: {
          'Authorization': 'Bearer $expired',
          'Content-Type': 'application/json'
        },
        body: '{"iv":"unchanged","data":"unchanged","tag":"unchanged"}');
    expect(writes, 1);
    client.close();
  });

  test(
      'refresh failure and stale refresh completion do not overwrite a new session',
      () async {
    final old = jwt(const Duration(hours: -1));
    final fresh = jwt(const Duration(hours: 1));
    await signIn(old, refresh: jwt(const Duration(days: 2)));
    final session = SessionService(refresh: (_) async {
      await signIn(fresh, refresh: jwt(const Duration(days: 5)));
      return {'success': true, 'accessToken': jwt(const Duration(hours: 2))};
    });
    expect(await session.refreshAccessToken(), isFalse);
    expect(await storage.read(key: 'accessToken'), fresh);
    final failing =
        SessionService(refresh: (_) async => throw Exception('offline'));
    expect(await failing.refreshAccessToken(), isFalse);
    expect(await storage.read(key: 'accessToken'), fresh);
  });

  test(
      'history metadata handles filtered counts, missing counts and empty pages',
      () {
    expect(
        HistoryPage.fromJson({
          'data': [
            {'id': 1}
          ],
          'count': 2
        }, page: 1, limit: 1)
            .hasMore,
        isTrue);
    expect(
        HistoryPage.fromJson({
          'data': [
            {'id': 2}
          ],
          'count': 2
        }, page: 2, limit: 1)
            .hasMore,
        isFalse);
    expect(
        HistoryPage.fromJson({'data': [], 'count': 100}, page: 2, limit: 1)
            .hasMore,
        isFalse);
    final credit = HistoryPage.fromJson({
      'data': {
        'credit': 42,
        'history': [
          {'amount': 10}
        ]
      }
    }, page: 1, limit: 1, storeCredit: true);
    expect(credit.hasMore, isTrue);
    expect(credit.summary['credit'], 42);
    expect(() => HistoryPage.fromJson({'data': 'bad'}, page: 1, limit: 20),
        throwsFormatException);
  });

  test('repository preserves filters, pagination, summaries and errors',
      () async {
    await signIn(jwt(const Duration(hours: 1)));
    final client = MockClient((request) async {
      expect(request.url.queryParameters,
          {'page': '2', 'limit': '20', 'startDate': '2026-11-01'});
      expect(request.headers['Authorization'], startsWith('Bearer '));
      return http.Response(
          jsonEncode({
            'data': [
              {'id': 21}
            ],
            'count': 21,
            'amount': {'totalRemainingBalance': 75}
          }),
          200);
    });
    final repository = HistoryRepository(
        client: client, baseUrl: () => 'https://api.example/v1');
    final page = await repository.fetch('giftCard/myGiftCards',
        page: 2, limit: 20, filters: {'startDate': '2026-11-01'});
    expect(page.items.single['id'], 21);
    expect(page.hasMore, isFalse);
    expect(page.summary['totalRemainingBalance'], 75);
    repository.dispose();
  });
  test('startup preserves a newer login while an old refresh completes',
      () async {
    final old = jwt(const Duration(hours: -1));
    final fresh = jwt(const Duration(days: 1));
    await signIn(old, refresh: jwt(const Duration(days: 2)));
    final session = SessionService(refresh: (_) async {
      await signIn(fresh, refresh: jwt(const Duration(days: 4)));
      return {'success': true, 'accessToken': jwt(const Duration(hours: 2))};
    });
    expect(
        await session.resolveStartup(
            isBiometricEnabled: () async => false,
            authenticate: () async => true),
        SessionDestination.dashboard);
    expect(await storage.read(key: 'accessToken'), fresh);
  });

  test('serialized sign-in and invalidation preserve the newest credentials',
      () async {
    final old = jwt(const Duration(hours: 1));
    final fresh = jwt(const Duration(days: 1));
    final session = SessionService();
    for (final expireFirst in [true, false]) {
      await session.saveSession(old, 'old-refresh');
      final seen = Completer<bool>();
      final subscription = SessionService.expired.listen((_) async {
        final valid = await session.hasValidSession();
        if (!seen.isCompleted) seen.complete(valid);
      });
      await Future.wait(expireFirst
          ? [
              session.expireAccessToken(old),
              session.saveSession(fresh, 'new-refresh')
            ]
          : [
              session.saveSession(fresh, 'new-refresh'),
              session.expireAccessToken(old)
            ]);
      expect(await storage.read(key: 'accessToken'), fresh);
      expect(await storage.read(key: 'refreshToken'), 'new-refresh');
      if (expireFirst) expect(await seen.future, isTrue);
      await subscription.cancel();
    }
  });

  test('multipart upload is sent once and a 401 leaves the response readable',
      () async {
    final token = jwt(const Duration(hours: 1));
    await signIn(token);
    var sends = 0;
    final client = ApiHttpClient(
        baseUrl: () => 'https://api.example/v1',
        inner: MockClient((request) async {
          sends++;
          expect(
              request.headers['content-type'], contains('multipart/form-data'));
          expect(request.body, contains('fixture-profile'));
          return http.Response('upload rejected', 401);
        }));
    final request = http.MultipartRequest(
        'PUT', Uri.parse('https://api.example/v1/customer/myProfile'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['fname'] = 'fixture-profile';
    final response = await client.send(request);
    expect(await response.stream.bytesToString(), 'upload rejected');
    expect(sends, 1);
    expect(await storage.read(key: 'accessToken'), isNull);
    client.close();
  });
}
