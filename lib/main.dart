import 'package:cassettefrontend/core/env.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';

import 'core/services/router.dart';
import 'core/services/spotify_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool isAuthenticated = false;
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  // const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
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
  late GoRouter router;

  @override
  void initState() {
    super.initState();
    _handleInitialUri();
    if (supabase.auth.currentSession != null) {
      isAuthenticated = true;
    }
    router = AppRouter.getRouter(isAuthenticated);
    supabase.auth.onAuthStateChange.listen(
      (event) {
        if (event.event == AuthChangeEvent.signedOut) {
          isAuthenticated = false;
        }
        if (event.event == AuthChangeEvent.signedIn) {
          isAuthenticated = true;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Cassette App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: FlutterSmartDialog.init(),
    );
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
    // router.go('/profile');
  }
}
