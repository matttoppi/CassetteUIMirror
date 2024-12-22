import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';

class AnimatedPrimaryButton extends StatefulWidget {
  final String text;
  final double? height;
  final double? width;
  final double? initialPos;
  final Color? colorTop;
  final Color? colorBottom;
  final Color? borderColorTop;
  final Color? borderColorBottom;
  final double? radius;
  final double? bottomBorderWidth;
  final double? topBorderWidth;
  final TextStyle? textStyle;
  final Function onTap;
  final Function(TapDownDetails)? onTapDown;

  const AnimatedPrimaryButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.bottomBorderWidth,
      this.textStyle,
      this.topBorderWidth,
      this.borderColorBottom,
      this.borderColorTop,
      this.height,
      this.width,
      this.initialPos,
      this.colorTop,
      this.colorBottom,
      this.onTapDown,
      this.radius});

  @override
  State<AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<AnimatedPrimaryButton> {
  double _position = 4;
  double initialPos = 4;
  double height = 32;
  double width = 100;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.initialPos != null) {
      initialPos = widget.initialPos ?? 4;
      _position = widget.initialPos ?? 4;
    }
    if (widget.height != null) {
      height = widget.height ?? 32;
    }
    if (widget.width != null) {
      width = widget.width ?? 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(!mounted) return;
        setState(() {
          _position = 0;
        });
        Future.delayed(
          const Duration(milliseconds: 125),
          () {
            if(!mounted) return;
            setState(() {
              _position = initialPos;
            });
          },
        );
        widget.onTap();
      },
      onTapDown: widget.onTapDown,
      child: SizedBox(
        height: height + initialPos,
        width: width + initialPos,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: height,
                width: width,
                decoration: AppStyles.animatedButtonBottomStyle(
                    borderColor: widget.borderColorBottom,
                    borderWidth: widget.bottomBorderWidth,
                    color: widget.colorBottom,
                    radius: widget.radius),
              ),
            ),
            AnimatedPositioned(
              curve: Curves.easeIn,
              bottom: _position,
              right: _position,
              duration: const Duration(milliseconds: 50),
              child: Container(
                height: height,
                width: width,
                decoration: AppStyles.animatedButtonTopStyle(
                    borderWidth: widget.topBorderWidth,
                    borderColor: widget.borderColorTop,
                    color: widget.colorTop,
                    radius: widget.radius),
                child: Center(
                  child: Text(
                    widget.text,
                    style: widget.textStyle ?? AppStyles.animatedBtnTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
