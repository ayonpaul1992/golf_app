import 'package:driver_pos/services/api_payload.dart';
import 'dart:async';
import 'dart:convert';
import 'package:driver_pos/controllers/async_action_controller.dart';
import 'package:driver_pos/models/api_envelope.dart';
import 'package:driver_pos/repositories/customer_api_repository.dart';
import 'package:driver_pos/repositories/feature_repositories.dart';
import 'package:driver_pos/services/api_http.dart';
import 'package:driver_pos/services/session_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
      'feature repositories preserve method, route, filters, payload and response errors',
      () async {
    final calls = <http.Request>[];
    await storage.write(key: 'accessToken', value: 'fixture-token');
    final api = CustomerApiRepository(
      baseUrl: () => 'https://api.example/v1',
      client: MockClient((request) async {
        calls.add(request);
        return http.Response(
            '{"success":false,"message":"Slot taken","data":{"slotFull":true}}',
            409);
      }),
    );
    final auth = AuthRepository(api: api);
    final checkout = CheckoutRepository(api: api);
    final gifts = GiftCardRepository(api: api);
    final booking = BookingRepository(api: api);
    final profile = ProfileRepository(api: api);
    final payload = <String, dynamic>{
      'amount': 42,
      'cardType': 'savedCard',
      'otp': 'fixture',
      'termsAgreed': true
    };
    final operations = <(String, String, Future<ApiEnvelope> Function())>[
      ('POST', 'auth/customer-login', () => auth.login(payload, 'COURSE')),
      ('POST', 'auth/password/forgot', () => auth.forgotPassword(payload)),
      ('PUT', 'auth/password', () => auth.resetPassword(payload)),
      ('POST', 'auth/sign-up', () => auth.signUp(payload)),
      ('GET', 'pageSettings/COURSE', () => auth.pageSettings('COURSE')),
      ('GET', 'sales/customer', checkout.summary),
      ('DELETE', 'sales/clear', checkout.clear),
      ('POST', 'transaction/payment', () => checkout.pay(payload)),
      ('POST', 'transaction/sendOtp', () => checkout.sendOtp(payload)),
      ('GET', 'template/giftcards/customer', gifts.templates),
      (
        'GET',
        'customer/email-or-phone',
        () => gifts.customerByPhone('+1&phone')
      ),
      (
        'GET',
        'customer/email-or-phone',
        () => gifts.customerByEmail('a+b@example.invalid')
      ),
      ('POST', 'giftCard/purchase', () => gifts.purchase(payload)),
      ('GET', 'teesheet/myBookings', booking.upcoming),
      (
        'GET',
        'customer/players',
        () => booking.players('course', '2026-11-04', '12:00')
      ),
      ('POST', 'teesheet/book-teesheet', () => booking.book(payload)),
      (
        'DELETE',
        'teesheet/myBookings/cancel/slot',
        () => booking.cancel('slot', payload)
      ),
      ('GET', 'teesheet/customer-facility', () => booking.facilities('COURSE')),
      (
        'GET',
        'reservationGroup/customer',
        () => booking.reservationGroups('sheet')
      ),
      ('GET', 'customer/myMembership', () => booking.memberships('course')),
      ('GET', 'customer/myProfile', profile.profile),
      ('DELETE', 'customer/delete', () => profile.deleteAccount(payload)),
    ];
    for (final (method, path, action) in operations) {
      final before = calls.length;
      final result = await action();
      expect(calls.length, before + 1, reason: '$method $path must not retry');
      final request = calls.last;
      expect(request.method, method);
      expect(request.url.path, '/v1/$path');
      expect(result.statusCode, 409);
      expect(result.message, 'Slot taken');
      expect(result.data['slotFull'], true);
      if (request.body.isNotEmpty) expect(jsonDecode(request.body), payload);
      if (!path.startsWith('auth/') && !path.startsWith('pageSettings/')) {
        expect(request.headers['Authorization'], 'Bearer fixture-token');
      }
    }
    expect(calls[0].url.queryParameters, {'golfCourseCode': 'COURSE'});
    expect(calls[6].url.queryParameters, {'cartState': 'customerCart'});
    expect(calls[10].url.queryParameters['phoneNumber'], '+1&phone');
    expect(calls[11].url.queryParameters['email'], 'a+b@example.invalid');
    expect(calls[13].url.queryParameters['isDashboard'], 'true');
    api.dispose();
  });

  test(
      'explicit JSON opt-in applies only to backend writes and never external services',
      () async {
    final seen = <http.Request>[];
    final client = ApiHttpClient(
        baseUrl: () => 'https://api.example/v1',
        payloadCodec: ApiPayloadCodec(useJson: () => true),
        inner: MockClient((request) async {
          seen.add(request);
          return http.Response('{}', 200);
        }));
    for (final url in [
      'https://api.example/v1/auth/login',
      'https://api.example/v1/cart/pay',
      'https://external.example/service'
    ]) {
      await client.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'}, body: '{"amount":42}');
    }
    expect(seen[0].headers['X-Api-Payload-Format'], 'json');
    expect(seen[1].headers['X-Api-Payload-Format'], 'json');
    expect(seen[2].headers['X-Api-Payload-Format'], isNull);
    expect(seen[1].body, '{"amount":42}');
    client.close();
  });

  test(
      'form action controller coalesces submissions and does not notify after disposal',
      () async {
    final controller = AsyncActionController<int>();
    final complete = Completer<int>();
    var notifications = 0;
    var requests = 0;
    controller.addListener(() => notifications++);
    final first = controller.run(() {
      requests++;
      return complete.future;
    });
    final second = controller.run(() async {
      requests++;
      return 2;
    });
    expect(identical(first, second), true);
    expect(controller.isLoading, true);
    controller.dispose();
    complete.complete(42);
    expect(await first, 42);
    expect(requests, 1);
    expect(notifications, 1);
  });

  test('form failure clears loading and permits an explicit retry', () async {
    final controller = AsyncActionController<int>();
    await expectLater(controller.run(() => Future.error(StateError('offline'))),
        throwsStateError);
    expect(controller.isLoading, false);
    expect(controller.error, isA<StateError>());
    expect(await controller.run(() async => 42), 42);
    expect(controller.error, isNull);
    controller.dispose();
  });

  test(
      'offline logout clears local state and cannot clear a newer sign-in when revocation completes',
      () async {
    await storage.write(key: 'accessToken', value: 'old-access');
    await storage.write(key: 'refreshToken', value: 'old-refresh');
    final pending = Completer<void>();
    final started = Completer<void>();
    final session = SessionService(revoke: (access, refresh) async {
      expect(access, 'old-access');
      expect(refresh, 'old-refresh');
      started.complete();
      await pending.future;
      throw StateError('offline');
    });
    final logout = session.logout();
    await started.future;
    expect(await storage.read(key: 'accessToken'), isNull);
    await session.saveSession('new-access', 'new-refresh');
    pending.complete();
    await logout;
    expect(await storage.read(key: 'accessToken'), 'new-access');
    expect(await storage.read(key: 'refreshToken'), 'new-refresh');
  });
}
