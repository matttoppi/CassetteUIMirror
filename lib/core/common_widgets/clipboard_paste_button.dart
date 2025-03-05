import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' if (dart.library.html) 'dart:html' show window;

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
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(milliseconds: 300);

  // Helper to detect iOS in web
  bool get _isIOS {
    if (kIsWeb) {
      // Check user agent for iOS
      final userAgent = window.navigator.userAgent.toLowerCase();
      return userAgent.contains('iphone') ||
          userAgent.contains('ipad') ||
          userAgent.contains('ipod');
    }
    try {
      return Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  // Helper to check if it's an Apple Music link
  bool _isAppleMusicLink(String? text) {
    if (text == null) return false;
    final linkLower = text.toLowerCase();
    return linkLower.contains('apple.com') || linkLower.contains('music.apple');
  }

  // Retry mechanism for clipboard access
  Future<ClipboardData?> _getClipboardWithRetry() async {
    ClipboardData? clipboardData;

    while (_retryCount < maxRetries && clipboardData?.text?.isEmpty != false) {
      try {
        // Add delay for iOS devices, especially for Apple Music links
        if (_isIOS) {
          await Future.delayed(retryDelay * (_retryCount + 1));
        }

        clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

        // If we got data, or if it's not iOS/Apple Music, break
        if (clipboardData?.text?.isNotEmpty == true ||
            (!_isIOS && !_isAppleMusicLink(clipboardData?.text))) {
          break;
        }

        _retryCount++;
      } catch (e) {
        print('Retry $_retryCount failed: $e');
        _retryCount++;
      }
    }

    return clipboardData;
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
    // Reset retry count
    _retryCount = 0;

    // Run a quick tap animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      // Get clipboard data with retry mechanism
      final clipboardData = await _getClipboardWithRetry();

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
        // Show a more detailed snackbar message
        if (mounted) {
          final message = _isIOS && _retryCount >= maxRetries
              ? 'Unable to access clipboard. For Apple Music links, try manually entering the URL.'
              : 'No text found in clipboard';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Manual Entry',
                onPressed: () {
                  // Show manual entry dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController manualController =
                          TextEditingController();
                      return AlertDialog(
                        title: const Text('Enter Music Link'),
                        content: TextField(
                          controller: manualController,
                          decoration: const InputDecoration(
                            hintText: 'Paste or type your music link here',
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (manualController.text.isNotEmpty) {
                                widget.controller.text = manualController.text;
                                _updateDisplayText(manualController.text);
                                if (widget.onPaste != null) {
                                  widget.onPaste!(manualController.text);
                                }
                                setState(() {
                                  _hasContent = true;
                                });
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error pasting from clipboard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing clipboard. Try manual entry.'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Manual Entry',
              onPressed: () {
                // Show manual entry dialog (same as above)
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController manualController =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text('Enter Music Link'),
                      content: TextField(
                        controller: manualController,
                        decoration: const InputDecoration(
                          hintText: 'Paste or type your music link here',
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (manualController.text.isNotEmpty) {
                              widget.controller.text = manualController.text;
                              _updateDisplayText(manualController.text);
                              if (widget.onPaste != null) {
                                widget.onPaste!(manualController.text);
                              }
                              setState(() {
                                _hasContent = true;
                              });
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
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
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
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
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: _shouldHighlight(isDesktop)
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              size: 20,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final TextEditingController manualController =
                                      TextEditingController();
                                  return AlertDialog(
                                    title: const Text('Enter Music Link'),
                                    content: TextField(
                                      controller: manualController,
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Paste or type your music link here',
                                      ),
                                      autofocus: true,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (manualController
                                              .text.isNotEmpty) {
                                            widget.controller.text =
                                                manualController.text;
                                            _updateDisplayText(
                                                manualController.text);
                                            if (widget.onPaste != null) {
                                              widget.onPaste!(
                                                  manualController.text);
                                            }
                                            setState(() {
                                              _hasContent = true;
                                            });
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
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
