import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/api_envelope.dart';
import '../services/api_config.dart';
import '../services/api_http.dart';

class CustomerApiRepository {
  CustomerApiRepository(
      {http.Client? client,
      FlutterSecureStorage? storage,
      String Function()? baseUrl})
      : client = client ?? ApiHttpClient(),
        storage = storage ?? const FlutterSecureStorage(),
        baseUrl = baseUrl ?? (() => ApiConfig.baseUrl);
  final http.Client client;
  final FlutterSecureStorage storage;
  final String Function() baseUrl;

  Future<ApiEnvelope> request(String method, String path,
      {Map<String, String>? query,
      Map<String, dynamic>? data,
      bool authenticated = true}) async {
    final uri = Uri.parse('${baseUrl()}/$path').replace(queryParameters: query);
    final request = http.Request(method, uri);
    request.headers['Content-Type'] = 'application/json';
    if (authenticated) {
      final token = await storage.read(key: 'accessToken');
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
    }
    if (data != null) request.body = jsonEncode(data);
    return ApiEnvelope(
        await http.Response.fromStream(await client.send(request)));
  }

  void dispose() => client.close();
}
