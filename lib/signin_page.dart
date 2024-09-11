import 'package:flutter/material.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';
import 'signup_page.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent back
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        _handleBackNavigation(context);
      },
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          clipBehavior: Clip.antiAlias,
          decoration: AppStyles.mainContainerDecoration,
          child: Stack(
            children: [
              // X icon to go back
              Positioned(
                left: MediaQuery.of(context).size.width * 0.05,
                top: MediaQuery.of(context).size.height * 0.05,
                child: GestureDetector(
                  onTap: () => _handleBackNavigation(context),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
              // Logo
              Positioned(
                left: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.35)) / 2, 
                top: MediaQuery.of(context).size.height * 0.05, 
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.15, 
                  child: Image.asset(
                    'lib/assets/images/cassette_name_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Sign in to your account text
              Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height * 0.206,
                child: const Center(
                  child: Text(
                    AppStrings.signInToAccountText,
                    style: AppStyles.signInToAccountStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Email Address
              Positioned(
                left: MediaQuery.of(context).size.width * 0.056,
                top: MediaQuery.of(context).size.height * 0.267,
                child: Text(
                  AppStrings.emailAddressText,
                  style: AppStyles.bodyStyle,
                ),
              ),
              // Email input field
              Positioned(
                left: MediaQuery.of(context).size.width * 0.136,
                top: MediaQuery.of(context).size.height * 0.300,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.729,
                  height: MediaQuery.of(context).size.height * 0.058,
                  child: TextField(
                    decoration: AppStyles.textFieldDecoration.copyWith(
                      hintText: 'Enter your email address',
                    ),
                  ),
                ),
              ),
              // Password
              Positioned(
                left: MediaQuery.of(context).size.width * 0.056,
                top: MediaQuery.of(context).size.height * 0.377,
                child: Text(
                  AppStrings.passwordText,
                  style: AppStyles.bodyStyle,
                ),
              ),
              // Password input field
              Positioned(
                left: MediaQuery.of(context).size.width * 0.136,
                top: MediaQuery.of(context).size.height * 0.409,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.729,
                  height: MediaQuery.of(context).size.height * 0.058,
                  child: TextField(
                    obscureText: true,
                    decoration: AppStyles.textFieldDecoration.copyWith(
                      hintText: 'Enter your password',
                      suffixIcon: const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
              ),
              // Forgot password
              Positioned(
                left: MediaQuery.of(context).size.width * 0.577,
                top: MediaQuery.of(context).size.height * 0.471,
                child: const Text(
                  AppStrings.forgotPasswordText,
                  textAlign: TextAlign.right,
                  style: AppStyles.forgotPasswordStyle,
                ),
              ),
              // Sign in button
              Positioned(
                left: MediaQuery.of(context).size.width * 0.136,
                top: MediaQuery.of(context).size.height * 0.632,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement sign in functionality
                  },
                  style: AppStyles.roundedButtonStyle.copyWith(
                    minimumSize: WidgetStateProperty.all(
                      Size(
                        MediaQuery.of(context).size.width * 0.729,
                        MediaQuery.of(context).size.height * 0.058,
                      ),
                    ),
                  ),
                  child: const Text(
                    AppStrings.signInText,
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ),
              // Other way to sign in
              Positioned(
                left: MediaQuery.of(context).size.width * 0.376,
                top: MediaQuery.of(context).size.height * 0.709,
                child: const Text(
                  AppStrings.otherWayToSignInText,
                  textAlign: TextAlign.center,
                  style: AppStyles.otherWayToSignInStyle,
                ),
              ),
              // Don't have an account
              Positioned(
                left: MediaQuery.of(context).size.width * 0.161,
                top: MediaQuery.of(context).size.height * 0.880,
                child: Row(
                  children: [
                    const Text(
                      AppStrings.dontHaveAccountText,
                      style: AppStyles.createAccountPromptStyle,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        AppStrings.createAccountText,
                        style: AppStyles.createAccountActionStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBackNavigation(BuildContext context) {
    Navigator.of(context).pop();
  }
}