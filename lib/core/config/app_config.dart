import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

/// Application configuration settings
class AppConfig {
  /// Private constructor to prevent instantiation
  AppConfig._();

  /// Initialize configuration
  static Future<void> initialize() async {
    try {
      // Try to load from web directory first for web builds
      await dotenv.load(fileName: 'web/.env').catchError((e) async {
        print(
            'Failed to load .env from web directory, trying root directory...');
        // If that fails, try loading from root directory
        await dotenv.load(fileName: '.env').catchError((e) {
          print('Warning: Failed to load .env file: $e');
          // Continue execution even if .env fails to load
          // as we'll fall back to environment variables
        });
      });

      // Verify critical environment variables
      final webhookUrl = reportWebhookUrl;
      if (webhookUrl.isEmpty) {
        print('Warning: REPORT_WEBHOOK_URL is not configured');
      } else {
        print('Webhook URL configured successfully');
      }
    } catch (e) {
      print('Warning: Error during .env initialization: $e');
      // Continue execution as we'll fall back to environment variables
    }
  }

  /// Get the report webhook URL
  static String get reportWebhookUrl {
    String url = '';

    // First try to get from environment variables
    const envValue =
        String.fromEnvironment('REPORT_WEBHOOK_URL', defaultValue: '');
    if (envValue.isNotEmpty) {
      url = envValue;
    } else {
      // Then try to get from .env file
      url = dotenv.env['REPORT_WEBHOOK_URL'] ?? '';
    }

    if (url.isEmpty) {
      print(
          'Warning: REPORT_WEBHOOK_URL is not set in either environment variables or .env file');
    }

    return url;
  }

  /// Get the Supabase URL
  static String get supabaseUrl {
    // First try to get from environment variables
    const envValue = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (envValue.isNotEmpty) {
      return envValue;
    }

    // Then try to get from .env file
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  /// Get the Supabase anonymous key
  static String get supabaseAnonKey {
    // First try to get from environment variables
    const envValue =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (envValue.isNotEmpty) {
      return envValue;
    }

    // Then try to get from .env file
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  /// Get the Supabase service role key (for admin operations)
  static String get supabaseServiceRoleKey {
    // First try to get from environment variables
    const envValue =
        String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY', defaultValue: '');
    if (envValue.isNotEmpty) {
      return envValue;
    }

    // Then try to get from .env file
    return dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  }
}
