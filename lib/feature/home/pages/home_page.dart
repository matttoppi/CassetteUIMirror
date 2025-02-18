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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isMenuVisible = false;
  late final AnimationController _fadeController;
  late final Animation<double> groupAFadeAnimation;
  late final Animation<double> groupBFadeAnimation;
  late final Animation<double> groupCFadeAnimation;
  late final Animation<Offset> _logoSlideAnimation;
  late final Animation<Offset> groupBSlideAnimation;
  final ScrollController scrollController = ScrollController();
  final TextEditingController tfController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );
    groupAFadeAnimation = TweenSequence<double>([
      // Fade in from 0.0 to 1.0 during the first 45% of the timeline
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 45,
      ),
      // Then maintain full opacity until the end (remaining 55%)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 55,
      ),
    ]).animate(_fadeController);
    _logoSlideAnimation = TweenSequence<Offset>([
      // Hold the logo at the lower offset for the first 45% of the timeline
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0.8)),
        weight: 45,
      ),
      // Slide upward from offset (0, 0.8) to (0, 0.0) over the remaining 55%
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
    ]).animate(_fadeController);
    groupBFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.818, 1.0, curve: Curves.easeIn),
      ),
    );
    groupCFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.818, 1.0, curve: Curves.easeIn),
      ),
    );
    groupBSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.818, 1.0, curve: Curves.easeOut),
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      _fadeController.forward();
    });
  }

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
              FadeTransition(
                opacity: groupAFadeAnimation,
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
                    SlideTransition(
                      position: _logoSlideAnimation,
                      child: Column(
                        children: [
                          textGraphics(),
                          const SizedBox(height: 5),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12 + 16),
                            child: Text(
                              "Express yourself through your favorite songs and playlists - wherever you stream them",
                              textAlign: TextAlign.center,
                              style: AppStyles.homeCenterTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: groupBFadeAnimation,
                child: SlideTransition(
                  position: groupBSlideAnimation,
                  child: Column(
                    children: [
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
                                const Duration(milliseconds: 180),
                                () =>
                                    context.go('/track/${tfController.text}/0'),
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
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: groupCFadeAnimation,
                child: Column(
                  children: [
                    Image.asset(
                      homeGraphics,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 1.05,
                    ),
                    const SizedBox(height: 50),
                    AnimatedPrimaryButton(
                      text: "Create Your Free Account!",
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 180),
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

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
