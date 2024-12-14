import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';

class PopUpWidget extends StatefulWidget {
  bool isMenuVisible;

  PopUpWidget({super.key, required this.isMenuVisible});

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
    return Positioned(
        top: kToolbarHeight + 8, // Below AppBar
        right: 16, // Align with the burger icon
        child: Visibility(
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
                width: MediaQuery.of(context).size.width / 1.3,
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                decoration: const BoxDecoration(
                  color: AppColors.popBgColor,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child:
                                  Image.asset(appLogo, fit: BoxFit.scaleDown)),
                          const SizedBox(width: 25),
                          AnimatedPrimaryButton(
                              text:  "Sign In",
                              onTap: () {

                              },
                              height: 26,
                              width: 100,
                              initialPos: 2.5,
                              textStyle: AppStyles.popUpAnimatedBtnStyle),
                          const SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 20),
                      popUpItemWidget("Home"),
                      popUpItemWidget("Our Team"),
                      popUpItemWidget("Our Story"),
                      const SizedBox(height: 75),
                      popUpItemWidget("Terms of Service"),
                      popUpItemWidget("Privacy Policy "),
                      const SizedBox(height: 8),
                      const Divider(
                          color: AppColors.popUpDividerColor,
                          endIndent: 25,
                          indent: 25),
                      const SizedBox(height: 8),
                      Text("Share your music,\nwherever you\nstream it",
                          style: AppStyles.popUpBottomText),
                      const SizedBox(height: 20),
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
          ),
        ));
  }

  socialWidget(String image) {
    return Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(5),
        child: Image.asset(image, height: 18, fit: BoxFit.contain));
  }

  popUpItemWidget(text) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        minVerticalPadding: 0,
        dense: true,
        onTap: () {},
        title: Text(text, style: AppStyles.popUpItemStyle));
  }
}
