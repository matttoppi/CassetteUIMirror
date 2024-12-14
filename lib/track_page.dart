import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/constants/app_constants.dart';
import 'core/services/track_service.dart';
import 'core/styles/app_styles.dart';
import 'package:go_router/go_router.dart';
class TrackPage extends StatefulWidget {
  final String trackId;

  const TrackPage({super.key, required this.trackId});

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late Future<Map<String, dynamic>> _trackDataFuture;
  final TrackService _trackService = TrackService();

  @override
  void initState() {
    super.initState();
    _trackDataFuture = _trackService.getTrackData(widget.trackId);
  }

  Future<Map<String, dynamic>> _loadTrackData() async {
    return await _trackService.getTrackData(widget.trackId);
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadTrackData(); // Retry loading the data
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final trackData = snapshot.data!;
          final dominantColor = Color(trackData['dominantColor']);

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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          dominantColor,
                          dominantColor.withOpacity(0.5),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                // Cassette logo and Track identifier
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.03,
                  child: GestureDetector(
                    onTap: () => context.go('/'),
                    child: Image.asset(
                      'lib/assets/images/cassette_name.png',
                      width: MediaQuery.of(context).size.width * AppSizes.cassetteNameWidth,
                      height: MediaQuery.of(context).size.height * AppSizes.cassetteNameHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Album cover
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.175,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * AppSizes.albumCoverSize,
                      height: MediaQuery.of(context).size.width * AppSizes.albumCoverSize,
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
                  top: MediaQuery.of(context).size.height * 0.45, 
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
                // Album name
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.182,
                  top: MediaQuery.of(context).size.height * 0.535, 
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
                  top: MediaQuery.of(context).size.height * 0.560, 
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.636,
                    child: Text(
                      trackData['genres'].join(', '),
                      textAlign: TextAlign.center,
                      style: AppStyles.genresStyle,
                    ),
                  ),
                ),
                // Updated Create Free Account button
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.248,
                  top: MediaQuery.of(context).size.height * 0.6125, 
                  child: GestureDetector(
                    onTap: () => context.push('/signup'),
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
          onTap: () {
            final url = data['url'];
            launchUrl(Uri.parse(url));  // Use url_launcher to open the link
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
