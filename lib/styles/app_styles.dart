import 'package:cassettefrontend/constants/app_constants.dart';
import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle headlineStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyStyleBold = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontFamily: 'Roboto Flex',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontFamily: 'Roboto Flex',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  static const TextStyle hintTextStyle = TextStyle(
    color: AppColors.hintText,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle signInTextStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontFamily: 'Roboto Flex',
    fontWeight: FontWeight.w400,
    letterSpacing: 1.44,
  );

  static const TextStyle signUpTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: 'Roboto Flex',
    fontWeight: FontWeight.w900,
    letterSpacing: 1.44,
  );

  static BoxDecoration mainContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Color(0x4C000000),
        blurRadius: 4,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x26000000),
        blurRadius: 12,
        offset: Offset(0, 8),
        spreadRadius: 6,
      )
    ],
  );

  static InputDecoration textFieldDecoration = InputDecoration(
    hintText: 'Paste your music link here...',
    hintStyle: hintTextStyle,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.hintText),
    ),
  );

  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );

  static const TextStyle signInToAccountStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 20,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle forgotPasswordStyle = TextStyle(
    color: Color(0xFF757575),
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle otherWayToSignInStyle = TextStyle(
    color: Color(0xFF757575),
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle createAccountPromptStyle = TextStyle(
    color: Color(0xFF757575),
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle createAccountActionStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static ButtonStyle roundedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  );
}
