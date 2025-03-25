import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';

class TrackService {
  final _authService = AuthService();
  late final ApiService _apiService;
  Map<String, dynamic>? _cachedDummyData;
  Map<String, dynamic>? _currentTrackData;

  TrackService() {
    _apiService = ApiService(_authService);
  }

  Future<Map<String, dynamic>> getTrackData(String trackId) async {
    Map<String, dynamic> trackData;

    if (['track1', 'track2', 'track3'].contains(trackId)) {
      print("📝 Using dummy track data");
      trackData = await _getDummyTrackData(trackId);
    } else {
      print("📡 Fetching track data");
      try {
        trackData = await _apiService.fetchTrackData(trackId);
      } catch (e) {
        print("❌ Failed to fetch track data");
        rethrow;
      }
    }

    _currentTrackData = trackData;

    try {
      String? artworkUrl = _extractArtworkUrl(trackData);

      if (artworkUrl != null && artworkUrl.isNotEmpty) {
        print("🎨 Generating color from artwork");
        Color dominantColor = await getDominantColor(artworkUrl);
        trackData['dominantColor'] = dominantColor.value;
      } else {
        print("⚠️ No artwork found, using default color");
        trackData['dominantColor'] = Colors.blue.value;
      }
    } catch (e) {
      print("❌ Color generation failed, using default");
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
