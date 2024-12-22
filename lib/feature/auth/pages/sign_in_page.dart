import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/auth_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/pop_up_widget.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isChecked = false;
  bool isMenuVisible = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        showGraphics: true,
        onBurgerPop: () {
          setState(() {
            isMenuVisible = !isMenuVisible;
          });
        },
        isMenuVisible: isMenuVisible,
        body: SingleChildScrollView(
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
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Welcome back!",
                    textAlign: TextAlign.center,
                    style: AppStyles.signInSignUpTitleTextStyle),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 6),
                child: Text("Enter your information below to sign in",
                    textAlign: TextAlign.center,
                    style: AppStyles.signInSignUpCenterTextStyle),
              ),
              cmLabelTextFieldWidget(),
              const SizedBox(height: 28),
              tncWidget(),
              const SizedBox(height: 38),
              AnimatedPrimaryButton(
                text: "Sign In",
                onTap: () {
                  context.go("/profile");
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
              const SizedBox(height: 38),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: DottedLine(
                          direction: Axis.horizontal,
                          dashColor: AppColors.textPrimary),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text("OR",
                          style: AppStyles.signInSignUpCenterTextStyle),
                    ),
                    const Expanded(
                      child: DottedLine(
                          direction: Axis.horizontal,
                          dashColor: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(authGoogle, height: 52, fit: BoxFit.contain),
                  Image.asset(icSpotify,
                      height: 52,
                      fit: BoxFit.contain,
                      color: AppColors.greenAppColor),
                  Image.asset(icApple,
                      height: 52,
                      fit: BoxFit.contain,
                      color: AppColors.animatedBtnColorToolBarTop),
                ],
              ),
              const SizedBox(height: 26),
              bottomRichText(),
              const SizedBox(height: 22),
            ],
          ),
        ));
  }

  cmLabelTextFieldWidget() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Email Address",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldWidget(hint: "Enter your email address"),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Password",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldWidget(hint: "Enter your password"),
          ),
        ],
      ),
    );
  }

  tncWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 1.3,
            child: Checkbox(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              side: const BorderSide(color: AppColors.textPrimary, width: 1),
              activeColor: AppColors.textPrimary,
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
                });
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'I have read and agreed to the ',
                style: AppStyles.tncTextStyle,
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: AppStyles.tncTextStyle2,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigate to Terms of Service page
                        print('Terms of Service clicked');
                      },
                  ),
                  TextSpan(
                    text: ' and ',
                    style: AppStyles.tncTextStyle,
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppStyles.tncTextStyle2,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigate to Privacy Policy page
                        print('Privacy Policy clicked');
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bottomRichText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        text: TextSpan(
          text: 'Don’t have an account yet? ',
          style: AppStyles.bottomRichTextStyle,
          children: [
            TextSpan(
              text: 'Sign In',
              style: AppStyles.bottomRichTextStyle2,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.go('/signup');
                },
            ),
          ],
        ),
      ),
    );
  }
}
