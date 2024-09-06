import 'package:flutter/material.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        clipBehavior: Clip.antiAlias,
        decoration: AppStyles.mainContainerDecoration,
        child: Stack(
          children: [
            // X icon to go back to home page
            Positioned(
              left: MediaQuery.of(context).size.width * 0.05,
              top: MediaQuery.of(context).size.height * 0.05,
              child: GestureDetector(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Icon(
                  Icons.close,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
            // Logo
            Positioned(
              left: MediaQuery.of(context).size.width * 0.378,
              top: MediaQuery.of(context).size.height * 0.070,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.241,
                height: MediaQuery.of(context).size.height * 0.091,
                child: Image.asset(
                  'lib/assets/images/cassette_name_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Create new account text
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.192,
              child: const Center(
                child: Text(
                  AppStrings.createNewAccountText,
                  style: AppStyles.signInToAccountStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Email Address input
            Positioned(
              left: MediaQuery.of(context).size.width * 0.056,
              top: MediaQuery.of(context).size.height * 0.250,
              child: Text(
                'Email Address',
                style: AppStyles.bodyStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.136,
              top: MediaQuery.of(context).size.height * 0.278,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.729,
                height: MediaQuery.of(context).size.height * 0.054,
                child: TextField(
                  decoration: AppStyles.textFieldDecoration.copyWith(
                    hintText: 'Enter your email address',
                  ),
                ),
              ),
            ),
            // Password input
            Positioned(
              left: MediaQuery.of(context).size.width * 0.056,
              top: MediaQuery.of(context).size.height * 0.352,
              child: Text(
                'Password',
                style: AppStyles.bodyStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.136,
              top: MediaQuery.of(context).size.height * 0.382,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.729,
                height: MediaQuery.of(context).size.height * 0.054,
                child: TextField(
                  obscureText: true,
                  decoration: AppStyles.textFieldDecoration.copyWith(
                    hintText: 'Enter your password',
                    suffixIcon: const Icon(Icons.visibility_off),
                  ),
                ),
              ),
            ),
            // Confirm Password input
            Positioned(
              left: MediaQuery.of(context).size.width * 0.056,
              top: MediaQuery.of(context).size.height * 0.454,
              child: Text(
                'Confirm Password',
                style: AppStyles.bodyStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.136,
              top: MediaQuery.of(context).size.height * 0.485,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.729,
                height: MediaQuery.of(context).size.height * 0.054,
                child: TextField(
                  obscureText: true,
                  decoration: AppStyles.textFieldDecoration.copyWith(
                    hintText: 'Confirm your password',
                    suffixIcon: const Icon(Icons.visibility_off),
                  ),
                ),
              ),
            ),
            // Sign up button
            Positioned(
              left: MediaQuery.of(context).size.width * 0.136,
              top: MediaQuery.of(context).size.height * 0.726,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement sign up functionality
                },
                style: AppStyles.elevatedButtonStyle.copyWith(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width * 0.729,
                      MediaQuery.of(context).size.height * 0.054,
                    ),
                  ),
                ),
                child: const Text(
                  AppStrings.signUpText,
                  style: AppStyles.buttonTextStyle,
                ),
              ),
            ),
            // Terms and conditions
            Positioned(
              left: MediaQuery.of(context).size.width * 0.131,
              top: MediaQuery.of(context).size.height * 0.639,
              child: Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement checkbox functionality
                    },
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'I\'ve read and agreed to ',
                          style: AppStyles.bodyStyle.copyWith(
                            color: const Color(0xFF757575),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'User Agreement\n',
                          style: AppStyles.bodyStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'and ',
                          style: AppStyles.bodyStyle.copyWith(
                            color: const Color(0xFF757575),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppStyles.bodyStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Other sign up options
            Positioned(
              left: MediaQuery.of(context).size.width * 0.374,
              top: MediaQuery.of(context).size.height * 0.798,
              child: Text(
                'other way to sign up',
                textAlign: TextAlign.center,
                style: AppStyles.bodyStyle.copyWith(
                  color: const Color(0xFF757575),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Already have an account
            Positioned(
              left: MediaQuery.of(context).size.width * 0.154,
              bottom: MediaQuery.of(context).size.height * 0.05,
              child: Row(
                children: [
                  Text(
                    'Already have an account?',
                    style: AppStyles.bodyStyle.copyWith(
                      color: const Color(0xFF757575),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to Sign In',
                      style: AppStyles.bodyStyle.copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}