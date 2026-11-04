import 'dart:convert';

import 'package:http/http.dart' as transport;
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_payload.dart';
import 'session_service.dart';

export 'package:http/http.dart' hide get, post, put, patch, delete, head;

/// Preserves existing HTTP bodies and status codes while handling revoked
/// sessions centrally. Never retries writes. Payload format defaults to deployed-server compatibility.
class ApiHttpClient extends transport.BaseClient {
  ApiHttpClient({
    transport.Client? inner,
    SessionService? session,
    String Function()? baseUrl,
    ApiPayloadCodec? payloadCodec,
  })  : _inner = inner ?? transport.Client(),
        _session = session ?? SessionService(),
        _baseUrl = baseUrl ?? (() => ApiConfig.baseUrl),
        _payloadCodec = payloadCodec ?? ApiPayloadCodec();

  final transport.Client _inner;
  final SessionService _session;
  final String Function() _baseUrl;
  final ApiPayloadCodec _payloadCodec;

  bool _isCustomerApi(Uri url) {
    final base = Uri.tryParse(_baseUrl());
    if (base == null || !base.hasAuthority) return false;
    final prefix = base.path.replaceFirst(RegExp(r'/$'), '');
    final relative = url.path.startsWith('$prefix/')
        ? url.path.substring(prefix.length)
        : '';
    return url.origin == base.origin &&
        relative.isNotEmpty &&
        !relative.startsWith('/auth/');
  }

  @override
  Future<transport.StreamedResponse> send(transport.BaseRequest request) async {
    final base = Uri.tryParse(_baseUrl());
    final prefix = base?.path.replaceFirst(RegExp(r'/$'), '');
    final backend = base != null &&
        base.hasAuthority &&
        request.url.origin == base.origin &&
        request.url.path.startsWith('$prefix/');
    if (backend) {
      if (kReleaseMode && request.url.scheme != 'https') {
        throw StateError('HTTPS is required for API requests');
      }
      await _payloadCodec.prepare(request);
    }
    final authorization =
        request.headers['Authorization'] ?? request.headers['authorization'];
    // Refresh before sending an expired bearer, including writes. This avoids
    // replaying a payment/multipart body after it has been sent.
    if (authorization?.startsWith('Bearer ') == true &&
        _isCustomerApi(request.url)) {
      final sentToken = authorization!.substring(7);
      if (!SessionService.isTokenValid(sentToken) &&
          await _session.storage.read(key: 'accessToken') == sentToken &&
          await _session.refreshAccessToken()) {
        final current = await _session.storage.read(key: 'accessToken');
        request.headers['Authorization'] = 'Bearer $current';
      }
    }
    final response = await _inner.send(request);
    if (response.statusCode == 401 &&
        authorization?.startsWith('Bearer ') == true &&
        _isCustomerApi(request.url)) {
      final sent =
          request.headers['Authorization'] ?? request.headers['authorization'];
      await _session.expireAccessToken(sent!.substring(7));
    }
    return response;
  }

  @override
  void close() => _inner.close();
}

final _client = ApiHttpClient();

Future<transport.Response> get(Uri url, {Map<String, String>? headers}) =>
    _client.get(url, headers: headers);
Future<transport.Response> head(Uri url, {Map<String, String>? headers}) =>
    _client.head(url, headers: headers);
Future<transport.Response> post(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _client.post(url, headers: headers, body: body, encoding: encoding);
Future<transport.Response> put(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _client.put(url, headers: headers, body: body, encoding: encoding);
Future<transport.Response> patch(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _client.patch(url, headers: headers, body: body, encoding: encoding);
Future<transport.Response> delete(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _client.delete(url, headers: headers, body: body, encoding: encoding);
Future<transport.StreamedResponse> send(transport.BaseRequest request) =>
    _client.send(request);
