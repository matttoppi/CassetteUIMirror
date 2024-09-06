import 'package:cassettefrontend/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
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

  static EdgeInsets trackPagePadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width * 0.182,
  );

  static TextStyle trackIdentifierStyle(Color backgroundColor) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: backgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
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

  static const TextStyle profileNameStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 18,
    fontFamily: 'Teko',
    fontWeight: FontWeight.w600,
    height: 0.06,
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
}
