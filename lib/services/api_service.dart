import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_data.dart';

/// Service for communicating with the Vibe Tracker API
class ApiService {
  final String baseUrl;
  final String accessToken;

  ApiService({
    required this.baseUrl,
    required this.accessToken,
  });

  /// Send location data to the /api/track endpoint
  Future<bool> sendLocation(LocationData location) async {
    try {
      // Remove trailing slash from baseUrl if present
      final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final url = Uri.parse('$cleanUrl/api/track');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'User-Agent': 'VibeTracker-CLI/1.0',
        },
        body: jsonEncode(location.toGeoJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Location sent successfully: ${location.toString()}');
        return true;
      } else {
        print('Failed to send location. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending location: $e');
      return false;
    }
  }

  /// Test the API connection
  Future<bool> testConnection() async {
    try {
      final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final url = Uri.parse('$cleanUrl/api/track');

      // Try a simple request to see if the endpoint responds
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'VibeTracker-CLI/1.0',
        },
      ).timeout(const Duration(seconds: 5));

      // Any response (even 401/403) means the server is reachable
      return response.statusCode < 500;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
