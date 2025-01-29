// This file contains all the styles used throughout the app.
// It centralizes styling to maintain consistency and ease of maintenance.
// The AppStyles class provides static members for various UI elements.

import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // TEXT STYLES --------------------------------
  static TextStyle headlineStyle = GoogleFonts.teko(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle bodyStyleBold = GoogleFonts.robotoFlex(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TextStyle bodyStyle = GoogleFonts.robotoFlex(
    color: AppColors.textPrimary,
    fontSize: 20,
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

  // BOX DECORATION STYLES ----------------------------
  // Main container decoration used across multiple pages
  // It provides a white background with rounded corners and a subtle shadow effect

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

  static const TextStyle cassetteTextStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    height: 0,
  );

  static const TextStyle songTitleStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 36,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w700,
    height: 0,
    letterSpacing: 1.08,
  );

  static const TextStyle artistNameStyle = TextStyle(
    color: Color(0xFF5C5C5C),
    fontSize: 24,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w700,
    height: 0,
    letterSpacing: 0.72,
  );

  static const TextStyle createFreeAccountStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w800,
    height: 0.10,
    letterSpacing: 0.65,
  );

  static const TextStyle trackTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
  );

  static BoxDecoration gradientBackgroundDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(0.00, -1.00),
      end: Alignment(0, 1),
      colors: [Color(0xFF0093FF), Colors.white],
    ),
  );

  static ShapeDecoration albumCoverDecoration = ShapeDecoration(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    shadows: const [
      BoxShadow(
        color: Color(0x3F000000),
        blurRadius: 4,
        offset: Offset(0, 4),
        spreadRadius: 0,
      )
    ],
  );

  static ShapeDecoration circleDecoration = const ShapeDecoration(
    color: Color(0xFFC4C4C4),
    shape: OvalBorder(),
  );

  static BoxDecoration platformIconDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.textPrimary, width: 2),
  );

  static ShapeDecoration dividerDecoration = const ShapeDecoration(
    shape: RoundedRectangleBorder(
      side: BorderSide(
        width: 1,
        strokeAlign: BorderSide.strokeAlignCenter,
        color: AppColors.hintText,
      ),
    ),
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

  static const TextStyle albumNameStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle genresStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  static BoxDecoration createAccountButtonDecoration = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(100),
  );

  // DYNAMIC STYLING FOR TRACK PAGE ----------------------------
  // Dynamic styling for track identifier
  // This adjusts the text color based on the background color's luminance
  // ensuring readability on both light and dark backgrounds
  static EdgeInsets trackPagePadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.182,
      );

  static TextStyle trackIdentifierStyle(Color backgroundColor) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: backgroundColor.computeLuminance() > 0.5
          ? Colors.black87
          : Colors.white,
      letterSpacing: 1.5,
    );
  }

  static BoxDecoration trackIdentifierDecoration(Color backgroundColor) {
    return BoxDecoration(
      color: backgroundColor.computeLuminance() > 0.5
          ? Colors.black.withOpacity(0.1)
          : Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: backgroundColor.computeLuminance() > 0.5
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  // PROFILE PAGE STYLES ----------------------------
  // Styles for the profile page components

  static const TextStyle profileNameStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle profileUsernameStyle = TextStyle(
    color: Color(0xCCB4B4B4),
    fontSize: 14,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w400,
    letterSpacing: 1.26,
  );

  static const TextStyle profileBioStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle profileActionButtonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    letterSpacing: 1.12,
  );

  static const TextStyle profileTabStyle = TextStyle(
    color: Color(0xFF1F2327),
    fontSize: 16,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w400,
    letterSpacing: 0.96,
  );

  static const TextStyle profileSelectedTabStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    letterSpacing: 0.45,
  );

  static const TextStyle playlistLabelStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 18,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    height: 0,
  );

  static const TextStyle playlistTitleStyle = TextStyle(
    color: Color(0xCC353535),
    fontSize: 20,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    height: 0,
  );

  static const TextStyle songCountStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w300,
    height: 0,
  );

  static const TextStyle songCountTextStyle = TextStyle(
    color: Color(0xCC353535),
    fontSize: 14,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w300,
    height: 0,
  );

  static const TextStyle playlistDescriptionStyle = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 0.07,
  );

  static const TextStyle durationStyle = TextStyle(
    color: Color(0xCC353535),
    fontSize: 14,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w300,
    height: 0,
  );

  static const TextStyle bioStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 0,
  );

  static const TextStyle usernameStyle = TextStyle(
    color: Color(0xCCB4B4B4),
    fontSize: 14,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w400,
    height: 0.08,
    letterSpacing: 1.26,
  );

  static const TextStyle websiteStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 0.08,
  );

  static const TextStyle tabLabelStyle = TextStyle(
    color: Color(0xFF1F2327),
    fontSize: 16,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w400,
    height: 0.06,
    letterSpacing: 0.96,
  );

  static const TextStyle selectedTabLabelStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    height: 0.06,
    letterSpacing: 0.45,
  );

  static const TextStyle appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    height: 0,
  );

  static final ButtonStyle profileActionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );

  // For the Cassette text in ProfilePage
  static const TextStyle profileCassetteStyle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
  );

  // EDIT PROFILE PAGE STYLES ----------------------------
  // Styles for the edit profile page components

  // For the Edit Profile text in EditProfilePage
  static const TextStyle editProfileTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
  );

  // For the Change Picture button in EditProfilePage
  static ButtonStyle changePictureButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: AppColors.primary,
  );

  // For text fields in EditProfilePage
  static InputDecoration editProfileTextFieldDecoration(
      String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }

  // For the Connect Streaming Service button in EditProfilePage
  static ButtonStyle connectStreamingButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: AppColors.primary,
    minimumSize: const Size(double.infinity, 50),
  );

  // For the Connected Streaming Services text in EditProfilePage
  static const TextStyle connectedServicesHeaderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // For the Save Changes button in EditProfilePage
  static ButtonStyle saveChangesButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: AppColors.primary,
    minimumSize: const Size(200, 50),
  );

  // For the TrackPage components
  static BoxDecoration trackPageBackgroundDecoration(Color color) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          Colors.white,
        ],
      ),
    );
  }

  static const TextStyle trackPageSongTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 36,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w700,
    letterSpacing: 1.08,
  );

  static const TextStyle trackPageArtistNameStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w700,
    letterSpacing: 0.72,
  );

  static const TextStyle trackPageAlbumNameStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle trackPageGenresStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  // Custom TextStyle for Auth UI Buttons
  static TextStyle authButtonTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // Custom InputDecorationTheme for Auth UI TextFields
  static InputDecorationTheme authInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputBackground,
    hintStyle: hintTextStyle,
    labelStyle: const TextStyle(color: AppColors.textPrimary),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.textSecondary, width: 1.0),
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    ),
    // Additional decoration properties if needed
  );

  // animated button front style
  static BoxDecoration animatedButtonTopStyle(
      {Color? color, double? radius, Color? borderColor, double? borderWidth}) {
    return BoxDecoration(
      color: color ?? AppColors.animatedBtnColorToolBarTop,
      border: Border.all(
          color: borderColor ?? AppColors.animatedBtnColorToolBarTopBorder,
          width: borderWidth ?? 1.0),
      borderRadius: BorderRadius.all(
        Radius.circular(radius ?? AppSizes.buttonBorderRadius),
      ),
    );
  }

  static BoxDecoration animatedButtonBottomStyle(
      {Color? color, double? radius, double? borderWidth, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? AppColors.animatedBtnColorToolBarBottom,
      border: Border.all(
          color: borderColor ?? AppColors.animatedBtnColorToolBarTop,
          width: borderWidth ?? 1.0),
      borderRadius: BorderRadius.all(
        Radius.circular(radius ?? AppSizes.buttonBorderRadius),
      ),
    );
  }

  static TextStyle animatedBtnTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.7);
  static TextStyle signBtnTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.9);

  static TextStyle animatedBtnConvertTextStyle =
      GoogleFonts.atkinsonHyperlegible(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.7);

  static TextStyle animatedBtnFreeAccTextStyle =
      GoogleFonts.atkinsonHyperlegible(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.7);

  static TextStyle animatedBtnAddServiceDialogTextStyle =
      GoogleFonts.atkinsonHyperlegible(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.7);

  static TextStyle popUpAnimatedBtnStyle = GoogleFonts.atkinsonHyperlegible(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.7);

  static TextStyle popUpItemStyle = GoogleFonts.atkinsonHyperlegible(
      color: Colors.white, fontSize: 20, letterSpacing: 0);

  static homeTextBtnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      overlayColor: AppColors.animatedBtnColorToolBarTop,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
    );
  }

  static TextStyle bottomRichTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5);

  static TextStyle bottomRichTextStyle2 = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.blackColor,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      letterSpacing: 0.5);

  static TextStyle tncTextStyle2 = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.blackColor,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      letterSpacing: 0.5);

  static TextStyle tncTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5);

  static TextStyle authTextFieldLabelTextStyle =
      GoogleFonts.atkinsonHyperlegible(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25);

  static TextStyle signInSignUpCenterTextStyle =
      GoogleFonts.atkinsonHyperlegible(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25);

  static TextStyle signInSignUpTitleTextStyle =
      GoogleFonts.atkinsonHyperlegible(
          color: AppColors.textPrimary,
          fontSize: 38,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25);

  static TextStyle homeCenterTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);

  static TextStyle textFieldHintTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5);

  static TextStyle profileTitleTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);

  static TextStyle addServiceTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.appBg,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 1);

  static TextStyle addMoreBtnTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.7);

  static TextStyle editProfileServicesTextStyle =
      GoogleFonts.atkinsonHyperlegible(
          color: AppColors.appBg,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0);

  static TextStyle dialogTitleTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.blackColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);

  static TextStyle dialogItemsTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.blackColor,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);

  static TextStyle popUpBottomText = GoogleFonts.teko(
    color: AppColors.animatedBtnColorToolBarTop,
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );

  static TextStyle profileNameTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.7);

  static TextStyle profileUserNameTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite.withOpacity(0.54),
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.7);

  static TextStyle profileBioTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite.withOpacity(0.88),
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.7);

  static TextStyle profileLinkTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite.withOpacity(0.88),
      fontSize: 14,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.colorWhite.withOpacity(0.88),
      fontWeight: FontWeight.normal,
      letterSpacing: 0.7);

  static TextStyle profileShareTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.7);

  static TextStyle profileAddMusicTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.7);

  static TextStyle profileTabTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.grayColor,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);
  static TextStyle profileTabSelectedTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);

  static TextStyle itemTypeTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.animatedBtnColorToolBarTop,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);

  static TextStyle itemTitleTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);

  static TextStyle itemRichTextTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.animatedBtnColorToolBarTop,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);

  static TextStyle itemRichText2Ts = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);

  static TextStyle itemDesTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0);

  static TextStyle itemFromTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0);

  static TextStyle itemSongDurationTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0);

  static TextStyle itemUsernameTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textPrimary,
      letterSpacing: 0);


  static TextStyle trackTrackTitleTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.colorWhite.withOpacity(0.78),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);
  static TextStyle trackNameTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);

  static TextStyle trackArtistNameTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 24,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5);

  static TextStyle trackDetailTitleTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.animatedBtnColorToolBarTop,
      fontSize: 18,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.animatedBtnColorToolBarTop,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);

  static TextStyle trackDetailContentTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 17,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5);

  static TextStyle trackBelowBtnStringTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.7);

  static TextStyle trackPlaylistSongNoTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);

  static TextStyle playlistTitleAndDurationTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5);

  static TextStyle playlistSubTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary.withOpacity(0.6),
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.7);

  static TextStyle playlistLeadTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.blackColor,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.7);

  static TextStyle addMusicTitleTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 38,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5);

  static TextStyle addMusicSubTitleTs = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5);

  static TextStyle toastStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.appBg,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3);

  static TextStyle textFieldErrorTextStyle = GoogleFonts.atkinsonHyperlegible(
      color: AppColors.animatedBtnColorToolBarTopBorder,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0);
}
