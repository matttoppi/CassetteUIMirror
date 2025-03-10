import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer player = AudioPlayer();

  // Track the current URL being played
  String? _currentUrl;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> playPreview(String url) async {
    try {
      print(
          'AudioService: Attempting to play preview from URL: ${url.substring(0, min(50, url.length))}...');

      // If we're already playing this URL, just resume playback
      if (_currentUrl == url && player.playing) {
        print('AudioService: Already playing this URL, resuming playback');
        return;
      }

      // Stop any current playback
      await player.stop();

      // Set the new URL
      _currentUrl = url;

      // Configure audio source with proper error handling
      final duration = await player.setUrl(
        url,
        preload: true, // Preload audio for smoother playback
      );

      if (duration == null) {
        print('AudioService: Failed to load audio - null duration returned');
        throw Exception('Failed to load audio preview');
      }

      print(
          'AudioService: Audio loaded successfully, duration: ${duration.inSeconds} seconds');

      // Start playback
      await player.play();
      print('AudioService: Playback started');
    } catch (e) {
      print('AudioService: Error playing preview: $e');
      _currentUrl = null;
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      print('AudioService: Stopping playback');
      await player.stop();
      _currentUrl = null;
    } catch (e) {
      print('AudioService: Error stopping preview: $e');
      rethrow;
    }
  }

  void dispose() {
    print('AudioService: Disposing player');
    player.dispose();
    _currentUrl = null;
  }

  // Helper function to get min value
  int min(int a, int b) => a < b ? a : b;
}
