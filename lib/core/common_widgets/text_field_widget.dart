import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({super.key});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: MediaQuery.of(context).size.width - 32,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 50,
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
            height: 50,
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
                maxLines: 1,
                minLines: 1,
                decoration: InputDecoration(
                    hintText: "Paste your music link here...",
                    border: InputBorder.none,
                    hintStyle: AppStyles.textFieldHintTextStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
