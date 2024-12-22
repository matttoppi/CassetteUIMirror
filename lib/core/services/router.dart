import 'package:cassettefrontend/feature/auth/pages/sign_in_page.dart';
import 'package:cassettefrontend/feature/auth/pages/sign_up_page.dart';
import 'package:cassettefrontend/feature/home/pages/home_page.dart';
import 'package:cassettefrontend/feature/profile/pages/edit_profile_page.dart';
import 'package:cassettefrontend/feature/profile/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cassettefrontend/track_page.dart';
import 'package:cassettefrontend/spotify_callback_page.dart';

// import '../../feature/auth_old/pages/signin_page_old.dart';
import '../../feature/auth_old/pages/signup_page_old.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/spotify_callback',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        final error = state.uri.queryParameters['error'];
        return SpotifyCallbackPage(code: code, error: error);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        return const ProfilePage();
      },
    ),
    GoRoute(
      path: '/track/:trackId',
      builder: (context, state) => TrackPage(trackId: state.pathParameters['trackId']!),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity:animation,
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/signin',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const SignInPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity:animation,
              child: child,
            );
          },
        );
      },
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
