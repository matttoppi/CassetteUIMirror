import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class Env {
  // Dev
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get profileBucket => kDebugMode
      ? dotenv.env['PROFILE_BUCKET_DEV'] ?? 'profile_bucket'
      : dotenv.env['PROFILE_BUCKET_PROD'] ?? 'profile-pictures';
  static String get appDomain => kDebugMode
      ? dotenv.env['APP_DOMAIN_DEV'] ?? 'https://localhost:56752'
      : dotenv.env['APP_DOMAIN_PROD'] ?? 'https://cassetteinc.org';

  // Production
  // const supabaseUrl = "https://wefxtfnobcmlzysornxw.supabase.co";
  // const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndlZnh0Zm5vYmNtbHp5c29ybnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ2MTAyOTQsImV4cCI6MjAzMDE4NjI5NH0.OW-VZZB4fRevnkSIwh7w8iApJ8W7QNk9Mf1cGVJ1z-s";
  // const profileBucket = 'profile-pictures';
  // const appDomain = 'https://cassetteinc.org';

  // Production values can be added as needed
  // static const prodSupabaseUrl = "...";
  // static const prodSupabaseAnonKey = "...";

  // Spotify configuration
  static String get spotifyApiKey => dotenv.env['SPOTIFY_API_KEY'] ?? '';
  static String get spotifyClientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  static String get spotifyClientSecret =>
      dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';

  // Webhook configuration
  static String get reportWebhookUrl => dotenv.env['REPORT_WEBHOOK_URL'] ?? '';
}
