import 'package:cassettefrontend/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment('SUPABASE_URL');


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
