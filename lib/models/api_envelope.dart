import 'dart:convert';
import 'package:http/http.dart' as http;

/// Retains transport status and the original body for existing screen handling.
/// JSON decoding belongs to the response boundary, including error envelopes.
class ApiEnvelope {
  ApiEnvelope(this.response);
  final http.Response response;
  int get statusCode => response.statusCode;
  String? get reasonPhrase => response.reasonPhrase;
  String get body => response.body;
  late final dynamic json = jsonDecode(body);
  bool get success => json is Map && json['success'] == true;
  dynamic get data => json is Map ? json['data'] : null;
  String? get message {
    try {
      final value = json;
      return value is Map &&
              value['message'] is String &&
              (value['message'] as String).trim().isNotEmpty
          ? value['message'] as String
          : null;
    } on FormatException {
      return null;
    }
  }
}
