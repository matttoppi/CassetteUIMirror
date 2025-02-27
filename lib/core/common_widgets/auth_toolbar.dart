import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthToolbar extends StatefulWidget {
  final Function burgerMenuFnc;

  const AuthToolbar({super.key, required this.burgerMenuFnc});

  @override
  State<AuthToolbar> createState() => _AuthToolbarState();
}

class _AuthToolbarState extends State<AuthToolbar>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // Get screen width to make layout responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 400; // Threshold for narrow screens
    final bool isVeryNarrow =
        screenWidth < 320; // Threshold for very narrow screens

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo with flexible width
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                context.go("/");
              },
              child: Image.asset(
                appLogo,
                fit: BoxFit.scaleDown,
                // Constrain image width on smaller screens
                width: isVeryNarrow ? 60 : (isNarrow ? 80 : null),
              ),
            ),
          ),
          const SizedBox(width: 4), // Small gap between logo and buttons
          // Right side buttons
          Flexible(
            flex: isNarrow ? 2 : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Use minimum space needed
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isVeryNarrow) // Hide Sign In on very narrow screens
                  TextButton(
                    onPressed: () {
                      context.go('/signin');
                    },
                    style: AppStyles.homeTextBtnStyle(),
                    child: Text(
                      "Sign In",
                      style: AppStyles.signBtnTextStyle.copyWith(
                        fontSize: isNarrow
                            ? 12
                            : 13, // Smaller text on narrow screens
                      ),
                    ),
                  ),
                if (!isVeryNarrow) const SizedBox(width: 4), // Reduced spacing
                AnimatedPrimaryButton(
                  text: isVeryNarrow
                      ? "Sign"
                      : "Sign Up", // Shorter text on very narrow screens
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 180),
                        () => context.go('/signup'));
                  },
                  // Make button smaller on narrow screens
                  width: isVeryNarrow ? 50 : (isNarrow ? 70 : 100),
                  height: isNarrow ? 28 : 32,
                ),
                const SizedBox(width: 4),
                AppUtils.burgerMenu(
                  onPressed: () {
                    widget.burgerMenuFnc();
                  },
                  // Use smaller size on narrow screens
                  size: isVeryNarrow ? 30.0 : (isNarrow ? 36.0 : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
