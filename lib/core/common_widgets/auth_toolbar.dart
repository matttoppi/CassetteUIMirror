import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthToolbar extends StatefulWidget {
  final Function burgerMenuFnc;
  const AuthToolbar({super.key,required this.burgerMenuFnc});

  @override
  State<AuthToolbar> createState() => _AuthToolbarState();
}

class _AuthToolbarState extends State<AuthToolbar> with TickerProviderStateMixin{
  late AnimationController _menuController;

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
                  Future.delayed(Duration(milliseconds: 135),() => context.go('/signup'),);
                },
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
                 widget.burgerMenuFnc();
                },
                icon: const Icon(Icons.menu,size: 34,color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
