import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/services/spotify_service.dart';

class SpotifyCallbackPage extends StatefulWidget {
  final String? code;
  final String? error;

  const SpotifyCallbackPage({super.key, this.code, this.error});

  @override
  _SpotifyCallbackPageState createState() => _SpotifyCallbackPageState();
}

class _SpotifyCallbackPageState extends State<SpotifyCallbackPage> {
  @override
  void initState() {
    super.initState();
    print('SpotifyCallbackPage: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCallback();
    });
  }

  void _handleCallback() async {
    print('SpotifyCallbackPage: _handleCallback called');
    print('Spotify Callback Code: ${widget.code}');
    print('Spotify Callback Error: ${widget.error}');

    final uri = Uri.base;
    print('Spotify Callback URL: $uri');
    print('Path: ${uri.path}');
    print('Query Parameters: ${uri.queryParameters}');

    if (widget.code != null) {
      try {
        bool success = await SpotifyService.exchangeCodeForToken(widget.code!);
        if (success) {
          print('Successfully exchanged code for token and updated user profile');
        } else {
          print('Failed to exchange code for token or update user profile');
        }
      } catch (e) {
        print('Error exchanging code for token: $e');
      }
    } else if (widget.error != null) {
      print('Spotify authentication error: ${widget.error}');
    }

    // Navigate to the profile page
    if (mounted) {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
