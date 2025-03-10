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
import 'package:cassettefrontend/core/services/report_service.dart';
import 'package:intl/intl.dart';

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

  @override
  void dispose() {
    _otherIssueController.dispose();
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

              if (imageUrl.isEmpty) {
                final platforms =
                    widget.postData!['platforms'] as Map<String, dynamic>?;
                if (platforms != null) {
                  final deezer = platforms['deezer'] as Map<String, dynamic>?;
                  final spotify = platforms['spotify'] as Map<String, dynamic>?;
                  final appleMusic =
                      platforms['applemusic'] as Map<String, dynamic>?;

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
              dominateColor.withOpacity(0.8),
              dominateColor.withOpacity(0.6),
              AppColors.appBg,
            ],
            stops: const [0, 0.13, 0.3],
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
          ],
        ),
      ),
    ));
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl,
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
          Text(
            name,
            style: AppStyles.trackNameTs,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          widget.type == "artist"
              ? _buildArtistDetails()
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
          widget.postData != null
              ? AppUtils.trackSocialLinksWidget(
                  platforms: widget.postData!['platforms'])
              : AppUtils.trackSocialLinksWidget(),
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
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: genres
                .map((genre) => Chip(
                      label: Text(genre),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: TextStyle(color: AppColors.primary),
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
