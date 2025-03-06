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

  void _handleSearchFocus() {
    setState(() {
      isSearchFocused = _searchFocusNode.hasFocus;
    });

    if (_searchFocusNode.hasFocus) {
      // Fast fade out
      _logoFadeController.duration = const Duration(milliseconds: 350);
      _searchAnimController.forward();
      _logoFadeController.forward();
    } else if (tfController.text.isEmpty) {
      // Slower fade in
      _logoFadeController.duration = const Duration(milliseconds: 800);
      _searchAnimController.reverse();
      _logoFadeController.reverse();
    }
  }

  void _handleTextChange() {
    if (tfController.text.isNotEmpty && !_searchAnimController.isAnimating) {
      // Fast fade out
      _logoFadeController.duration = const Duration(milliseconds: 350);
      _searchAnimController.forward();
      _logoFadeController.forward();
    } else if (tfController.text.isEmpty &&
        !_searchFocusNode.hasFocus &&
        !_searchAnimController.isAnimating) {
      // Slower fade in
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
        tfController.text.isNotEmpty;

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

                  // Search bar that can animate up to just below the nav bar
                  AnimatedBuilder(
                    animation: _searchAnimController,
                    builder: (context, searchBarChild) {
                      return Column(
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
                                        opacity: 1 - _logoFadeController.value,
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
                              child: AnimatedBuilder(
                                animation: _searchAnimController,
                                builder: (context, child) {
                                  // Calculate a smooth top padding from 22.0 to 5.0 based on animation value
                                  final animValue = CurvedAnimation(
                                    parent: _searchAnimController,
                                    curve: Curves.easeOutQuart,
                                  ).value;
                                  final double topPadding =
                                      lerpDouble(22.0, 5.0, animValue)!;
                                  final double verticalOffset =
                                      lerpDouble(0, -160, animValue)!;

                                  return Transform.translate(
                                    offset: Offset(0, verticalOffset),
                                    child: Padding(
                                      padding: EdgeInsets.only(top: topPadding),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: ClipboardPasteButton(
                                    hint:
                                        "Search or paste your music link here...",
                                    controller: tfController,
                                    focusNode: _searchFocusNode,
                                    onPaste: (value) {
                                      _autoConvertTimer?.cancel();

                                      final linkLower = value.toLowerCase();
                                      final isSupported = linkLower
                                              .contains('spotify.com') ||
                                          linkLower
                                              .contains('apple.com/music') ||
                                          linkLower.contains('deezer.com');

                                      if (isSupported &&
                                          !isLoading &&
                                          mounted) {
                                        setState(() {
                                          searchResults = null;
                                        });

                                        _autoConvertTimer = Timer(
                                            const Duration(milliseconds: 300),
                                            () {
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
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
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

                  // Bottom graphics and create account button (only visible when not searching)
                  AnimatedBuilder(
                    animation: _logoFadeController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1 - _logoFadeController.value,
                        child: Visibility(
                          visible: !isSearchActive ||
                              _logoFadeController.value < 0.5,
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

    print('START _handleLinkConversion with link: $link');

    setState(() {
      isLoading = true;
    });

    try {
      print('Making API request to convert link...');
      // Make the conversion request
      final response = await _apiService.convertMusicLink(link);

      // Log the response for debugging
      print('API Response received: ${response.runtimeType}');
      print('API Response keys: ${response.keys.toList()}');
      print('API Response full data: $response');

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

        print('Validating required fields...');
        for (final field in requiredFields) {
          print(
              'Field "$field": ${response.containsKey(field) ? "exists" : "MISSING"}, value: ${response[field]}');
        }

        final details = response['details'] as Map<String, dynamic>?;
        if (details != null) {
          print('Details fields: ${details.keys.toList()}');
          print('Title: ${details['title']}');
          print('Artist: ${details['artist']}');
          print('Cover Art: ${details['coverArtUrl']}');
        } else {
          print('WARNING: Details is null or not a map');
        }

        final missingFields = requiredFields
            .where((field) =>
                !response.containsKey(field) || response[field] == null)
            .toList();

        if (missingFields.isNotEmpty) {
          throw Exception(
              'Missing required fields in response: ${missingFields.join(', ')}');
        }

        // Add the original link to the response data for later use in reports
        response['originalLink'] = link;

        print('Navigating to /post with data...');
        // Navigate to PostPage which will handle routing to the appropriate page
        context.go('/post', extra: response);
      }
    } catch (e) {
      print('ERROR in _handleLinkConversion: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Show error snackbar with more detailed message
        final scaffoldContext = context;
        if (mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text('Error converting link: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        print('Link conversion error: $e');
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
      final results = await _apiService.searchMusic(query);
      if (mounted) {
        setState(() {
          searchResults = results;
          isSearching = false;
        });
      }
    } catch (e) {
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
    if (isSearching) {
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
          return ListTile(
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
              final spotifyUrl = 'https://open.spotify.com/$type/$id';

              tfController.text =
                  'Converting ${type.substring(0, 1).toUpperCase() + type.substring(1)} - $title...';

              setState(() {
                searchResults = null;
                isLoading = true;
              });
              _handleLinkConversion(spotifyUrl);
            },
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
