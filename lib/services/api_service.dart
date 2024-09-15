import 'package:cassettefrontend/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _databaseApiKey = dotenv.env['DATABASE_API_KEY'] ?? '';
  final String _spotifyApiKey = dotenv.env['SPOTIFY_API_KEY'] ?? '';

  static const String baseUrl = ApiConstraints.baseUrl;

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
