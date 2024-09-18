import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpotifyService {
  static const String _clientId = '352a874dee3c4b46b27f1a96df70aa0b';
  static const String _clientSecret = '393f714172be4f00a2f68dbac3baa029'; 
  static const String _localRedirectUri = 'http://localhost:56752/spotify_callback';
  static const String _productionRedirectUri = 'https://cassetteinc.org/spotify_callback';
  static const String _scope = 'user-read-private user-read-email';

  static String get _redirectUri {
    if (kIsWeb) {
      final currentUrl = Uri.base.toString();
      print('Current URL: $currentUrl');
      if (currentUrl.startsWith('http://localhost') || currentUrl.startsWith('http://127.0.0.1')) {
        return _localRedirectUri;
      } else {
        return _productionRedirectUri;
      }
    } else {
      // For non-web platforms, always use the local redirect URI
      return _localRedirectUri;
    }
  }

  static Future<void> initiateSpotifyAuth(BuildContext context) async {
    final String redirectUri = _redirectUri;
    final String encodedRedirectUri = Uri.encodeComponent(redirectUri);
    final String authUrl = 'https://accounts.spotify.com/authorize'
        '?client_id=$_clientId'
        '&response_type=code'
        '&redirect_uri=$encodedRedirectUri'
        '&scope=$_scope';

    print('Full Spotify auth URL: $authUrl');
    print('Redirect URI (not encoded): $redirectUri');
    print('Redirect URI (encoded): $encodedRedirectUri');

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

  static Future<bool> exchangeCodeForToken(String code) async {
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

        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          try {
            await Supabase.instance.client.from('user_profiles').upsert({
              'id': user.id,
              'spotify_refresh_token': refreshToken,
              'updated_at': DateTime.now().toIso8601String(),
            });
            return true; // Return true if successful
          } catch (e) {
            print('Error updating user profile: $e');
            return false; // Return false if there's an error updating the profile
          }
        } else {
          print('No current user found');
          return false; // Return false if there's no current user
        }
      } else {
        print('Failed to exchange code for token: ${response.body}');
        return false; // Return false if the API call was not successful
      }
    } catch (e) {
      print('Error in exchangeCodeForToken: $e');
      return false; // Return false if there's an exception
    }
  }
}
