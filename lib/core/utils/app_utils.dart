import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/feature/profile/model/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;

class AppUtils {
  static ProfileModel profileModel = ProfileModel(
      id: 1,
      fullName: "Matt Toppi",
      userName: "@MattToppi280",
      link: "instragram.com/@MattToppi280",
      bio: "Founder of Cassette. Lead developer and music lover at heart",
      profilePath:
          // "https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "https://images.unsplash.com/photo-1608008961553-0c83c2883ad2?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      services: [
        Services(serviceName: "Spotify"),
        Services(serviceName: "Apple Music"),
      ]);

  static Widget burgerMenu(
      {required VoidCallback onPressed, Color? iconColor}) {
    return IconButton(
      iconSize: 42,
      onPressed: onPressed,
      icon: Image.asset(icMenu,
          color: iconColor ?? AppColors.textPrimary,
          fit: BoxFit.contain,
          height: 24),
    );
  }

  static Widget cacheImage({
    required String imageUrl,
    double? height,
    double? width,
    Widget? placeholder,
    BoxFit fit = BoxFit.cover,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          placeholder: (context, url) {
            return placeholder ??
                Center(
                  child: Image.asset(
                    icMusic,
                    height: 50,
                    width: 50,
                    fit: BoxFit.scaleDown,
                  ),
                );
          },
          errorWidget: (context, url, error) {
            return Center(
              child: Image.asset(
                height: 75,
                width: 75,
                icMusic,
                fit: BoxFit.scaleDown,
              ),
            );
          },
        ),
      ),
    );
  }

  static Future<void> onShare(context, content) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      content,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  static authLinksWidgets({googleOnTap, spotifyOnTap, appleOnTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
            onTap: googleOnTap,
            child: Image.asset(authGoogle, height: 52, fit: BoxFit.contain)),
        GestureDetector(
          onTap: spotifyOnTap,
          child: Image.asset(icSpotify,
              height: 52, fit: BoxFit.contain, color: AppColors.greenAppColor),
        ),
        GestureDetector(
          onTap: appleOnTap,
          child: Image.asset(icApple,
              height: 52,
              fit: BoxFit.contain,
              color: AppColors.animatedBtnColorToolBarTop),
        ),
      ],
    );
  }

  static void openUrlOnNewTab(String url) {
    html.window.open(url, "new tab");
  }

  static trackSocialLinksWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        socialImageWidget(icApple, () {
          AppUtils.openUrlOnNewTab("https://music.apple.com");
        }),
        socialImageWidget(icYtMusic, () {
          AppUtils.openUrlOnNewTab("https://music.youtube.com");
        }),
        socialImageWidget(icSpotify, () {
          AppUtils.openUrlOnNewTab("https://open.spotify.com");
        }),
        socialImageWidget(icTidal, () {
          AppUtils.openUrlOnNewTab("https://tidal.com");
        }),
        socialImageWidget(icDeezer, () {
          AppUtils.openUrlOnNewTab("https://www.deezer.com");
        }),
      ],
    );
  }

  static socialImageWidget(String image, onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Image.asset(image, height: 48, fit: BoxFit.contain));
  }

  static cmDesBox({String? userName, String? des}) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                color: AppColors.grayColor),
            height: 175,
            margin: EdgeInsets.symmetric(horizontal: 16)),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(42),
              color: AppColors.colorWhite),
          height: 175,
          width: double.infinity,
          margin: EdgeInsets.only(top: 3, right: 18, left: 18),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(userName ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.trackDetailTitleTs),
              const SizedBox(height: 12),
              Text(
                des ?? "",
                textAlign: TextAlign.left,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.trackDetailContentTs,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<XFile?> uploadPhoto() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
      return image;
  }
}
