import 'package:flutter/foundation.dart' show kDebugMode;

class Env {
  // Dev
  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static String get profileBucket =>
      kDebugMode ? 'profile_bucket' : 'profile-pictures';

  // Feature flags
  // Control whether lambda warmup is enabled
  static bool get enableLambdaWarmup =>
      const bool.fromEnvironment('ENABLE_LAMBDA_WARMUP', defaultValue: false);

  // Updated to use localhost:3000 in debug mode
  static String get appDomain {
    if (kDebugMode) {
      // Get base URL from window.location in web
      if (Uri.base.toString().isNotEmpty) {
        return Uri.base.origin;
      }
      // Default to localhost:3000 for development
      return 'http://localhost:3000';
    }
    return 'https://cassetteinc.org';
  }

  // Production values can be added as needed
  // static const prodSupabaseUrl = "...";
  // static const prodSupabaseAnonKey = "...";

  // Spotify configuration
  static String get spotifyClientId =>
      const String.fromEnvironment('SPOTIFY_CLIENT_ID', defaultValue: '');
  static String get spotifyClientSecret =>
      const String.fromEnvironment('SPOTIFY_CLIENT_SECRET', defaultValue: '');

  // Webhook configuration
  static String get reportWebhookUrl =>
      const String.fromEnvironment('REPORT_WEBHOOK_URL', defaultValue: '');

  // Apple Music configuration
  static String get appleMusicDeveloperToken =>
      const String.fromEnvironment('APPLE_MUSIC_DEVELOPER_TOKEN',
          defaultValue: '');
  static String get appleMusicKeyId =>
      const String.fromEnvironment('APPLE_MUSIC_KEY_ID', defaultValue: '');
  static String get appleMusicTeamId =>
      const String.fromEnvironment('APPLE_MUSIC_TEAM_ID', defaultValue: '');
  static String get appleMusicPrivateKey =>
      const String.fromEnvironment('APPLE_MUSIC_PRIVATE_KEY', defaultValue: '');
}
