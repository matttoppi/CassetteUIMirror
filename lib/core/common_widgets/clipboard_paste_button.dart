import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pasteboard/pasteboard.dart';

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

  Future<void> _handlePastedText(String? text) async {
    if (text != null && text.isNotEmpty) {
      // Clean up the text - remove extra whitespace and newlines
      final cleanText = text.trim();
      if (cleanText.isEmpty) return;

      widget.controller.text = cleanText;
      _updateDisplayText(cleanText);
      if (widget.onPaste != null) {
        // Ensure we call onPaste with the cleaned text
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
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      String? clipboardText;

      // Try pasteboard first for better iOS compatibility
      if (!kIsWeb) {
        try {
          clipboardText = await Pasteboard.text;
          // If we got text from pasteboard, clean and validate it
          if (clipboardText != null) {
            clipboardText = clipboardText.trim();
            // If it's empty after cleaning, set to null to try system clipboard
            if (clipboardText.isEmpty) {
              clipboardText = null;
            }
          }
        } catch (e) {
          print('Pasteboard error: $e');
        }
      }

      // Fallback to default clipboard if pasteboard fails or on web
      if (clipboardText == null) {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        clipboardText = clipboardData?.text?.trim();
      }

      if (clipboardText != null && clipboardText.isNotEmpty) {
        // Check if it looks like a music link before auto-pasting
        final linkLower = clipboardText.toLowerCase();
        final isLikelyMusicLink = linkLower.contains('spotify') ||
            linkLower.contains('apple.com') ||
            linkLower.contains('music.apple') ||
            linkLower.contains('deezer') ||
            linkLower.contains('tidal') ||
            linkLower.contains('youtube') ||
            linkLower.contains('youtu.be') ||
            linkLower.contains('soundcloud') ||
            linkLower.contains('amazon');

        if (isLikelyMusicLink) {
          await _handlePastedText(clipboardText);
        } else {
          // If it doesn't look like a music link, show manual entry with the text pre-filled
          if (mounted) {
            _showManualEntryDialog(initialText: clipboardText);
          }
        }
      } else {
        // If no text found, show empty manual entry dialog
        if (mounted) {
          _showManualEntryDialog();
        }
      }
    } catch (e) {
      print('Error pasting from clipboard: $e');
      if (mounted) {
        _showManualEntryDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showManualEntryDialog({String? initialText}) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController manualController =
            TextEditingController(text: initialText);
        return AlertDialog(
          title: const Text('Enter Music Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: manualController,
                decoration: const InputDecoration(
                  hintText: 'Paste or type your music link here',
                ),
                autofocus: true,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _handlePastedText(value);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Supported services: Spotify, Apple Music, YouTube, Deezer, Tidal, SoundCloud, Amazon Music',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (manualController.text.isNotEmpty) {
                  _handlePastedText(manualController.text);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
              onTap: _hasContent ? null : _pasteFromClipboard,
              onTapDown: _hasContent
                  ? null
                  : (details) {
                      _animationController.forward();
                      setState(() => _isPressed = true);
                    },
              onTapUp: _hasContent
                  ? null
                  : (details) {
                      _animationController.reverse();
                      setState(() => _isPressed = false);
                    },
              onTapCancel: _hasContent
                  ? null
                  : () {
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
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: _shouldHighlight(isDesktop)
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                        size: 20,
                                      ),
                                      onPressed: _showManualEntryDialog,
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
