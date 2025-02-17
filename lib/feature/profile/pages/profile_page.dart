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
  TabController? tabController;
  int selectedIndex = 0;
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
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
    tabController?.dispose();
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
        body: DefaultTabController(
          length: 4,
          child: NestedScrollView(
            headerSliverBuilder: (context, value) {
              return [
                SliverPersistentHeader(
                  pinned: false,
                  delegate: SliverAppBarDelegate(
                    minHeight: 320,
                    maxHeight: 320,
                    child: Container(
                      color: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          toolBar(),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 34.0,
                                backgroundImage: NetworkImage(
                                    AppUtils.profileModel.profilePath ?? ''),
                                backgroundColor: Colors.transparent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(userData['FullName'] ?? '',
                                          style: AppStyles.profileNameTs),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                          onTap: () {
                                            context.go("/edit_profile");
                                          },
                                          child:
                                              Image.asset(icEdit, height: 30)),
                                    ],
                                  ),
                                  // const SizedBox(height: 4),
                                  Text(userData['Username'] ?? '',
                                      style: AppStyles.profileUserNameTs),
                                ],
                              )),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(userData['Bio'] ?? '',
                              style: AppStyles.profileBioTs),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(icLink, height: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(AppUtils.profileModel.link ?? '',
                                    style: AppStyles.profileLinkTs),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: AppUtils.profileModel.services
                                          ?.map((service) => Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: getServiceIcon(
                                                    service.serviceName ?? ''),
                                              ))
                                          .toList() ??
                                      [],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedPrimaryButton(
                                centerWidget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(icShare,
                                        fit: BoxFit.contain, height: 18),
                                    const SizedBox(width: 12),
                                    Text("Share Profile",
                                        style: AppStyles.profileShareTs),
                                  ],
                                ),
                                width: MediaQuery.of(context).size.width / 2.4,
                                onTap: () {
                                  AppUtils.onShare(context,
                                      AppUtils.profileModel.link ?? '');
                                },
                                radius: 12,
                              ),
                              const SizedBox(width: 8),
                              AnimatedPrimaryButton(
                                topBorderWidth: 2,
                                colorTop: AppColors.appBg,
                                colorBottom: AppColors.appBg,
                                borderColorTop: AppColors.textPrimary,
                                borderColorBottom: AppColors.textPrimary,
                                centerWidget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(icMusic,
                                        fit: BoxFit.contain, height: 18),
                                    const SizedBox(width: 12),
                                    Text("Add Music",
                                        style: AppStyles.profileAddMusicTs),
                                  ],
                                ),
                                width: MediaQuery.of(context).size.width / 2.4,
                                onTap: () {
                                  Future.delayed(Duration(milliseconds: 180),
                                      () => context.go("/add_music"));
                                },
                                radius: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: SliverAppBarDelegate(
                    minHeight: 65,
                    maxHeight: 65,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: AppColors.textPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0XFF000000),
                              blurRadius: 11,
                              offset: Offset(0, 9),
                              spreadRadius: 0,
                            ),
                          ]),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TabBar(
                              controller: tabController,
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              indicatorPadding: EdgeInsets.zero,
                              indicatorColor: AppColors.colorWhite,
                              dividerColor: AppColors.tabDividerColor,
                              indicatorSize: TabBarIndicatorSize.label,
                              labelStyle: AppStyles.profileTabSelectedTs,
                              unselectedLabelStyle: AppStyles.profileTabTs,
                              dividerHeight: 1,
                              onTap: (v) {},
                              tabs: const [
                                Tab(child: Text("Playlists")),
                                Tab(child: Text("Songs")),
                                Tab(child: Text("Artists")),
                                Tab(child: Text("Albums")),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                listWidget(),
                listWidget(),
                listWidget(),
                listWidget(),
              ],
            ),
          ),
        ));
  }

  listWidget() {
    return ListView.builder(
      itemCount: profileItemList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 5),
      itemBuilder: (context, index) {
        return Container(
          padding:
              const EdgeInsets.only(top: 14, bottom: 15, left: 12, right: 10),
          decoration: BoxDecoration(
              border: const Border(
                  bottom:
                      BorderSide(color: AppColors.textPrimary, width: 0.25)),
              gradient: LinearGradient(colors: [
                AppColors.colorWhite.withOpacity(0.51),
                AppColors.appBg
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: AppUtils.cacheImage(
                      imageUrl: profileItemList[index].source ?? '',
                      borderRadius: BorderRadius.circular(5),
                      height: 130,
                      width: 125,
                      fit: BoxFit.cover)),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(profileItemList[index].type ?? '',
                                    style: AppStyles.itemTypeTs),
                                Text(profileItemList[index].title ?? '',
                                    style: AppStyles.itemTitleTs,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                profileItemList[index].type == "Song"
                                    ? Text(
                                        "${profileItemList[index].artist} | ${profileItemList[index].album} | ${profileItemList[index].duration}",
                                        style: AppStyles.itemSongDurationTs,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis)
                                    : playlistDurationWidget(
                                        profileItemList[index]
                                            .songCount
                                            .toString(),
                                        " songs | ${profileItemList[index].duration}"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          AnimatedPrimaryButton(
                            centerWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(icShare,
                                    fit: BoxFit.contain, height: 15),
                              ],
                            ),
                            colorBottom:
                                AppColors.animatedBtnColorConvertBottom,
                            borderColorTop: AppColors.textPrimary,
                            colorTop: AppColors.textPrimary,
                            borderColorBottom: AppColors.textPrimary,
                            initialPos: 3,
                            width: 50,
                            height: 28,
                            onTap: () {},
                            radius: 12,
                          ),
                        ],
                      ),
                      Text(profileItemList[index].description ?? '',
                          style: AppStyles.itemDesTs,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      playlistDurationWidget(
                          "from: ", profileItemList[index].username,
                          style: AppStyles.itemFromTs,
                          style2: AppStyles.itemUsernameTs),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  playlistDurationWidget(text, textSpan, {style, style2}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: style ?? AppStyles.itemRichTextTs,
        children: <TextSpan>[
          TextSpan(
            text: textSpan,
            style: style2 ?? AppStyles.itemRichText2Ts,
          ),
        ],
      ),
    );
  }

  serviceIcon(image, color) {
    return Image.asset(image, height: 24, fit: BoxFit.contain, color: color);
  }

  toolBar() {
    return Row(
      children: [
        Expanded(child: Image.asset(appLogo, fit: BoxFit.scaleDown)),
        SizedBox(width: MediaQuery.of(context).size.width / 1.85),
        AppUtils.burgerMenu(
            onPressed: () {
              setState(() {
                isMenuVisible = !isMenuVisible;
              });
            },
            iconColor: AppColors.colorWhite),
      ],
    );
  }

  Widget getServiceIcon(String serviceName) {
    switch (serviceName) {
      case "Spotify":
        return serviceIcon(
          icSpotify,
          AppColors.greenAppColor,
        );
      case "Apple Music":
        return serviceIcon(
          icApple,
          AppColors.animatedBtnColorToolBarTop,
        );
      case "YouTube Music":
        return serviceIcon(
          icYtMusic,
          AppColors.animatedBtnColorToolBarTop,
        );
      case "Tidal":
        return serviceIcon(
          icTidal,
          AppColors.textPrimary,
        );
      case "Deezer":
        return serviceIcon(
          icDeezer,
          AppColors.textPrimary,
        );
      default:
        return serviceIcon(
          icSpotify,
          AppColors.greenAppColor,
        );
    }
  }
}
