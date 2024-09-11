import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:palette_generator/palette_generator.dart';
import 'api_service.dart';

class TrackService {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _cachedDummyData;

  Future<Map<String, dynamic>> getTrackData(String trackId) async {
    Map<String, dynamic> trackData;

    if (['track1', 'track2', 'track3'].contains(trackId)) {
      print("Using dummy data for $trackId");
      trackData = await _getDummyTrackData(trackId);
    } else {
      print("Fetching data from API for $trackId");
      try {
        // Replace 'fetchTrackData' with the actual method name from your ApiService
        trackData = await _apiService.fetchTrackData(trackId);
      } catch (e) {
        print("Error fetching track data: $e");
        rethrow; // This will propagate the error up to the UI
      }
    }

    // Get the dominant color from the album artwork 
    Color dominantColor = await getDominantColor(trackData['platforms']['spotify']['art_url']);

    // Add the dominant color to the trackData
    trackData['dominantColor'] = dominantColor.value;

    return trackData;
  }

  Future<Map<String, dynamic>> _getDummyTrackData(String trackId) async {
    if (_cachedDummyData == null) {
      String jsonString = await rootBundle.loadString('lib/data/dummy_track_data.json');
      _cachedDummyData = json.decode(jsonString);
    }
    
    final trackData = _cachedDummyData![trackId];
    if (trackData == null) {
      throw Exception('Track not found');
    }
    return trackData;
  }

  Future<Color> getDominantColor(String imageUrl) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
      size: const Size(200, 200),
      maximumColorCount: 32,
    );

    // Filter for more vibrant colors
    List<PaletteColor> vibrantColors = paletteGenerator.paletteColors.where((paletteColor) {
      final hsl = HSLColor.fromColor(paletteColor.color);
      return hsl.saturation > 0.4 && hsl.lightness > 0.3 && hsl.lightness < 0.7;
    }).toList()
      ..sort((a, b) => b.population.compareTo(a.population));

    // Return the most vibrant color, or a default if none found
    return vibrantColors.isNotEmpty ? vibrantColors.first.color : Colors.blue;
  }
}
