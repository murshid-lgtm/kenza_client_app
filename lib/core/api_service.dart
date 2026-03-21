import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> guestTrack(String trackingId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/guest-track?tracking_id=$trackingId',
    );

    final response = await http.get(
      uri,
      headers: ApiConfig.headers(),
    );

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
}