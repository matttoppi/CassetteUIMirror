import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF0054); 
  static const Color textPrimary = Color(0xFF1F2327);
  static const Color hintText = Color(0xFFC4C4C4);
  static const Color artistNameColor = Color(0xFF5C5C5C);
  static const Color textSecondary = Color(0xFF757575);
  static const Color profileBackground = Color(0xFF1F2327);
  static const Color profileTabBackground = Color(0xFFC4C4C4);

  static const Color appBg = Color(0xFFF8F0DE);
  static const Color grayColor = Color(0xFFA7A7A7);
  static const Color tabDividerColor = Color(0xFF333333);
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color greenAppColor = Color(0xFF1ED760);
  static const Color animatedBtnColorToolBarTop = Color(0xFFED2748);
  static const Color animatedBtnColorToolBarTopBorder = Color(0xFFFF002B);
  static const Color animatedBtnColorToolBarBottom = Color(0xFFE95E75);
  static const Color animatedBtnColorConvertTop = Color(0xFF1F2327);
  static const Color animatedBtnColorConvertBottom = Color(0xFF595C5E);
  static const Color animatedBtnColorConvertBottomBorder = Color(0xFF1F2327);
  static const Color popUpDividerColor = Color(0xFF8A8A8A);
  static const Color popBgColor = Color.fromRGBO(31, 35, 39, 0.78);
  static const Color blackColor = Color.fromRGBO(0, 0, 0, 1);

  static var inputBackground;
}

class AppSizes {
  static const double borderRadius = 8.0;
  static const double buttonBorderRadius = 5.0;

  static const double trackTextSpacing = 0.01; 
  static const double albumCoverSize = 0.46;
  static const double textContainerWidth = 0.636;
  static const double createAccountButtonWidth = 0.533;
  static const double createAccountButtonHeight = 0.058;

  // Includes Logo and Text
  static const double cassetteNameLogoWidth = 0.8; 
  static const double cassetteNameLogoHeight = 0.2;

  // Incudes just the text
  static const double cassetteNameWidth = 0.35;
  static const double cassetteNameHeight = 0.04;
}

class AppStrings {
  static const String appTitle = 'Cassette Technologies';
  static const String convertButtonText = 'Convert';
  static const String hintText = 'Paste your music link here...';
  static const String signInText = 'Sign In';
  static const String signUpText = 'Sign Up';
  static const String infoBoxTitle =
      'Convert and Share your Music Between Streaming Platforms';
  static const String infoBoxContent =
      'Paste links to songs, playlists, and more!\n\nGet smart links across 5 major streaming platforms';
  
  static const String signInToAccountText = 'Sign in to your account';
  static const String emailAddressText = 'Email Address';
  static const String passwordText = 'Password';
  static const String forgotPasswordText = 'Forgot password?';
  static const String otherWayToSignInText = 'other way to sign in';
  static const String dontHaveAccountText = 'Don\'t have an account?';
  static const String createAccountText = 'Create Account';
  static const String createNewAccountText = 'Create new account';
  static const String alreadyHaveAccountText = 'Already have an account?';
  static const String backToSignInText = 'Back to Sign In';
  static const String cassetteTitle = 'Cassette';
  static const String trackText = 'Track';
  static const String createFreeAccountText = 'Create Free Account';
  static const String homeTitle = 'Home';

}

class Validation{
  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    return regex.hasMatch(value);
  }
}
