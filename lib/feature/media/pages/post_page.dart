import 'package:flutter/material.dart';
import 'package:cassettefrontend/feature/media/pages/entity_page.dart';
import 'package:cassettefrontend/feature/media/pages/collection_page.dart';

class PostPage extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostPage({
    super.key,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    print('===== PostPage BUILD =====');
    print('PostPage received data type: ${postData.runtimeType}');
    print('PostPage received data keys: ${postData.keys.toList()}');
    print('PostPage received data: $postData');

    try {
      // Validate required fields
      final elementType = postData['elementType'] as String?;
      final musicElementId = postData['musicElementId'] as String?;
      final postId = postData['postId'] as String?;
      final details = postData['details'] as Map<String, dynamic>?;

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

      print('Routing to ${elementType!.toLowerCase()} page');

      // Route to the appropriate page based on element type
      switch (elementType.toLowerCase()) {
        case 'track':
        case 'artist':
          print(
              'Creating EntityPage with type=${elementType.toLowerCase()}, trackId=$musicElementId, postId=$postId');
          return EntityPage(
            type: elementType.toLowerCase(),
            trackId: musicElementId,
            postId: postId,
            postData: postData,
          );
        case 'album':
        case 'playlist':
          print(
              'Creating CollectionPage with type=${elementType.toLowerCase()}, trackId=$musicElementId, postId=$postId');
          return CollectionPage(
            type: elementType.toLowerCase(),
            trackId: musicElementId,
            postId: postId,
            postData: postData,
          );
        default:
          print('ERROR: Unknown element type: $elementType');
          return Center(
            child: Text('Error: Unknown element type "$elementType"'),
          );
      }
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
}
