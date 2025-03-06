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
  String name = '';
  String artistName = '';
  String? des;
  String? desUsername;
  Color dominateColor = AppColors.appBg;
  bool isLoggedIn = false;
  String coverArtUrl = '';
  List<CollectionItem> trackList = [];
  // Selected issue for reporting
  String? _selectedIssue;
  // Text controller for "Other" option
  final TextEditingController _otherIssueController = TextEditingController();

  @override
  void dispose() {
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

        print('Set name: $name');
        print('Set artistName: $artistName');
        print('Set coverArtUrl: $coverArtUrl');

        // Parse tracks if available
        if (details.containsKey('tracks')) {
          final tracks = details['tracks'] as List<dynamic>?;
          print('Tracks data available: ${tracks?.length ?? 0} tracks found');
          if (tracks != null) {
            try {
              trackList = tracks
                  .map((track) => CollectionItem.fromJson(track))
                  .toList();
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
}
