import 'package:cassettefrontend/core/common_widgets/pop_up_widget.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/feature/home/widgets/animated_background.dart';
import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/useanimations.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isMenuVisible = false;
  late AnimationController _menuController;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _menuController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Stack(
        children: [
          AnimatedBackground(),
          Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  toolBar(),
                  const SizedBox(height: 22),
                  textGraphics(),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12 + 16),
                    child: Text(
                        "Express yourself through your favorite songs and playlists - wherever you stream them",
                        textAlign: TextAlign.center,
                        style: AppStyles.homeCenterTextStyle),
                  ),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextFieldWidget(),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedPrimaryButton(
                      text: "Convert",
                      onTap: () {},
                      height: 32,
                      width: 200,
                      radius: 10,
                      initialPos: 5,
                      topBorderWidth: 3,
                      bottomBorderWidth: 3,
                      colorTop: AppColors.animatedBtnColorConvertTop,
                      textStyle: AppStyles.animatedBtnConvertTextStyle,
                      borderColorTop: AppColors.animatedBtnColorConvertTop,
                      colorBottom: AppColors.animatedBtnColorConvertBottom,
                      borderColorBottom:
                          AppColors.animatedBtnColorConvertBottomBorder,
                    ),
                  ),
                  // const SizedBox(height: 60),
                  Image.asset(homeGraphics,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 1.05),
                  const SizedBox(height: 50),
                  AnimatedPrimaryButton(
                    text: "Create Your Free Account!",
                    onTap: () {},
                    height: 40,
                    width: MediaQuery.of(context).size.width - 46 + 16,
                    radius: 10,
                    initialPos: 6,
                    topBorderWidth: 3,
                    bottomBorderWidth: 3,
                    colorTop: AppColors.animatedBtnColorConvertTop,
                    textStyle: AppStyles.animatedBtnFreeAccTextStyle,
                    borderColorTop: AppColors.animatedBtnColorConvertTop,
                    colorBottom: AppColors.animatedBtnColorConvertBottom,
                    borderColorBottom:
                        AppColors.animatedBtnColorConvertBottomBorder,
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
          PopUpWidget(isMenuVisible: _isMenuVisible),
        ],
      ),
    );
  }

  Widget toolBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Image.asset(appLogo, fit: BoxFit.scaleDown)),
          const SizedBox(width: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {},
                  style: AppStyles.homeTextBtnStyle(),
                  child: Text("Sign In", style: AppStyles.signBtnTextStyle)),
              const SizedBox(width: 6),
              AnimatedPrimaryButton(
                text: "Sign Up",
                onTap: () {},
              ),
              const SizedBox(width: 4),
              IconButton(
                iconSize: 42,
                color: AppColors.textPrimary,
                onPressed: () {
                  if (_menuController.status == AnimationStatus.dismissed) {
                    _menuController.reset();
                    _menuController.animateTo(1);
                  } else {
                    _menuController.reverse();
                  }
                  setState(() {
                    _isMenuVisible = !_isMenuVisible;
                  });
                },
                icon: Lottie.asset(Useanimations.menuV3,
                    controller: _menuController,
                    height: 42,
                    fit: BoxFit.fitHeight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textGraphics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Image.asset(appLogoText, fit: BoxFit.contain),
    );
  }
}
