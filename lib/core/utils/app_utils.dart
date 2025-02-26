import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/env.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/feature/profile/model/profile_model.dart';
import 'package:cassettefrontend/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:supabase_flutter/supabase_flutter.dart';

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

  static authLinksWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
            onTap: () async {
              await googleSignInSignUpFnc();
            },
            child: Image.asset(authGoogle, height: 52, fit: BoxFit.contain)),
        GestureDetector(
          onTap: () async {
            await spotifySignInSignUpFnc();
          },
          child: Image.asset(icSpotify,
              height: 52, fit: BoxFit.contain, color: AppColors.greenAppColor),
        ),
        GestureDetector(
          onTap: () async {
            await appleSignInSignUpFnc();
          },
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

  static Widget trackSocialLinksWidget({Map<String, dynamic>? platforms}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            try {
              if (platforms?.containsKey('spotify') ?? false) {
                final spotifyData =
                    platforms!['spotify'] as Map<String, dynamic>;
                final url = spotifyData['url'] ??
                    spotifyData['link'] ??
                    spotifyData['href'] ??
                    '';
                if (url.isNotEmpty) {
                  openUrlOnNewTab(url);
                }
              }
            } catch (e) {
              print('Error opening Spotify link: $e');
            }
          },
          icon: Image.asset(icSpotify, height: 38),
        ),
        IconButton(
          onPressed: () {
            try {
              // Check for applemusic key (all lowercase, no underscore)
              if (platforms?.containsKey('applemusic') ?? false) {
                final appleData =
                    platforms!['applemusic'] as Map<String, dynamic>;
                final url = appleData['url'] ??
                    appleData['link'] ??
                    appleData['href'] ??
                    '';
                if (url.isNotEmpty) {
                  openUrlOnNewTab(url);
                }
              }
              // Check for apple_music key (with underscore)
              else if (platforms?.containsKey('apple_music') ?? false) {
                final appleData =
                    platforms!['apple_music'] as Map<String, dynamic>;
                final url = appleData['url'] ??
                    appleData['link'] ??
                    appleData['href'] ??
                    '';
                if (url.isNotEmpty) {
                  openUrlOnNewTab(url);
                }
              }
              // Check for appleMusic key (camelCase)
              else if (platforms?.containsKey('appleMusic') ?? false) {
                final appleData =
                    platforms!['appleMusic'] as Map<String, dynamic>;
                final url = appleData['url'] ??
                    appleData['link'] ??
                    appleData['href'] ??
                    '';
                if (url.isNotEmpty) {
                  openUrlOnNewTab(url);
                }
              }
              // Check for apple-music key (with dash)
              else if (platforms?.containsKey('apple-music') ?? false) {
                final appleData =
                    platforms!['apple-music'] as Map<String, dynamic>;
                final url = appleData['url'] ??
                    appleData['link'] ??
                    appleData['href'] ??
                    '';
                if (url.isNotEmpty) {
                  openUrlOnNewTab(url);
                }
              }
            } catch (e) {
              print('Error opening Apple Music link: $e');
            }
          },
          icon: Image.asset(icApple, height: 38),
        ),
        IconButton(
          onPressed: () {
            try {
              if (platforms?.containsKey('deezer') ?? false) {
                final deezerData = platforms!['deezer'] as Map<String, dynamic>;
                final url = deezerData['url'] ??
                    deezerData['link'] ??
                    deezerData['href'] ??
                    '';
                if (url.isNotEmpty) {
                  openUrlOnNewTab(url);
                }
              }
            } catch (e) {
              print('Error opening Deezer link: $e');
            }
          },
          icon: Image.asset(icDeezer, height: 38),
        ),
      ],
    );
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

  static showToast({required BuildContext context, required String title}) {
    AnimatedSnackBar(
      desktopSnackBarPosition: DesktopSnackBarPosition.bottomCenter,
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      duration: const Duration(seconds: 3),
      builder: ((context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.textPrimary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(title, style: AppStyles.toastStyle),
        );
      }),
    ).show(context);
  }

  static Future<void> googleSignInSignUpFnc() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google,
          redirectTo: '${Env.appDomain}/profile');
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
    }
  }

  static Future<void> appleSignInSignUpFnc() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: '${Env.appDomain}/profile',
      );
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
    }
  }

  static Future<void> spotifySignInSignUpFnc() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.spotify,
        redirectTo: '${Env.appDomain}/profile',
      );
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
    }
  }

  static loader() {
    return LinearProgressIndicator(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(12),
        backgroundColor: AppColors.appBg);
  }

  static void authenticateAppleMusic() {
    js.context.callMethod('requestUserToken');
  }

  static void listenForUserToken() {
    html.window.onMessage.listen((event) {
      String? userToken = event.data;
      if (userToken != null && userToken.isNotEmpty) {
        print("Music User Token: $userToken");
      }
    });
  }
}
