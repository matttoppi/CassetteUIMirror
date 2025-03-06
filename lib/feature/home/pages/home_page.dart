import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/auth_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/common_widgets/auto_paste_text_field_widget.dart';
import 'package:cassettefrontend/core/common_widgets/clipboard_paste_button.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cassettefrontend/core/services/api_service.dart';
import 'package:cassettefrontend/core/constants/element_type.dart';
import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool isMenuVisible = false;
  late final AnimationController _fadeController;
  late final Animation<double> groupAFadeAnimation;
  late final Animation<double> groupBFadeAnimation;
  late final Animation<double> groupCFadeAnimation;
  late final Animation<Offset> _logoSlideAnimation;
  late final Animation<Offset> groupBSlideAnimation;
  final ScrollController scrollController = ScrollController();
  final TextEditingController tfController = TextEditingController();
  bool isLoading = false;
  Timer? _autoConvertTimer;
  Map<String, dynamic>? searchResults;
  bool isSearching = false;
  late final AnimationController _searchAnimController;
  late final Animation<double> _searchBarSlideAnimation;
  late final Animation<double> _logoFadeAnimation;
  bool isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  late final AnimationController _logoFadeController;
  bool isLoadingCharts = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _searchBarSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeOutCubic,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoFadeController,
      curve: Curves.easeOutCubic,
    ));

    _searchFocusNode.addListener(_handleSearchFocus);
    tfController.addListener(_handleTextChange);

    // Load top charts when app starts
    _loadTopCharts();

    // Test API connection
    _apiService.testConnection().then((isConnected) {
      if (!isConnected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Warning: Cannot connect to API server'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    groupAFadeAnimation = TweenSequence<double>([
      // Fade in from 0.0 to 1.0 during the first 23.3% of the timeline (35% of original 4000ms)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 23.3,
      ),
      // Then maintain full opacity until the end
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 76.7,
      ),
    ]).animate(_fadeController);
    _logoSlideAnimation = TweenSequence<Offset>([
      // Hold the logo at the lower offset for the first 23.3% of the timeline (35% of original 4000ms)
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0.8)),
        weight: 23.3,
      ),
      // Slide upward from offset (0, 0.8) to (0, 0.0) - over 26.7% (40% of original 4000ms)
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 26.7,
      ),
      // Hold at final position for remaining time
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 50.0,
      ),
    ]).animate(_fadeController);
    groupBFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        // Adjusted for 6000ms duration (0.55 to 0.825 of original 4000ms = 0.367 to 0.55 of 6000ms)
        curve: const Interval(0.367, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    groupCFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        // Start 1s after others finish (0.55 + 1s/6s = 0.55 + 0.167 = 0.717)
        // End at same duration as group B (0.717 + 0.183 = 0.9)
        curve: const Interval(0.717, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    groupBSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        // Adjusted for 6000ms duration (0.55 to 0.825 of original 4000ms = 0.367 to 0.55 of 6000ms)
        curve: const Interval(0.367, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
  }

  Future<void> _loadTopCharts() async {
    try {
      setState(() => isLoadingCharts = true);
      final results = await _apiService.fetchTop50USAPlaylist();
      if (mounted) {
        setState(() {
          searchResults = results;
          isLoadingCharts = false;
        });
      }
    } catch (e) {
      print('Error loading top charts: $e');
      if (mounted) {
        setState(() => isLoadingCharts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading charts: $e')),
        );
      }
    }
  }

  void _handleSearchFocus() {
    setState(() {
      isSearchFocused = _searchFocusNode.hasFocus;
    });

    if (isSearchFocused && tfController.text.isEmpty) {
      setState(() => isSearching = true);
      _apiService.fetchTop50USAPlaylist().then((results) {
        if (mounted) {
          setState(() {
            searchResults = results;
            isSearching = false;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() => isSearching = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading playlist: $error')),
          );
        }
      });
    }

    if (isSearchFocused) {
      _searchAnimController.forward();
      _logoFadeController.forward();
    } else {
      _searchAnimController.reverse();
      _logoFadeController.reverse();
    }
  }

  void _handleTextChange() {
    // Only clear search results if text is not empty (to keep showing charts)
    if (tfController.text.isNotEmpty) {
      setState(() {
        searchResults = null;
        isSearching = false;
      });
    }

    // Handle animations
    if (tfController.text.isNotEmpty && !_searchAnimController.isAnimating) {
      _logoFadeController.duration = const Duration(milliseconds: 250);
      _searchAnimController.forward();
      _logoFadeController.forward();
    } else if (tfController.text.isEmpty &&
        !_searchFocusNode.hasFocus &&
        !_searchAnimController.isAnimating) {
      _logoFadeController.duration = const Duration(milliseconds: 800);
      _searchAnimController.reverse();
      _logoFadeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearchActive = isSearchFocused ||
        isSearching ||
        searchResults != null ||
        (tfController.text.isNotEmpty && !isLoading);

    return AppScaffold(
      showAnimatedBg: true,
      onBurgerPop: () {
        setState(() {
          isMenuVisible = !isMenuVisible;
        });
      },
      isMenuVisible: isMenuVisible,
      body: Stack(
        children: [
          Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  AuthToolbar(
                    burgerMenuFnc: () {
                      setState(() {
                        isMenuVisible = !isMenuVisible;
                      });
                    },
                  ),

                  // Search bar and results container
                  AnimatedBuilder(
                    animation: _searchAnimController,
                    builder: (context, searchBarChild) {
                      final animValue = CurvedAnimation(
                        parent: _searchAnimController,
                        curve: Curves.easeOutQuart,
                      ).value;

                      // Calculate offset based on AuthToolbar height (40) plus padding
                      const startOffset = 0.0;
                      final endOffset =
                          -(MediaQuery.of(context).padding.top + 58.0 + 160.0);
                      final double verticalOffset =
                          lerpDouble(startOffset, endOffset, animValue)!;

                      return Transform.translate(
                        offset: Offset(0, verticalOffset),
                        child: Column(
                          children: [
                            // Content that appears/fades when not searching
                            FadeTransition(
                              opacity: groupAFadeAnimation,
                              child: Column(
                                children: [
                                  SlideTransition(
                                    position: _logoSlideAnimation,
                                    child: AnimatedBuilder(
                                      animation: _logoFadeController,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity:
                                              1 - _logoFadeController.value,
                                          child: child,
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          textGraphics(),
                                          const SizedBox(height: 5),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12 + 16),
                                            child: Text(
                                              "Express yourself through your favorite songs and playlists - wherever you stream them",
                                              textAlign: TextAlign.center,
                                              style:
                                                  AppStyles.homeCenterTextStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Search bar with independent sliding animation
                            FadeTransition(
                              opacity: groupBFadeAnimation,
                              child: SlideTransition(
                                position: groupBSlideAnimation,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: lerpDouble(22.0, 5.0, animValue)!,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: ClipboardPasteButton(
                                          hint:
                                              "Search or paste your music link here...",
                                          controller: tfController,
                                          focusNode: _searchFocusNode,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (_) {
                                            // Clear search and reset animations
                                            setState(() {
                                              searchResults = null;
                                              isSearching = false;
                                              isSearchFocused = false;
                                            });
                                            _searchAnimController.reverse();
                                            _logoFadeController.reverse();
                                          },
                                          onPaste: (value) {
                                            _autoConvertTimer?.cancel();

                                            final linkLower =
                                                value.toLowerCase();
                                            final isSupported = linkLower
                                                    .contains('spotify.com') ||
                                                linkLower.contains(
                                                    'apple.com/music') ||
                                                linkLower
                                                    .contains('deezer.com');

                                            if (isSupported &&
                                                !isLoading &&
                                                mounted) {
                                              setState(() {
                                                searchResults = null;
                                                // Reset animations when starting conversion
                                                _searchAnimController.reverse();
                                                _logoFadeController.reverse();
                                              });

                                              _autoConvertTimer = Timer(
                                                  const Duration(
                                                      milliseconds: 300), () {
                                                _handleLinkConversion(value);
                                              });
                                            }
                                          },
                                          onSearch: (query) {
                                            if (!isLoading) {
                                              _handleSearch(query);
                                            }
                                          },
                                        ),
                                      ),
                                      if (isLoading)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    AppColors
                                                        .animatedBtnColorConvertTop,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Converting...',
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Search results with improved fade in
                            if (isSearchActive)
                              AnimatedBuilder(
                                animation: _searchAnimController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: Curves.easeOutQuad
                                        .transform(_searchAnimController.value),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.5,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: _buildSearchResults(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Bottom graphics and create account button (only visible when not searching)
                  AnimatedBuilder(
                    animation: _searchAnimController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1 - _searchAnimController.value,
                        child: Visibility(
                          visible: !isSearchActive ||
                              _searchAnimController.value < 0.5,
                          child: child!,
                        ),
                      );
                    },
                    child: FadeTransition(
                      opacity: groupCFadeAnimation,
                      child: Column(
                        children: [
                          Image.asset(
                            homeGraphics,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 1.05,
                          ),
                          const SizedBox(height: 50),
                          AnimatedPrimaryButton(
                            text: "Create Your Free Account!",
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 180),
                                () => context.go('/signup'),
                              );
                            },
                            height: 40,
                            width: MediaQuery.of(context).size.width - 46 + 16,
                            radius: 10,
                            initialPos: 6,
                            topBorderWidth: 3,
                            bottomBorderWidth: 3,
                            colorTop: AppColors.animatedBtnColorConvertTop,
                            textStyle: AppStyles.animatedBtnFreeAccTextStyle,
                            borderColorTop:
                                AppColors.animatedBtnColorConvertTop,
                            colorBottom:
                                AppColors.animatedBtnColorConvertBottom,
                            borderColorBottom:
                                AppColors.animatedBtnColorConvertBottomBorder,
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
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

  Widget textGraphics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Image.asset(appLogoText, fit: BoxFit.contain),
    );
  }

  Future<void> _handleLinkConversion(String link) async {
    if (link.isEmpty) return;

    print('🔄 Starting music conversion');

    setState(() {
      isLoading = true;
    });

    try {
      print('📡 Making conversion request...');
      final response = await _apiService.convertMusicLink(link);

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Validate required fields
        final requiredFields = [
          'elementType',
          'musicElementId',
          'postId',
          'details'
        ];
        final missingFields = requiredFields
            .where((field) =>
                !response.containsKey(field) || response[field] == null)
            .toList();

        if (missingFields.isNotEmpty) {
          print('❌ Missing required fields in response');
          throw Exception('Missing required fields in response');
        }

        // Add the original link to the response data
        response['originalLink'] = link;

        print('✅ Conversion successful');
        context.go('/post', extra: response);
      }
    } catch (e) {
      print('❌ Conversion failed');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error converting link: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = null;
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      print('🔍 Starting search for: "$query"');
      final results = await _apiService.searchMusic(query);
      if (mounted) {
        setState(() {
          searchResults = results;
          isSearching = false;
        });
        print('✅ Search completed successfully');
      }
    } catch (e) {
      print('❌ Search error: $e');
      if (mounted) {
        setState(() {
          searchResults = null;
          isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSearchResults() {
    if (isLoadingCharts || isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchResults == null) {
      return const SizedBox.shrink();
    }

    final results = searchResults!['results'] as List<dynamic>? ?? [];

    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: results.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = results[index];
          return Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: item['coverArtUrl'] != null
                    ? Image.network(
                        item['coverArtUrl'],
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[200],
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.grey,
                        ),
                      ),
              ),
              title: Text(
                item['title'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                item['artist'] ?? '',
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
              hoverColor: Colors.black.withOpacity(0.05),
              onTap: () {
                final type = item['type'].toString().toLowerCase();
                final id = item['id'];
                final title = item['title'] ?? 'Unknown';
                final source = searchResults?['source'] ?? 'spotify';

                // Format URL based on the source
                String url;
                if (source == 'apple_music') {
                  url = item['url'] ?? ''; // Use direct Apple Music URL
                  if (url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: No valid Apple Music URL found'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                } else {
                  // Construct Spotify URL
                  url = 'https://open.spotify.com/$type/$id';
                }

                tfController.text =
                    'Converting ${type.substring(0, 1).toUpperCase() + type.substring(1)} - $title...';

                setState(() {
                  searchResults = null;
                  isLoading = true;
                });
                _handleLinkConversion(url);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchAnimController.dispose();
    _logoFadeController.dispose();
    _searchFocusNode.dispose();
    tfController.removeListener(_handleTextChange);
    _autoConvertTimer?.cancel();
    super.dispose();
  }
}
