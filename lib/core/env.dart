import 'package:flutter/foundation.dart' show kDebugMode;

class Env {
  // Dev
  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static String get profileBucket =>
      kDebugMode ? 'profile_bucket' : 'profile-pictures';
  static String get appDomain =>
      kDebugMode ? 'https://localhost:56752' : 'https://cassetteinc.org';

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
}
