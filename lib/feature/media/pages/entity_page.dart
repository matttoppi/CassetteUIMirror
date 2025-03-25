import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/post_header_toolbar.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cassettefrontend/core/services/track_service.dart';
import 'package:cassettefrontend/core/services/report_service.dart';
import 'package:cassettefrontend/core/services/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:math' show max;
import 'package:cassettefrontend/core/services/api_service.dart';
import 'package:cassettefrontend/core/env.dart';
import 'package:cassettefrontend/core/utils/web_utils.dart';
import 'package:cassettefrontend/core/services/auth_service.dart';

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
  final ReportService _reportService = ReportService();
  final AudioService _audioService = AudioService();
  String name = '';
  String artistName = '';
  String? des;
  String? desUsername;
  Color dominateColor = AppColors.appBg;
  bool isLoggedIn = false;
  String imageUrl = '';
  // Selected issue for reporting
  String? _selectedIssue;
  // Text controller for "Other" option
  final TextEditingController _otherIssueController = TextEditingController();
  // Audio preview state
  bool isPlaying = false;
  String? previewUrl;
  bool hasPreview = false;
  bool isLoadingAudio = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  // Add a property to track loading errors
  bool _loadError = false;
  // Add loading state tracking
  bool _isLoading = false;
  // Add platforms data to store from API response
  Map<String, dynamic>? platformsData;

  @override
  void dispose() {
    _otherIssueController.dispose();
    _playerStateSubscription?.cancel();
    _audioService.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('===== EntityPage initState =====');
    print(
        'EntityPage initState - type: ${widget.type}, trackId: ${widget.trackId}, postId: ${widget.postId}');
    print('EntityPage postData keys: ${widget.postData?.keys.toList()}');
    print('EntityPage postData: ${widget.postData}');

    isLoggedIn = PreferenceHelper.getBool(PreferenceHelper.isLoggedIn);

    // Check if we need to load data based on postId
    if (widget.postId != null &&
        widget.postData == null &&
        widget.trackId == null) {
      print('Loading data for postId: ${widget.postId}');
      setState(() => _isLoading = true);
      _loadPostDataByPostId(widget.postId!);
    }

    // Initialize data from postData if available
    if (widget.postData != null) {
      try {
        print('Processing postData: ${widget.postData}');
        final details = widget.postData!['details'] as Map<String, dynamic>?;
        print('Details from postData: $details');
        print('Details type: ${details?.runtimeType}');

        if (details != null) {
          setState(() {
            // For artists, use name directly from details
            if (widget.type == 'artist') {
              name = details['name']?.toString() ?? 'Unknown Artist';
              // For artists, we don't set artistName since they are the artist
              artistName = '';

              // Try to get image URL from details first
              imageUrl = details['imageUrl']?.toString() ?? '';

              // If no imageUrl in details, try platforms
              if (imageUrl.isEmpty) {
                print('No imageUrl in details, trying platforms');
                final platforms =
                    widget.postData!['platforms'] as Map<String, dynamic>?;
                if (platforms != null) {
                  // Try each platform in order of preference
                  final deezer = platforms['deezer'] as Map<String, dynamic>?;
                  final spotify = platforms['spotify'] as Map<String, dynamic>?;
                  final appleMusic =
                      platforms['applemusic'] as Map<String, dynamic>?;

                  // For artists, try artworkUrl or imageUrl from each platform
                  imageUrl = deezer?['artworkUrl']?.toString() ??
                      spotify?['imageUrl']?.toString() ??
                      appleMusic?['imageUrl']?.toString() ??
                      // Fallback to Spotify's default artist image if available
                      'https://i.scdn.co/image/${spotify?['platformSpecificId']}' ??
                      '';
                }
              }
            } else {
              // For tracks, use existing logic
              name = details['title']?.toString() ?? 'Unknown Title';
              artistName = details['artist']?.toString() ?? 'Unknown Artist';
              imageUrl = details['coverArtUrl']?.toString() ?? '';

              // Check for preview URL in platforms data
              final platforms =
                  widget.postData!['platforms'] as Map<String, dynamic>?;
              if (platforms != null) {
                final deezer = platforms['deezer'] as Map<String, dynamic>?;
                final spotify = platforms['spotify'] as Map<String, dynamic>?;
                final appleMusic =
                    platforms['applemusic'] as Map<String, dynamic>?;

                // Try to get preview URL from Spotify first (most common)
                previewUrl = spotify?['previewUrl']?.toString();

                // If no preview URL in Spotify, try Deezer's preview URL
                // Note: Deezer sometimes stores preview URL in artworkUrl field
                if (previewUrl == null || previewUrl!.isEmpty) {
                  // Check if Deezer has a previewUrl field
                  previewUrl = deezer?['previewUrl']?.toString();

                  // If not, check if Deezer's artworkUrl contains a preview URL
                  // (Deezer sometimes puts the preview URL in artworkUrl if it contains 'preview')
                  if ((previewUrl == null || previewUrl!.isEmpty) &&
                      deezer?['artworkUrl'] != null &&
                      deezer!['artworkUrl'].toString().contains('preview')) {
                    previewUrl = deezer['artworkUrl'].toString();
                  }
                }

                // Try Apple Music as last resort
                if (previewUrl == null || previewUrl!.isEmpty) {
                  previewUrl = appleMusic?['previewUrl']?.toString();
                }

                // Set hasPreview flag if we have a valid preview URL
                hasPreview = previewUrl != null && previewUrl!.isNotEmpty;

                print('Preview URL: $previewUrl');
                print('Has preview: $hasPreview');

                if (imageUrl.isEmpty) {
                  imageUrl = deezer?['artworkUrl']?.toString() ??
                      spotify?['artworkUrl']?.toString() ??
                      appleMusic?['artworkUrl']?.toString() ??
                      '';
                }
              }
            }

            print('Set name: $name');
            print('Set artistName: $artistName');
            print('Set imageUrl: $imageUrl');

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
            name = widget.type == 'artist'
                ? 'Error Loading Artist'
                : 'Error Loading Track';
            artistName = '';
            imageUrl = '';
          });
        }
      } catch (e, stackTrace) {
        print('Error processing track data: $e');
        print('Stack trace: $stackTrace');
        setState(() {
          name = widget.type == 'artist'
              ? 'Error Loading Artist'
              : 'Error Loading Track';
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

  // Toggle audio preview playback
  Future<void> _togglePlayback() async {
    if (!hasPreview || previewUrl == null || previewUrl!.isEmpty) {
      // Show a message if no preview is available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No audio preview available for this track'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      if (isPlaying) {
        // Stop playback
        setState(() {
          isPlaying = false;
        });
        await _audioService.stop();
        _playerStateSubscription?.cancel();
      } else {
        // Start loading
        setState(() {
          isLoadingAudio = true;
        });

        // Cancel any existing subscription
        _playerStateSubscription?.cancel();

        // Set up new listener for player state changes
        _playerStateSubscription =
            _audioService.player.playerStateStream.listen((state) {
          if (!mounted) return;

          // Handle loading state
          if (state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering) {
            if (mounted && !isLoadingAudio) {
              setState(() {
                isLoadingAudio = true;
              });
            }
          } else {
            // Clear loading state when not loading
            if (mounted && isLoadingAudio) {
              setState(() {
                isLoadingAudio = false;
              });
            }
          }

          // Handle playback completion
          if (state.processingState == ProcessingState.completed) {
            if (mounted && isPlaying) {
              setState(() {
                isPlaying = false;
              });
            }
          }
        });

        // Start playback
        await _audioService.playPreview(previewUrl!);

        // Update state
        if (mounted) {
          setState(() {
            isPlaying = true;
            isLoadingAudio = false;
          });
        }
      }
    } catch (e) {
      print('Error toggling playback: $e');
      if (mounted) {
        setState(() {
          isPlaying = false;
          isLoadingAudio = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing preview: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set page title based on entity type and details
    String pageTitle = 'Cassette';
    if (widget.type != null && name.isNotEmpty) {
      switch (widget.type!.toLowerCase()) {
        case 'artist':
          pageTitle = '$name | Cassette';
          break;
        case 'track':
          if (artistName.isNotEmpty) {
            pageTitle = '$name by $artistName | Cassette';
          } else {
            pageTitle = '$name | Cassette';
          }
          break;
      }
      WebUtils.setDocumentTitle(pageTitle);
    }

    // Check if we're on a desktop-sized screen (width > 900px)
    final isDesktop = MediaQuery.of(context).size.width > 900;

    // Show loading skeleton while data is loading
    if (_isLoading) {
      return _buildLoadingSkeleton(isDesktop);
    }

    // Show retry widget if there was an error loading data
    if (_loadError && widget.postId != null) {
      return AppScaffold(
        body: _buildRetryWidget(),
      );
    }

    return AppScaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              dominateColor,
              dominateColor.withOpacity(0.85),
              dominateColor.withOpacity(0.6),
              dominateColor.withOpacity(0.4),
              dominateColor.withOpacity(0.25),
              dominateColor.withOpacity(0.15),
              AppColors.appBg.withOpacity(0.3),
              AppColors.appBg,
            ],
            // Extend gradient much further down the page
            stops: const [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PostHeaderToolbar(
                  isLoggedIn: isLoggedIn,
                  postId: widget.postId,
                  pageType: widget.type,
                ),
              ),
              const SizedBox(height: 24),
              // Use different layout based on screen size
              if (isDesktop) desktopBody() else body(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Desktop layout with side-by-side content
  Widget desktopBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Cover art and basic info (fixed position)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.type == "artist" ? "Artist" : "Track",
                    style: AppStyles.trackTrackTitleTs),
                const SizedBox(height: 24),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          // Fixed size for desktop
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Only show play button for tracks, not artists
                    if (widget.type == "track")
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: GestureDetector(
                          onTap: _togglePlayback,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background circle
                              Image.asset(
                                icPlay,
                                height: 56,
                              ),
                              // Play/pause icon overlay or loading indicator
                              if (hasPreview)
                                isLoadingAudio
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Icon(
                                        isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: AppStyles.trackNameTs.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                widget.type == "artist"
                    ? _buildArtistDetails()
                    : Column(
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            artistName,
                            style: AppStyles.trackArtistNameTs.copyWith(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
              ],
            ),
          ),
          // Right side - Links, description, and buttons (scrollable)
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate the height of the container based on viewport height
                final viewportHeight = MediaQuery.of(context).size.height;
                // Use 80% of viewport height or a minimum of 600px
                final containerHeight = max(viewportHeight * 0.8, 600.0);

                return SizedBox(
                  height: containerHeight,
                  child: ShaderMask(
                    // Apply a shader mask for the fade effect
                    shaderCallback: (Rect rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.white.withOpacity(0.0)
                        ],
                        // The stops define where the gradient transitions happen
                        // The last 10% of the height will fade out
                        stops: const [0.0, 0.85, 0.9, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      child: Padding(
                        // Add extra padding at the bottom to ensure content doesn't get cut off by the fade
                        padding: const EdgeInsets.only(
                            left: 40.0, top: 60.0, bottom: 100.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (des != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 36),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.appBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        AppColors.textPrimary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: AppUtils.cmDesBox(
                                    userName: desUsername, des: des),
                              ),
                            const Divider(
                                height: 2,
                                thickness: 1,
                                color: AppColors.textPrimary,
                                endIndent: 0,
                                indent: 0),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.textPrimary.withOpacity(0.1),
                                  width: 1,
                                ),
                                // Add glass effect
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.textPrimary.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Transform.scale(
                                scale: 1.15,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: widget.postData != null
                                      ? () {
                                          // Add debugging for platforms data
                                          print(
                                              'Rendering social links with platforms data:');
                                          print('PostData: ${widget.postData}');
                                          if (widget.postData!
                                              .containsKey('platforms')) {
                                            print(
                                                'Platforms found in postData: ${widget.postData!['platforms']}');

                                            // Check if platforms data contains the expected structure
                                            final platforms =
                                                widget.postData!['platforms']
                                                    as Map<String, dynamic>?;
                                            if (platforms != null) {
                                              platforms.forEach((key, value) {
                                                print('Platform: $key');
                                                if (value
                                                    is Map<String, dynamic>) {
                                                  print('URL: ${value['url']}');
                                                }
                                              });
                                            }

                                            // Use platforms from postData
                                            return AppUtils
                                                .trackSocialLinksWidget(
                                                    platforms: widget.postData![
                                                        'platforms']);
                                          } else {
                                            print(
                                                'No platforms key found in postData!');

                                            // Fall back to platformsData stored in state
                                            if (platformsData != null) {
                                              print(
                                                  'Using platformsData from state: $platformsData');
                                              return AppUtils
                                                  .trackSocialLinksWidget(
                                                      platforms: platformsData);
                                            }

                                            return AppUtils
                                                .trackSocialLinksWidget();
                                          }
                                        }()
                                      : platformsData != null
                                          ? () {
                                              print(
                                                  'Using platforms from state since no postData (desktop)');
                                              return AppUtils
                                                  .trackSocialLinksWidget(
                                                      platforms: platformsData);
                                            }()
                                          : AppUtils.trackSocialLinksWidget(),
                                ),
                              ),
                            ),
                            if (!isLoggedIn)
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: createAccWidget(),
                              ),
                            _reportProblemButton(),
                            // Add extra padding at the bottom for better scrolling experience
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(widget.type == "artist" ? "Artist" : "Track",
              style: AppStyles.trackTrackTitleTs),
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: MediaQuery.of(context).size.width / 2.3,
                    height: MediaQuery.of(context).size.width / 2.3,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Only show play button for tracks, not artists
              if (widget.type == "track")
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: _togglePlayback,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        Image.asset(
                          icPlay,
                          height: 56,
                        ),
                        // Play/pause icon overlay or loading indicator
                        if (hasPreview)
                          isLoadingAudio
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28,
                                ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: AppStyles.trackNameTs.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          widget.type == "artist"
              ? _buildArtistDetails()
              : Column(
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      artistName,
                      style: AppStyles.trackArtistNameTs.copyWith(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
          if (des != null) desWidget(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
                height: 2,
                thickness: 1,
                color: AppColors.textPrimary,
                endIndent: 0,
                indent: 0),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.textPrimary.withOpacity(0.1),
                width: 1,
              ),
              // Add glass effect
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Transform.scale(
              scale: 1.15,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: widget.postData != null
                    ? () {
                        // Add debugging for platforms data
                        print('Rendering social links with platforms data:');
                        print('PostData: ${widget.postData}');
                        if (widget.postData!.containsKey('platforms')) {
                          print(
                              'Platforms found in postData: ${widget.postData!['platforms']}');

                          // Check if platforms data contains the expected structure
                          final platforms = widget.postData!['platforms']
                              as Map<String, dynamic>?;
                          if (platforms != null) {
                            platforms.forEach((key, value) {
                              print('Platform: $key');
                              if (value is Map<String, dynamic>) {
                                print('URL: ${value['url']}');
                              }
                            });
                          }
                          return AppUtils.trackSocialLinksWidget(
                              platforms: widget.postData!['platforms']);
                        } else {
                          print('No platforms key found in postData!');
                          // Use platforms data from state if available
                          if (platformsData != null) {
                            print('Using platforms from state');
                            return AppUtils.trackSocialLinksWidget(
                                platforms: platformsData);
                          }
                          return AppUtils.trackSocialLinksWidget();
                        }
                      }()
                    : platformsData != null
                        ? () {
                            print(
                                'Using platforms from state since no postData');
                            return AppUtils.trackSocialLinksWidget(
                                platforms: platformsData);
                          }()
                        : AppUtils.trackSocialLinksWidget(),
              ),
            ),
          ),
          if (!isLoggedIn) createAccWidget(),
          _reportProblemButton(),
        ],
      ),
    );
  }

  Widget _buildArtistDetails() {
    final details = widget.postData?['details'] as Map<String, dynamic>?;
    if (details == null) return const SizedBox();

    final genres = (details['genres'] as List<dynamic>?)?.cast<String>() ?? [];

    return Column(
      children: [
        if (genres.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: genres
                .map((genre) => Chip(
                      label: Text(
                        genre,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  desWidget() {
    return Column(
      children: [
        const SizedBox(height: 36),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.appBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: AppUtils.cmDesBox(userName: desUsername, des: des),
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  createAccWidget() {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: des == null ? 12 : 24, horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate button width based on container constraints
          // Account for the animation offset (initialPos = 6) on both sides
          final buttonWidth =
              constraints.maxWidth - 12; // Subtract 2 * initialPos
          return Column(
            mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space
            children: [
              // Center the button to ensure it's not clipped on either side
              Center(
                child: AnimatedPrimaryButton(
                  text: "Create Your Free Account!",
                  onTap: () {
                    Future.delayed(
                      const Duration(milliseconds: 180),
                      () => context.go('/signup'),
                    );
                  },
                  height: 46,
                  width: buttonWidth,
                  radius: 10,
                  initialPos: 6,
                  topBorderWidth: 3,
                  bottomBorderWidth: 3,
                  colorTop: AppColors.animatedBtnColorConvertTop,
                  textStyle: AppStyles.animatedBtnFreeAccTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  borderColorTop: AppColors.animatedBtnColorConvertTop,
                  colorBottom: AppColors.animatedBtnColorConvertBottom,
                  borderColorBottom:
                      AppColors.animatedBtnColorConvertBottomBorder,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Save this page to share again? Showcase your\nfavorite tunes with your Cassette Profile!",
                style: AppStyles.trackBelowBtnStringTs.copyWith(
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  // Show report problem dialog with radio buttons for issue selection
  void _showReportDialog() {
    // Reset the text controller when opening the dialog
    _otherIssueController.clear();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report a Problem'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please select the issue you\'re experiencing:'),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text('Conversion Links'),
                    value: 'Conversion Links',
                    groupValue: _selectedIssue,
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedIssue = value;
                            });
                          },
                  ),
                  RadioListTile<String>(
                    title: const Text('Cover Art'),
                    value: 'Cover Art',
                    groupValue: _selectedIssue,
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedIssue = value;
                            });
                          },
                  ),
                  RadioListTile<String>(
                    title: const Text('Music Element Title or Artist'),
                    value: 'Music Element Title or Artist',
                    groupValue: _selectedIssue,
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedIssue = value;
                            });
                          },
                  ),
                  RadioListTile<String>(
                    title: const Text('Other'),
                    value: 'Other',
                    groupValue: _selectedIssue,
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedIssue = value;
                            });
                          },
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _selectedIssue == 'Other' ? 80 : 0,
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: _selectedIssue == 'Other' ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _otherIssueController,
                          decoration: const InputDecoration(
                            hintText: 'Please describe the issue...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          enabled: _selectedIssue == 'Other' && !isSubmitting,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Cancel'),
                ),
                if (isSubmitting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else
                  TextButton(
                    onPressed: _selectedIssue == null
                        ? null
                        : () async {
                            if (_selectedIssue == 'Other' &&
                                _otherIssueController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please describe the issue'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              isSubmitting = true;
                            });

                            try {
                              await _reportService.submitReport(
                                postId: widget.postId ?? '',
                                issueType: _selectedIssue!,
                                elementType: widget.type ?? 'track',
                                elementId: widget.trackId ?? '',
                                description: _selectedIssue == 'Other'
                                    ? _otherIssueController.text
                                    : null,
                                apiResponse: widget.postData,
                                originalLink:
                                    widget.postData?['originalLink'] as String?,
                              );

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Thank you for your report. We\'ll look into it.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                isSubmitting = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error submitting report: $e'),
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
                            }
                          },
                    child: const Text('Submit'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Report problem button widget
  Widget _reportProblemButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextButton.icon(
        onPressed: _showReportDialog,
        icon:
            const Icon(Icons.report_problem_outlined, color: AppColors.primary),
        label: const Text(
          'Report a Problem',
          style:
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: AppColors.primary.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // Add new method to load data by postId if necessary
  Future<void> _loadPostDataByPostId(String postId) async {
    try {
      print('Loading data by postId: $postId');

      setState(() {
        // Show loading state
        _isLoading = true;
        name = 'Loading...';
        artistName = '';
        imageUrl = '';
        // Set interim page title while loading
        WebUtils.setDocumentTitle('Loading... | Cassette');
      });

      final authService = AuthService();
      final apiService = ApiService(authService);
      final data = await apiService.fetchPostById(postId);

      // Add detailed debug info for the API response
      print('✅ API Response received for postId: $postId');
      print('✅ API Response data keys: ${data.keys.toList()}');

      // Specifically check for platforms data
      if (data.containsKey('platforms')) {
        print('✅ Platforms data found in API response:');
        print(data['platforms']);

        // Examine each platform data structure
        final platforms = data['platforms'] as Map<String, dynamic>?;
        if (platforms != null) {
          platforms.forEach((platform, platformData) {
            print('Platform: $platform');
            if (platformData is Map<String, dynamic>) {
              final url = platformData['url'];
              print('URL: $url (${url.runtimeType})');
            } else {
              print('Platform data is not a Map: ${platformData.runtimeType}');
            }
          });
        }
      } else {
        print('❌ No platforms data found in API response!');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Determine element type if not already set
          String? elementType = widget.type;
          if (elementType == null && data['elementType'] != null) {
            elementType = (data['elementType'] as String).toLowerCase();
            print('Determined element type from API data: $elementType');
          }

          // Store platforms data in state
          if (data.containsKey('platforms')) {
            platformsData = data['platforms'] as Map<String, dynamic>;
            print('✅ Stored platforms data in state: $platformsData');
          }

          // Process the data similar to how we process postData in initState
          if (data['details'] != null) {
            // Update entity data based on retrieved post data
            if (elementType == 'artist') {
              name = data['details']['name']?.toString() ?? 'Unknown Artist';
              artistName = '';

              // Update page title for artist
              WebUtils.setDocumentTitle('$name | Cassette');
            } else {
              name = data['details']['title']?.toString() ?? 'Unknown Title';
              artistName =
                  data['details']['artist']?.toString() ?? 'Unknown Artist';

              // Update page title for track
              WebUtils.setDocumentTitle('$name by $artistName | Cassette');
            }

            // Get image URL
            imageUrl = data['details']['coverArtUrl']?.toString() ??
                data['details']['imageUrl']?.toString() ??
                '';

            // Get preview URL if available
            if (data['platforms'] != null) {
              final platforms = data['platforms'] as Map<String, dynamic>;
              final spotify = platforms['spotify'] as Map<String, dynamic>?;
              final deezer = platforms['deezer'] as Map<String, dynamic>?;
              final appleMusic =
                  platforms['applemusic'] as Map<String, dynamic>?;

              previewUrl = spotify?['previewUrl']?.toString() ??
                  deezer?['previewUrl']?.toString() ??
                  appleMusic?['previewUrl']?.toString();

              hasPreview = previewUrl != null && previewUrl!.isNotEmpty;

              print('Preview URL: $previewUrl');
              print('Has preview: $hasPreview');

              // Fallback for image URL
              if (imageUrl.isEmpty) {
                imageUrl = spotify?['artworkUrl']?.toString() ??
                    deezer?['artworkUrl']?.toString() ??
                    appleMusic?['artworkUrl']?.toString() ??
                    '';
              }
            }

            // Get description if available
            des = data['caption']?.toString();
            desUsername = data['username']?.toString();

            // Generate color palette if we have an image
            if (imageUrl.isNotEmpty) {
              _generatePalette(imageUrl);
            }
          }
        });
      }
    } catch (e) {
      print('Error loading data for postId $postId: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Show error state with retry option
          name = 'Content Not Found';
          artistName = 'This link may have been removed or the link is invalid';
          imageUrl = '';
          _loadError = true;

          // Update page title for error state
          WebUtils.setDocumentTitle('Content Not Found | Cassette');
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load content: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _loadPostDataByPostId(postId),
            ),
          ),
        );
      }
    }
  }

  // Add a retry widget that can be shown when loading fails
  Widget _buildRetryWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Unable to load content',
            style: AppStyles.trackNameTs.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This content may have been removed or the link is invalid',
            style: AppStyles.trackArtistNameTs,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _loadPostDataByPostId(widget.postId!),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Add/update sharing functionality to use postId in URL
  void _shareEntityPage() {
    if (widget.postId == null) return;

    // Get the base URL from the current page when possible
    final baseUrl =
        Uri.base.toString().isNotEmpty ? Uri.base.origin : Env.appDomain;

    String shareUrl = '';
    if (widget.type == 'artist') {
      shareUrl = '$baseUrl/artist/${widget.postId}';
    } else {
      shareUrl = '$baseUrl/track/${widget.postId}';
    }

    print('Sharing URL: $shareUrl'); // Add debugging output
    AppUtils.onShare(context, shareUrl);
  }

  // Add a loading skeleton widget
  Widget _buildLoadingSkeleton(bool isDesktop) {
    return AppScaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade300,
              Colors.grey.shade200,
              Colors.grey.shade100,
              AppColors.appBg.withOpacity(0.8),
              AppColors.appBg,
            ],
            stops: const [0.0, 0.2, 0.4, 0.6, 0.8],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PostHeaderToolbar(
                  isLoggedIn: isLoggedIn,
                  postId: widget.postId,
                  pageType: widget.type,
                ),
              ),
              const SizedBox(height: 50),
              if (isDesktop)
                _buildDesktopLoadingSkeleton()
              else
                _buildMobileLoadingSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(widget.type == "artist" ? "Artist" : "Track",
              style: AppStyles.trackTrackTitleTs),
          const SizedBox(height: 24),
          // Shimmer effect for image
          Container(
            width: MediaQuery.of(context).size.width / 2.3,
            height: MediaQuery.of(context).size.width / 2.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          // Shimmer effect for title
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 12),
          // Shimmer effect for artist
          Container(
            width: 150,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          // Shimmer effect for streaming links
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Cover art and basic info
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.type == "artist" ? "Artist" : "Track",
                    style: AppStyles.trackTrackTitleTs),
                const SizedBox(height: 24),
                // Shimmer effect for image
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 20),
                // Shimmer effect for title
                Container(
                  width: 200,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 12),
                // Shimmer effect for artist
                Container(
                  width: 150,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
          // Right side with spacing and shimmer effect for links
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer effect for description
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Shimmer effect for streaming links
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
