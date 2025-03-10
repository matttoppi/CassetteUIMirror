import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer player = AudioPlayer();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> playPreview(String url) async {
    try {
      await player.stop();
      await player.setUrl(url);
      await player.play();
    } catch (e) {
      print('Error playing preview: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await player.stop();
    } catch (e) {
      print('Error stopping preview: $e');
      rethrow;
    }
  }

  void dispose() {
    player.dispose();
  }
}
