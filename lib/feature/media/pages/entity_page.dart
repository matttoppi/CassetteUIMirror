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
import 'package:cassettefrontend/core/services/track_service.dart';

/// Handles display of standalone entities (individual tracks and artists)
/// Both types share similar UI as they are single items without inner track listings
class EntityPage extends StatefulWidget {
  final String? type; // "artist" or "track"
  final String? trackId;
  final String? postId;
  final Map<String, dynamic>? postData;

  const EntityPage({
    super.key,
    this.type,
    this.trackId,
    this.postId,
    this.postData,
  });

  @override
  State<EntityPage> createState() => _EntityPageState();
}

class _EntityPageState extends State<EntityPage> {
  final TrackService _trackService = TrackService();
  String name = '';
  String artistName = '';
  String? des;
  String? desUsername;
  Color dominateColor = AppColors.appBg;
  bool isLoggedIn = false;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    print(
        'EntityPage initState - type: ${widget.type}, trackId: ${widget.trackId}');
    print('EntityPage postData: ${widget.postData}');

    isLoggedIn = PreferenceHelper.getBool(PreferenceHelper.isLoggedIn);

    // Initialize data from postData if available
    if (widget.postData != null) {
      try {
        print('Processing postData: ${widget.postData}');
        final details = widget.postData!['details'] as Map<String, dynamic>?;
        print('Details from postData: $details');

        if (details != null) {
          setState(() {
            name = details['title']?.toString() ?? 'Unknown Title';
            artistName = details['artist']?.toString() ?? 'Unknown Artist';
            imageUrl = details['coverArtUrl']?.toString() ?? '';

            print('Set name: $name');
            print('Set artistName: $artistName');
            print('Set imageUrl: $imageUrl');

            // If no coverArtUrl in details, try to get it from platforms
            if (imageUrl.isEmpty) {
              print('No coverArtUrl in details, trying platforms');
              final platforms =
                  widget.postData!['platforms'] as Map<String, dynamic>?;
              if (platforms != null) {
                // Try Spotify first, then Apple Music
                final spotify = platforms['spotify'] as Map<String, dynamic>?;
                final appleMusic =
                    platforms['applemusic'] as Map<String, dynamic>?;

                imageUrl = spotify?['artworkUrl']?.toString() ??
                    appleMusic?['artworkUrl']?.toString() ??
                    '';
                print('Got imageUrl from platforms: $imageUrl');
              }
            }

            des = widget.postData!['caption']?.toString();
            desUsername = widget.postData!['username']?.toString();
          });

          // Only generate palette if we have a valid image URL
          if (imageUrl.isNotEmpty) {
            print('Generating palette from imageUrl: $imageUrl');
            _generatePalette(imageUrl);
          } else {
            print('Warning: No valid image URL found for palette generation');
          }
        } else {
          print('Error: No details found in postData');
          setState(() {
            name = 'Error Loading Track';
            artistName = '';
            imageUrl = '';
          });
        }
      } catch (e, stackTrace) {
        print('Error processing track data: $e');
        print('Stack trace: $stackTrace');
        setState(() {
          name = 'Error Loading Track';
          artistName = '';
          imageUrl = '';
        });
      }
    } else {
      print('Warning: No postData provided to EntityPage');
      print('Type: ${widget.type}');
      print('TrackId: ${widget.trackId}');
    }
  }

  Future<void> _generatePalette(String imageUrl) async {
    try {
      Color color = await _trackService.getDominantColor(imageUrl);
      if (mounted) {
        setState(() {
          dominateColor = color;
        });
      }
    } catch (e) {
      print('Error generating palette: $e');
      if (mounted) {
        setState(() {
          dominateColor = Colors.blue.shade500;
        });
      }
    }
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
            dominateColor.withOpacity(0.8), // Add opacity for smoother gradient
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
                child: Image.network(imageUrl,
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
          if (des != null) desWidget(),
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
          if (!isLoggedIn) createAccWidget(),
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
              const Duration(milliseconds: 180),
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
