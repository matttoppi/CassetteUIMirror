import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class TrackService {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _cachedDummyData;
  Map<String, dynamic>? _currentTrackData;

  Future<Map<String, dynamic>> getTrackData(String trackId) async {
    Map<String, dynamic> trackData;

    if (['track1', 'track2', 'track3'].contains(trackId)) {
      print("Using dummy data for $trackId");
      trackData = await _getDummyTrackData(trackId);
    } else {
      print("Fetching data from API for $trackId");
      try {
        trackData = await _apiService.fetchTrackData(trackId);
      } catch (e) {
        print("Error fetching track data: $e");
        rethrow;
      }
    }

    _currentTrackData = trackData;

    try {
      // Extract artwork URL
      String? artworkUrl = _extractArtworkUrl(trackData);

      if (artworkUrl != null && artworkUrl.isNotEmpty) {
        print("Getting dominant color from artwork: $artworkUrl");
        Color dominantColor = await getDominantColor(artworkUrl);
        trackData['dominantColor'] = dominantColor.value;
      } else {
        print("No valid artwork URL found for color generation");
        trackData['dominantColor'] = Colors.blue.value;
      }
    } catch (e) {
      print("Error generating dominant color: $e");
      trackData['dominantColor'] = Colors.blue.value;
    }

    return trackData;
  }

  Future<Map<String, dynamic>> _getDummyTrackData(String trackId) async {
    if (_cachedDummyData == null) {
      String jsonString =
          await rootBundle.loadString('lib/data/dummy_track_data.json');
      _cachedDummyData = json.decode(jsonString);
    }

    final trackData = _cachedDummyData![trackId];
    if (trackData == null) {
      throw Exception('Track not found');
    }
    return trackData;
  }

  String? _extractArtworkUrl(Map<String, dynamic> trackData) {
    return trackData['details']?['coverArtUrl'] as String?;
  }

  Future<Color> getDominantColor(String imageUrl) async {
    try {
      // Download image bytes using http to avoid canvas tainting issues
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        // Fallback to default color if the image fails to load
        return Colors.blue; // Default color
      }
      // Create an in-memory image from the downloaded bytes
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        MemoryImage(response.bodyBytes),
        size: const Size(200, 200), // Constrain size for faster processing
        maximumColorCount: 32, // Increased for better color selection
      );
      // Filter for more vibrant colors
      List<PaletteColor> vibrantColors =
          paletteGenerator.paletteColors.where((paletteColor) {
        final hsl = HSLColor.fromColor(paletteColor.color);
        // Filter colors based on saturation and lightness
        return hsl.saturation > 0.4 &&
            hsl.lightness > 0.3 &&
            hsl.lightness < 0.7;
      }).toList()
            ..sort((a, b) => b.population.compareTo(a.population));
      // Return the most vibrant color, or default to blue if none found
      return vibrantColors.isNotEmpty ? vibrantColors.first.color : Colors.blue;
    } catch (e) {
      print('Error in getDominantColor: $e'); // Log error for debugging
      return Colors.blue; // Fallback color
    }
  }
}
