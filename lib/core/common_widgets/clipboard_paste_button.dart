import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pasteboard/pasteboard.dart';
import 'dart:js' as js;
import 'dart:js_util' show promiseToFuture, callMethod, hasProperty;
import 'dart:async' show Completer;

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

  @override
  void initState() {
    super.initState();
    _hasContent = widget.controller.text.isNotEmpty;
    if (_hasContent) {
      _updateDisplayText(widget.controller.text);
    }
    widget.controller.addListener(_updateHasContent);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  bool _isDesktopWithContext(BuildContext context) {
    if (kIsWeb) {
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth > 600;
    }

    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      return false;
    }
  }

  void _updateHasContent() {
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

  void _updateDisplayText(String link) {
    final linkLower = link.toLowerCase();

    if (linkLower.contains('spotify')) {
      _displayText = "Spotify link pasted...";
    } else if (linkLower.contains('apple')) {
      _displayText = "Apple Music link pasted...";
    } else if (linkLower.contains('deezer')) {
      _displayText = "Deezer link pasted...";
    } else {
      _displayText = "Link pasted...";
    }
  }

  Future<void> _handlePastedText(String? text) async {
    if (text != null && text.isNotEmpty) {
      // Clean up the text - remove extra whitespace and newlines
      final cleanText = text.trim();
      if (cleanText.isEmpty) return;

      widget.controller.text = cleanText;
      _updateDisplayText(cleanText);

      if (widget.onPaste != null) {
        widget.onPaste!(cleanText);
      }
      if (widget.onTap != null) {
        widget.onTap!();
      }
      setState(() {
        _hasContent = true;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    print('Starting paste operation...'); // Debug log

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      String? clipboardText;

      // Handle web platform specifically
      if (kIsWeb) {
        print('Running in web mode...'); // Debug log

        try {
          // Try to read clipboard text directly
          print('Attempting to read clipboard...'); // Debug log

          // Check if clipboard API is available
          final hasClipboard = js.context.hasProperty('navigator') &&
              js.context['navigator'].hasProperty('clipboard') &&
              js.context['navigator']['clipboard'].hasProperty('readText');

          if (hasClipboard) {
            print('Clipboard API available, reading text...'); // Debug log
            try {
              // Convert the Promise to a Future and await it
              final result = await promiseToFuture<String>(
                  js.context['navigator']['clipboard'].callMethod('readText'));

              if (result.isNotEmpty) {
                clipboardText = result;
                print(
                    'Successfully read clipboard text: $clipboardText'); // Debug log
              }
            } catch (e) {
              print('Error reading clipboard: $e'); // Debug log
            }
          } else {
            print('Clipboard API not available'); // Debug log
          }
        } catch (e) {
          print('Web clipboard access failed: $e');
        }

        // Fallback to legacy clipboard API if modern API failed
        if (clipboardText == null) {
          print('Attempting legacy clipboard API...'); // Debug log
          try {
            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
            clipboardText = clipboardData?.text?.trim();
            print('Got text from legacy API: $clipboardText'); // Debug log
          } catch (e) {
            print('Legacy clipboard API failed: $e');
          }
        }

        // If all else fails, show paste instruction
        if (clipboardText == null) {
          print('Showing paste instruction...'); // Debug log
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please use Ctrl+V or Command+V to paste'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('Running in non-web mode...'); // Debug log
        try {
          // Try pasteboard first for better iOS/desktop compatibility
          clipboardText = await Pasteboard.text;
          print('Got text from pasteboard: $clipboardText'); // Debug log
          if (clipboardText != null) {
            clipboardText = clipboardText.trim();
            if (clipboardText.isEmpty) {
              clipboardText = null;
            }
          }
        } catch (e) {
          print('Pasteboard error: $e');
        }

        // Fallback to default clipboard if pasteboard fails
        if (clipboardText == null) {
          print('Attempting default clipboard...'); // Debug log
          final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
          clipboardText = clipboardData?.text?.trim();
          print('Got text from default clipboard: $clipboardText'); // Debug log
        }
      }

      if (clipboardText != null && clipboardText.isNotEmpty) {
        print('Handling pasted text...'); // Debug log
        await _handlePastedText(clipboardText);
      } else {
        print('No clipboard text found'); // Debug log
      }
    } catch (e) {
      print('Error pasting from clipboard: $e');
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

  @override
  Widget build(BuildContext context) {
    print(
        'Building ClipboardPasteButton, hasContent: $_hasContent'); // Debug log
    final isDesktop = _isDesktopWithContext(context);

    return SizedBox(
      height: widget.height ?? 54,
      width: MediaQuery.of(context).size.width - 32,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: widget.height2 ?? 50,
              width: MediaQuery.of(context).size.width - 36,
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () {
                print('Button tapped, hasContent: $_hasContent'); // Debug log
                if (!_hasContent) {
                  _pasteFromClipboard();
                }
              },
              onTapDown: _hasContent
                  ? null
                  : (details) {
                      print('Button pressed down'); // Debug log
                      _animationController.forward();
                      setState(() => _isPressed = true);
                    },
              onTapUp: _hasContent
                  ? null
                  : (details) {
                      print('Button released'); // Debug log
                      _animationController.reverse();
                      setState(() => _isPressed = false);
                    },
              onTapCancel: _hasContent
                  ? null
                  : () {
                      print('Button tap cancelled'); // Debug log
                      _animationController.reverse();
                      setState(() => _isPressed = false);
                    },
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
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
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
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
                                            style: AppStyles
                                                .textFieldHintTextStyle
                                                .copyWith(
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
                                          style:
                                              AppStyles.textFieldHintTextStyle,
                                        ),
                                        if (isDesktop &&
                                            _isHovering &&
                                            !_hasContent) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            "(tap to paste)",
                                            style: AppStyles
                                                .textFieldHintTextStyle
                                                .copyWith(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                        ),
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
                                  ],
                                ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldHighlight(bool isDesktop) {
    if (isDesktop) {
      return _isHovering && !_hasContent;
    } else {
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
