import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpotifyService {
  static const String _clientId = '352a874dee3c4b46b27f1a96df70aa0b';
  static const String _clientSecret = '393f714172be4f00a2f68dbac3baa029'; 
  static const String _redirectUri = 'http://localhost:56752/spotify_callback';
  static const String _scope = 'user-read-private user-read-email';

  static Future<void> initiateSpotifyAuth(BuildContext context) async {
    final String authUrl = 'https://accounts.spotify.com/authorize'
        '?client_id=$_clientId'
        '&response_type=code'
        '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
        '&scope=$_scope';

    print('Launching Spotify auth URL: $authUrl');

    if (kIsWeb) {
      // For web, open in the same tab
      await launchUrl(Uri.parse(authUrl), webOnlyWindowName: '_self');
    } else {
      // For mobile platforms
      if (await canLaunchUrl(Uri.parse(authUrl))) {
        await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $authUrl';
      }
    }
  }

  static Future<void> exchangeCodeForToken(String code) async {
    try {
      print('Exchanging code for token...');
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final refreshToken = data['refresh_token'];

        // Store the refresh token in the user_profiles table
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          try {
            await Supabase.instance.client.from('user_profiles').upsert({
              'id': user.id,
              'spotify_refresh_token': refreshToken,
              'updated_at': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            print('Error updating user profile: $e');
            // Continue execution even if update fails
          }
        }
      } else {
        throw Exception('Failed to exchange code for token: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error in exchangeCodeForToken: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow the exception, allow the process to continue
    }
  }
}