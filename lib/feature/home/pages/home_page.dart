import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/auth_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/common_widgets/auto_paste_text_field_widget.dart';
import 'package:cassettefrontend/core/common_widgets/music_search_bar.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cassettefrontend/core/services/api_service.dart';
import 'package:cassettefrontend/core/services/music_search_service.dart';
import 'package:cassettefrontend/core/constants/element_type.dart';
import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final MusicSearchService _musicSearchService = MusicSearchService();
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
  bool isShowingSearchResults = false;
  late final AnimationController _searchAnimController;
  late final Animation<double> _searchBarSlideAnimation;
  late final Animation<double> _logoFadeAnimation;
  bool isSearchFocused = false;
  bool isSearchActive = false;
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

    _searchAnimController.addStatusListener(_handleSearchAnimationStatus);

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

    // Ensure these states are initialized to false
    isSearchActive = false;
    isShowingSearchResults = false;

    // Load top charts when app starts - but don't show the search UI yet
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
        // Modified timing: Start earlier at 0.4 and end at 0.7
        // This ensures the graphic fades in much earlier
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
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

    // Register _handleTextChange to listen for changes in the text field
    tfController.addListener(_handleTextChange);
  }

  void _handleSearchFocus() {
    setState(() {
      isSearchFocused = _searchFocusNode.hasFocus;
      print(
          '[_handleSearchFocus] isSearchFocused: $isSearchFocused, current text: "${tfController.text}"');

      if (isSearchFocused) {
        isSearchActive = true;

        // When text is empty and search animation is complete, show top charts
        if (tfController.text.isEmpty) {
          print(
              '[_handleSearchFocus] Focused with empty text, ensuring top charts are loaded');
          isShowingSearchResults = false;

          // Only load top charts if not already loaded
          if (searchResults == null || isLoadingCharts) {
            print('[_handleSearchFocus] Calling _loadTopCharts from focus');
            _loadTopCharts();
          } else {
            print('[_handleSearchFocus] Top charts already loaded on focus');
          }
        }
      } else {
        // When losing focus with empty text, keep charts visible
        if (tfController.text.isEmpty) {
          print(
              '[_handleSearchFocus] Lost focus but text is empty, keeping charts visible');
          isSearchActive = true; // Maintain search container visible
          isShowingSearchResults = false;
        } else if (searchResults != null) {
          // Keep search results visible when scrolling
          print(
              '[_handleSearchFocus] Lost focus but keeping search results visible');
          isSearchActive = true;
          isShowingSearchResults = true;
        }
      }
    });

    if (isSearchFocused) {
      _searchAnimController.forward();
      _logoFadeController.forward();
    } else if (tfController.text.isEmpty) {
      // Don't reverse animations when text is empty
      print('[_handleSearchFocus] Not reversing animations for empty text');
    } else if (searchResults != null) {
      // Don't reverse animations when we have search results (to keep them visible during scrolling)
      print(
          '[_handleSearchFocus] Not reversing animations when there are search results');
    } else {
      _searchAnimController.reverse();
      _logoFadeController.reverse();
    }
  }

  void _handleTextChange() {
    // Log current text and state
    print('[_handleTextChange] Current text: "${tfController.text}"');

    if (tfController.text.isNotEmpty) {
      setState(() {
        searchResults = null; // Clear previous search results
        isSearching = false;
        isShowingSearchResults = true;
        isSearchActive = true; // Keep search view active
      });

      // Ensure animations are playing
      if (!_searchAnimController.isAnimating &&
          _searchAnimController.value < 1.0) {
        _logoFadeController.duration = const Duration(milliseconds: 250);
        _searchAnimController.forward();
        _logoFadeController.forward();
      }
    } else {
      // Log that text is empty
      print(
          '[_handleTextChange] Text is empty. Reloading top charts if needed.');

      // When text is empty, maintain the search container and show charts
      setState(() {
        isShowingSearchResults = false;
        isSearchActive = true; // Keep the search container visible

        // Only clear searchResults if they're not top charts
        if (searchResults != null &&
            searchResults!['source'] != 'apple_music') {
          searchResults = null;
        }
      });

      // Reload the top charts only if not already loaded
      if (searchResults == null || isLoadingCharts) {
        print('[_handleTextChange] Calling _loadTopCharts');
        _loadTopCharts();
      } else {
        print('[_handleTextChange] Top charts already loaded.');
      }
    }
  }

  void _closeSearch() {
    setState(() {
      isSearchActive = false;
      searchResults = null;
      isSearching = false;
      isShowingSearchResults = false;
      _searchFocusNode.unfocus();
    });
    _searchAnimController.reverse();
    _logoFadeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure isSearchViewActive is false during loading (to hide results)
    // but keep search bar visible by keeping isSearchActive true
    final bool isSearchViewActive = isSearchActive ||
        isSearchFocused ||
        isSearching ||
        (searchResults != null &&
            _searchAnimController.value >
                0) || // Only consider searchResults when search animation is active
        (tfController.text.isNotEmpty && !isLoading);

    // When loading, we don't show search results, but we do show the search bar
    final bool shouldShowResults = isSearchViewActive && !isLoading;

    // Get screen size for responsive calculations
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
          // Main scrollable content
          Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: shouldShowResults
                  ? const NeverScrollableScrollPhysics()
                  : kIsWeb
                      ? const ClampingScrollPhysics() // Default for web
                      : Platform.isIOS
                          ? const BouncingScrollPhysics() // iOS native bounce effect
                          : const ClampingScrollPhysics(), // Android behavior
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
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

                        // Calculate offset based on screen size and SafeArea
                        // This ensures search bar doesn't overlap with nav bar
                        const startOffset = 0.0;
                        // Calculate a responsive endOffset that considers device size
                        final toolbarHeight = 58.0; // AuthToolbar height
                        final safeTop = topPadding > 0 ? topPadding : 20.0;
                        // Use percentage of screen height instead of fixed value
                        final percentOffset = screenSize.height * 0.18;
                        final endOffset =
                            -(safeTop + toolbarHeight + percentOffset);

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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12 + 16),
                                              child: Text(
                                                "Express yourself through your favorite songs and playlists - wherever you stream them",
                                                textAlign: TextAlign.center,
                                                style: AppStyles
                                                    .homeCenterTextStyle,
                                                // Add overflow handling
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
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
                                      // Make top padding responsive
                                      top: lerpDouble(22.0,
                                          screenSize.height * 0.01, animValue)!,
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: MusicSearchBar(
                                            hint:
                                                "Search or paste your music link here...",
                                            controller: tfController,
                                            focusNode: _searchFocusNode,
                                            textInputAction:
                                                TextInputAction.done,
                                            onSubmitted: (_) {
                                              FocusScope.of(context).unfocus();

                                              // If text is empty, ensure we're showing top charts
                                              if (tfController.text.isEmpty) {
                                                setState(() {
                                                  isShowingSearchResults =
                                                      false;
                                                });

                                                if (searchResults == null) {
                                                  _loadTopCharts();
                                                }
                                              }
                                            },
                                            onPaste: (value) {
                                              _autoConvertTimer?.cancel();

                                              final linkLower =
                                                  value.toLowerCase();
                                              final isSupported = linkLower
                                                      .contains(
                                                          'spotify.com') ||
                                                  linkLower.contains(
                                                      'apple.com/music') ||
                                                  linkLower.contains(
                                                      'music.apple.com') ||
                                                  linkLower
                                                      .contains('deezer.com');

                                              if (isSupported &&
                                                  !isLoading &&
                                                  mounted) {
                                                setState(() {
                                                  searchResults = null;
                                                  _searchAnimController
                                                      .reverse();
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
                                            isLoading: isLoading,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Search results with improved fade in
                              if (shouldShowResults)
                                AnimatedBuilder(
                                  animation: _searchAnimController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: Curves.easeOutQuad.transform(
                                          _searchAnimController.value),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: 100,
                                      // Make maxHeight calculation more responsive and web compatible
                                      maxHeight: kIsWeb
                                          ? screenSize.height *
                                              0.5 // Slightly smaller on web
                                          : screenSize.height *
                                              0.6, // Maintain mobile size
                                    ),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: kIsWeb
                                            ? 24
                                            : 16, // Wider margins on web
                                        vertical: screenSize.height * 0.01),
                                    child: GestureDetector(
                                      // Prevent taps in this area from dismissing the search
                                      onTap: () {},
                                      // Prevent scroll gestures from being interpreted as taps
                                      behavior: HitTestBehavior.opaque,
                                      child: Stack(
                                        children: [
                                          // Bottom "shadow" container
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 4), // Offset for 3D effect
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .animatedBtnColorConvertBottom,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors
                                                    .animatedBtnColorConvertBottomBorder,
                                                width: 2,
                                              ),
                                            ),
                                            child: const SizedBox(
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                          // Top content container
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors
                                                    .animatedBtnColorConvertTop,
                                                width: 2,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Add a header row with title and close button
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            top: 12,
                                                            right: 8,
                                                            bottom: 2),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          // Show different text based on whether this is search or charts
                                                          isShowingSearchResults
                                                              ? "Search Results"
                                                              : "Top Charts",
                                                          style: AppStyles
                                                              .itemTypeTs
                                                              .copyWith(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.close,
                                                            size: 20,
                                                            color: AppColors
                                                                .textPrimary,
                                                          ),
                                                          onPressed:
                                                              _closeSearch,
                                                          splashColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Add a divider
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12),
                                                    child: Divider(
                                                      color: AppColors
                                                          .animatedBtnColorConvertTop
                                                          .withOpacity(0.3),
                                                      height: 1,
                                                    ),
                                                  ),
                                                  // Remove the previous standalone close button since we've integrated it into the header
                                                  Expanded(
                                                    child:
                                                        _buildSearchResults(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Bottom graphics and create account button
                    if (!shouldShowResults) // Only show when search is not active
                      AnimatedBuilder(
                        animation: _searchAnimController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 1 - _searchAnimController.value,
                            child: Visibility(
                              visible: !shouldShowResults,
                              child: child!,
                            ),
                          );
                        },
                        child: FadeTransition(
                          opacity: groupCFadeAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Use responsive height for image with web adjustments
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: kIsWeb
                                      ? screenSize.height *
                                          0.4 // Smaller on web
                                      : screenSize.height *
                                          0.5, // Keep mobile size
                                ),
                                child: Image.asset(
                                  homeGraphics,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              ),
                              SizedBox(
                                  height: kIsWeb
                                      ? screenSize.height *
                                          0.04 // More space on web
                                      : screenSize.height * 0.03),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: kIsWeb
                                      ? 48 +
                                          bottomPadding *
                                              0.5 // More padding on web
                                      : 36 + bottomPadding * 0.5,
                                ),
                                child: AnimatedPrimaryButton(
                                  text: "Create Your Free Account!",
                                  onTap: () {
                                    Future.delayed(
                                      const Duration(milliseconds: 180),
                                      () => context.go('/signup'),
                                    );
                                  },
                                  height:
                                      kIsWeb ? 48 : 40, // Taller button on web
                                  // Make width responsive with web adjustments
                                  width: kIsWeb
                                      ? (screenSize.width > 800
                                          ? 500
                                          : screenSize.width *
                                              0.7) // Constrained on web
                                      : screenSize.width *
                                          0.85, // Original mobile width
                                  radius: 10,
                                  initialPos: 6,
                                  topBorderWidth: 3,
                                  bottomBorderWidth: 3,
                                  colorTop:
                                      AppColors.animatedBtnColorConvertTop,
                                  textStyle:
                                      AppStyles.animatedBtnFreeAccTextStyle,
                                  borderColorTop:
                                      AppColors.animatedBtnColorConvertTop,
                                  colorBottom:
                                      AppColors.animatedBtnColorConvertBottom,
                                  borderColorBottom: AppColors
                                      .animatedBtnColorConvertBottomBorder,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget textGraphics() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Use percentage-based padding for different screen sizes
    // Use smaller padding on smaller screens, more on larger ones
    final horizontalPadding =
        screenWidth < 400 ? screenWidth * 0.04 : screenWidth * 0.05;

    // On web, we need to account for different viewport sizes
    final maxWidth = kIsWeb
        ? (screenWidth > 800 ? 500.0 : screenWidth * 0.85)
        : screenWidth * 0.9;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Limit width on larger screens to prevent stretched look
          maxWidth: maxWidth,
        ),
        child: Image.asset(
          appLogoText,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> _handleLinkConversion(String link) async {
    if (link.isEmpty) return;

    print('🔄 Starting music conversion');

    setState(() {
      isLoading = true;
      // Hide results but keep search interface visible in center position
      isShowingSearchResults = false;
      isSearchActive = true; // Keep search UI visible
    });

    try {
      print('📡 Making conversion request...');
      final response = await _apiService.convertMusicLink(link);

      if (mounted) {
        setState(() {
          isLoading = false;
          // Close search interface after successful conversion
          isSearchActive = false;
          isShowingSearchResults = false;
        });

        print('✅ Conversion successful');
        context.go('/post', extra: response);
      }
    } catch (e) {
      print('❌ Conversion failed');
      if (mounted) {
        setState(() {
          isLoading = false;
          // Close search interface on error
          isSearchActive = false;
          isShowingSearchResults = false;
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
        isShowingSearchResults = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      print('🔍 Starting search for: "$query"');
      final results = await _musicSearchService.searchMusic(query);
      if (mounted) {
        setState(() {
          searchResults = results;
          isSearching = false;
          isShowingSearchResults = true;
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
    // Logging state for debugging chart visibility
    print(
        '[_buildSearchResults] isShowingSearchResults: $isShowingSearchResults, isSearchActive: $isSearchActive, searchResults: $searchResults');

    // Show loading indicator while loading charts or searching
    if (isLoadingCharts || isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.animatedBtnColorConvertTop,
            ),
          ),
        ),
      );
    }

    // If searchResults is null and we're not showing search results, schedule loading top charts
    if (searchResults == null && !isShowingSearchResults && isSearchActive) {
      // Schedule the loading after the build phase
      if (!isLoadingCharts) {
        print('[_buildSearchResults] Scheduling _loadTopCharts');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isLoadingCharts && searchResults == null) {
            print('[_buildSearchResults] Executing scheduled _loadTopCharts');
            _loadTopCharts();
          }
        });
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.animatedBtnColorConvertTop,
            ),
          ),
        ),
      );
    }

    if (searchResults == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Loading charts...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final results = searchResults!['results'] as List<dynamic>? ?? [];

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No results found',
            style: AppStyles.itemDesTs.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: results.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = results[index];
          // Get screen dimensions for adaptive layout
          final screenWidth = MediaQuery.of(context).size.width;
          // Calculate adaptive sizes based on screen width
          final bool isSmallScreen = screenWidth < 360;
          final double coverSize = isSmallScreen ? 40 : 50;
          final double iconSize = isSmallScreen ? 14 : 16;
          final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
          final double verticalPadding = isSmallScreen ? 6.0 : 8.0;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final type = item['type'].toString().toLowerCase();
                final id = item['id'];
                final title = item['title'] ?? 'Unknown';
                final source = searchResults?['source'] ?? 'spotify';

                // Format URL based on the source and type
                String url;
                if (source == 'apple_music') {
                  // For artists, use their Apple Music profile URL with region code and name
                  if (type == 'artist') {
                    // Convert artist name to URL-safe format (lowercase, spaces to hyphens)
                    final urlSafeName = title
                        .toLowerCase()
                        .replaceAll(' ', '-')
                        .replaceAll(
                            RegExp(r'[^\w-]'), ''); // Remove special characters
                    url = 'https://music.apple.com/us/artist/$urlSafeName/$id';
                  } else {
                    url = item['url'] ?? '';
                  }
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
                  url = 'https://open.spotify.com/$type/$id';
                }

                tfController.text =
                    'Converting ${type.substring(0, 1).toUpperCase() + type.substring(1)} - $title...';

                // Return search UI to center position
                _searchFocusNode.unfocus();
                _searchAnimController
                    .reverse(); // Reverse animation to move search bar back to center
                _logoFadeController.reverse(); // Show logo again

                setState(() {
                  searchResults = null;
                  isLoading = true;
                  isShowingSearchResults = false;
                  isSearchActive = true; // Keep search bar visible
                });
                _handleLinkConversion(url);
              },
              splashColor:
                  AppColors.animatedBtnColorConvertTop.withOpacity(0.2),
              highlightColor:
                  AppColors.animatedBtnColorConvertTop.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: item['coverArtUrl'] != null
                          ? Container(
                              width: coverSize,
                              height: coverSize,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.animatedBtnColorConvertTop
                                      .withOpacity(0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Image.network(
                                item['coverArtUrl'],
                                width: coverSize,
                                height: coverSize,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: coverSize,
                                    height: coverSize,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: SizedBox(
                                        width: coverSize * 0.4,
                                        height: coverSize * 0.4,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors
                                                .animatedBtnColorConvertTop,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: coverSize,
                              height: coverSize,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.animatedBtnColorConvertTop
                                      .withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.music_note,
                                size: coverSize * 0.6,
                                color: AppColors.textPrimary.withOpacity(0.5),
                              ),
                            ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? 'Unknown',
                            style: AppStyles.itemTitleTs.copyWith(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 6, // gap between adjacent chips
                            runSpacing: 2, // gap between lines
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item['artist'] ?? '',
                                style: AppStyles.itemDesTs.copyWith(
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item['type'] != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 4 : 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.animatedBtnColorConvertTop
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors
                                          .animatedBtnColorConvertTop
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    item['type']?.toString().toUpperCase() ??
                                        '',
                                    style: AppStyles.itemTypeTs.copyWith(
                                      fontSize: isSmallScreen ? 8 : 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: iconSize,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Handle animation status changes
  void _handleSearchAnimationStatus(AnimationStatus status) {
    // When the search animation completes (search bar fully visible)
    if (status == AnimationStatus.completed) {
      // Add a small delay to ensure the animation has fully rendered
      // before updating the UI state - helps on slower devices
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;

        // If search field is empty, show top charts
        if (tfController.text.isEmpty && !isLoading) {
          setState(() {
            isShowingSearchResults = false;
            isSearchActive = true; // Keep search active
            print(
                '[_handleSearchAnimationStatus] Animation completed: Setting search active, no results');
          });

          // Only load if we don't already have them
          if (searchResults == null || isLoadingCharts) {
            print(
                '[_handleSearchAnimationStatus] Loading top charts after animation');
            _loadTopCharts();
          }
        } else if (tfController.text.isNotEmpty) {
          // Ensure search results are visible when there's text
          setState(() {
            isShowingSearchResults = true;
            isSearchActive = true;
          });
        }
      });
    } else if (status == AnimationStatus.dismissed) {
      // Animation has fully reversed
      // If text is empty and not loading, reset search UI state
      if (tfController.text.isEmpty && !isLoading) {
        setState(() {
          isSearchActive = false;
          isShowingSearchResults = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchAnimController.removeStatusListener(_handleSearchAnimationStatus);
    _searchAnimController.dispose();
    _logoFadeController.dispose();
    _searchFocusNode.dispose();
    tfController.removeListener(_handleTextChange);
    _autoConvertTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTopCharts() async {
    try {
      setState(() => isLoadingCharts = true);
      final results = await _musicSearchService.fetchTop50USAPlaylist();
      // Only update top charts if the search text is still empty
      if (tfController.text.isNotEmpty) {
        // User started typing, so ignore these results
        return;
      }
      if (mounted) {
        setState(() {
          searchResults = results;
          isLoadingCharts = false;
          isShowingSearchResults = false;

          // Only activate search UI if user has interacted with search
          // Check if this is not the initial load (search animations have been triggered)
          isSearchActive = isSearchFocused || _searchAnimController.value > 0;
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
}
