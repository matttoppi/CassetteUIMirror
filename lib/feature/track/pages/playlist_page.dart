import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/track_toolbar.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/feature/track/json/playlist_items_json.dart';
import 'package:cassettefrontend/feature/track/model/playlist_item_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

class TracklistPage extends StatefulWidget {
  final String? type;
  final String? trackId;

  const TracklistPage({super.key, this.type, this.trackId});

  @override
  State<TracklistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<TracklistPage> {
  String name = '';
  String artistName = "Daniel Caesar";
  String desUsername = 'matttoppi';
  String? des =
      "One of the my favorite songs off of Daniel Caesar’s magnum opus. I recently bought the entire Freudian album on vinyl.";

  Color dominateColor = AppColors.appBg;

  List<String> playlist = [
    "https://images.pexels.com/photos/15447298/pexels-photo-15447298/free-photo-of-retro-cassette-records-in-stacks.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/1853542/pexels-photo-1853542.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/1164975/pexels-photo-1164975.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/844928/pexels-photo-844928.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
  ];

  String albumUrl =
      "https://images.pexels.com/photos/7086286/pexels-photo-7086286.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1";

  List<PlaylistItemModel> playlistList = [];
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    isLoggedIn = PreferenceHelper.getBool(PreferenceHelper.isLoggedIn);
    // isLoggedIn = true;
    // des = null;
    name = widget.type == "album" ? "CHROMAKOPIA" : "Waves";
    _generatePalette(widget.type == "album" ? albumUrl : playlist.last);
    playlistList = (playlistItemsJson as List)
        .map((item) => PlaylistItemModel.fromJson(item))
        .toList();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TrackToolbar(isLoggedIn: isLoggedIn),
            ),
            const SizedBox(height: 18),
            body(),
            const SizedBox(height: 18),
            listingView(),
            Visibility(visible: !isLoggedIn && des != null, child: createAccWidget()),
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
                    child: widget.type == "album"
                        ? Image.network(albumUrl,
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.width / 2.5,
                            fit: BoxFit.cover)
                        : SizedBox(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.width / 2.5,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: playlist.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              itemBuilder: (context, index) {
                                return Image.network(playlist[index],
                                    fit: BoxFit.cover);
                              },
                            ),
                          ),
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
          if (widget.type == "album")
            Text(
              "Tyler the Creator",
              style: AppStyles.trackArtistNameTs,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          Text(
            "14 songs | 1h",
            style: AppStyles.trackPlaylistSongNoTs,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          des == null && !isLoggedIn? createAccWidget() : desWidget(),
          SizedBox(height: des == null ? 40 : 0),
          AppUtils.trackSocialLinksWidget(),
          const SizedBox(height: 18),
          const Divider(
              height: 2,
              thickness: 2,
              color: AppColors.textPrimary,
              endIndent: 10,
              indent: 10),
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

  listingView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlistList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text("${index + 1}", style: AppStyles.playlistLeadTs),
          title: Text(playlistList[index].title ?? '',
              style: AppStyles.playlistTitleAndDurationTs),
          subtitle: Text(playlistList[index].artist ?? '',
              style: AppStyles.playlistSubTs),
          trailing: Text(playlistList[index].duration ?? '',
              style: AppStyles.playlistTitleAndDurationTs),
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
