import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/auth_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuVisible = false;
  ScrollController scrollController = ScrollController();
  TextEditingController tfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAnimatedBg: true,
      onBurgerPop: () {
        setState(() {
          isMenuVisible = !isMenuVisible;
        });
      },
      isMenuVisible: isMenuVisible,
      body: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              const SizedBox(height: 18),
              AuthToolbar(
                burgerMenuFnc: () {
                  setState(() {
                    isMenuVisible = !isMenuVisible;
                  });
                },
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFieldWidget(
                  hint: "Paste your music link here...",
                  controller: tfController,
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedPrimaryButton(
                  text: "Convert",
                  onTap: () {
                    if (tfController.text.isNotEmpty) {
                      Future.delayed(
                        Duration(milliseconds: 180),
                        () => context.go('/track/${tfController.text}/0'),
                      );
                    }
                  },
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
                onTap: () {
                  Future.delayed(
                    Duration(milliseconds: 180),
                    () => context.go('/signup'),
                  );
                },
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
    );
  }

  Widget textGraphics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Image.asset(appLogoText, fit: BoxFit.contain),
    );
  }
}
