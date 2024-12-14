import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/styles/app_styles.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SupaEmailAuth(
        redirectTo: kIsWeb ? null : 'http://localhost:56752/spotify_callback',
        onSignInComplete: (response) {
          if (response.session != null) {
            context.go('/profile');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.error?.message ?? 'Sign in failed')),
            );
          }
        },
        onSignUpComplete: (response) {
          if (response.session != null) {
            context.go('/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.error?.message ?? 'Sign up failed')),
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () {
            context.go('/forgot_password');
          },
          child: const Text(
            'Forgot Password?',
            style: AppStyles.forgotPasswordStyle,
          ),
        ),
      ),
    );
  }
}


extension on AuthResponse {
  get error => null;
}