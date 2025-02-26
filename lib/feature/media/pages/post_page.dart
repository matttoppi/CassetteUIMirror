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
    print('PostPage received data: $postData');

    // Validate required fields
    final elementType = postData['elementType'] as String?;
    final musicElementId = postData['musicElementId'] as String?;
    final postId = postData['postId'] as String?;
    final details = postData['details'] as Map<String, dynamic>?;

    if (elementType == null ||
        musicElementId == null ||
        postId == null ||
        details == null) {
      print('Missing required fields in postData');
      return Center(child: Text('Error: Invalid post data'));
    }

    print('Routing to ${elementType.toLowerCase()} page');

    // Route to the appropriate page based on element type
    switch (elementType.toLowerCase()) {
      case 'track':
      case 'artist':
        return EntityPage(
          type: elementType.toLowerCase(),
          trackId: musicElementId,
          postId: postId,
          postData: postData,
        );
      case 'album':
      case 'playlist':
        return CollectionPage(
          type: elementType.toLowerCase(),
          trackId: musicElementId,
          postId: postId,
          postData: postData,
        );
      default:
        print('Unknown element type: $elementType');
        return Center(
          child: Text('Error: Unknown element type "$elementType"'),
        );
    }
  }
}
