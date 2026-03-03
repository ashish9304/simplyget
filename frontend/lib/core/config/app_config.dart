import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    final url = dotenv.get('API_BASE_URL');
    return url.endsWith('/') ? url : '$url/';
  }
}
