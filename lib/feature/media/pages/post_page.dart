import 'package:flutter/material.dart';
import 'package:cassettefrontend/feature/media/pages/entity_page.dart';
import 'package:cassettefrontend/feature/media/pages/collection_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/scheduler.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/post_header_toolbar.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/utils/web_utils.dart';

class PostPage extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostPage({
    super.key,
    required this.postData,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Defer navigation until after the first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _processAndNavigate();
    });
  }

  void _processAndNavigate() {
    if (_isNavigating) return;

    try {
      // Validate required fields
      final elementType = widget.postData['elementType'] as String?;
      final musicElementId = widget.postData['musicElementId'] as String?;
      final postId = widget.postData['postId'] as String?;

      if (elementType == null || postId == null) {
        // Don't navigate if missing critical data
        return;
      }

      setState(() {
        _isNavigating = true;
      });

      // Navigate based on element type
      switch (elementType.toLowerCase()) {
        case 'track':
          print('Navigating to track page with postId: $postId');
          context.go('/track/$postId', extra: widget.postData);
          break;
        case 'artist':
          print('Navigating to artist page with postId: $postId');
          context.go('/artist/$postId', extra: widget.postData);
          break;
        case 'album':
          print('Navigating to album page with postId: $postId');
          context.go('/album/$postId', extra: widget.postData);
          break;
        case 'playlist':
          print('Navigating to playlist page with postId: $postId');
          context.go('/playlist/$postId', extra: widget.postData);
          break;
        default:
          print('ERROR: Unknown element type: $elementType');
          break;
      }
    } catch (e) {
      print('Error in navigation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('===== PostPage BUILD =====');
    print('PostPage received data type: ${widget.postData.runtimeType}');
    print('PostPage received data keys: ${widget.postData.keys.toList()}');
    print('PostPage received data: ${widget.postData}');

    try {
      // Validate required fields
      final elementType = widget.postData['elementType'] as String?;
      final musicElementId = widget.postData['musicElementId'] as String?;
      final postId = widget.postData['postId'] as String?;
      final details = widget.postData['details'] as Map<String, dynamic>?;

      // Set page title based on post type and details
      String pageTitle = 'Cassette';
      if (details != null && elementType != null) {
        switch (elementType.toLowerCase()) {
          case 'track':
            if (details['title'] != null && details['artist'] != null) {
              pageTitle =
                  '${details['title']} - ${details['artist']} | Cassette';
            }
            break;
          case 'artist':
            if (details['name'] != null) {
              pageTitle = '${details['name']} | Cassette';
            }
            break;
          case 'album':
            if (details['title'] != null && details['artist'] != null) {
              pageTitle =
                  '${details['title']} - ${details['artist']} | Cassette';
            }
            break;
          case 'playlist':
            if (details['title'] != null) {
              pageTitle = '${details['title']} | Cassette';
            }
            break;
        }
      }
      // Set the document title
      WebUtils.setDocumentTitle(pageTitle);

      print('Extracted values:');
      print('- elementType: $elementType (${elementType.runtimeType})');
      print(
          '- musicElementId: $musicElementId (${musicElementId?.runtimeType})');
      print('- postId: $postId (${postId?.runtimeType})');
      print('- details: ${details?.runtimeType}');

      if (details != null) {
        print('- details keys: ${details.keys.toList()}');
        // Check for either title/artist (tracks) or name (artists)
        final hasTrackInfo =
            details['title'] != null || details['artist'] != null;
        final hasArtistInfo = details['name'] != null;
        print('- details.name: ${details['name']}');
        print('- details.title: ${details['title']}');
        print('- details.artist: ${details['artist']}');
        print('- has track info: $hasTrackInfo');
        print('- has artist info: $hasArtistInfo');
      }

      // Check for missing fields and provide specific error message
      List<String> missingFields = [];
      if (elementType == null) missingFields.add('elementType');
      if (musicElementId == null) missingFields.add('musicElementId');
      if (postId == null) missingFields.add('postId');
      if (details == null) missingFields.add('details');

      // For artists, we expect 'name' in details
      // For tracks, we expect 'title' and 'artist' in details
      if (details != null && elementType != null) {
        if (elementType.toLowerCase() == 'artist' && details['name'] == null) {
          missingFields.add('details.name');
        } else if (elementType.toLowerCase() == 'track') {
          if (details['title'] == null) missingFields.add('details.title');
          if (details['artist'] == null) missingFields.add('details.artist');
        }
      }

      if (missingFields.isNotEmpty) {
        final errorMessage =
            'Missing required fields: ${missingFields.join(', ')}';
        print('ERROR: $errorMessage');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: Invalid post data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // Show an enhanced loading UI while we prepare to navigate
      return _buildLoadingUI(context, elementType);
    } catch (e, stackTrace) {
      print('ERROR in PostPage: $e');
      print('Stack trace: $stackTrace');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error processing data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  // Enhanced loading UI that matches the styling of other pages
  Widget _buildLoadingUI(BuildContext context, String? elementType) {
    // Check if we're on a desktop-sized screen (width > 900px)
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isLoggedIn = PreferenceHelper.getBool(PreferenceHelper.isLoggedIn);

    // Get a nice loading title based on element type
    String loadingTitle = 'Loading';
    if (elementType != null) {
      switch (elementType.toLowerCase()) {
        case 'track':
          loadingTitle = 'Loading Track';
          break;
        case 'artist':
          loadingTitle = 'Loading Artist';
          break;
        case 'album':
          loadingTitle = 'Loading Album';
          break;
        case 'playlist':
          loadingTitle = 'Loading Playlist';
          break;
      }
    }

    // Get postId from postData if available
    final postId = widget.postData['postId'] as String?;

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
                  postId: postId,
                  pageType: elementType?.toLowerCase(),
                ),
              ),
              const SizedBox(height: 50),
              if (isDesktop)
                _buildDesktopLoadingSkeleton(loadingTitle)
              else
                _buildMobileLoadingSkeleton(loadingTitle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLoadingSkeleton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(title, style: AppStyles.trackTrackTitleTs),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
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
        ],
      ),
    );
  }

  Widget _buildDesktopLoadingSkeleton(String title) {
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
                Text(title, style: AppStyles.trackTrackTitleTs),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
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
              ],
            ),
          ),
          // Right side with spacing
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          ),
        ],
      ),
    );
  }
}
