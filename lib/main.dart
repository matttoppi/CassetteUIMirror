import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/router.dart';
import 'core/services/spotify_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const supabaseUrl = "https://bvhbuedlkzcmsndvsdiw.supabase.co";
  const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2aGJ1ZWRsa3pjbXNuZHZzZGl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY2NzUzMTAsImV4cCI6MjA1MjI1MTMxMH0._ym-Q5UjmBTANucwfIGhyVOqC9KnCGXqcenWEiZVvbU";
  // const spotifyApiKey = String.fromEnvironment('SPOTIFY_API_KEY');

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true,
    );
  } catch (e) {
    print('Supabase initialization error: $e');
  }

  PreferenceHelper.load().then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = router;
    _handleInitialUri();
  }

  void _handleInitialUri() {
    final uri = Uri.base;
    if (uri.path == '/spotify_callback') {
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      _handleSpotifyCallback(code, error);
    }
  }

  void _handleSpotifyCallback(String? code, String? error) async {
    if (code != null) {
      try {
        await SpotifyService.exchangeCodeForToken(code);
        print('Successfully exchanged code for token');
      } catch (e) {
        print('Error exchanging code for token: $e');
      }
    } else if (error != null) {
      print('Spotify auth error: $error');
    }
    _router.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Cassette App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: FlutterSmartDialog.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}
