import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'api_payload.dart';

Future<Map<String, dynamic>> requestSessionRefresh(String refreshToken,
    {http.Client? client,
    String? baseUrl,
    ApiPayloadCodec? payloadCodec}) async {
  final url = Uri.parse('${baseUrl ?? ApiConfig.baseUrl}/auth/accesstoken');
  if (kReleaseMode && url.scheme != 'https') {
    throw StateError('HTTPS is required for API requests');
  }
  final request = http.Request('POST', url)
    ..headers['Content-Type'] = 'application/json'
    ..body = jsonEncode({'refreshToken': refreshToken});
  await (payloadCodec ?? ApiPayloadCodec()).prepare(request);
  final ownClient = client == null;
  final transport = client ?? http.Client();
  try {
    final response =
        await http.Response.fromStream(await transport.send(request));
    if (response.statusCode != 200) return {'status': response.statusCode};
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  } finally {
    if (ownClient) transport.close();
  }
}
