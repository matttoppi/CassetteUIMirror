import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/track_toolbar.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/feature/media/json/collection_items.dart';
import 'package:cassettefrontend/feature/media/model/collection_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

/// Handles display of track collections (playlists and albums)
/// Both types share similar UI as they are collections of tracks
class CollectionPage extends StatefulWidget {
  final String? type; // "album" or "playlist"
  final String? trackId;
  final String? postId;
  final Map<String, dynamic>? postData;

  const CollectionPage({
    super.key,
    this.type,
    this.trackId,
    this.postId,
    this.postData,
  });

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  String name = '';
  String artistName = '';
  String? des;
  String? desUsername;
  Color dominateColor = AppColors.appBg;
  bool isLoggedIn = false;
  String coverArtUrl = '';
  List<CollectionItem> trackList = [];

  @override
  void initState() {
    super.initState();
    isLoggedIn = PreferenceHelper.getBool(PreferenceHelper.isLoggedIn);

    // Initialize data from postData if available
    if (widget.postData != null) {
      final details = widget.postData!['details'] as Map<String, dynamic>;
      name = details['title'] as String;
      artistName = details['artist'] as String;
      coverArtUrl = details['coverArtUrl'] as String;
      des = widget.postData!['caption'] as String?;
      desUsername = widget.postData!['username'] as String?;

      // Parse tracks if available
      if (details.containsKey('tracks')) {
        final tracks = details['tracks'] as List<dynamic>;
        trackList =
            tracks.map((track) => CollectionItem.fromJson(track)).toList();
      }

      // Generate palette from cover art
      _generatePalette(coverArtUrl);
    }
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
        body: SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              dominateColor,
              AppColors.colorWhite,
              AppColors.appBg,
            ],
            stops: const [0, 0.35, 1],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            if (widget.postId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Post ID: ${widget.postId}',
                  style: AppStyles.trackTrackTitleTs,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TrackToolbar(isLoggedIn: isLoggedIn),
            ),
            const SizedBox(height: 18),
            body(),
            const SizedBox(height: 18),
            listingView(),
            Visibility(
                visible: !isLoggedIn && des != null, child: createAccWidget()),
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
          Text(widget.type == "album" ? "Album" : "Playlist",
              style: AppStyles.trackTrackTitleTs),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    icPrevious,
                    height: 38,
                  )),
              Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                    child: Image.network(coverArtUrl,
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
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    icNext,
                    height: 38,
                  )),
            ],
          ),
          Text(
            name,
            style: AppStyles.trackNameTs,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
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
          // Pass platforms data to social links widget
          widget.postData != null
              ? AppUtils.trackSocialLinksWidget(
                  platforms: widget.postData!['platforms'])
              : AppUtils.trackSocialLinksWidget(),
        ],
      ),
    );
  }

  desWidget() {
    return Column(
      children: [
        const SizedBox(height: 36),
        AppUtils.cmDesBox(userName: desUsername, des: des),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget listingView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trackList.length,
      itemBuilder: (context, index) {
        final track = trackList[index];
        return ListTile(
          title: Text(track.title, style: AppStyles.trackTrackTitleTs),
          subtitle: Text(track.artist, style: AppStyles.trackArtistNameTs),
          leading: Image.network(track.coverArtUrl, width: 50, height: 50),
          onTap: () {
            // Handle track selection
          },
        );
      },
    );
  }

  createAccWidget() {
    return Column(
      children: [
        const SizedBox(height: 18),
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
