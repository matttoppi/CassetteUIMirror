import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthToolbar extends StatefulWidget {
  final Function burgerMenuFnc;
  const AuthToolbar({super.key,required this.burgerMenuFnc});

  @override
  State<AuthToolbar> createState() => _AuthToolbarState();
}

class _AuthToolbarState extends State<AuthToolbar> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    context.go('/signin');
                  },
                  style: AppStyles.homeTextBtnStyle(),
                  child: Text("Sign In", style: AppStyles.signBtnTextStyle)),
              const SizedBox(width: 6),
              AnimatedPrimaryButton(
                text: "Sign Up",
                onTap: () {
                  Future.delayed(Duration(milliseconds: 180),() => context.go('/signup'),);
                },
              ),
              const SizedBox(width: 4),
              AppUtils.burgerMenu(onPressed: (){
                widget.burgerMenuFnc();
              }),
            ],
          ),
        ],
      ),
    );
  }
}
