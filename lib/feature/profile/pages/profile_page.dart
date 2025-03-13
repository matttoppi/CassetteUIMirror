import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/sliver_app_bar_delegate.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/feature/profile/json/profile_items_json.dart';
import 'package:cassettefrontend/feature/profile/model/profile_item_model.dart';
import 'package:cassettefrontend/main.dart'; // Import for supabase client
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMenuVisible = false;
  List<ProfileItemsJson> profileItemList = [];
  late TabController tabController;
  int selectedIndex = 0;
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      setState(() {
        selectedIndex = tabController.index;
      });
    });
    profileItemList = (profileItemsJson as List)
        .map((item) => ProfileItemsJson.fromJson(item))
        .toList();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await supabase
            .from('Users')
            .select()
            .eq('AuthUserId', user.id)
            .single();

        setState(() {
          userData = {
            'FullName': data['FullName'] ?? '',
            'Username': data['Username'] ?? '',
            'Bio': data['Bio'] ?? '',
            'AvatarUrl': data['AvatarUrl'] ?? ''
          };
          isLoading = false;
        });
      } catch (e) {
        print('[ERROR] Profile load failed: $e');
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      onBurgerPop: () {
        setState(() {
          isMenuVisible = !isMenuVisible;
        });
      },
      isMenuVisible: isMenuVisible,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) {
        return [
          // App Bar with logo and hamburger menu
          SliverAppBar(
            backgroundColor: AppColors.textPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.zero)),
            pinned: false,
            automaticallyImplyLeading: false,
            title: _buildToolbar(),
            toolbarHeight: 50,
          ),
          // Profile Details Section
          SliverPersistentHeader(
            pinned: false,
            delegate: _ProfileHeaderDelegate(
              height: 250,
              child: Container(
                color: AppColors.textPrimary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildProfileDetails(),
                ),
              ),
            ),
          ),
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverAppBarDelegate(
              minHeight: 50,
              maxHeight: 50,
              child: Material(
                elevation: 0,
                shadowColor: Colors.transparent,
                color: AppColors.textPrimary,
                child: _buildTabBar(),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        physics:
            const NeverScrollableScrollPhysics(), // Disable tab swiping to avoid controller conflicts
        controller: tabController,
        children: [
          _buildContentList(), // Playlists
          _buildContentList(), // Songs
          _buildContentList(), // Artists
          _buildContentList(), // Albums
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        // App logo
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.3,
              ),
              child: Image.asset(appLogo, fit: BoxFit.contain),
            ),
          ),
        ),
        // Burger menu
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
            ),
            child: AppUtils.burgerMenu(
              onPressed: () {
                setState(() {
                  isMenuVisible = !isMenuVisible;
                });
              },
              iconColor: AppColors.colorWhite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Profile avatar and name section
        Row(
          children: [
            // Profile Avatar with animation
            Hero(
              tag: 'profile-avatar',
              child: CircleAvatar(
                radius: 34.0,
                backgroundImage: NetworkImage(
                  userData['AvatarUrl'] ??
                      AppUtils.profileModel.profilePath ??
                      '',
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(width: 12),
            // Name and username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userData['FullName'] ?? '',
                          style: AppStyles.profileNameTs,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Edit button with ripple effect
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go("/edit_profile"),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(icEdit, height: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    userData['Username'] ?? '',
                    style: AppStyles.profileUserNameTs,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        // Bio
        Text(
          userData['Bio'] ?? '',
          style: AppStyles.profileBioTs,
          maxLines: 3, // Increased for better readability
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 16),
        // Link and service icons
        Row(
          children: [
            Image.asset(icLink, height: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppUtils.profileModel.link ?? '',
                style: AppStyles.profileLinkTs,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Service icons with horizontal scroll
            SizedBox(
              width: 120,
              child: _buildServiceIcons(),
            ),
          ],
        ),

        const SizedBox(height: 16),
        // Action buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildServiceIcons() {
    // Use ScrollConfiguration to customize the horizontal scroll behavior
    return ScrollConfiguration(
      // Apply custom scroll physics to make horizontal scrolling require more effort
      behavior: const ScrollBehavior().copyWith(
        physics: const ClampingScrollPhysics(), // More resistance
        overscroll: false, // Disable overscroll glow
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Make horizontal scrolling require more deliberate movement
        physics: const AlwaysScrollableScrollPhysics(
          parent: PageScrollPhysics(), // Requires more effort to scroll
        ),
        child: Row(
          children: AppUtils.profileModel.services
                  ?.map((service) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _getServiceIcon(service.serviceName ?? ''),
                      ))
                  .toList() ??
              [],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Share Profile button
        AnimatedPrimaryButton(
          centerWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icShare, fit: BoxFit.contain, height: 18),
              const SizedBox(width: 12),
              Text("Share Profile", style: AppStyles.profileShareTs),
            ],
          ),
          width: (screenWidth - 40) / 2.1, // More responsive width calculation
          onTap: () =>
              AppUtils.onShare(context, AppUtils.profileModel.link ?? ''),
          radius: 12,
        ),

        // Add Music button
        AnimatedPrimaryButton(
          topBorderWidth: 2,
          colorTop: AppColors.appBg,
          colorBottom: AppColors.appBg,
          borderColorTop: AppColors.textPrimary,
          borderColorBottom: AppColors.textPrimary,
          centerWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icMusic, fit: BoxFit.contain, height: 18),
              const SizedBox(width: 12),
              Text("Add Music", style: AppStyles.profileAddMusicTs),
            ],
          ),
          width: (screenWidth - 40) / 2.1, // More responsive width calculation
          onTap: () => Future.delayed(
            const Duration(milliseconds: 180),
            () => context.go("/add_music"),
          ),
          radius: 10,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: tabController,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      indicatorPadding: EdgeInsets.zero,
      indicatorColor: AppColors.colorWhite,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: AppStyles.profileTabSelectedTs,
      unselectedLabelStyle: AppStyles.profileTabTs,
      dividerHeight: 0,
      tabs: const [
        Tab(child: Text("Playlists")),
        Tab(child: Text("Songs")),
        Tab(child: Text("Artists")),
        Tab(child: Text("Albums")),
      ],
    );
  }

  Widget _buildContentList() {
    if (profileItemList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note,
                size: 50, color: AppColors.textPrimary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "No items to display",
              style: AppStyles.itemTitleTs.copyWith(
                color: AppColors.textPrimary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: profileItemList.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (context, index) {
        return _buildContentItem(profileItemList[index], index);
      },
    );
  }

  Widget _buildContentItem(ProfileItemsJson item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.textPrimary.withOpacity(0.1), width: 0.5),
        gradient: LinearGradient(
            colors: [AppColors.colorWhite.withOpacity(0.51), AppColors.appBg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AppUtils.cacheImage(
              imageUrl: item.source ?? '',
              borderRadius: BorderRadius.circular(6),
              height: 130,
              width: 125,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Content details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: title and share button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type label (Song, Playlist, etc.) - replaced with badge
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.textPrimary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(item.type ?? ''),
                                  size: 12,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (item.type ?? '').toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Title
                          Text(
                            item.title ?? '',
                            style: AppStyles.itemTitleTs,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Duration info based on type
                          item.type == "Song"
                              ? Text(
                                  "${item.artist} | ${item.album} | ${item.duration}",
                                  style: AppStyles.itemSongDurationTs,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : _buildRichText(
                                  "${item.songCount} songs | ${item.duration}",
                                  style: AppStyles.itemRichTextTs,
                                  style2: AppStyles.itemRichText2Ts,
                                ),
                        ],
                      ),
                    ),
                    // Share button
                    AnimatedPrimaryButton(
                      centerWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            icShare,
                            fit: BoxFit.contain,
                            height: 15,
                          ),
                        ],
                      ),
                      colorBottom: AppColors.animatedBtnColorConvertBottom,
                      borderColorTop: AppColors.textPrimary,
                      colorTop: AppColors.textPrimary,
                      borderColorBottom: AppColors.textPrimary,
                      initialPos: 3,
                      width: 50,
                      height: 28,
                      onTap: () => _shareItem(item),
                      radius: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  item.description ?? '',
                  style: AppStyles.itemDesTs,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Creator info
                _buildRichText(
                  "from: ${item.username}",
                  leadingText: "from: ",
                  style: AppStyles.itemFromTs,
                  style2: AppStyles.itemUsernameTs,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _shareItem(ProfileItemsJson item) {
    // Implement share functionality
    AppUtils.onShare(context, item.shareLink ?? '');
  }

  Widget _buildRichText(String text,
      {String? leadingText, TextStyle? style, TextStyle? style2}) {
    if (leadingText != null) {
      return RichText(
        text: TextSpan(
          text: leadingText,
          style: style ?? AppStyles.itemRichTextTs,
          children: <TextSpan>[
            TextSpan(
              text: text.substring(leadingText.length),
              style: style2 ?? AppStyles.itemRichText2Ts,
            ),
          ],
        ),
      );
    } else {
      return Text(
        text,
        style: style2 ?? AppStyles.itemRichText2Ts,
      );
    }
  }

  Widget _getServiceIcon(String serviceName) {
    switch (serviceName) {
      case "Spotify":
        return _serviceIcon(
          icSpotify,
          AppColors.greenAppColor,
        );
      case "Apple Music":
        return _serviceIcon(
          icApple,
          AppColors.animatedBtnColorToolBarTop,
        );
      case "YouTube Music":
        return _serviceIcon(
          icYtMusic,
          AppColors.animatedBtnColorToolBarTop,
        );
      case "Tidal":
        return _serviceIcon(
          icTidal,
          AppColors.textPrimary,
        );
      case "Deezer":
        return _serviceIcon(
          icDeezer,
          AppColors.textPrimary,
        );
      default:
        return _serviceIcon(
          icSpotify,
          AppColors.greenAppColor,
        );
    }
  }

  Widget _serviceIcon(String image, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.appBg.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        image,
        height: 24,
        fit: BoxFit.contain,
        color: color,
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case "Song":
        return Icons.music_note;
      case "Playlist":
        return Icons.playlist_play;
      case "Artist":
        return Icons.person;
      case "Album":
        return Icons.album;
      default:
        return Icons.help;
    }
  }
}

// Profile header delegate for sliver persistent header
class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _ProfileHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Return the child directly without the opacity animation
    return child;
  }

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
