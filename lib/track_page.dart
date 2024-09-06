import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';
import 'services/track_service.dart';

class TrackPage extends StatefulWidget {
  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late Future<Map<String, dynamic>> _trackDataFuture;

  @override
  void initState() {
    super.initState();
    _trackDataFuture = TrackService().getTrackData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _trackDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final trackData = snapshot.data!;

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            clipBehavior: Clip.antiAlias,
            decoration: AppStyles.mainContainerDecoration,
            child: Stack(
              children: [
                // Gradient background
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.55,
                    decoration: AppStyles.gradientBackgroundDecoration,
                  ),
                ),
                // Cassette logo
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.05,
                  child: Center(
                    child: Image.asset(
                      'lib/assets/images/cassette_name.png',
                      width: MediaQuery.of(context).size.width * 0.4,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Track text
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.12,
                  child: const Center(
                    child: Text(
                      AppStrings.trackText,
                      textAlign: TextAlign.center,
                      style: AppStyles.trackTextStyle,
                    ),
                  ),
                ),
                // Album cover
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.17,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.46,
                      height: MediaQuery.of(context).size.width * 0.46,
                      decoration: AppStyles.albumCoverDecoration,
                      child: Image.network(
                        trackData['platforms']['spotify']['art_url'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Song title and artist
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.182,
                  top: MediaQuery.of(context).size.height * 0.452,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.636,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${trackData['track']['name']}\n',
                            style: AppStyles.songTitleStyle,
                          ),
                          TextSpan(
                            text: trackData['artist']['name'][0],
                            style: AppStyles.artistNameStyle,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Create Free Account button
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.248,
                  top: MediaQuery.of(context).size.height * 0.591,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.533,
                    height: MediaQuery.of(context).size.height * 0.058,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Center(
                      child: Text(
                        AppStrings.createFreeAccountText,
                        textAlign: TextAlign.center,
                        style: AppStyles.createFreeAccountStyle,
                      ),
                    ),
                  ),
                ),
                // Platform icons
                ..._buildPlatformIcons(trackData['platforms'], context),
                // Divider
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.159,
                  top: MediaQuery.of(context).size.height * 0.701,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.664,
                    decoration: AppStyles.dividerDecoration,
                  ),
                ),
                // Album name
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.182,
                  top: MediaQuery.of(context).size.height * 0.52,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.636,
                    child: Text(
                      trackData['album']['name'],
                      textAlign: TextAlign.center,
                      style: AppStyles.albumNameStyle,
                    ),
                  ),
                ),
                // Genres
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.182,
                  top: MediaQuery.of(context).size.height * 0.55,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.636,
                    child: Text(
                      trackData['genres'].join(', '),
                      textAlign: TextAlign.center,
                      style: AppStyles.genresStyle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPlatformIcons(Map<String, dynamic> platforms, BuildContext context) {
    final platformIcons = {
      'spotify': Icons.music_note,
      'apple_music': Icons.apple,
      'deezer': Icons.headphones,
      'youtube_music': Icons.play_circle_filled,
      'tidal': Icons.waves,
    };

    return platforms.entries.map((entry) {
      final platform = entry.key;
      final data = entry.value;
      final index = platforms.keys.toList().indexOf(platform);

      return Positioned(
        left: MediaQuery.of(context).size.width * (0.14 + 0.15 * index),
        top: MediaQuery.of(context).size.height * 0.745,
        child: GestureDetector(
          onTap: () async {
            final url = data['url'];
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $url')),
              );
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: AppStyles.platformIconDecoration,
            child: Icon(
              platformIcons[platform],
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }).toList();
  }
}
