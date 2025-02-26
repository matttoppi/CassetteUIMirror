import 'package:flutter/material.dart';
import 'package:cassettefrontend/core/constants/element_type.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';

class PostContainer extends StatelessWidget {
  final Map<String, dynamic> details;
  final Map<String, dynamic> platforms;
  final int elementType;
  final bool isPreview;
  final String? caption;
  final String? username;

  const PostContainer({
    super.key,
    required this.details,
    required this.platforms,
    required this.elementType,
    this.isPreview = false,
    this.caption,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isPreview && username != null) ...[
            Text(
              '@$username',
              style: AppStyles.usernameStyle,
            ),
            const SizedBox(height: 12),
          ],
          // Music element info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album art
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  details['coverArtUrl'] as String,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Track details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details['title'] as String,
                      style: AppStyles.titleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details['artist'] as String,
                      style: AppStyles.subtitleStyle,
                    ),
                    if (details['album'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        details['album'] as String,
                        style: AppStyles.subtitleStyle.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isPreview && caption != null) ...[
            const SizedBox(height: 16),
            Text(
              caption!,
              style: AppStyles.captionStyle,
            ),
          ],
          const SizedBox(height: 16),
          // Platform links
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: platforms.entries.map((entry) {
              final platform = entry.value as Map<String, dynamic>;
              return _PlatformButton(
                platformName: platform['platformName'] as String,
                url: platform['url'] as String,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PlatformButton extends StatelessWidget {
  final String platformName;
  final String url;

  const _PlatformButton({
    required this.platformName,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: Implement URL launching
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        'Open in $platformName',
        style: AppStyles.platformButtonTextStyle,
      ),
    );
  }
}
