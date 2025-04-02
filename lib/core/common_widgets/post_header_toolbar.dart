import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/storage/preference_helper.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/core/env.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Renamed from TrackToolbar to PostHeaderToolbar to better reflect its purpose
class PostHeaderToolbar extends StatefulWidget {
  bool? isLoggedIn;
  final String? postId;
  final String? pageType;

  PostHeaderToolbar({
    super.key,
    this.isLoggedIn,
    this.postId,
    this.pageType,
  });

  @override
  State<PostHeaderToolbar> createState() => _PostHeaderToolbarState();
}

class _PostHeaderToolbarState extends State<PostHeaderToolbar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _shareCurrentPage() {
    if (widget.postId == null || widget.pageType == null) {
      // Use the current origin if available for the base URL, otherwise fall back to Env.appDomain
      final baseUrl =
          Uri.base.toString().isNotEmpty ? Uri.base.origin : Env.appDomain;
      AppUtils.onShare(context, baseUrl);
      return;
    }

    // Get the base URL from the current page when possible
    final baseUrl =
        Uri.base.toString().isNotEmpty ? Uri.base.origin : Env.appDomain;

    // Append appropriate path based on page type
    String shareUrl = baseUrl;

    switch (widget.pageType) {
      case 'track':
        shareUrl = '$baseUrl/track/${widget.postId}';
        break;
      case 'artist':
        shareUrl = '$baseUrl/artist/${widget.postId}';
        break;
      case 'album':
        shareUrl = '$baseUrl/album/${widget.postId}';
        break;
      case 'playlist':
        shareUrl = '$baseUrl/playlist/${widget.postId}';
        break;
      default:
        // Just share base domain if we don't have specific info
        break;
    }

    print('Sharing URL: $shareUrl'); // Add debugging output
    AppUtils.onShare(context, shareUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.isLoggedIn ?? false
            ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  onTap: () {
                    context.go('/profile');
                  },
                  child: CircleAvatar(
                    radius: 24.0,
                    backgroundImage:
                        NetworkImage(AppUtils.userProfile.avatarUrl ?? ''),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              )
            : IconButton(
                onPressed: () {
                  context.go('/');
                },
                icon: Image.asset(
                  icBack,
                  height: 22,
                  color: AppColors.colorWhite,
                )),
        const SizedBox(width: 4),
        Expanded(
            child: Image.asset(
          appLogoTextSmall,
          fit: BoxFit.contain,
          height: MediaQuery.of(context).size.height / 15,
        )),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => _shareCurrentPage(),
          color: AppColors.colorWhite,
          icon: Image.asset(
            icShare,
            height: 24,
            color: AppColors.colorWhite,
          ),
        ),
      ],
    );
  }
}
