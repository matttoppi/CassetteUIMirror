import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/main.dart';
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
                        text: isAuthenticated ? "Sign Out" : "Sign In",
                        onTap: () async {
                          if (isAuthenticated) {
                            await supabase.auth.signOut().then((value) {
                              Future.delayed(const Duration(milliseconds: 180),
                                  () => context.go('/'));
                              AppUtils.showToast(
                                  context: context, title: "Signed Out");
                            });
                          } else {
                            Future.delayed(const Duration(milliseconds: 180),
                                () => context.go('/signin'));
                          }
                        },
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
                if (isAuthenticated)
                  popUpItemWidget("My Profile", () {
                    context.go('/profile');
                  }),
                if (isAuthenticated)
                  popUpItemWidget("Edit Profile", () {
                    context.go('/edit_profile');
                  }),
                if (isAuthenticated)
                  popUpItemWidget("Add Music", () {
                    context.go('/add_music');
                  }),
                if (isAuthenticated) const Spacer(),
                popUpItemWidget("Our Team", () {}),
                popUpItemWidget("Our Story", () {}),
                if (!isAuthenticated) const Spacer(),
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
                    socialWidget(instagramImage, () {
                      AppUtils.openUrlOnNewTab("https://www.instagram.com");
                    }),
                    socialWidget(threadsImage, () {
                      AppUtils.openUrlOnNewTab("https://www.threads.net");
                    }),
                    socialWidget(tiktokImage, () {
                      AppUtils.openUrlOnNewTab("https://www.tiktok.com");
                    }),
                    socialWidget(redditImage, () {
                      AppUtils.openUrlOnNewTab("https://www.reddit.com");
                    }),
                    socialWidget(linkedImage, () {
                      AppUtils.openUrlOnNewTab("https://www.linkedin.com");
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  socialWidget(String image, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset(image, height: 22, fit: BoxFit.contain)),
    );
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
