import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:palette_generator/palette_generator.dart';

class TrackService {
  Future<Map<String, dynamic>> getTrackData(String trackId) async {
    // Load the JSON file from the assets
    String jsonString = await rootBundle.loadString('lib/data/dummy_track_data.json');

    // Parse the JSON string
    Map<String, dynamic> allData = json.decode(jsonString);
    
    // Find the track with the matching ID
    Map<String, dynamic>? trackData;
    allData.forEach((key, value) {
      if (value['track']['id'] == trackId) {
        trackData = value;
      }
    });

    if (trackData == null) {
      throw Exception('Track not found');
    }

    // Get the dominant color from the album artwork 
    Color dominantColor = await getDominantColor(trackData!['platforms']['spotify']['art_url']);

    // Add the dominant color to the trackData
    trackData!['dominantColor'] = dominantColor.value;

    return trackData!;
  }

  Future<Color> getDominantColor(String imageUrl) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
      size: Size(200, 200),   // This is the size of the image that is sampled for the palette
      maximumColorCount: 32,  // This is the number of colors that are sampled for the palette
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
