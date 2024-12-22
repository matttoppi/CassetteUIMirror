import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PopUpWidget extends StatefulWidget {
  bool isMenuVisible;
  Function? onPop;

  PopUpWidget({super.key, required this.isMenuVisible, this.onPop});

  @override
  State<PopUpWidget> createState() => _PopUpWidgetState();
}

class _PopUpWidgetState extends State<PopUpWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isMenuVisible,
      maintainAnimation: true,
      maintainState: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        opacity: widget.isMenuVisible ? 1 : 0,
        child: Material(
          elevation: 0,
          shadowColor: Colors.black,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
            decoration: const BoxDecoration(
              color: AppColors.popBgColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Image.asset(appLogo, fit: BoxFit.scaleDown)),
                    const SizedBox(width: 25),
                    AnimatedPrimaryButton(
                        text: "Sign In",
                        onTap: () {},
                        height: 32,
                        width: 125,
                        initialPos: 4,
                        textStyle: AppStyles.popUpAnimatedBtnStyle),
                    const SizedBox(width: 22),
                    IconButton(
                        onPressed: () {
                          if (widget.onPop != null) {
                            widget.onPop!();
                          }
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.colorWhite,
                          size: 32,
                        ))
                  ],
                ),
                const SizedBox(height: 20),
                popUpItemWidget("Home", () {
                  context.go('/');
                }),
                popUpItemWidget("Our Team", () {}),
                popUpItemWidget("Our Story", () {}),
                const Spacer(),
                popUpItemWidget("Terms of Service", () {}),
                popUpItemWidget("Privacy Policy ", () {}),
                const SizedBox(height: 12),
                const Divider(
                    color: AppColors.popUpDividerColor,
                    endIndent: 25,
                    indent: 25),
                const SizedBox(height: 12),
                Text("Share your music,\nwherever you\nstream it",
                    style: AppStyles.popUpBottomText),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    socialWidget(instagramImage),
                    socialWidget(threadsImage),
                    socialWidget(tiktokImage),
                    socialWidget(redditImage),
                    socialWidget(linkedImage),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  socialWidget(String image) {
    return Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(6),
        child: Image.asset(image, height: 22, fit: BoxFit.contain));
  }

  popUpItemWidget(text, onTap) {
    return ListTile(
        // contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        minVerticalPadding: 12,
        // dense: true,
        onTap: onTap,
        title: Text(text, style: AppStyles.popUpItemStyle));
  }
}
