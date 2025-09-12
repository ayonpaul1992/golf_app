import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
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
