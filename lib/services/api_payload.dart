import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Compatibility with the deployed server: SHA256(secret), AES-256-GCM,
/// 12-byte IV and separate base64 ciphertext/tag. The shared payload key is
/// recoverable in legacy clients and does not replace HTTPS or authorization.
class ApiPayloadCodec {
  ApiPayloadCodec({bool Function()? useJson, String Function()? key})
      : _useJson = useJson ?? (() => ApiConfig.useJsonPayload),
        _key = key ?? (() => ApiConfig.encryptionKey);
  final bool Function() _useJson;
  final String Function() _key;

  Future<void> prepare(http.BaseRequest request) async {
    if (!['POST', 'PUT', 'PATCH', 'DELETE'].contains(request.method) ||
        request is http.MultipartRequest ||
        request.headers['content-type']
                ?.split(';')
                .first
                .trim()
                .toLowerCase() !=
            'application/json') {
      return;
    }
    if (request is! http.Request) {
      throw StateError('JSON payload requires a buffered request');
    }
    final payload =
        request.body.isEmpty ? <String, dynamic>{} : jsonDecode(request.body);
    final alreadyEncrypted = payload is Map &&
        payload.length == 3 &&
        ['iv', 'data', 'tag'].every((field) => payload[field] is String);
    if (alreadyEncrypted) {
      request.headers.remove('X-Api-Payload-Format');
      return;
    }
    if (_useJson()) {
      request.headers['X-Api-Payload-Format'] = 'json';
      return;
    }
    final algorithm = AesGcm.with256bits();
    final key = SecretKey(sha256.convert(utf8.encode(_key())).bytes);
    final box = await algorithm.encrypt(utf8.encode(jsonEncode(payload)),
        secretKey: key, nonce: algorithm.newNonce());
    request.body = jsonEncode({
      'iv': base64Encode(box.nonce),
      'data': base64Encode(box.cipherText),
      'tag': base64Encode(box.mac.bytes),
    });
    request.headers.remove('X-Api-Payload-Format');
  }
}
