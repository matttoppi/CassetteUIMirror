import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/app_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/feature/profile/model/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isMenuVisible = false;
  int value = 0;

  TextEditingController nameCtr = TextEditingController();
  TextEditingController userNameCtr = TextEditingController();
  TextEditingController linkCtr = TextEditingController();
  TextEditingController bioCtr = TextEditingController();

  List<Services> allServicesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameCtr.text = AppUtils.profileModel.fullName ?? '';
    userNameCtr.text = AppUtils.profileModel.userName ?? '';
    linkCtr.text = AppUtils.profileModel.link ?? '';
    bioCtr.text = AppUtils.profileModel.bio ?? '';
  }

  fillAllServices() {
    allServicesList
      ..add(Services(serviceName: "Spotify"))
      ..add(Services(serviceName: "Apple Music"))
      ..add(Services(serviceName: "YouTube Music"))
      ..add(Services(serviceName: "Tidal"))
      ..add(Services(serviceName: "Deezer"));
  }

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
              AppToolbar(burgerMenuFnc: () {
                setState(() {
                  isMenuVisible = !isMenuVisible;
                });
              }),
              const SizedBox(height: 18),
              profileTopView(),
              const SizedBox(height: 38),
              connectServiceView(),
              const SizedBox(height: 28),
              labelTextFieldWidget(),
              const SizedBox(height: 56),
              AnimatedPrimaryButton(
                text: "Save Changes",
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
              const SizedBox(height: 56),
            ],
          ),
        ));
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
          Text("Edit Your Profile", style: AppStyles.profileTitleTextStyle),
        ],
      ),
    );
  }

  connectServiceView() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.only(top: 8, left: 8, right: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text("Connected Services",
                      style: AppStyles.addServiceTextStyle)),
              const SizedBox(width: 6),
              AnimatedPrimaryButton(
                  text: "Add More",
                  onTap: () {},
                  onTapDown: (details) {
                    double tapY = details.globalPosition.dy;
                    openAddServiceDialog(tapY);
                  },
                  width: 120,
                  height: 22,
                  radius: 16,
                  textStyle: AppStyles.addMoreBtnTextStyle),
            ],
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppUtils.profileModel.services?.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: serviceRow(
                    AppUtils.profileModel.services?[index].serviceName),
              );
            },
          ),
        ],
      ),
    );
  }

  labelTextFieldWidget() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Name",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                TextFieldWidget(hint: "Enter your name", controller: nameCtr),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Username",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldWidget(
                hint: "Enter your username", controller: userNameCtr),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Link",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                TextFieldWidget(hint: "Enter your link", controller: linkCtr),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Bio",
                textAlign: TextAlign.left,
                style: AppStyles.authTextFieldLabelTextStyle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldWidget(
                hint: "Enter your bio",
                controller: bioCtr,
                maxLines: 6,
                minLines: 6,
                height: 160,
                height2: 156),
          ),
        ],
      ),
    );
  }

  serviceRow(serviceName) {
    return Row(
      children: [
        getServiceIcon(serviceName),
        const SizedBox(width: 8),
        Expanded(
            child: Text(serviceName,
                style: AppStyles.editProfileServicesTextStyle)),
        InkWell(
            onTap: () {
              setState(() {
                AppUtils.profileModel.services?.removeWhere(
                    (element) => element.serviceName == serviceName);
              });
            },
            child: Image.asset(icDelete, fit: BoxFit.scaleDown, height: 22)),
      ],
    );
  }

  serviceIcon(image, color, {double? height}) {
    return Image.asset(image,
        height: height ?? 22, fit: BoxFit.contain, color: color);
  }

  getServiceIcon(String serviceName, {double? iconHeight}) {
    switch (serviceName) {
      case "Spotify":
        return serviceIcon(icSpotify, AppColors.greenAppColor,
            height: iconHeight);
      case "Apple Music":
        return serviceIcon(icApple, AppColors.animatedBtnColorToolBarTop,
            height: iconHeight);
      case "YouTube Music":
        return serviceIcon(icYtMusic, AppColors.animatedBtnColorToolBarTop,
            height: iconHeight);
      case "Tidal":
        return serviceIcon(icTidal, AppColors.textPrimary, height: iconHeight);
      case "Deezer":
        return serviceIcon(icDeezer, AppColors.textPrimary, height: iconHeight);
      default:
        return serviceIcon(icSpotify, AppColors.greenAppColor,
            height: iconHeight);
    }
  }

  openAddServiceDialog(tapY) {
    value = 0;
    allServicesList.clear();
    fillAllServices();
    if (AppUtils.profileModel.services?.isNotEmpty ?? false) {
      for (var i in AppUtils.profileModel.services!) {
        allServicesList
            .removeWhere((element) => element.serviceName == i.serviceName);
      }
    }
    SmartDialog.show(
      alignment:
          Alignment(0, (tapY / MediaQuery.of(context).size.height) * 2 - 1),
      builder: (BuildContext ctx2) {
        return StatefulBuilder(
            builder: (BuildContext ctx, StateSetter setState2) {
          return Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 6),
            decoration: const BoxDecoration(
              color: AppColors.colorWhite,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Select a service",
                        style: AppStyles.dialogTitleTextStyle),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        SmartDialog.dismiss();
                      },
                      child: const Icon(Icons.close,
                          color: AppColors.blackColor, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allServicesList.length,
                  itemBuilder: (context, index) {
                    return AppUtils.profileModel.services
                                ?.map((e) => e.serviceName)
                                .toList()
                                .contains(allServicesList[index].serviceName) ??
                            false
                        ? SizedBox()
                        : RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.textPrimary,
                            value: index,
                            groupValue: value,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.trailing,
                            onChanged: (ind) {
                              setState2(() => value = index);
                            },
                            title: Row(
                              children: [
                                getServiceIcon(
                                    allServicesList[index].serviceName ?? '',
                                    iconHeight: 18),
                                const SizedBox(width: 6),
                                Text(
                                  allServicesList[index].serviceName ?? '',
                                  style: AppStyles.dialogItemsTextStyle,
                                ),
                              ],
                            ),
                          );
                  },
                ),
                const SizedBox(height: 12),
                AnimatedPrimaryButton(
                  text: "Add Service",
                  onTap: () {
                    Future.delayed(
                      const Duration(milliseconds: 180),
                      () {
                        SmartDialog.dismiss();
                        addServiceFnc();
                      },
                    );
                  },
                  height: 35,
                  width: MediaQuery.of(context).size.width / 1.69,
                  radius: 12,
                  initialPos: 4,
                  colorTop: AppColors.animatedBtnColorConvertTop,
                  textStyle: AppStyles.animatedBtnAddServiceDialogTextStyle,
                  borderColorTop: AppColors.animatedBtnColorConvertTop,
                  colorBottom: AppColors.animatedBtnColorConvertBottom,
                  borderColorBottom:
                      AppColors.animatedBtnColorConvertBottomBorder,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }

  addServiceFnc() {
    if (allServicesList.isNotEmpty) {
      AppUtils.profileModel.services
          ?.add(Services(serviceName: allServicesList[value].serviceName));
      setState(() {});
    }
  }
}
