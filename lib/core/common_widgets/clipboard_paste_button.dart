import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ClipboardPasteButton extends StatefulWidget {
  final String hint;
  final double? height;
  final double? height2;
  final TextEditingController controller;
  final Function(String)? onPaste;
  final VoidCallback? onTap;

  const ClipboardPasteButton({
    super.key,
    required this.hint,
    required this.controller,
    this.height,
    this.height2,
    this.onPaste,
    this.onTap,
  });

  @override
  State<ClipboardPasteButton> createState() => _ClipboardPasteButtonState();
}

class _ClipboardPasteButtonState extends State<ClipboardPasteButton>
    with SingleTickerProviderStateMixin {
  bool _hasContent = false;
  bool _isLoading = false;
  bool _isHovering = false;
  bool _isPressed = false;
  String _displayText = "";
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Determine if we're on a desktop platform where hover makes sense
  // This is a fallback method used in initState before we have context
  bool get _isDesktop {
    if (kIsWeb) {
      // For web, we'll need context to determine if it's mobile or desktop
      // So we'll default to true and update in didChangeDependencies
      return true;
    }

    try {
      // Check if we're on a desktop OS
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      // If Platform is not available, default to false
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if controller already has content
    _hasContent = widget.controller.text.isNotEmpty;
    if (_hasContent) {
      _updateDisplayText(widget.controller.text);
    }
    // Listen for changes to the controller
    widget.controller.addListener(_updateHasContent);

    // Setup animation for tap feedback only
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    // Scale animation for tap feedback
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  // More reliable desktop detection with MediaQuery context
  bool _isDesktopWithContext(BuildContext context) {
    if (kIsWeb) {
      // For web, check screen width using MediaQuery
      final screenWidth = MediaQuery.of(context).size.width;

      // Common breakpoints:
      // < 600px: Mobile
      // 600px - 900px: Tablet
      // > 900px: Desktop
      return screenWidth > 600;
    }

    try {
      // Check if we're on a desktop OS
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      // If Platform is not available, default to false
      return false;
    }
  }

  void _updateHasContent() {
    // Get current content state from controller
    final hasContent = widget.controller.text.isNotEmpty;

    if (_hasContent != hasContent) {
      setState(() {
        _hasContent = hasContent;
        if (hasContent) {
          _updateDisplayText(widget.controller.text);
        }
      });
    }
  }

  // Determine which music service the link is from
  void _updateDisplayText(String link) {
    final linkLower = link.toLowerCase();

    if (linkLower.contains('spotify')) {
      _displayText = "Spotify link pasted...";
    } else if (linkLower.contains('apple.com') ||
        linkLower.contains('music.apple')) {
      _displayText = "Apple Music link pasted...";
    } else if (linkLower.contains('deezer')) {
      _displayText = "Deezer link pasted...";
    } else if (linkLower.contains('tidal')) {
      _displayText = "Tidal link pasted...";
    } else if (linkLower.contains('youtube') ||
        linkLower.contains('youtu.be')) {
      _displayText = "YouTube link pasted...";
    } else if (linkLower.contains('soundcloud')) {
      _displayText = "SoundCloud link pasted...";
    } else if (linkLower.contains('amazon') ||
        linkLower.contains('music.amazon')) {
      _displayText = "Amazon Music link pasted...";
    } else {
      _displayText = "Music link pasted...";
    }
  }

  Future<void> _pasteFromClipboard() async {
    // Run a quick tap animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      // Get clipboard data
      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null &&
          clipboardData.text != null &&
          clipboardData.text!.isNotEmpty) {
        // Set the text to the controller
        widget.controller.text = clipboardData.text!;

        // Update display text based on the link
        _updateDisplayText(clipboardData.text!);

        // Call onPaste callback if provided
        if (widget.onPaste != null) {
          widget.onPaste!(clipboardData.text!);
        }

        // Call onTap callback if provided
        if (widget.onTap != null) {
          widget.onTap!();
        }

        if (mounted) {
          setState(() {
            _hasContent = true;
          });
        }
      } else {
        // Show a snackbar if clipboard is empty
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No text found in clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors
      print('Error pasting from clipboard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing clipboard: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearText() {
    widget.controller.clear();
    setState(() {
      _hasContent = false;
      _displayText = "";
    });
  }

  // Tap handlers
  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    _animationController.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktopWithContext(context);

    return SizedBox(
      height: widget.height ?? 54,
      width: MediaQuery.of(context).size.width - 32,
      child: Stack(
        children: [
          // Shadow container (positioned behind)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: widget.height2 ?? 50,
              width: MediaQuery.of(context).size.width - 36,
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
            ),
          ),
          // Main container with tap animation only
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildPlatformAwareContainer(isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformAwareContainer(bool isDesktop) {
    // For desktop, use MouseRegion for hover effects
    if (isDesktop) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: _buildGestureDetector(isDesktop),
      );
    }
    // For mobile, just use the gesture detector without hover effects
    else {
      return _buildGestureDetector(isDesktop);
    }
  }

  Widget _buildGestureDetector(bool isDesktop) {
    return GestureDetector(
      onTap: _hasContent ? null : _pasteFromClipboard,
      onTapDown: _hasContent ? null : _onTapDown,
      onTapUp: _hasContent ? null : _onTapUp,
      onTapCancel: _hasContent ? null : _onTapCancel,
      child: Container(
        height: widget.height2 ?? 50,
        width: MediaQuery.of(context).size.width - 36,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _shouldHighlight(isDesktop)
                ? AppColors.primary
                : AppColors.textPrimary,
            width: _shouldHighlight(isDesktop) ? 2 : 1,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              // Display either the hint text or the pasted content
              Expanded(
                child: _isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Pasting...",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : _hasContent
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _displayText,
                                  style:
                                      AppStyles.textFieldHintTextStyle.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                widget.hint,
                                style: AppStyles.textFieldHintTextStyle,
                              ),
                              // Only show the "tap to paste" hint on desktop when hovering
                              if (isDesktop && _isHovering && !_hasContent)
                                const SizedBox(width: 8),
                              if (isDesktop && _isHovering && !_hasContent)
                                Text(
                                  "(tap to paste)",
                                  style:
                                      AppStyles.textFieldHintTextStyle.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
              ),
              // Show either paste icon or clear button
              if (!_isLoading)
                _hasContent
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: _clearText,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.content_paste_rounded,
                          color: _shouldHighlight(isDesktop)
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: _pasteFromClipboard,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to determine if we should highlight the button
  bool _shouldHighlight(bool isDesktop) {
    if (isDesktop) {
      // On desktop, highlight on hover
      return _isHovering && !_hasContent;
    } else {
      // On mobile, highlight when pressed
      return _isPressed && !_hasContent;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateHasContent);
    _animationController.dispose();
    super.dispose();
  }
}
