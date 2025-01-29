import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/auth_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/pop_up_widget.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/env.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/main.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isLoading = false;
  bool _isChecked = false;
  bool isMenuVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  Map<String, String> validation = {"": ""};

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
                child: Text("Let’s get started!",
                    textAlign: TextAlign.center,
                    style: AppStyles.signInSignUpTitleTextStyle),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 6),
                child: Text("Enter your information below to create an account",
                    textAlign: TextAlign.center,
                    style: AppStyles.signInSignUpCenterTextStyle),
              ),
              cmLabelTextFieldWidget(),
              const SizedBox(height: 28),
              tncWidget(),
              const SizedBox(height: 19),
              _isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppUtils.loader())
                  : const SizedBox(),
              const SizedBox(height: 19),
              AnimatedPrimaryButton(
                text: "Sign Up",
                onTap: () {
                  Future.delayed(
                    Duration(milliseconds: 180),
                    () {
                      _signUp();
                    },
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
              AppUtils.authLinksWidgets(),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldWidget(
              hint: "Enter your email address",
              controller: emailController,
              errorText: validation.keys.first == "email"
                  ? validation.values.first
                  : null,
              onChanged: (v) {
                validation = {"": ""};
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Password",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldWidget(
              hint: "Enter your password",
              controller: passController,
              errorText: validation.keys.first == "password"
                  ? validation.values.first
                  : null,
              onChanged: (v) {
                validation = {"": ""};
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Confirm Password",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldWidget(
              hint: "Re-enter your password",
              controller: confirmPassController,
              errorText: validation.keys.first == "conPassword"
                  ? validation.values.first
                  : null,
              onChanged: (v) {
                validation = {"": ""};
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  tncWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  side:
                      const BorderSide(color: AppColors.textPrimary, width: 1),
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
          validation.keys.first != "isChecked"
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    validation.values.first,
                    style: AppStyles.textFieldErrorTextStyle,
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
          text: 'Already have an account? ',
          style: AppStyles.bottomRichTextStyle,
          children: [
            TextSpan(
              text: 'Sign In',
              style: AppStyles.bottomRichTextStyle2,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.go('/signin');
                },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> validateSignUpForm() {
    if (emailController.text.isEmpty) {
      validation = {"email": "Please Enter Email"};
    } else if (!Validation.validateEmail(emailController.text)) {
      validation = {"email": "Please Enter A Valid Email"};
    } else if (passController.text.isEmpty) {
      validation = {"password": "Please Enter Password"};
    } else if (passController.text.length < 8) {
      validation = {"password": "Please Enter At-Least 8 Digit Password"};
    } else if (confirmPassController.text.isEmpty) {
      validation = {"conPassword": "Please Enter Confirm Password"};
    } else if (confirmPassController.text != passController.text) {
      validation = {
        "conPassword": "Confirm Password does not match with Password"
      };
    } else if (!_isChecked) {
      validation = {
        "isChecked":
            "Please agree to all the terms and conditions before Sign Up"
      };
    } else {
      validation = {"": ""};
    }
    setState(() {});
    return validation;
  }

  Future<void> _signUp() async {
    if (validateSignUpForm().keys.first != "") return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.auth.signUp(
          email: emailController.text,
          password: passController.text,
          emailRedirectTo: "$appDomain/profile");

      if (response.user != null) {
        if (response.session != null) {
          // Email confirmation is disabled
          context.go('/profile'); // Redirect to profile page
        } else {
          context.go('/profile'); // Redirect to profile page
          // Email confirmation is enabled
          AppUtils.showToast(
              context: context,
              title: "Please check your email to confirm your account");
        }
      } else {
        throw Exception('Signup failed');
      }
    } catch (error) {
      AppUtils.showToast(context: context, title: error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
