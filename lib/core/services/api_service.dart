import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // API URLs for different environments
  static const String _prodBaseUrl =
      'https://nm2uheummh.us-east-1.awsapprunner.com';
  static const String _localBaseUrl = 'http://localhost:5173';

  // Get the base URL from environment configuration
  static String get baseUrl {
    // Read the API_ENV from dart-define, default to 'prod' if not set
    const apiEnv =
        String.fromEnvironment('API_ENV', defaultValue: 'prod');
    print('Current API Environment: $apiEnv'); // Helpful for debugging
    const baseDomain = apiEnv == 'local' ? _localBaseUrl : _prodBaseUrl;
    return '$baseDomain/api/v1';
  }

  // Base domain without path for connection testing
  static String get baseDomain {
    const apiEnv =
        String.fromEnvironment('API_ENV', defaultValue: 'prod');
    return apiEnv == 'local' ? _localBaseUrl : _prodBaseUrl;
  }

  // Test function to verify API connection using root endpoint
  Future<bool> testConnection() async {
    try {
      // Test with root endpoint GET request
      final response = await http.get(
        Uri.parse(baseDomain), // Root URL without /api/v1
      );
      print('API test connection status: ${response.statusCode}');
      print('API info: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API test connection error: $e');
      return false;
    }
  }

  // Convert a music link from one service to another
  Future<Map<String, dynamic>> convertMusicLink(String sourceLink) async {
    print('🔄 Converting music link');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/convert'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sourceLink': sourceLink}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Validate required fields
          final requiredFields = [
            'elementType',
            'musicElementId',
            'postId',
            'details'
          ];

          final missingFields = requiredFields
              .where((field) => !data.containsKey(field) || data[field] == null)
              .toList();

          if (missingFields.isNotEmpty) {
            throw Exception(
                'Missing required fields: ${missingFields.join(", ")}');
          }

          // Add the original link to the response data
          data['originalLink'] = sourceLink;
          return data;
        } else {
          final error = data['errorMessage'] ?? 'Failed to convert link';
          throw Exception(error);
        }
      } else {
        throw Exception('Failed to convert link: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Convert] Error: $e');
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTrackData(String trackId) async {
    final response = await http.get(Uri.parse('$baseUrl/tracks/$trackId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to load track data: ${response.statusCode}');
      throw Exception('Failed to load track data: ${response.statusCode}');
    }
  }

  // Helper method to get default headers for API requests
  Map<String, String> getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
