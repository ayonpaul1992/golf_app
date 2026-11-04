import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:driver_pos/services/api_config.dart';
import 'package:driver_pos/services/api_http.dart';
import 'package:driver_pos/services/api_payload.dart';
import 'package:driver_pos/services/session_refresh.dart';
import 'package:driver_pos/services/session_revoke.dart';
import 'package:driver_pos/services/weather_service.dart';
import 'package:driver_pos/models/api_envelope.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const fixtureKey = 'fixture-only-compatibility-key';
ApiPayloadCodec legacy() =>
    ApiPayloadCodec(useJson: () => false, key: () => fixtureKey);
Future<dynamic> decryptBody(String body) async {
  final box = jsonDecode(body) as Map;
  final clear = await AesGcm.with256bits().decrypt(
      SecretBox(
        base64Decode(box['data'] as String),
        nonce: base64Decode(box['iv'] as String),
        mac: Mac(base64Decode(box['tag'] as String)),
      ),
      secretKey: SecretKey(sha256.convert(utf8.encode(fixtureKey)).bytes));
  return jsonDecode(utf8.decode(clear));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => dotenv.loadFromString(
      envString:
          'API_ENCRYPTION_KEY=$fixtureKey\nOPEN_WEATHER_API_KEY=fixture-weather-key\n'));

  test('compatibility defaults do not require undeployed backend protocols',
      () {
    expect(ApiConfig.useJsonPayload, false);
    expect(ApiConfig.useWeatherProxy, false);
    expect(ApiConfig.sessionRevocationEnabled, false);
  });

  test(
      'all JSON write methods encrypt exactly once, preserving passwords and payment fields',
      () async {
    final payload = {
      'email': 'fixture@example.invalid',
      'password': '  exact password  ',
      'cardType': 'savedCard',
      'otp': 'fixture',
      'amount': 42.25,
      'termsAgreed': true
    };
    final requests = <http.Request>[];
    final client = ApiHttpClient(
        baseUrl: () => 'https://api.example/v1',
        payloadCodec: legacy(),
        inner: MockClient((request) async {
          requests.add(request);
          expect(request.headers['X-Api-Payload-Format'], isNull);
          expect(await decryptBody(request.body), payload);
          final encoded = jsonDecode(request.body) as Map;
          expect(base64Decode(encoded['iv']).length, 12);
          expect(base64Decode(encoded['tag']).length, 16);
          return http.Response('{"message":"fixture error"}', 409);
        }));
    for (final method in ['POST', 'PUT', 'PATCH', 'DELETE']) {
      final request = http.Request(
          method, Uri.parse('https://api.example/v1/auth/customer-login'))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(payload);
      expect((await client.send(request)).statusCode, 409);
    }
    expect(requests.length, 4);
    expect(requests.map((r) => jsonDecode(r.body)['iv']).toSet().length, 4);
    client.close();
  });

  test('existing envelopes and multipart uploads retain their original bytes',
      () async {
    final prepared =
        http.Request('POST', Uri.parse('https://api.example/v1/cart'))
          ..headers['Content-Type'] = 'application/json'
          ..body = '{"iv":"existing","data":"existing","tag":"existing"}';
    final body = prepared.body;
    await legacy().prepare(prepared);
    expect(prepared.body, body);
    final multipart = http.MultipartRequest('PUT', prepared.url)
      ..fields['name'] = 'Fixture';
    await legacy().prepare(multipart);
    expect(multipart.fields, {'name': 'Fixture'});
    expect(multipart.headers['X-Api-Payload-Format'], isNull);
  });

  test(
      'empty JSON delete bodies are encoded as an empty object for legacy middleware',
      () async {
    final request =
        http.Request('DELETE', Uri.parse('https://api.example/v1/sales/clear'))
          ..headers['Content-Type'] = 'application/json';
    await legacy().prepare(request);
    expect(await decryptBody(request.body), <String, dynamic>{});
  });

  test('external API bodies stay unchanged and do not use the customer cipher',
      () async {
    final client = ApiHttpClient(
        baseUrl: () => 'https://api.example/v1',
        payloadCodec: ApiPayloadCodec(
            useJson: () =>
                throw StateError('must not inspect external payload')),
        inner: MockClient((request) async {
          expect(request.body, '{"external":true}');
          expect(request.headers['X-Api-Payload-Format'], isNull);
          return http.Response('{}', 200);
        }));
    await client.post(Uri.parse('https://external.example/service'),
        headers: {'Content-Type': 'application/json'},
        body: '{"external":true}');
    client.close();
  });

  test(
      'session refresh uses the same deployed encryption without recursively invoking auth transport',
      () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      expect(request.url.path, '/v1/auth/accesstoken');
      expect(
          await decryptBody(request.body), {'refreshToken': 'fixture-refresh'});
      expect(request.headers['X-Api-Payload-Format'], isNull);
      return http.Response('{"success":true,"accessToken":"new-access"}', 200);
    });
    final result = await requestSessionRefresh('fixture-refresh',
        client: client,
        baseUrl: 'https://api.example/v1',
        payloadCodec: legacy());
    expect(result['accessToken'], 'new-access');
    expect(calls, 1);
    client.close();
  });

  test('new server logout route stays disabled until explicitly enabled',
      () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      expect(
          await decryptBody(request.body), {'refreshToken': 'fixture-refresh'});
      return http.Response('{}', 200);
    });
    await requestSessionRevocation('fixture-access', 'fixture-refresh',
        client: client);
    expect(calls, 0);
    await requestSessionRevocation('fixture-access', 'fixture-refresh',
        client: client,
        enabled: true,
        baseUrl: 'https://api.example/v1',
        payloadCodec: legacy());
    expect(calls, 1);
    client.close();
  });

  test(
      'weather uses the existing HTTPS provider by default with unchanged units and data',
      () async {
    final client = MockClient((request) async {
      expect(request.url.scheme, 'https');
      expect(request.url.host, 'api.openweathermap.org');
      expect(request.url.queryParameters, {
        'lat': '40.0',
        'lon': '-70.0',
        'units': 'imperial',
        'appid': 'fixture-weather-key'
      });
      return http.Response('{"main":{"temp":70},"weather":[{"id":800}]}', 200);
    });
    final result = await WeatherService.fetchWeather(40, -70, client: client);
    expect(result['main']['temp'], 70);
    client.close();
  });

  test('weather proxy is an explicit opt-in and never sends a provider key',
      () async {
    final client = MockClient((request) async {
      expect(request.url.toString(),
          'https://api.example/v1/public/weather?lat=40.0&lon=-70.0&units=imperial');
      return http.Response('{"main":{"temp":70}}', 200);
    });
    await WeatherService.fetchWeather(40, -70,
        client: client, useProxy: true, baseUrl: 'https://api.example/v1');
    client.close();
  });

  test(
      'server error messages are available without leaking HTML failures into the UI',
      () {
    expect(
        ApiEnvelope(
                http.Response('{"message":"Invalid encrypted payload"}', 400))
            .message,
        'Invalid encrypted payload');
    expect(
        ApiEnvelope(http.Response('<html>upstream failed</html>', 502)).message,
        isNull);
  });
}
