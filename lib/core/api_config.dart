class ApiConfig {
  static const String baseUrl = 'https://trial.mellodeals.com/wp-json/kst/v5';

  // Keep empty for now if Production Hardening token is OFF
  static const String appToken = '';

  static Map<String, String> headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (appToken.isNotEmpty) {
      headers['X-KST-App-Token'] = appToken;
    }

    return headers;
  }
}