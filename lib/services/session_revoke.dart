import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_payload.dart';

Future<void> requestSessionRevocation(String? access, String? refresh,
    {http.Client? client,
    String? baseUrl,
    ApiPayloadCodec? payloadCodec,
    bool? enabled}) async {
  // This endpoint is new backend functionality. Existing local logout remains
  // available; enable server revocation only after its deployment is verified.
  if (!(enabled ?? ApiConfig.sessionRevocationEnabled) ||
      (access == null && refresh == null)) {
    return;
  }
  final url = Uri.parse('${baseUrl ?? ApiConfig.baseUrl}/auth/logout');
  if (url.scheme != 'https') return;
  final request = http.Request('POST', url)
    ..headers.addAll({
      'Content-Type': 'application/json',
      if (access != null) 'Authorization': 'Bearer $access'
    })
    ..body = jsonEncode({if (refresh != null) 'refreshToken': refresh});
  await (payloadCodec ?? ApiPayloadCodec()).prepare(request);
  final ownClient = client == null;
  final transport = client ?? http.Client();
  try {
    await http.Response.fromStream(await transport.send(request))
        .timeout(const Duration(seconds: 5));
  } finally {
    if (ownClient) transport.close();
  }
}
