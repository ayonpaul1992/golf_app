import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as transport;

import '../models/history_page.dart';
import '../services/api_config.dart';
import '../services/api_http.dart';

class ApiException implements Exception {
  const ApiException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => message;
}

class HistoryRepository {
  HistoryRepository(
      {transport.Client? client,
      FlutterSecureStorage? storage,
      String Function()? baseUrl})
      : _client = client ?? ApiHttpClient(),
        _storage = storage ?? const FlutterSecureStorage(),
        _baseUrl = baseUrl ?? (() => ApiConfig.baseUrl);
  final transport.Client _client;
  final FlutterSecureStorage _storage;
  final String Function() _baseUrl;

  Future<HistoryPage> fetch(String endpoint,
      {int page = 1,
      int limit = 50,
      Map<String, String> filters = const {},
      bool storeCredit = false}) async {
    if (page < 1 || limit < 1) throw ArgumentError('Invalid pagination');
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw const ApiException(401, 'Please sign in again.');
    final uri = Uri.parse('${_baseUrl()}/$endpoint').replace(queryParameters: {
      ...filters,
      'page': '$page',
      'limit': '$limit',
    });
    final response =
        await _client.get(uri, headers: {'Authorization': 'Bearer $token'});
    Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw ApiException(
          response.statusCode, 'Invalid server response. Please retry.');
    }
    if (response.statusCode != 200 || body['success'] == false) {
      throw ApiException(response.statusCode,
          body['message']?.toString() ?? 'Unable to load history.');
    }
    return HistoryPage.fromJson(body,
        page: page, limit: limit, storeCredit: storeCredit);
  }

  void dispose() => _client.close();
}
