import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'auth_service.dart';

mixin AuthRequiredState<T extends StatefulWidget> on State<T> {
  final _authService = AuthService();
  bool _isCheckingAuth = false;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _redirectIfUnauthenticated();
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((isAuthenticated) {
      if (!isAuthenticated && mounted && !_isCheckingAuth) {
        _handleUnauthenticated();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _redirectIfUnauthenticated() async {
    if (_isCheckingAuth) return;
    _isCheckingAuth = true;

    try {
      // First check cached auth state
      final cachedUser = await _authService.getCurrentUser();
      if (cachedUser != null) {
        _isCheckingAuth = false;
        return;
      }

      // If no cached user, check token validity
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated && mounted) {
        _handleUnauthenticated();
      }
    } finally {
      _isCheckingAuth = false;
    }
  }

  void _handleUnauthenticated() {
    // Use addPostFrameCallback to avoid build/navigation conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          ModalRoute.of(context)?.settings.name != '/signin' &&
          !_isCheckingAuth) {
        GoRouter.of(context).go('/signin');
      }
    });
  }

  void onUnauthenticated() {
    if (_isCheckingAuth) return;
    _isCheckingAuth = true;

    _authService.signOut().then((_) {
      _isCheckingAuth = false;
      if (mounted) {
        GoRouter.of(context).go('/signin');
      }
    }).catchError((e) {
      _isCheckingAuth = false;
      print('❌ Error during sign out: $e');
    });
  }

  void onAuthenticated(Map<String, dynamic> userData) {
    if (mounted && !_isCheckingAuth) {
      GoRouter.of(context).go('/profile');
    }
  }

  void onPasswordRecovery() {
    // Handle password recovery if needed
  }

  void onErrorAuthenticating(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
