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
import 'package:cassettefrontend/core/services/report_service.dart';
import 'package:cassettefrontend/core/services/audio_service.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;
import 'package:intl/intl.dart';
import 'package:cassettefrontend/core/services/track_service.dart';

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
  final ReportService _reportService = ReportService();
  final AudioService _audioService = AudioService();
  String name = '';
  String artistName = '';
  String? des;
  String? desUsername;
  Color dominateColor = AppColors.appBg;
  bool isLoggedIn = false;
  String coverArtUrl = '';
  List<CollectionItem> trackList = [];
  // Album-specific fields
  String? releaseDate;
  int? trackCount;
  // Selected issue for reporting
  String? _selectedIssue;
  // Text controller for "Other" option
  final TextEditingController _otherIssueController = TextEditingController();
  int? _playingIndex;

  @override
  void dispose() {
    _audioService.dispose();
    _otherIssueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('===== CollectionPage initState =====');
    print(
        'CollectionPage type: ${widget.type}, id: ${widget.trackId}, postId: ${widget.postId}');
    print('CollectionPage postData: ${widget.postData}');
    print('CollectionPage postData keys: ${widget.postData?.keys.toList()}');

    isLoggedIn = PreferenceHelper.getBool(PreferenceHelper.isLoggedIn);

    // Initialize data from postData if available
    if (widget.postData != null) {
      try {
        final details = widget.postData!['details'] as Map<String, dynamic>?;
        print('CollectionPage details: $details');
        print('CollectionPage details keys: ${details?.keys.toList()}');

        if (details == null) {
          print('ERROR: details field is null or not a map');
          setState(() {
            name =
                'Error Loading ${widget.type == 'album' ? 'Album' : 'Playlist'}';
            artistName = '';
            coverArtUrl = '';
          });
          return;
        }

        name = details['title'] as String? ?? 'Untitled';
        artistName = details['artist'] as String? ?? 'Unknown Artist';
        coverArtUrl = details['coverArtUrl'] as String? ?? '';
        des = widget.postData!['caption'] as String?;
        desUsername = widget.postData!['username'] as String?;

        // Parse album-specific details
        if (widget.type == 'album') {
          releaseDate = details['releaseDate'] as String?;
          trackCount = details['trackCount'] as int?;
        }

        print('Set name: $name');
        print('Set artistName: $artistName');
        print('Set coverArtUrl: $coverArtUrl');

        // Parse tracks if available
        if (details.containsKey('tracks')) {
          final tracks = details['tracks'] as List<dynamic>?;
          print('Tracks data available: ${tracks?.length ?? 0} tracks found');
          if (tracks != null) {
            try {
              trackList = tracks.map((track) {
                // Handle both simple and detailed track formats
                if (track is Map<String, dynamic>) {
                  return CollectionItem(
                    title: track['title'] as String? ?? 'Unknown Title',
                    artist: track['artists']?.first as String? ??
                        track['artist'] as String? ??
                        'Unknown Artist',
                    coverArtUrl: track['coverArtUrl'] as String? ?? '',
                    duration: track['duration'] as String?,
                    trackNumber: track['trackNumber'] as int?,
                    previewUrl: track['previewUrl'] as String?,
                  );
                }
                return CollectionItem.fromJson(track);
              }).toList();
              print('Successfully parsed ${trackList.length} tracks');
            } catch (e) {
              print('ERROR parsing tracks: $e');
            }
          }
        } else {
          print('No tracks data available in details');
        }

        // Generate palette from cover art
        if (coverArtUrl.isNotEmpty) {
          print('Generating palette from coverArtUrl: $coverArtUrl');
          _generatePalette(coverArtUrl);
        } else {
          print('No cover art URL available for palette generation');

          // Try to get coverArtUrl from platforms as fallback
          final platforms =
              widget.postData!['platforms'] as Map<String, dynamic>?;
          if (platforms != null) {
            print('Attempting to get cover art from platforms data');
            for (final platform in platforms.values) {
              if (platform is Map<String, dynamic> &&
                  platform.containsKey('artworkUrl') &&
                  platform['artworkUrl'] != null) {
                coverArtUrl = platform['artworkUrl'];
                print('Found cover art in platform data: $coverArtUrl');
                _generatePalette(coverArtUrl);
                break;
              }
            }
          }
        }
      } catch (e, stackTrace) {
        print('ERROR in CollectionPage initState: $e');
        print('Stack trace: $stackTrace');
        setState(() {
          name =
              'Error Loading ${widget.type == 'album' ? 'Album' : 'Playlist'}';
          artistName = '';
          coverArtUrl = '';
        });
      }
    } else {
      print('WARNING: No postData provided to CollectionPage');
    }
  }

  Future<void> _generatePalette(String imageUrl) async {
    try {
      final TrackService trackService = TrackService();
      Color color = await trackService.getDominantColor(imageUrl);
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
        body: SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              dominateColor.withOpacity(1),
              dominateColor.withOpacity(0.4),
              AppColors.appBg,
            ],
            stops: const [0, 0.11, 0.3],
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(coverArtUrl,
                          width: MediaQuery.of(context).size.width / 2.5,
                          height: MediaQuery.of(context).size.width / 2.5,
                          fit: BoxFit.cover),
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
          Text(
            artistName,
            style: AppStyles.trackArtistNameTs,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (widget.type == 'album' &&
              (releaseDate != null || trackCount != null))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (releaseDate != null)
                    Text(
                      DateFormat('MMMM d, y')
                          .format(DateTime.parse(releaseDate!)),
                      style: AppStyles.trackArtistNameTs.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  if (releaseDate != null && trackCount != null)
                    Text(
                      ' • ',
                      style: AppStyles.trackArtistNameTs.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  if (trackCount != null)
                    Text(
                      '$trackCount tracks',
                      style: AppStyles.trackArtistNameTs.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
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
          // Add report problem button
          _reportProblemButton(),
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trackList.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.5,
        indent: 70,
        endIndent: 16,
        color: AppColors.textPrimary,
      ),
      itemBuilder: (context, index) {
        final track = trackList[index];
        final hasPreview =
            track.previewUrl != null && track.previewUrl!.isNotEmpty;
        final isPlaying = _playingIndex == index;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            dense: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Text(
              track.title,
              style: AppStyles.trackNameTs.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                track.artist,
                style: AppStyles.trackArtistNameTs.copyWith(
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            leading: SizedBox(
              width: 50,
              child: widget.type == 'album' && track.trackNumber != null
                  ? Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasPreview
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.textPrimary.withOpacity(0.1),
                      ),
                      child: Text(
                        track.trackNumber.toString(),
                        style: AppStyles.trackTrackTitleTs.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: hasPreview
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        track.coverArtUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.music_note,
                              color: AppColors.textPrimary.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            trailing: Container(
              width: 80,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (track.duration != null)
                    Text(
                      track.duration!,
                      style: AppStyles.trackArtistNameTs.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (hasPreview)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            onTap: () {
              if (hasPreview) {
                _handlePreviewPlayback(index, track.previewUrl!);
              }
            },
          ),
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
                                elementType: widget.type ?? 'album',
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
                                    backgroundColor: Colors.red,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton.icon(
        onPressed: _showReportDialog,
        icon: const Icon(Icons.report_problem_outlined, color: Colors.red),
        label: const Text(
          'Report a Problem',
          style: TextStyle(color: Colors.red),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: Colors.red.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePreviewPlayback(int index, String previewUrl) async {
    try {
      print('Attempting to play preview: $previewUrl');

      if (_playingIndex == index) {
        // Stop if the same track is playing
        print('Stopping current track');
        await _audioService.stop();
        setState(() => _playingIndex = null);
      } else {
        // Play the new track
        print('Playing new track at index $index');
        setState(() => _playingIndex = index);

        // Make sure URL is valid
        if (!previewUrl.startsWith('http')) {
          print('Invalid URL format: $previewUrl');
          throw Exception('Invalid preview URL format');
        }

        await _audioService.playPreview(previewUrl);
        print('Preview playback started successfully');

        // Reset state when playback completes
        _audioService.player.playerStateStream.listen((state) {
          print('Player state changed: ${state.processingState}');
          if (state.processingState == ProcessingState.completed) {
            if (mounted) {
              print('Playback completed, resetting state');
              setState(() => _playingIndex = null);
            }
          }
        });
      }
    } catch (e) {
      print('Error playing preview: $e');
      if (mounted) {
        setState(() => _playingIndex = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play preview: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
