import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TrackService {
  Future<Map<String, dynamic>> getTrackData() async {
    // Load the JSON file from the assets
    String jsonString = await rootBundle.loadString('lib/data/dummy_track_data.json');

    // Parse the JSON string
    Map<String, dynamic> jsonData = json.decode(jsonString);

    return jsonData;
  }
}
