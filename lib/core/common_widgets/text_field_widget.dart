import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final String? hint;
  final double? height;
  final double? height2;
  final int? maxLines;
  final int? minLines;
  final TextEditingController? controller;
  final String? errorText;
  final Function(String value)? onChanged;

  const TextFieldWidget(
      {super.key,
      this.hint,
      this.controller,
      this.height,
      this.height2,
      this.maxLines,
      this.minLines,
      this.errorText,
      this.onChanged});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              Container(
                height: widget.height2 ?? 50,
                width: MediaQuery.of(context).size.width - 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.textPrimary),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    maxLines: widget.maxLines ?? 1,
                    minLines: widget.minLines ?? 1,
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    decoration: InputDecoration(
                        hintText: widget.hint,
                        border: InputBorder.none,
                        hintStyle: AppStyles.textFieldHintTextStyle),
                  ),
                ),
              ),
            ],
          ),
        ),
        widget.errorText == null || widget.errorText == ""
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  widget.errorText ?? '',
                  style: AppStyles.textFieldErrorTextStyle,
                ),
              ),
      ],
    );
  }
}
