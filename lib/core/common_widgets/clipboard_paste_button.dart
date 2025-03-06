import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ClipboardPasteButton extends StatefulWidget {
  final String hint;
  final double? height;
  final double? height2;
  final TextEditingController controller;
  final Function(String)? onPaste;
  final Function(String)? onSearch;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const ClipboardPasteButton({
    super.key,
    required this.hint,
    required this.controller,
    this.height,
    this.height2,
    this.onPaste,
    this.onSearch,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<ClipboardPasteButton> createState() => _ClipboardPasteButtonState();
}

class _ClipboardPasteButtonState extends State<ClipboardPasteButton> {
  bool _hasContent = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _hasContent = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasContent = widget.controller.text.isNotEmpty;
    if (_hasContent != hasContent) {
      setState(() {
        _hasContent = hasContent;
      });
    }

    if (hasContent) {
      final text = widget.controller.text.toLowerCase();

      // Simple check for any URL containing the service names
      final isUrl = text.contains('spotify') ||
          text.contains('apple') ||
          text.contains('deezer');

      if (isUrl && widget.onPaste != null) {
        widget.onPaste!(widget.controller.text);
      } else if (!isUrl && widget.onSearch != null) {
        _searchDebounce?.cancel();
        _searchDebounce = Timer(const Duration(milliseconds: 500), () {
          widget.onSearch!(widget.controller.text);
        });
      }
    }
  }

  void _clearText() {
    widget.controller.clear();
    _onTextChanged(); // Ensure text change handler is triggered
    setState(() {
      _hasContent = false;
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
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        textInputAction: widget.textInputAction,
                        onSubmitted: (value) {
                          // Ensure keyboard is dismissed and prevent auto-focus
                          FocusScope.of(context).unfocus();
                          if (widget.onSubmitted != null) {
                            widget.onSubmitted!(value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: widget.hint,
                          hintStyle: AppStyles.textFieldHintTextStyle,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppStyles.textFieldHintTextStyle.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        enableInteractiveSelection: true,
                        mouseCursor: MaterialStateMouseCursor.textable,
                        contextMenuBuilder: (context, editableTextState) {
                          if (SystemContextMenu.isSupported(context)) {
                            return SystemContextMenu.editableText(
                              editableTextState: editableTextState,
                            );
                          }
                          return AdaptiveTextSelectionToolbar.editableText(
                            editableTextState: editableTextState,
                          );
                        },
                        onChanged: (value) => _onTextChanged(),
                      ),
                    ),
                    if (_hasContent)
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: _clearText,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
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
