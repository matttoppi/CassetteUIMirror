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
  bool isLinkConversion = false;
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
  bool _isChartLoadRequested = false;
  bool _disableAutoFocus =
      false; // Flag to disable auto focus after conversion failure

  // Cache text styles to avoid rebuilding them
  static final _homeCenterTextStyle = AppStyles.homeCenterTextStyle;
  static final _animatedBtnFreeAccTextStyle =
      AppStyles.animatedBtnFreeAccTextStyle;
  static final _itemTitleTs = AppStyles.itemTitleTs;
  static final _itemDesTs = AppStyles.itemDesTs;
  static final _itemTypeTs = AppStyles.itemTypeTs;

  @override
  void initState() {
    super.initState();

    // Create animation controllers first
    _fadeController = AnimationController(
      vsync: this,
      // Keep duration but coordinate simultaneous animations
      duration: const Duration(milliseconds: 6000),
    );

    _searchAnimController = AnimationController(
      vsync: this,
      // Keep this animation speed for responsiveness
      duration: const Duration(milliseconds: 200),
      value: 0.0,
    );

    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Setup animations
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

    // Add animation listeners first
    _searchAnimController.addStatusListener(_handleSearchAnimationStatus);

    // Then add focus listener
    _searchFocusNode.addListener(_handleSearchFocus);

    // Finally add text change listener
    tfController.addListener(_handleTextChange);

    // Initialize state variables
    isSearchActive = false;
    isShowingSearchResults = false;
    isLinkConversion = false;
    _isChartLoadRequested = false;
    isLoadingCharts = true;

    // 1. Start preloading top charts right away before animations even start
    _preloadTopCharts();

    // 3. Setup remaining animations (sequence animations etc.)
    groupAFadeAnimation = TweenSequence<double>([
      // Hold at 0 for first 5% of animation for initial delay
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 15.0,
      ),
      // Fade in logo over 25% of the timeline
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45.0,
      ),
      // Hold logo at full opacity for the remaining 65% of animation
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 65.0,
      ),
    ]).animate(_fadeController);

    // Coordinate slide animation with fade animation
    _logoSlideAnimation = TweenSequence<Offset>([
      // Start in initial position
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0.9)),
        weight: 5.0,
      ),
      // Hold position during initial fade-in
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0.9)),
        weight: 5.0,
      ),
      // Hold in center position for longer (same as the opacity hold)
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0.9)),
        weight: 40.0, // 40% of the timeline
      ),
      // Slide upward over 15% of the timeline
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, 0.9), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20.0,
      ),
      // Hold at final position for the rest of the animation
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 20.0,
      ),
    ]).animate(_fadeController);

    // Make search bar fade in as the logo starts moving up
    groupBFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        // Start when logo begins moving up (at 70%) and finish at 85%
        curve: const Interval(0.65, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    // Bottom graphics appearance after both main elements
    groupCFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        // Start after both logo and search bar are visible
        curve: const Interval(0.75, 0.99, curve: Curves.easeOutCubic),
      ),
    );

    groupBSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        // Match timing with the logo slide animation
        curve: const Interval(0.65, 0.80, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Move MediaQuery-dependent initialization here
    // Precache images to avoid jank when they first appear
    _precacheAssets();

    // Move API warmup to didChangeDependencies since it might use BuildContext indirectly
    _apiService.warmupLambdas().then((results) {
      if (!mounted) return;

      if (!results.values.every((success) => success)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Warning: Some services may be temporarily slower or unavailable'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    // When dependencies are available, set the animation start
    if (!_fadeController.isAnimating && _fadeController.isDismissed) {
      // Start with a single frame delay to ensure everything is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _fadeController.isDismissed) {
          _fadeController.forward();
        }
      });
    }
  }

  void _handleSearchFocus() {
    final wasFocused = isSearchFocused;
    isSearchFocused = _searchFocusNode.hasFocus;

    // Log state change for debugging
    // print('[Focus] Changed from $wasFocused to $isSearchFocused');

    // Don't alter animation state during active search operations
    if (isSearching || isLoading) {
      // If we're in active search but losing focus, restore focus
      if (!isSearchFocused && (isSearching || isLoading)) {
        // Schedule focus restoration after current frame
        Future.microtask(() => _searchFocusNode.requestFocus());
      }
      return;
    }

    setState(() {
      if (isSearchFocused) {
        // STATE 1: Initial focus - animate up and show top charts
        isSearchActive = true;

        // Ensure search UI is properly shown
        if (_searchAnimController.value < 1.0) {
          _searchAnimController.forward();

          // Re-request focus after animation starts to ensure keyboard appears
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted && !_searchFocusNode.hasFocus) {
              _searchFocusNode.requestFocus();
            }
          });
        }
        if (_logoFadeController.value < 1.0) {
          _logoFadeController.forward();
        }

        // Show appropriate content based on text
        if (tfController.text.isEmpty) {
          isShowingSearchResults = false;

          // Load charts if needed - prevent duplicate loads
          if ((searchResults == null || isLoadingCharts) &&
              !_isChartLoadRequested) {
            _loadTopCharts();
          }
        } else {
          isShowingSearchResults = true;
        }
      } else {
        // Only change UI when not in the middle of a search or loading operation
        if (!isSearching && !isLoading) {
          // When text is empty and not in active search, return to normal state
          if (tfController.text.isEmpty) {
            isSearchActive = false;
            isShowingSearchResults = false;
            _searchAnimController.reverse();
            _logoFadeController.reverse();
          } else if (searchResults != null) {
            // Keep search results visible when there's text and results
            isSearchActive = true;
            isShowingSearchResults = true;
          }
        }
      }
    });
  }

  void _handleTextChange() {
    final currentText = tfController.text;

    // Remove excessive logging that happens on every keystroke
    // print(
    //     '[_handleTextChange] Text: "$currentText", isLoading: $isLoading, isSearching: $isSearching');

    // Never change animation state during active search operations
    if (isSearching || isLoading) {
      // Force search UI to stay at top position during active operations
      if (_searchAnimController.value < 1.0) {
        _searchAnimController.forward();
      }
      if (_logoFadeController.value < 1.0) {
        _logoFadeController.forward();
      }
      return;
    }

    if (currentText.isNotEmpty) {
      // STATE 2: Text entry - keep at top, maintain focus
      setState(() {
        // Only clear previous results if not currently loading
        if (!isLoading && !isSearching) {
          searchResults = null;
        }
        isShowingSearchResults = true;
        isSearchActive = true;
      });

      // Ensure animations are in correct state
      if (_searchAnimController.value < 1.0) {
        _searchAnimController.forward();
      }
      if (_logoFadeController.value < 1.0) {
        _logoFadeController.forward();
      }
    } else {
      // Text empty - maintain search container and show charts
      setState(() {
        isShowingSearchResults = false;
        isSearchActive = true; // Keep search container visible

        // Only clear searchResults if they're not top charts
        if (searchResults != null &&
            searchResults!['source'] != 'apple_music') {
          searchResults = null;
        }
      });

      // Reload top charts if needed
      if (searchResults == null && !isLoadingCharts && !_isChartLoadRequested) {
        _loadTopCharts();
      }
    }

    // Always ensure focus is maintained during typing
    if (!_searchFocusNode.hasFocus) {
      _searchFocusNode.requestFocus();
    }
  }

  void _closeSearch() {
    // Don't unfocus during search operations
    if (!isSearching) {
      _searchFocusNode.unfocus();
    }

    _autoConvertTimer?.cancel();

    // Don't change UI during loading or search
    if (isLoading || isSearching) return;

    setState(() {
      isSearchActive = false;
      isShowingSearchResults = false;

      if (tfController.text.isNotEmpty) {
        tfController.clear();
      }

      if (searchResults != null && searchResults!['source'] != 'apple_music') {
        searchResults = null;
      }
    });

    // Animate back to normal position
    if (!_searchAnimController.isDismissed) {
      _searchAnimController.reverse().then((_) {
        if (!_searchFocusNode.hasFocus && mounted) {
          _logoFadeController.reverse();
        }
      });
    } else {
      _logoFadeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure search bar is at top position during search operations
    // But don't force it during link conversion
    if ((isSearching || isLoading) && !isLinkConversion) {
      _ensureSearchBarAtTopPosition();
    }

    // Ensure isSearchViewActive is false during loading (to hide results)
    // but keep search bar visible by keeping isSearchActive true
    final bool isSearchViewActive = (isSearchActive ||
            isSearchFocused ||
            isSearching ||
            (searchResults != null &&
                _searchAnimController.value >
                    0) || // Only consider searchResults when search animation is active
            (tfController.text.isNotEmpty && !isLoading)) &&
        !isLinkConversion; // Hide results when doing link conversion

    // When loading, we should show loading results, not hide the entire results area
    // During link conversion, we should hide results and show the home screen
    final bool shouldShowResults = isSearchViewActive && !isLinkConversion;

    // Get screen size safely for responsive calculations
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenSize =
        mediaQuery?.size ?? const Size(375, 667); // Fallback size
    final topPadding = mediaQuery?.padding.top ?? 0.0; // Fallback
    final bottomPadding = mediaQuery?.padding.bottom ?? 0.0; // Fallback

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
                  : const AlwaysScrollableScrollPhysics(), // Always allow scrolling when showing the home graphic
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Use maybeOf instead of direct access
                  minHeight: mediaQuery?.size.height ?? 600.0, // Fallback value
                ),
                child: Column(
                  children: [
                    // Replace direct use of SizedBox + AuthToolbar with a coordinated animated version
                    // The staggered animation approach will make the toolbar appear at the right time
                    AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, child) {
                        // Calculate when toolbar should appear based on the main animation timeline
                        // Start fading in early but more gradually
                        final double toolbarOpacity =
                            _fadeController.value < 0.03
                                ? 0.0
                                : _fadeController.value > 0.30
                                    ? 1.0
                                    : (_fadeController.value - 0.03) / 0.27;

                        // Add a subtle slide down effect to the toolbar
                        final double slideOffset = toolbarOpacity < 1.0
                            ? -10.0 * (1.0 - toolbarOpacity)
                            : 0.0;

                        return Column(
                          children: [
                            const SizedBox(height: 18),
                            // Wrap in RepaintBoundary to improve performance
                            RepaintBoundary(
                              child: Transform.translate(
                                offset: Offset(0, slideOffset),
                                child: Opacity(
                                  opacity: toolbarOpacity,
                                  child: AuthToolbar(
                                    burgerMenuFnc: () {
                                      setState(() {
                                        isMenuVisible = !isMenuVisible;
                                      });
                                    },
                                    // Use zero duration since we're controlling animation externally
                                    animationDuration: Duration.zero,
                                    // Skip the delay since we're controlling appearance timing
                                    animationDelay: Duration.zero,
                                    // Disable internal animations since we're handling them here
                                    disableInternalAnimations: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
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

                        // Starting position (no offset)
                        const startOffset = 0.0;

                        // Calculate minimum padding (5% of screen height)
                        final screenHeight =
                            MediaQuery.maybeOf(context)?.size.height ?? 600.0;
                        final minPadding = screenHeight * 0.05;

                        // Calculate the end position - right below the toolbar
                        const toolbarHeight = 65.0; // AuthToolbar height
                        const navBarTopPadding = 18.0; // SizedBox above toolbar
                        final safeTop = topPadding; // Use actual safe area
                        const logoHeight = 140.0; // Estimated logo block height

                        // Calculate the exact offset to position the search bar below the toolbar
                        // Include toolbar height, padding, and minimum spacing
                        final endOffset = -(logoHeight -
                            (toolbarHeight + navBarTopPadding + minPadding));

                        // Smoothly interpolate between start and end positions
                        // Cache this value to avoid recalculating during the same frame
                        final double verticalOffset = lerpDouble(
                            startOffset,
                            endOffset,
                            Curves.easeOutCubic.transform(animValue))!;

                        return Transform.translate(
                          offset: Offset(0, verticalOffset),
                          // Use LayoutBuilder instead of directly accessing MediaQuery multiple times
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                children: [
                                  // Only show text logo if appropriate based on our states
                                  if ((!isSearchActive ||
                                          (isLoading && isLinkConversion)) &&
                                      !isSearching)
                                    FadeTransition(
                                      opacity: groupAFadeAnimation,
                                      child: Column(
                                        children: [
                                          SlideTransition(
                                            position: _logoSlideAnimation,
                                            child: AnimatedBuilder(
                                              animation: _logoFadeController,
                                              builder: (context, child) {
                                                // Only show logo when NOT searching or when explicitly doing link conversion
                                                final bool shouldShowLogo =
                                                    (!isSearchActive ||
                                                            (isLoading &&
                                                                isLinkConversion)) &&
                                                        !isSearching;

                                                final opacity = shouldShowLogo
                                                    ? 1.0
                                                    : 1 -
                                                        _logoFadeController
                                                            .value;

                                                return Opacity(
                                                  opacity: opacity,
                                                  child: RepaintBoundary(
                                                      child: child),
                                                );
                                              },
                                              child: Column(
                                                children: [
                                                  textGraphics(),
                                                  const SizedBox(height: 5),
                                                  // Add a slight delay for the tagline text for a staggered effect
                                                  AnimatedBuilder(
                                                    animation: _fadeController,
                                                    builder: (context, child) {
                                                      // Make tagline fade in with the logo but stay visible
                                                      final double
                                                          taglineOpacity =
                                                          _fadeController
                                                                      .value <
                                                                  0.10
                                                              ? 0.0
                                                              : _fadeController
                                                                          .value <
                                                                      0.30
                                                                  ? (_fadeController
                                                                              .value -
                                                                          0.10) /
                                                                      0.20
                                                                  : 1.0;

                                                      return Opacity(
                                                        opacity: taglineOpacity,
                                                        child: child,
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 28),
                                                      child: Text(
                                                        "Express yourself through your favorite songs and playlists - wherever you stream them",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            _homeCenterTextStyle,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                      ),
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
                                      child: RepaintBoundary(
                                        // Add RepaintBoundary for the search bar to reduce repaint cost
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: lerpDouble(
                                                kIsWeb ? 35.0 : 30.0,
                                                4.0,
                                                animValue)!,
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Reset auto focus disable flag on manual tap
                                                    setState(() {
                                                      _disableAutoFocus = false;
                                                    });

                                                    // STATE 1: Initial click - animate up, load charts, focus
                                                    if (!isSearchActive) {
                                                      setState(() {
                                                        isSearchActive = true;
                                                        // Load top charts if needed
                                                        if (searchResults ==
                                                                null &&
                                                            !isLoadingCharts &&
                                                            !_isChartLoadRequested) {
                                                          _loadTopCharts();
                                                        }
                                                      });

                                                      // Start animations
                                                      _searchAnimController
                                                          .forward();
                                                      _logoFadeController
                                                          .forward();

                                                      // Request focus after a short delay to ensure animations have started
                                                      Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  150), () {
                                                        if (mounted &&
                                                            !_searchFocusNode
                                                                .hasFocus) {
                                                          _searchFocusNode
                                                              .requestFocus();
                                                        }
                                                      });
                                                    } else {
                                                      // When already active, just ensure focus
                                                      _searchFocusNode
                                                          .requestFocus();
                                                    }
                                                  },
                                                  child: MusicSearchBar(
                                                    hint:
                                                        "Search or paste your music link here...",
                                                    controller: tfController,
                                                    focusNode: _searchFocusNode,
                                                    textInputAction:
                                                        TextInputAction.search,
                                                    onSubmitted: (_) {
                                                      // When user hits enter/done, perform search if there's text
                                                      if (tfController
                                                          .text.isNotEmpty) {
                                                        _handleSearch(
                                                            tfController.text);
                                                        // Don't unfocus - we want to keep focus for subsequent edits
                                                      } else {
                                                        // If empty search, allow unfocus
                                                        _searchFocusNode
                                                            .unfocus();
                                                        _closeSearch();
                                                      }
                                                    },
                                                    onPaste: (value) {
                                                      // First, cancel any existing timers
                                                      _autoConvertTimer
                                                          ?.cancel();

                                                      // Check if this is a music link
                                                      final linkLower =
                                                          value.toLowerCase();
                                                      final isSupported = linkLower
                                                              .contains(
                                                                  'spotify.com') ||
                                                          linkLower.contains(
                                                              'apple.com/music') ||
                                                          linkLower.contains(
                                                              'music.apple.com') ||
                                                          linkLower.contains(
                                                              'deezer.com');

                                                      // If we're already in a search, ignore paste events
                                                      if (isSearching ||
                                                          isLoading) {
                                                        // print(
                                                        //     '🚫 Ignoring paste during active operation');
                                                        return;
                                                      }

                                                      if (isSupported &&
                                                          !isLoading &&
                                                          mounted) {
                                                        // STATE 3: Link conversion - animate down to original position
                                                        setState(() {
                                                          searchResults = null;
                                                          isLoading = true;
                                                          isLinkConversion =
                                                              true;
                                                          isShowingSearchResults =
                                                              false;
                                                          _disableAutoFocus =
                                                              true;

                                                          // Unfocus and animate down
                                                          _searchFocusNode
                                                              .unfocus();
                                                          _searchAnimController
                                                              .reverse();
                                                          _logoFadeController
                                                              .reverse();
                                                        });

                                                        // Process the link with slight delay for UI feedback
                                                        _autoConvertTimer =
                                                            Timer(
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                                () {
                                                          if (mounted) {
                                                            _handleLinkConversion(
                                                                value);
                                                          }
                                                        });
                                                      } else {
                                                        // STATE 2: Regular text - keep at top with focus
                                                        // Force search bar to stay at top
                                                        if (_searchAnimController
                                                                .value <
                                                            1.0) {
                                                          _searchAnimController
                                                              .forward();
                                                        }
                                                        if (_logoFadeController
                                                                .value <
                                                            1.0) {
                                                          _logoFadeController
                                                              .forward();
                                                        }

                                                        setState(() {
                                                          isSearchActive = true;
                                                          isShowingSearchResults =
                                                              true;
                                                        });

                                                        // Ensure focus is maintained
                                                        if (!_searchFocusNode
                                                            .hasFocus) {
                                                          _searchFocusNode
                                                              .requestFocus();
                                                        }
                                                      }
                                                    },
                                                    onSearch: (query) {
                                                      // Never initiate a new search if one is already in progress
                                                      if (!isLoading &&
                                                          !isSearching) {
                                                        _handleSearch(query);
                                                      } else {
                                                        // print(
                                                        //     '🚫 Search already in progress, ignoring new search request');
                                                      }
                                                    },
                                                    isLoading: isLoading,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Search results with improved fade in
                                  if (shouldShowResults && !isLinkConversion)
                                    AnimatedBuilder(
                                      animation: _searchAnimController,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: Curves.easeOutQuad.transform(
                                              _searchAnimController.value),
                                          child: RepaintBoundary(
                                              child:
                                                  child), // Add RepaintBoundary for search results
                                        );
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          minHeight: 100,
                                          // Calculate height to extend to bottom of screen with consistent padding
                                          maxHeight: screenSize.height -
                                              (safeTop + // Top safe area
                                                  toolbarHeight + // AuthToolbar height
                                                  navBarTopPadding + // Padding above toolbar
                                                  minPadding + // Min padding below toolbar (matches top)
                                                  58 + // Search bar height
                                                  minPadding + // Same padding at bottom
                                                  bottomPadding // Bottom safe area
                                              ),
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: kIsWeb ? 24 : 16,
                                            vertical: minPadding *
                                                0.25), // Smaller vertical margin for visual balance
                                        child: GestureDetector(
                                          onTap: () {},
                                          behavior: HitTestBehavior.opaque,
                                          child: Stack(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 4),
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
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
                                                              isShowingSearchResults
                                                                  ? "Search Results"
                                                                  : "Top Charts",
                                                              style: _itemTypeTs
                                                                  .copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12),
                                                        child: Divider(
                                                          color: AppColors
                                                              .animatedBtnColorConvertTop
                                                              .withOpacity(0.3),
                                                          height: 1,
                                                        ),
                                                      ),
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
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // Bottom graphics and create account button
                    if (!shouldShowResults) // Only show when search is not active
                      AnimatedBuilder(
                        animation: _searchAnimController,
                        builder: (context, child) {
                          // Make sure graphics are visible during link conversion
                          final opacity = isLinkConversion
                              ? 1.0
                              : 1 - _searchAnimController.value;

                          return Opacity(
                            opacity: opacity,
                            child: Visibility(
                              visible: !shouldShowResults || isLinkConversion,
                              child: RepaintBoundary(
                                  child:
                                      child!), // Add RepaintBoundary to optimize bottom content
                            ),
                          );
                        },
                        child: FadeTransition(
                          opacity: groupCFadeAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment
                                .stretch, // Ensure children stretch full width
                            children: [
                              // Use responsive height for image with web adjustments
                              Padding(
                                padding: EdgeInsets.only(
                                  top: screenSize.width < 600
                                      ? 70.0 // Further reduced to move graphic up more
                                      : 90.0, // Further reduced to move graphic up more
                                ),
                                child: Image.asset(
                                  homeGraphics,
                                  width: screenSize.width *
                                      0.99, // 99% of screen width
                                  fit: BoxFit
                                      .fitWidth, // Fit to width while maintaining aspect ratio
                                ),
                              ),
                              // Increase space below the image
                              SizedBox(
                                  height: screenSize.width < 600
                                      ? screenSize.height *
                                          0.08 // More space on small screens
                                      : screenSize.height *
                                          0.1), // More space on larger screens
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: screenSize.width < 600
                                      ? 60 +
                                          bottomPadding *
                                              0.5 // More padding on small screens
                                      : 48 +
                                          bottomPadding *
                                              0.5, // Padding on larger screens
                                ),
                                child: Center(
                                  // Center the button horizontally
                                  child: AnimatedPrimaryButton(
                                    text: "Create Your Free Account!",
                                    onTap: () {
                                      Future.delayed(
                                        const Duration(milliseconds: 180),
                                        () => context.go('/signup'),
                                      );
                                    },
                                    height: screenSize.width < 600
                                        ? 48
                                        : 40, // Taller button on small screens
                                    // Enhanced dynamic width calculation based on screen size
                                    width: screenSize.width < 360
                                        ? screenSize.width *
                                            0.9 // Extra small screens: 90%
                                        : screenSize.width < 600
                                            ? screenSize.width *
                                                0.85 // Small screens: 85%
                                            : screenSize.width < 900
                                                ? screenSize.width *
                                                    0.75 // Medium screens: 75%
                                                : screenSize.width < 1200
                                                    ? screenSize.width *
                                                        0.65 // Large screens: 65%
                                                    : screenSize.width *
                                                        0.55, // Extra large screens: 55%
                                    radius: 10,
                                    initialPos: 6,
                                    topBorderWidth: 3,
                                    bottomBorderWidth: 3,
                                    colorTop:
                                        AppColors.animatedBtnColorConvertTop,
                                    textStyle: _animatedBtnFreeAccTextStyle,
                                    borderColorTop:
                                        AppColors.animatedBtnColorConvertTop,
                                    colorBottom:
                                        AppColors.animatedBtnColorConvertBottom,
                                    borderColorBottom: AppColors
                                        .animatedBtnColorConvertBottomBorder,
                                  ),
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
    // Get MediaQuery safely - if context doesn't have MediaQuery yet, use fallback values
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? 375.0; // Fallback value
    final devicePixelRatio =
        mediaQuery?.devicePixelRatio ?? 1.0; // Get device pixel ratio

    // Use percentage-based padding for different screen sizes
    final horizontalPadding =
        screenWidth < 400 ? screenWidth * 0.04 : screenWidth * 0.05;

    // On web, we need to account for different viewport sizes
    final maxWidth = kIsWeb
        ? (screenWidth > 800 ? 500.0 : screenWidth * 0.85)
        : screenWidth * 0.9;

    // Calculate appropriate cache height based on device pixel ratio
    // For high-density displays (like mobile), use a higher resolution
    // Base height of 150 for standard displays, scaled up for high-density displays
    final int cacheHeight = (250 * devicePixelRatio).round();

    // Use RepaintBoundary for the logo which doesn't change often
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // Limit width on larger screens to prevent stretched look
            maxWidth: maxWidth,
          ),
          child: Image.asset(
            // Use high-res logo for high-density displays
            devicePixelRatio > 2.0 ? appLogoTextHiRes : appLogoText,
            fit: BoxFit.contain,
            // Use device pixel ratio to determine appropriate cache size
            cacheHeight: cacheHeight,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cancel any in-progress operations first
    _autoConvertTimer?.cancel();
    _musicSearchService.cancelActiveRequests();

    // Remove listeners in reverse order of addition
    tfController.removeListener(_handleTextChange);
    _searchFocusNode.removeListener(_handleSearchFocus);
    _searchAnimController.removeStatusListener(_handleSearchAnimationStatus);

    // Dispose controllers
    _fadeController.dispose();
    _searchAnimController.dispose();
    _logoFadeController.dispose();
    _searchFocusNode.dispose();

    // Dispose other resources
    scrollController.dispose();

    super.dispose();
  }

  // Cancel previous operations when starting a new one
  void _cancelPreviousOperations() {
    _autoConvertTimer?.cancel();
    _musicSearchService.cancelActiveRequests();
  }

  Future<void> _handleSearch(String query) async {
    _autoConvertTimer?.cancel();

    if (query.isEmpty) {
      _updateStateWithBatchedChanges(() {
        if (!isLoadingCharts) {
          searchResults = null;
        }
        isSearching = false;
        isShowingSearchResults = false;
      });

      if (searchResults == null && !isLoadingCharts && !_isChartLoadRequested) {
        _loadTopCharts();
      }
      return;
    }

    if (isSearching) {
      return;
    }

    // Remember focus state
    final wasFocused = _searchFocusNode.hasFocus;

    _updateStateWithBatchedChanges(() {
      isSearching = true;
      isLoading = true;
      isLinkConversion = false;
      isSearchActive = true;
      isShowingSearchResults = true;
    });

    // Force animations to proper state
    if (_searchAnimController.value < 1.0) {
      _searchAnimController.forward();
    }
    if (_logoFadeController.value < 1.0) {
      _logoFadeController.forward();
    }

    try {
      final results = await _musicSearchService.searchMusic(query);

      if (!mounted) return;

      if (query != tfController.text) {
        _updateStateWithBatchedChanges(() {
          isSearching = false;
          isLoading = false;
        });
        return;
      }

      _updateStateWithBatchedChanges(() {
        searchResults = results;
        isSearching = false;
        isLoading = false;
        isShowingSearchResults = true;
      });

      // Restore focus after search completes
      if (wasFocused && !_searchFocusNode.hasFocus) {
        _searchFocusNode.requestFocus();
      }
    } catch (e) {
      if (!mounted) return;

      if (query != tfController.text) {
        _updateStateWithBatchedChanges(() {
          isSearching = false;
          isLoading = false;
        });
        return;
      }

      _updateStateWithBatchedChanges(() {
        isSearching = false;
        isLoading = false;
      });

      // Restore focus after error
      if (wasFocused && !_searchFocusNode.hasFocus) {
        _searchFocusNode.requestFocus();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handleSearch(query),
          ),
        ),
      );
    }
  }

  void _handleLinkConversion(String link) async {
    if (link.isEmpty) return;

    // Cancel any previous operations
    _cancelPreviousOperations();

    // Batch all state changes together
    _updateStateWithBatchedChanges(() {
      isLoading = true;
      isLinkConversion = true;
      isShowingSearchResults = false;
      isSearchActive =
          false; // Change to false to fully restore home screen look
      _disableAutoFocus = true; // Disable auto focus during conversion

      // Unfocus and animate down
      _searchFocusNode.unfocus();
    });

    // Use a single microtask to start both animations together
    Future.microtask(() {
      _searchAnimController.reverse();
      _logoFadeController.reverse();
    });

    try {
      final response = await _apiService.convertMusicLink(link);

      if (!mounted) return;

      _updateStateWithBatchedChanges(() {
        isLoading = false;
        isLinkConversion = false;
        isSearchActive = false;
        isShowingSearchResults = false;
        _disableAutoFocus =
            false; // Re-enable auto focus for future interactions
      });

      context.go('/post', extra: response);
    } catch (e) {
      if (!mounted) return;

      _updateStateWithBatchedChanges(() {
        isLoading = false;
        isLinkConversion = false;
        isSearchActive = true;
        isShowingSearchResults = false; // Ensure results stay hidden on error
      });

      // Use a microtask to ensure animations start after the state changes are applied
      Future.microtask(() {
        if (mounted) {
          _searchAnimController.forward();
          _logoFadeController.forward();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error converting link: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _handleLinkConversion(link);
            },
          ),
        ),
      );
    }
  }

  Widget _buildSearchResults() {
    // Remove logging that happens on every build cycle
    // print(
    //     '[_buildSearchResults] isShowingSearchResults: $isShowingSearchResults, isSearchActive: $isSearchActive, searchResults: $searchResults');

    // Show loading indicator while loading charts or searching
    if (isLoadingCharts || isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.animatedBtnColorConvertTop,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isLoadingCharts
                    ? 'Loading top charts...'
                    : isSearching
                        ? 'Searching...'
                        : 'Loading...',
                style: _itemDesTs.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If searchResults is null and we're not showing search results, schedule loading top charts
    if (searchResults == null && !isShowingSearchResults && isSearchActive) {
      // Schedule the loading after the build phase
      if (!isLoadingCharts) {
        // print('[_buildSearchResults] Scheduling _loadTopCharts');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isLoadingCharts && searchResults == null) {
            // print('[_buildSearchResults] Executing scheduled _loadTopCharts');
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
            style: _itemDesTs.copyWith(
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
        // Add these optimizations to improve ListView performance
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
        cacheExtent:
            500, // Cache more items to reduce rebuilds during scrolling
        itemBuilder: (context, index) {
          final item = results[index];
          // Get screen dimensions for adaptive layout
          final screenWidth = MediaQuery.maybeOf(context)?.size.width ?? 375.0;
          // Calculate adaptive sizes based on screen width
          final bool isSmallScreen = screenWidth < 360;
          final double coverSize = isSmallScreen ? 40 : 50;
          final double iconSize = isSmallScreen ? 14 : 16;
          final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
          final double verticalPadding = isSmallScreen ? 6.0 : 8.0;

          // Use RepaintBoundary to optimize individual list items
          return RepaintBoundary(
            child: Material(
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
                          .replaceAll(RegExp(r'[^\w-]'),
                              ''); // Remove special characters
                      url =
                          'https://music.apple.com/us/artist/$urlSafeName/$id';
                    } else {
                      url = item['url'] ?? '';
                    }
                    if (url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Error: No valid Apple Music URL found'),
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
                                          child:
                                              const CircularProgressIndicator(
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
                              style: _itemTitleTs.copyWith(
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
                                  style: _itemDesTs.copyWith(
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
                                      color: AppColors
                                          .animatedBtnColorConvertTop
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
                                      style: _itemTypeTs.copyWith(
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
            ),
          );
        },
      ),
    );
  }

  // Handle animation status changes - improved to prevent animation issues during search
  void _handleSearchAnimationStatus(AnimationStatus status) {
    if (!mounted) return;

    switch (status) {
      case AnimationStatus.completed:
        // When animation completes (search bar at top), mark search as active
        setState(() {
          isSearchActive = true;
        });
        // Use a longer delay on desktop/web to allow the cursor to render properly
        final delayMilliseconds =
            (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) ? 150 : 50;
        Future.delayed(Duration(milliseconds: delayMilliseconds), () {
          // Only request focus if auto focus is not disabled and not in link conversion mode
          if (!_disableAutoFocus &&
              !isLinkConversion &&
              !_searchFocusNode.hasFocus) {
            _searchFocusNode.requestFocus(); // Request focus on the search bar
          }
        });
        break;

      case AnimationStatus.dismissed:
        // When animation is dismissed (search bar back to original position)
        // Never allow dismissal during active search or loading
        if (isSearching || (isLoading && !isLinkConversion)) {
          // Force search bar back to top position
          _searchAnimController.forward();
          return;
        }

        // Only reset UI if not in active operations
        if (!isLoading && !isSearching && tfController.text.isEmpty) {
          setState(() {
            isSearchActive = false;
            isShowingSearchResults = false;
          });
        }
        break;

      default:
        break;
    }
  }

  Future<void> _loadTopCharts() async {
    // Set flag to prevent duplicate loading
    _isChartLoadRequested = true;

    try {
      setState(() => isLoadingCharts = true);
      final results = await _musicSearchService.fetchTop50USAPlaylist();

      // If component is unmounted, abort
      if (!mounted) return;

      // Only update top charts if the search text is still empty
      if (tfController.text.isNotEmpty) {
        // User started typing, so ignore these results
        setState(() {
          isLoadingCharts = false;
          _isChartLoadRequested = false;
        });
        return;
      }

      setState(() {
        searchResults = results;
        isLoadingCharts = false;
        _isChartLoadRequested = false;
        isShowingSearchResults = false;

        // Only activate search UI if user has interacted with search
        isSearchActive = isSearchFocused || _searchAnimController.value > 0;
      });
    } catch (e) {
      // print('Error loading top charts: $e');
      if (mounted) {
        setState(() {
          isLoadingCharts = false;
          _isChartLoadRequested = false;
        });

        // Only show error if search is still relevant
        if (tfController.text.isEmpty && isSearchActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading charts: $e')),
          );
        }
      }
    }
  }

  // Add a safety method to force search bar to top position
  void _ensureSearchBarAtTopPosition() {
    // Don't force top position during link conversion
    if (isLinkConversion) return;

    if (isSearching || isLoading || tfController.text.isNotEmpty) {
      if (_searchAnimController.value < 1.0 &&
          !_searchAnimController.isAnimating) {
        _searchAnimController.forward();
      }
      if (_logoFadeController.value < 1.0 && !_logoFadeController.isAnimating) {
        _logoFadeController.forward();
      }
    }
  }

  // Replace with batched state updates to reduce rebuilds
  void _updateStateWithBatchedChanges(void Function() updates) {
    // Avoid setting state if widget is not mounted
    if (!mounted) return;

    // Use a microtask to batch state updates that occur in the same frame
    Future.microtask(() {
      if (mounted) {
        setState(updates);
      }
    });
  }

  // Preload top charts without affecting UI state yet
  Future<void> _preloadTopCharts() async {
    try {
      // Start fetching without awaiting
      final resultsFuture = _musicSearchService.fetchTop50USAPlaylist();

      // If we get here at least we've started the request
      _isChartLoadRequested = true;

      // Now await the result
      final results = await resultsFuture;

      // If component is unmounted, abort
      if (!mounted) return;

      // Store results but don't update UI state yet
      searchResults = results;
      isLoadingCharts = false;

      // If we're already in search mode, update the UI
      if (isSearchActive && tfController.text.isEmpty) {
        setState(() {
          isShowingSearchResults = false;
        });
      }
    } catch (e) {
      // Silently handle error, we'll retry when needed
      if (mounted) {
        isLoadingCharts = false;
        _isChartLoadRequested = false;
      }
    }
  }

  // Add this method to preload images
  void _precacheAssets() {
    // Get device pixel ratio to determine which images to preload
    final devicePixelRatio =
        MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;

    // For high-density displays (mobile), preload high-res logo
    if (devicePixelRatio > 2.0) {
      precacheImage(const AssetImage(appLogoTextHiRes), context);
    } else {
      // For standard displays, preload regular logo
      precacheImage(const AssetImage(appLogoText), context);
    }

    // Always preload these common assets
    precacheImage(const AssetImage(appLogo), context);
    precacheImage(const AssetImage(homeGraphics), context);
  }
}
