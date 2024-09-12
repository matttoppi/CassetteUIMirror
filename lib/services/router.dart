import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cassettefrontend/main.dart';
import 'package:cassettefrontend/track_page.dart';
import 'package:cassettefrontend/profile_page.dart';
import 'package:cassettefrontend/signup_page.dart';
import 'package:cassettefrontend/signin_page.dart';
import 'package:cassettefrontend/edit_profile_page.dart';
import 'package:cassettefrontend/spotify_callback_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'Cassette'),
    ),
    GoRoute(
      path: '/spotify_callback',
      builder: (context, state) {
        // This route is now handled in the main.dart file
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        final error = state.uri.queryParameters['error'];
        return ProfilePage(code: code, error: error);
      },
    ),
    GoRoute(
      path: '/track/:trackId',
      builder: (context, state) => TrackPage(trackId: state.pathParameters['trackId']!),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SigninPage(),
    ),
    GoRoute(
      path: '/edit_profile',
      builder: (context, state) => const EditProfilePage(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    print('Router: Redirecting for path: ${state.uri.path}');
    return null; // No redirection
  },
);
