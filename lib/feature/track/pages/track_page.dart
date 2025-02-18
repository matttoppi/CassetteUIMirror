import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/track_toolbar.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

class MediaDetailPage extends StatefulWidget {
  final String? type;
  final String? trackId;

  const MediaDetailPage({super.key, this.type, this.trackId});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  /////
  String name = '';
  String artistName = "Daniel Caesar";
  String desUsername = 'matttoppi';
  String? des =
      "One of the my favorite songs off of Daniel Caesar's magnum opus. I recently bought the entire Freudian album on vinyl.";

  /////

  Color dominateColor = AppColors.appBg;
  bool isLoggedIn = false;

  String songUrl =
      "https://images.pexels.com/photos/7260262/pexels-photo-7260262.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1";

  String artistUrl =
      "https://images.pexels.com/photos/5650694/pexels-photo-5650694.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1";

  @override
  void initState() {
    super.initState();
    isLoggedIn = PreferenceHelper.getBool(PreferenceHelper.isLoggedIn);
    // isLoggedIn = true;
    // des = null;
    name = widget.type == "artist" ? "Kendrick Lamar" : "Loose";
    _generatePalette(widget.type == "artist" ? artistUrl : songUrl);
  }

  Future<void> _generatePalette(String imageUrl) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
      maximumColorCount: 5,
    );
    setState(() {
      dominateColor = paletteGenerator.colors.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            dominateColor,
            AppColors.colorWhite,
            AppColors.appBg,
          ],
          stops: const [0, 0.75, 1],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TrackToolbar(isLoggedIn: isLoggedIn),
            ),
            const SizedBox(height: 18),
            body(),
            const SizedBox(height: 18),
          ],
        ),
      ),
    ));
  }

  body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(widget.type == "artist" ? "Artist" : "Track",
              style: AppStyles.trackTrackTitleTs),
          const SizedBox(height: 18),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Image.network(
                    widget.type == "artist" ? artistUrl : songUrl,
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                    fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  icPlay,
                  height: 56,
                ),
              ),
            ],
          ),
          Text(
            name,
            style: AppStyles.trackNameTs,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          widget.type == "artist"
              ? const SizedBox()
              : Text(
                  artistName,
                  style: AppStyles.trackArtistNameTs,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
          des == null ? createAccWidget() : desWidget(),
          SizedBox(height: des == null ? 125 : 0),
          const Divider(
              height: 2,
              thickness: 2,
              color: AppColors.textPrimary,
              endIndent: 10,
              indent: 10),
          const SizedBox(height: 18),
          AppUtils.trackSocialLinksWidget(),
          Visibility(visible: !isLoggedIn, child: createAccWidget()),
        ],
      ),
    );
  }

  desWidget() {
    return Column(
      children: [
        const SizedBox(height: 36),
        AppUtils.cmDesBox(userName: desUsername, des: des),
        const SizedBox(height: 36),
      ],
    );
  }

  createAccWidget() {
    return Column(
      children: [
        const SizedBox(height: 36),
        AnimatedPrimaryButton(
          text: "Create Your Free Account!",
          onTap: () {
            Future.delayed(
              Duration(milliseconds: 180),
              () => context.go('/signup'),
            );
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
          borderColorBottom: AppColors.animatedBtnColorConvertBottomBorder,
        ),
        const SizedBox(height: 12),
        Text(
          "Save this page to share again? Showcase your\nfavorite tunes with your Cassette Profile!",
          style: AppStyles.trackBelowBtnStringTs,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
