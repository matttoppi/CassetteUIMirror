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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Add this import for TimeoutException

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
                child: Text("Let's get started!",
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
                  if (_isLoading)
                    return; // Prevent multiple sign ups if already loading
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
    } else if (emailController.text.split('@').first.length < 3) {
      validation = {"email": "Email prefix must be at least 3 characters"};
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
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Generate temporary username
      final emailPrefix = emailController.text.split('@').first;
      final rawUsername =
          'temp_${emailPrefix.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '').toLowerCase()}';
      final usersTableUsername =
          rawUsername.length > 30 ? rawUsername.substring(0, 30) : rawUsername;

      print(
          '[DEBUG] Starting signup process for email: ${emailController.text.trim().toLowerCase()}');

      // Add delay to ensure proper request handling
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        print('[DEBUG] Preparing signup request with:');
        print('[DEBUG] Email: ${emailController.text.trim().toLowerCase()}');
        print('[DEBUG] Username data: $usersTableUsername');

        // Basic signup with error catching
        final AuthResponse response;
        try {
          // Add request logging
          final signUpData = {
            'email': emailController.text.trim().toLowerCase(),
            'password': passController.text,
            'data': {
              'username': usersTableUsername,
            },
          };
          print(
              '[DEBUG] SignUp request data (excluding password): ${signUpData..remove('password')}');

          try {
            response = await supabase.auth.signUp(
              email: emailController.text.trim().toLowerCase(),
              password: passController.text,
              data: {
                'username': usersTableUsername,
              },
            ).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Signup request timed out');
              },
            );

            if (response.user == null) {
              throw AuthException('Signup failed - no user returned');
            }

            // Log response details
            print('[DEBUG] Auth response received:');
            print('[DEBUG] User ID: ${response.user?.id}');
            print('[DEBUG] User email: ${response.user?.email}');
            print('[DEBUG] Session present: ${response.session != null}');
          } catch (authError) {
            print('[ERROR] Auth signup error details:');
            print('[ERROR] Error type: ${authError.runtimeType}');
            print('[ERROR] Full error: $authError');

            if (authError is AuthException) {
              print('[ERROR] Status code: ${authError.statusCode}');
              print('[ERROR] Message: ${authError.message}');
              throw authError; // Throw the original error
            }

            // For other types of errors, wrap them in a more descriptive AuthException
            throw AuthException(
                'Failed to create account. Please try again later.');
          }
        } catch (authError) {
          print('[ERROR] Auth signup error details:');
          print('[ERROR] Error type: ${authError.runtimeType}');
          print('[ERROR] Full error: $authError');

          if (authError is AuthException) {
            print('[ERROR] Status code: ${authError.statusCode}');
            print('[ERROR] Message: ${authError.message}');
          }

          throw AuthException(
              'Failed to create account: ${authError.toString()}');
        }

        final user = response.user!;
        print('[DEBUG] User created successfully with ID: ${user.id}');

        try {
          // Create user profile in Users table
          print('[DEBUG] Auth UID: ${user.id} (Type: ${user.id.runtimeType})');
          print('[DEBUG] AuthUserId to insert: ${user.id}');
          print('[DEBUG] Attempting to insert with payload:');
          final payload = {
            'UserId': user.id,
            'AuthUserId': user.id,
            'Username': usersTableUsername,
            'Email': user.email!,
            'Bio': '',
            'AvatarUrl': '',
            'JoinDate': DateTime.now().toIso8601String()
          };
          print('[DEBUG] ${json.encode(payload)}');

          // Test select permission first
          print('[DEBUG] Testing SELECT permission...');
          try {
            final selectTest = await supabase.from('Users').select().limit(1);
            print(
                '[DEBUG] SELECT test successful: ${selectTest.length} rows found');
          } catch (selectError) {
            print('[ERROR] SELECT test failed: $selectError');
          }

          // Attempt insert with error details
          print('[DEBUG] Attempting INSERT...');
          try {
            final response =
                await supabase.from('Users').insert(payload).select().single();
            print(
                '[DEBUG] Insert successful. Response: ${json.encode(response)}');
          } catch (insertError) {
            print('[ERROR] Detailed insert error:');
            print('[ERROR] Error type: ${insertError.runtimeType}');
            print('[ERROR] Full error: $insertError');
            if (insertError is PostgrestException) {
              print('[ERROR] Code: ${insertError.code}');
              print('[ERROR] Message: ${insertError.message}');
              print('[ERROR] Details: ${insertError.details}');
              print('[ERROR] Hint: ${insertError.hint}');
            }
            rethrow;
          }

          print('[DEBUG] User profile created in database');

          // Only navigate if both auth and database operations succeed
          if (response.session != null) {
            context.go('/edit_profile');
          } else {
            context.go('/verify-email');
          }
        } catch (dbError) {
          print('[ERROR] Database error: $dbError');
          final errorMsg =
              dbError is PostgrestException && dbError.code == '42501'
                  ? 'Database permissions issue - contact support'
                  : 'Profile creation failed';

          if (mounted) {
            AppUtils.showToast(context: context, title: errorMsg);
          }
          rethrow;
        }
      } catch (error) {
        print('[ERROR] Signup process error: $error');

        String errorMessage = error is AuthException
            ? error.toString()
            : 'An unexpected error occurred. Please try again.';

        if (mounted) {
          AppUtils.showToast(
            context: context,
            title: errorMessage,
          );
        }
      }
    } catch (error) {
      print('[ERROR] Signup process error: $error');

      String errorMessage = error is AuthException
          ? error.toString()
          : 'An unexpected error occurred. Please try again.';

      if (mounted) {
        AppUtils.showToast(
          context: context,
          title: errorMessage,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
