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
    final apiEnv =
        const String.fromEnvironment('API_ENV', defaultValue: 'prod');
    final baseDomain = apiEnv == 'local' ? _localBaseUrl : _prodBaseUrl;
    return '$baseDomain/api/v1';
  }

  // Base domain without path for connection testing
  static String get baseDomain {
    final apiEnv =
        const String.fromEnvironment('API_ENV', defaultValue: 'prod');
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

  Future<Map<String, dynamic>> convertMusicLink(String sourceLink) async {
    print('Converting link: $sourceLink');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/convert'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sourceLink': sourceLink}),
      );

      print('Request URL: ${Uri.parse('$baseUrl/convert')}');
      print('Request headers: ${response.request?.headers}');
      print('Request body: ${json.encode({'sourceLink': sourceLink})}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Validate and transform the response
          final responseData = {
            'elementType': data['elementType'],
            'musicElementId': data['musicElementId'],
            'postId': data['postId'],
            'details': {
              'title': data['elementType']?.toLowerCase() == 'artist'
                  ? data['details']['name']
                  : data['details']['title'],
              'artist': data['elementType']?.toLowerCase() == 'artist'
                  ? '' // Artists don't have an artist field
                  : data['details']['artist'],
              'coverArtUrl': data['elementType']?.toLowerCase() == 'artist'
                  ? data['details']['imageUrl']
                  : data['details']['coverArtUrl'],
              // Add additional artist-specific fields
              if (data['elementType']?.toLowerCase() ==
                  'artist') ...<String, dynamic>{
                'followers': data['details']['followers'],
                'genres': data['details']['genres'],
                'popularity': data['details']['popularity'],
              },
              // Optional fields for collections
              if (data['details']['tracks'] != null)
                'tracks': data['details']['tracks'],
            },
            'platforms': data['platforms'],
            'userId': data['userId'],
            'username': data['username'],
            'caption': data['caption'],
          };

          print('Transformed response: $responseData');
          return responseData;
        } else {
          final error = data['errorMessage'] ?? 'Failed to convert link';
          print('API error: $error');
          throw Exception(error);
        }
      } else {
        final error = 'Failed to convert link: ${response.statusCode}';
        print(error);
        throw Exception(error);
      }
    } catch (e) {
      print('API request error: $e');
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
}
