import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

mixin AuthRequiredState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _redirectIfUnauthenticated();
  }

  void _redirectIfUnauthenticated() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go('/signin');
      });
    }
  }

  void onUnauthenticated() {
    GoRouter.of(context).go('/signin');
  }

  void onAuthenticated(Session session) {
    GoRouter.of(context).go('/profile');
  }

  void onPasswordRecovery(Session session) {}

  void onErrorAuthenticating(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
