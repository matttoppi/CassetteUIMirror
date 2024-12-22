import 'package:cassettefrontend/core/common_widgets/pop_up_widget.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/feature/home/widgets/animated_background.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatefulWidget {
  final bool? showAnimatedBg;
  final bool? showGraphics;
  final bool? isMenuVisible;
  final Function? onBurgerPop;
  final Widget body;

  const AppScaffold(
      {super.key,
      this.showAnimatedBg,
      required this.body,
      this.showGraphics,
      this.isMenuVisible,
      this.onBurgerPop});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Stack(
        children: [
          if (widget.showAnimatedBg ?? false) AnimatedBackground(),
          widget.showGraphics ?? false
              ? Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 15),
                  child: Image.asset(bgRedBlue, fit: BoxFit.fitWidth),
                )
              : const SizedBox(),
          widget.body,
          PopUpWidget(
            isMenuVisible: widget.isMenuVisible ?? false,
            onPop: widget.onBurgerPop,
          ),
        ],
      ),
    );
  }
}
