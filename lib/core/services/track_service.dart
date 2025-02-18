import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:palette_generator/palette_generator.dart';
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
      // Try to get artwork URL from different sources
      String? artworkUrl;
      if (trackData['platforms']?['spotify']?['artworkUrl'] != null) {
        artworkUrl = trackData['platforms']['spotify']['artworkUrl'];
      } else if (trackData['platforms']?['applemusic']?['artworkUrl'] != null) {
        artworkUrl = trackData['platforms']['applemusic']['artworkUrl'];
      } else if (trackData['details']?['coverArtUrl'] != null) {
        artworkUrl = trackData['details']['coverArtUrl'];
      }

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

  Future<Color> getDominantColor(String imageUrl) async {
    try {
      // Simple color mapping based on platform
      if (_currentTrackData != null) {
        final platforms =
            _currentTrackData!['platforms'] as Map<String, dynamic>?;

        // Get genres from any available platform
        final List<String> genres = [];
        if (platforms != null) {
          for (var platform in platforms.values) {
            if (platform is Map<String, dynamic> &&
                platform['genres'] is List) {
              genres.addAll((platform['genres'] as List).cast<String>());
            }
          }
        }

        // Color selection based on genre
        if (genres.isNotEmpty) {
          String mainGenre = genres.first.toLowerCase();

          // Genre-based color mapping
          if (mainGenre.contains('rock') || mainGenre.contains('metal')) {
            return Colors.red.shade700;
          } else if (mainGenre.contains('blues')) {
            return Colors.indigo.shade600;
          } else if (mainGenre.contains('jazz')) {
            return Colors.amber.shade700;
          } else if (mainGenre.contains('classical')) {
            return Colors.brown.shade500;
          } else if (mainGenre.contains('electronic') ||
              mainGenre.contains('dance')) {
            return Colors.purple.shade500;
          } else if (mainGenre.contains('hip') || mainGenre.contains('rap')) {
            return Colors.grey.shade800;
          } else if (mainGenre.contains('soul') || mainGenre.contains('r&b')) {
            return Colors.deepOrange.shade500;
          } else if (mainGenre.contains('pop')) {
            return Colors.pink.shade400;
          } else if (mainGenre.contains('country') ||
              mainGenre.contains('folk')) {
            return Colors.green.shade600;
          }
        }

        // If no genre match, use platform-based colors
        if (platforms?['spotify'] != null) {
          return const Color(0xFF1DB954); // Spotify green
        } else if (platforms?['applemusic'] != null) {
          return const Color(0xFFFA243C); // Apple Music red
        } else if (platforms?['deezer'] != null) {
          return const Color(0xFF00C7F2); // Deezer blue
        }
      }

      // Default color sequence if no other matches
      final defaultColors = [
        Colors.purple.shade500,
        Colors.teal.shade500,
        Colors.deepOrange.shade500,
        Colors.indigo.shade500,
        Colors.pink.shade500,
      ];

      // Use a deterministic selection based on the URL
      final colorIndex = imageUrl.hashCode.abs() % defaultColors.length;
      return defaultColors[colorIndex];
    } catch (e) {
      print("Error in getDominantColor: $e");
      return Colors.purple.shade500; // Different default than blue
    }
  }
}
