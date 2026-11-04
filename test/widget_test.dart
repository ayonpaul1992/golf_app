import 'dart:convert';
import 'package:driver_pos/main.dart';
import 'package:driver_pos/screens/payment_failed.dart';
import 'package:driver_pos/services/deep_link_service.dart';
import 'package:driver_pos/services/session_service.dart';
import 'package:driver_pos/services/token_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

String tokenWithExpiry(DateTime expiry) {
  String encode(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256'})}.'
      '${encode({'exp': expiry.millisecondsSinceEpoch ~/ 1000})}.signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SessionService session;
  late String validToken;
  late String expiredToken;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    session = SessionService();
    validToken = tokenWithExpiry(DateTime.now().add(const Duration(hours: 1)));
    expiredToken =
        tokenWithExpiry(DateTime.now().subtract(const Duration(hours: 1)));
  });
  Future<void> signIn(String token) async {
    await session.storage.write(key: 'isLoggedIn', value: 'true');
    await session.storage.write(key: 'accessToken', value: token);
    await session.storage.write(key: 'refreshToken', value: 'refresh');
  }

  Future<SessionDestination> startup({bool enabled = false, bool ok = true}) =>
      session.resolveStartup(
        isBiometricEnabled: () async => enabled,
        authenticate: () async => ok,
      );
  test('token validation rejects absent, expired and malformed JWTs', () {
    for (final value in [null, '', 'not-a-jwt', expiredToken]) {
      expect(SessionService.isTokenValid(value), isFalse);
    }
    expect(SessionService.isTokenValid(validToken), isTrue);
  });
  test('new users retain the welcome flow', () async {
    expect(await startup(), SessionDestination.welcome);
  });
  test('valid sessions retain dashboard access', () async {
    await signIn(validToken);
    expect(await startup(), SessionDestination.dashboard);
    expect(await session.storage.read(key: 'refreshToken'), 'refresh');
  });
  test('expired and malformed startup sessions clear authentication', () async {
    for (final token in [expiredToken, 'not-a-jwt']) {
      await signIn(token);
      expect(await startup(), SessionDestination.login);
      for (final key in ['accessToken', 'refreshToken', 'isLoggedIn']) {
        expect(await session.storage.read(key: key), isNull);
      }
    }
  });
  test('missing access token in a signed-in session requires login', () async {
    await session.storage.write(key: 'isLoggedIn', value: 'true');
    expect(await startup(), SessionDestination.login);
  });
  test('biometric rejection never returns the dashboard', () async {
    await signIn(validToken);
    expect(await startup(enabled: true, ok: false), SessionDestination.login);
    expect(await session.hasValidSession(), isFalse);
  });
  test('successful biometric authentication preserves the session', () async {
    await signIn(validToken);
    expect(await startup(enabled: true), SessionDestination.dashboard);
  });
  test('payment links resolve only complete destination names', () {
    for (final name in ['payment-success', 'payment-failed']) {
      for (final uri in ['driverpos://$name', 'https://example.com/$name']) {
        expect(DeepLinkService.paymentRouteForUri(Uri.parse(uri)), '/$name');
      }
      expect(paymentRoutes.containsKey('/$name'), isTrue);
    }
    for (final uri in [
      'https://example.com/not-payment-failed-extra',
      'driverpos://other'
    ]) {
      expect(DeepLinkService.paymentRouteForUri(Uri.parse(uri)), isNull);
    }
  });
  testWidgets('registered failure route opens a recoverable screen',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      routes: paymentRoutes,
      home: Builder(
          builder: (context) => TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/payment-failed'),
                child: const Text('Open failure'),
              )),
    ));
    await tester.tap(find.text('Open failure'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentFailedPage), findsOneWidget);
    expect(find.text('Return to app'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cold and warm payment links navigate through the service',
      (tester) async {
    const methods = MethodChannel('com.llfbandit.app_links/messages');
    const events = MethodChannel('com.llfbandit.app_links/events');
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        methods,
        (call) async => call.method == 'getInitialLink'
            ? 'driverpos://payment-failed'
            : null);
    messenger.setMockMethodCallHandler(events, (_) async => null);
    final service = DeepLinkService();
    try {
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        routes: {
          ...paymentRoutes,
          '/payment-success': (_) =>
              const Scaffold(body: Text('Payment success')),
        },
        home: const Scaffold(body: Text('Payment home')),
      ));
      await service.initDeepLinks();
      await tester.pumpAndSettle();
      expect(find.byType(PaymentFailedPage), findsOneWidget);
      tester.binding.channelBuffers.push(
        'com.llfbandit.app_links/events',
        const StandardMethodCodec().encodeSuccessEnvelope(
          'driverpos://payment-success',
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(find.text('Payment success'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.runAsync(service.dispose);
      messenger.setMockMethodCallHandler(methods, null);
      messenger.setMockMethodCallHandler(events, null);
    }
  });
  Future<GlobalKey<NavigatorState>> mountNavigator(WidgetTester tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      navigatorObservers: [
        TokenRouteObserver(
          session: session,
          loginBuilder: (_) => const Scaffold(body: Text('Session login')),
        )
      ],
      home: const Scaffold(body: Text('Home')),
    ));
    await tester.pumpAndSettle();
    return key;
  }

  testWidgets('public navigation remains available without a session',
      (tester) async {
    final key = await mountNavigator(tester);
    key.currentState!.push(MaterialPageRoute(
      builder: (_) => const Scaffold(body: Text('Public signup')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Public signup'), findsOneWidget);
    expect(find.text('Session login'), findsNothing);
  });
  testWidgets('expired token is caught on unnamed push', (tester) async {
    await signIn(validToken);
    final key = await mountNavigator(tester);
    await signIn(expiredToken);
    key.currentState!.push(MaterialPageRoute(
      builder: (_) => const Scaffold(body: Text('Private page')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Session login'), findsOneWidget);
    expect(key.currentState!.canPop(), isFalse);
    expect(await session.hasValidSession(), isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('malformed token is caught on route replacement', (tester) async {
    await signIn(validToken);
    final key = await mountNavigator(tester);
    await signIn('broken');
    key.currentState!.pushReplacement(MaterialPageRoute(
      builder: (_) => const Scaffold(body: Text('Replacement')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Session login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('expired token is caught when returning to previous page',
      (tester) async {
    await signIn(validToken);
    final key = await mountNavigator(tester);
    key.currentState!.push(MaterialPageRoute(
      builder: (_) => const Scaffold(body: Text('Child')),
    ));
    await tester.pumpAndSettle();
    await signIn(expiredToken);
    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('Session login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
