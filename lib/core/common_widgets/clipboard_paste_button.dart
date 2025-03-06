import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pasteboard/pasteboard.dart';
import 'dart:js' as js;
import 'dart:js_util' show promiseToFuture, callMethod, hasProperty;
import 'dart:async';
import 'package:cassettefrontend/core/services/api_service.dart';

class ClipboardPasteButton extends StatefulWidget {
  final String hint;
  final double? height;
  final double? height2;
  final TextEditingController controller;
  final Function(String)? onPaste;
  final Function(String)? onSearch;
  final VoidCallback? onTap;

  const ClipboardPasteButton({
    super.key,
    required this.hint,
    required this.controller,
    this.height,
    this.height2,
    this.onPaste,
    this.onSearch,
    this.onTap,
  });

  @override
  State<ClipboardPasteButton> createState() => _ClipboardPasteButtonState();
}

class _ClipboardPasteButtonState extends State<ClipboardPasteButton> {
  bool _hasContent = false;
  bool _isLoading = false;
  String _displayText = "";
  Timer? _searchDebounce;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _hasContent = widget.controller.text.isNotEmpty;
    if (_hasContent) {
      _updateDisplayText(widget.controller.text);
    }
    widget.controller.addListener(_onTextChanged);
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

  void _onTextChanged() {
    final hasContent = widget.controller.text.isNotEmpty;
    if (_hasContent != hasContent) {
      setState(() {
        _hasContent = hasContent;
        if (hasContent) {
          _updateDisplayText(widget.controller.text);
        }
      });
    }

    // Check if the text looks like a music service URL
    final text = widget.controller.text.toLowerCase();
    final isUrl = text.contains('spotify.com') ||
        text.contains('apple.com/music') ||
        text.contains('deezer.com');

    if (hasContent) {
      if (isUrl && widget.onPaste != null) {
        // If it's a URL, immediately trigger the paste handler
        widget.onPaste!(widget.controller.text);
      } else if (!isUrl && widget.onSearch != null) {
        // If it's not a URL and doesn't look empty, debounce and trigger search
        _searchDebounce?.cancel();
        _searchDebounce = Timer(const Duration(milliseconds: 500), () {
          _handleSearch(widget.controller.text);
        });
      }
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) return;

    // Check again if the input still doesn't look like a URL
    final isUrl = query.toLowerCase().contains('spotify.com') ||
        query.toLowerCase().contains('apple.com/music') ||
        query.toLowerCase().contains('deezer.com');

    if (!isUrl && widget.onSearch != null) {
      widget.onSearch!(query);
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
          Container(
            height: widget.height2 ?? 50,
            width: MediaQuery.of(context).size.width - 36,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColors.textPrimary,
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: AppStyles.textFieldHintTextStyle,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppStyles.textFieldHintTextStyle.copyWith(
                        color: AppColors.textPrimary,
                      ),
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
                        : IconButton(
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              color: AppColors.textPrimary,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _searchDebounce?.cancel();
    super.dispose();
  }
}
