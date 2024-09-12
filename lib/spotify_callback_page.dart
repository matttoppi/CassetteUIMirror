import 'package:cassettefrontend/services/spotify_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpotifyCallbackPage extends StatefulWidget {
  final String? code;
  final String? error;

  const SpotifyCallbackPage({Key? key, this.code, this.error}) : super(key: key);

  @override
  _SpotifyCallbackPageState createState() => _SpotifyCallbackPageState();
}

class _SpotifyCallbackPageState extends State<SpotifyCallbackPage> {
  bool _isProcessing = true;
  String _message = '';
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    print('SpotifyCallbackPage initState called');
    print('Code: ${widget.code}');
    print('Error: ${widget.error}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('SpotifyCallbackPage post-frame callback');
      _handleCallback();
    });
  }

  Future<void> _handleCallback() async {
    print('_handleCallback called');
    if (widget.code != null) {
      print('Received Spotify auth code: ${widget.code}');
      try {
        // Exchange the code for an access token
        await SpotifyService.exchangeCodeForToken(widget.code!);
        // Store the code securely
        print('Storing Spotify auth code...');
        await _storage.write(key: 'spotify_code', value: widget.code);
        print('Spotify auth code stored successfully.');

        // Retrieve the stored code to verify
        String? storedCode = await _storage.read(key: 'spotify_code');
        print('Retrieved stored Spotify auth code: $storedCode');

        setState(() {
          _isProcessing = false;
          _message = 'Authentication successful!';
        });
        // Navigate to the profile page after successful authentication
        Future.delayed(const Duration(seconds: 2), () {
          context.go('/profile');
        });
      } catch (e, stackTrace) {
        print('Error in _handleCallback: $e');
        print('Stack trace: $stackTrace');
        setState(() {
          _isProcessing = false;
          _message = 'Authentication failed: ${e.toString()}';
        });
      }
    } else if (widget.error != null) {
      print('Error received: ${widget.error}');
      setState(() {
        _isProcessing = false;
        _message = 'Authentication error: ${widget.error}';
      });
    } else {
      print('No code or error received');
      setState(() {
        _isProcessing = false;
        _message = 'No code or error received';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SpotifyCallbackPage build method called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Authentication'),
      ),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_message),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Return to Home'),
                  ),
                ],
              ),
      ),
    );
  }
}
