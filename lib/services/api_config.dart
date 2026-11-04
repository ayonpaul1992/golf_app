import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String _required(String name) {
    final value = dotenv.env[name];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing application configuration: $name');
    }
    return value;
  }

  // Deployed APIs currently require the legacy AES-GCM envelope. Enable JSON
  // only after that environment's backend has been deployed and verified.
  static bool get useJsonPayload {
    final mode = dotenv.env['API_PAYLOAD_FORMAT'] ?? 'legacy';
    if (mode != 'legacy' && mode != 'json') {
      throw StateError('Invalid API_PAYLOAD_FORMAT');
    }
    return mode == 'json';
  }

  static String get encryptionKey => _required('API_ENCRYPTION_KEY');
  static String get weatherApiKey => _required('OPEN_WEATHER_API_KEY');
  static bool get useWeatherProxy {
    final source = dotenv.env['WEATHER_SOURCE'] ?? 'direct';
    if (source != 'direct' && source != 'proxy') {
      throw StateError('Invalid WEATHER_SOURCE');
    }
    return source == 'proxy';
  }

  static bool get sessionRevocationEnabled =>
      dotenv.env['SESSION_REVOCATION_ENABLED'] == 'true';

  static String get baseUrl {
    final env = dotenv.env['ENV'] ?? 'dev';

    if (env == 'prod') {
      return dotenv.env['PROD_BASE_URL'] ?? '';
    } else {
      return dotenv.env['DEV_BASE_URL'] ?? '';
    }
  }

  static String get golfCourseCode {
    final env = dotenv.env['ENV'] ?? 'dev';

    if (env == 'prod') {
      return dotenv.env['PROD_GOLF_COURSE_CODE'] ?? '';
    } else {
      return dotenv.env['DEV_GOLF_COURSE_CODE'] ?? '';
    }
  }

  static String get socketUrl {
    final env = dotenv.env['ENV'] ?? 'dev';

    if (env == 'prod') {
      return dotenv.env['PROD_SOCKET_URL'] ?? '';
    } else {
      return dotenv.env['DEV_SOCKET_URL'] ?? '';
    }
  }
}
