import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' show max;

class AuthToolbar extends StatefulWidget {
  final Function burgerMenuFnc;
  // Add ability to control animation timing
  final Duration animationDuration;
  final Duration animationDelay;
  // Add flag to disable internal animations (for parent-controlled animations)
  final bool disableInternalAnimations;

  const AuthToolbar({
    super.key,
    required this.burgerMenuFnc,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationDelay = const Duration(milliseconds: 200),
    this.disableInternalAnimations = false,
  });

  @override
  State<AuthToolbar> createState() => _AuthToolbarState();
}

class _AuthToolbarState extends State<AuthToolbar>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Create fade-in animation controller
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    // If animations are disabled, set to completed state
    if (widget.disableInternalAnimations) {
      _fadeController.value = 1.0; // Set to fully visible immediately
    } else {
      // Start animation after a short delay to ensure it's coordinated with page load
      Future.delayed(widget.animationDelay, () {
        if (mounted) {
          _fadeController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to make layout responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 400; // Threshold for narrow screens
    final bool isVeryNarrow =
        screenWidth < 320; // Threshold for very narrow screens

    // Calculate dynamic horizontal padding to ensure elements don't overlap the edge
    // Use SafeArea's padding if available, or fallback to a minimum safe value
    final padding = MediaQuery.of(context).padding;
    final horizontalPadding = max(16.0, padding.left + 4); // Left padding
    final rightPadding = max(16.0, padding.right + 4); // Right padding

    // Build content without animations
    final Widget content = Padding(
      padding: EdgeInsets.only(left: horizontalPadding, right: rightPadding),
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
                const SizedBox(
                    width: 8), // Increased spacing before burger menu
                AppUtils.burgerMenu(
                  onPressed: () {
                    widget.burgerMenuFnc();
                  },
                  // Use smaller size on narrow screens
                  size: isVeryNarrow ? 24.0 : (isNarrow ? 32.0 : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // If animations are disabled, return content without transitions
    if (widget.disableInternalAnimations) {
      return content;
    }

    // Otherwise, wrap with animations as before
    return FadeTransition(
      opacity: _fadeAnimation,
      // Add a subtle slide-down effect
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1.0 - _fadeAnimation.value) * -10),
            child: child,
          );
        },
        child: content,
      ),
    );
  }
}
