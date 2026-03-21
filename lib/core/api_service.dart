import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> guestTrack(String trackingId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/guest-track?tracking_id=$trackingId',
    );

    debugPrintUrl(uri.toString());

    final response = await http.get(
      uri,
      headers: ApiConfig.headers(),
    );

    debugPrintStatus(response.statusCode);
    debugPrintBody(response.body);

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to load tracking data');
    }
  }

  static Future<Map<String, dynamic>> appSettings() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/app-settings');

    final response = await http.get(
      uri,
      headers: ApiConfig.headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to load app settings');
    }
  }

  static void debugPrintUrl(String value) {
    // ignore: avoid_print
    print('API URL: $value');
  }

  static void debugPrintStatus(int value) {
    // ignore: avoid_print
    print('API STATUS: $value');
  }

  static void debugPrintBody(String value) {
    // ignore: avoid_print
    print('API BODY: $value');
  }
}