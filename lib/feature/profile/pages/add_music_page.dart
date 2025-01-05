import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/app_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddMusicPage extends StatefulWidget {
  const AddMusicPage({super.key});

  @override
  State<AddMusicPage> createState() => _AddMusicPageState();
}

class _AddMusicPageState extends State<AddMusicPage> {
  bool isMenuVisible = false;

  TextEditingController linkCtr = TextEditingController();
  TextEditingController desCtr = TextEditingController();

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
      body: Column(
        children: [
          const SizedBox(height: 18),
          AppToolbar(burgerMenuFnc: () {
            setState(() {
              isMenuVisible = !isMenuVisible;
            });
          }),
          const SizedBox(height: 18),
          profileTopView(),
          const SizedBox(height: 38),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                    "Paste your link below to convert a\nsong or playlist that goes in your profile",
                    textAlign: TextAlign.center,
                    style: AppStyles.addMusicSubTitleTs),
                const SizedBox(height: 24),
                labelTextFieldWidget(),
                const SizedBox(height: 56),
                AnimatedPrimaryButton(
                  text: "Convert",
                  onTap: () {
                    context.go("/profile");
                  },
                  height: 40,
                  width: MediaQuery.of(context).size.width - 46,
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
                const SizedBox(height: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }

  profileTopView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage:
                NetworkImage(AppUtils.profileModel.profilePath ?? ''),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 22),
          Text("Add Music", style: AppStyles.addMusicTitleTs),
        ],
      ),
    );
  }

  labelTextFieldWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Music link",
            textAlign: TextAlign.left,
            style: AppStyles.authTextFieldLabelTextStyle),
        const SizedBox(height: 10),
        TextFieldWidget(
            hint: "Paste your music link here", controller: linkCtr),
        const SizedBox(height: 24),
        Text("Description",
            textAlign: TextAlign.left,
            style: AppStyles.authTextFieldLabelTextStyle),
        const SizedBox(height: 10),
        TextFieldWidget(
            hint: "Let us know a little bit about this song or playlist!",
            maxLines: 6,
            minLines: 6,
            height: 160,
            height2: 156,
            controller: desCtr),
      ],
    );
  }
}
