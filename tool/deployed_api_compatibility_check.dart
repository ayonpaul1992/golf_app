// Run explicitly: flutter test tool/deployed_api_compatibility_check.dart
// Sends no customer credentials, bookings or payments. Uses only the deployed
// login validator and a weather read at fixed public coordinates.
import 'dart:convert';
import 'dart:io';
import 'package:driver_pos/services/api_payload.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

Future<(int, Map<String, dynamic>)> curl(String url, {String? body}) async {
  final process = await Process.start('/usr/bin/curl', [
    '--silent',
    '--show-error',
    '--max-time',
    '20',
    if (body != null) ...[
      '--request',
      'POST',
      '--header',
      'Content-Type: application/json',
      '--data-binary',
      '@-'
    ],
    '--write-out',
    '\n%{http_code}',
    url,
  ]);
  final outputFuture = process.stdout.transform(utf8.decoder).join();
  final errorsFuture = process.stderr.transform(utf8.decoder).join();
  if (body != null) process.stdin.write(body);
  await process.stdin.close();
  final output = await outputFuture;
  await errorsFuture;
  if (await process.exitCode != 0) {
    throw StateError('Deployed compatibility probe transport failed');
  }
  final index = output.lastIndexOf('\n');
  return (
    int.parse(output.substring(index + 1)),
    Map<String, dynamic>.from(jsonDecode(output.substring(0, index)) as Map)
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final results = <Map<String, dynamic>>[];
  setUpAll(
      () => dotenv.loadFromString(envString: File('.env').readAsStringSync()));
  for (final env in ['PROD', 'DEV']) {
    test(
        '$env accepts the actual Flutter encrypted login format before credential validation',
        () async {
      final request = http.Request(
          'POST',
          Uri.parse('${dotenv.env['${env}_BASE_URL']}/auth/customer-login')
              .replace(queryParameters: {
            'golfCourseCode': dotenv.env['${env}_GOLF_COURSE_CODE']
          }))
        ..headers['Content-Type'] = 'application/json'
        ..body = '{}';
      await ApiPayloadCodec().prepare(request);
      expect(request.headers['X-Api-Payload-Format'], isNull);
      final (status, response) =
          await curl(request.url.toString(), body: request.body);
      expect(status, 400);
      expect(response['message'], 'Email address and password are required.');
      results.add({
        'environment': env,
        'endpoint': 'auth/customer-login',
        'status': status,
        'message': response['message'],
        'credentialsSubmitted': false,
        'actualFlutterCodec': true
      });
    });
  }
  test('existing weather provider is still available', () async {
    final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': '0',
      'lon': '0',
      'units': 'imperial',
      'appid': dotenv.env['OPEN_WEATHER_API_KEY']
    });
    final (status, response) = await curl(url.toString());
    expect(status, 200);
    expect(response['main']['temp'], isA<num>());
    expect(response['weather'], isA<List>());
    results.add({
      'feature': 'weather',
      'status': status,
      'contractVerified': true,
      'coordinates': 'fixed public 0,0'
    });
  });
  tearDownAll(() =>
      File('../audit/evidence/flutter-deployed-compatibility.json')
          .writeAsStringSync('${jsonEncode({
            'customerCredentialsSubmitted': false,
            'results': results
          })}\n'));
}
