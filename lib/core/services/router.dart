import 'package:cassettefrontend/core/common_widgets/error_page.dart';
import 'package:cassettefrontend/feature/auth/pages/sign_in_page.dart';
import 'package:cassettefrontend/feature/auth/pages/sign_up_page.dart';
import 'package:cassettefrontend/feature/home/pages/home_page.dart';
import 'package:cassettefrontend/feature/profile/pages/add_music_page.dart';
import 'package:cassettefrontend/feature/profile/pages/edit_profile_page.dart';
import 'package:cassettefrontend/feature/profile/pages/profile_page.dart';
import 'package:cassettefrontend/feature/media/pages/collection_page.dart';
import 'package:cassettefrontend/feature/media/pages/entity_page.dart';
import 'package:cassettefrontend/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cassettefrontend/spotify_callback_page.dart';

class AppRouter {
  static GoRouter getRouter(bool isAuth) {
    final GoRouter router = GoRouter(
      initialLocation: isAuthenticated ? '/profile' : '/',
      debugLogDiagnostics: true,
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          name: 'spotify_callback',
          path: '/spotify_callback',
          builder: (context, state) {
            final code = state.uri.queryParameters['code'];
            final error = state.uri.queryParameters['error'];
            return SpotifyCallbackPage(code: code, error: error);
          },
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) {
            return const ProfilePage();
          },
        ),
        GoRoute(
          name: 'track',
          path: '/track/:type/:trackId',
          builder: (context, state) {
            // Collections (multiple tracks): albums and playlists
            if (state.pathParameters['type'] == "playlist" ||
                state.pathParameters['type'] == "album") {
              return CollectionPage(
                type: state.pathParameters['type'],
                trackId: state.pathParameters['trackId'],
              );
            }
            // Standalone entities: individual tracks and artists
            return EntityPage(
              type: state.pathParameters['type'],
              trackId: state.pathParameters['trackId'],
            );
          },
        ),
        // GoRoute(
        //   path: '/track/:trackId',
        //   builder: (context, state) => TrackPage(trackId: state.pathParameters['trackId']!),
        // ),
        GoRoute(
          name: 'signup',
          path: '/signup',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const SignUpPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          name: 'signin',
          path: '/signin',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const SignInPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          name: 'edit_profile',
          path: '/edit_profile',
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          name: 'add_music',
          path: '/add_music',
          builder: (context, state) => const AddMusicPage(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        if (!isAuthenticated && state.matchedLocation.startsWith('/profile')) {
          return '/';
        } else {
          return null;
        }
        // print('Router: Redirecting for path: ${state.uri.path}');
      },
      errorPageBuilder: (context, state) => MaterialPage(child: ErrorPage()),
    );
    return router;
  }
}
