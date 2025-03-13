import 'package:cassettefrontend/core/common_widgets/animated_primary_button.dart';
import 'package:cassettefrontend/core/common_widgets/app_scaffold.dart';
import 'package:cassettefrontend/core/common_widgets/app_toolbar.dart';
import 'package:cassettefrontend/core/common_widgets/text_field_widget.dart';
import 'package:cassettefrontend/core/common_widgets/music_search_bar.dart';
import 'package:cassettefrontend/core/constants/app_constants.dart';
import 'package:cassettefrontend/core/styles/app_styles.dart';
import 'package:cassettefrontend/core/utils/app_utils.dart';
import 'package:cassettefrontend/core/services/api_service.dart';
import 'package:cassettefrontend/core/services/music_search_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class AddMusicPage extends StatefulWidget {
  const AddMusicPage({super.key});

  @override
  State<AddMusicPage> createState() => _AddMusicPageState();
}

class _AddMusicPageState extends State<AddMusicPage> {
  bool isMenuVisible = false;
  bool isLoading = false;
  bool isSearching = false;
  bool isShowingSearchResults = false;
  bool isLoadingCharts = false;
  bool _isChartLoadRequested = false;
  bool _itemSelected = false; // New flag to indicate an item has been selected
  String errorMessage = '';
  Map<String, dynamic>? searchResults;
  Map<String, dynamic>? selectedItem;
  String? pastedLinkSource;
  Timer? _searchDebounce;

  // Initialize services
  final ApiService _apiService = ApiService();
  final MusicSearchService _musicSearchService = MusicSearchService();
  final FocusNode _searchFocusNode = FocusNode();

  TextEditingController linkCtr = TextEditingController();
  TextEditingController desCtr = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Add focus listener
    _searchFocusNode.addListener(_handleSearchFocus);

    // Request focus after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();

      // Load top charts when page opens
      _loadTopCharts();

      // Ensure search UI is visible during loading
      _ensureSearchUIVisibleDuringLoading();
    });
  }

  @override
  void dispose() {
    // Cancel any active searches
    _musicSearchService.cancelActiveRequests();
    _searchDebounce?.cancel();

    // Dispose controllers and focus nodes
    linkCtr.dispose();
    desCtr.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  // Handle search focus changes
  void _handleSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      // When search gets focus, show search results
      setState(() {
        isShowingSearchResults = true;
      });

      // Load top charts if not already loaded
      if (searchResults == null && !isLoadingCharts) {
        _loadTopCharts();
      }
    } else {
      // Only hide results if user explicitly taps outside or presses back
      // Don't hide when text is entered or during operations
      if (linkCtr.text.isEmpty && !isLoading && !isSearching) {
        setState(() {
          isShowingSearchResults = false;
        });
      }
    }
  }

  // Load top charts
  Future<void> _loadTopCharts() async {
    // Set flag to prevent duplicate loading
    _isChartLoadRequested = true;

    try {
      setState(() => isLoadingCharts = true);
      // Ensure search UI is visible during loading
      _ensureSearchUIVisibleDuringLoading();

      final results = await _musicSearchService.fetchTop50USAPlaylist();

      // If component is unmounted, abort
      if (!mounted) return;

      // Only update top charts if the search text is still empty
      if (linkCtr.text.isNotEmpty) {
        // User started typing, so ignore these results
        setState(() {
          isLoadingCharts = false;
          _isChartLoadRequested = false;
        });
        return;
      }

      // Ensure each result has an id field for proper handling
      if (results.containsKey('results') && results['results'] is List) {
        final List<dynamic> items = results['results'];
        for (int i = 0; i < items.length; i++) {
          // If an item doesn't have an id, generate one
          if (!items[i].containsKey('id') || items[i]['id'] == null) {
            items[i]['id'] = 'chart_item_$i';
          }
        }
      }

      setState(() {
        searchResults = results;
        isLoadingCharts = false;
        _isChartLoadRequested = false;
        isShowingSearchResults = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingCharts = false;
          _isChartLoadRequested = false;
        });

        // Only show error if search is still relevant
        if (linkCtr.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading charts: $e')),
          );
        }
      }
    }
  }

  // Handle link conversion
  Future<void> _handleLinkConversion(String link) async {
    // Get the link from selectedItem if available, otherwise use the provided link
    final String linkToConvert =
        selectedItem != null ? selectedItem!['url'] as String : link;

    if (linkToConvert.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a music link';
      });
      return;
    }

    setState(() {
      isLoading = true;
      // Only keep search overlay visible during loading if no item is selected
      isShowingSearchResults = selectedItem == null;
      errorMessage = '';
    });

    try {
      // Call API to convert the link
      final response = await _apiService.convertMusicLink(linkToConvert);

      if (!mounted) return;

      // Add description to the response data if provided
      if (desCtr.text.isNotEmpty) {
        response['description'] = desCtr.text;
      }

      setState(() {
        isLoading = false;
      });

      // Navigate to post page with the converted data
      context.go('/post', extra: response);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Error converting link: ${e.toString()}';
        // Only keep search overlay visible on error if no item is selected
        isShowingSearchResults = selectedItem == null;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error converting link: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handleLinkConversion(link),
          ),
        ),
      );
    }
  }

  // Handle music search
  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = null;
        isSearching = false;
        // Don't hide search results when query is empty, just show top charts instead
        _loadTopCharts();
      });
      return;
    }

    if (isSearching) return;

    setState(() {
      isSearching = true;
      isLoading = true;
      isShowingSearchResults = true; // Ensure search overlay is visible
    });

    // Ensure search UI is visible during loading
    _ensureSearchUIVisibleDuringLoading();

    try {
      final results = await _musicSearchService.searchMusic(query);

      if (!mounted) return;

      // Check if the query is still the same
      if (query != linkCtr.text) {
        setState(() {
          isSearching = false;
          isLoading = false;
          // Keep search results visible even if query changed
          isShowingSearchResults = true;
        });
        return;
      }

      setState(() {
        searchResults = results;
        isSearching = false;
        isLoading = false;
        isShowingSearchResults =
            true; // Keep search overlay visible after results arrive
      });
    } catch (e) {
      if (!mounted) return;

      // Check if the query is still the same
      if (query != linkCtr.text) {
        setState(() {
          isSearching = false;
          isLoading = false;
          // Keep search results visible even on error
          isShowingSearchResults = true;
        });
        return;
      }

      setState(() {
        isSearching = false;
        isLoading = false;
        isShowingSearchResults =
            true; // Keep search overlay visible even on error
      });

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

  void _showSearchUI() {
    setState(() {
      isShowingSearchResults = true;
    });
    _searchFocusNode.requestFocus();

    // Always load top charts when showing search UI if no results are available
    if (searchResults == null && !isLoadingCharts && !_isChartLoadRequested) {
      _loadTopCharts();
    }
  }

  // Helper method to show top charts on the main page
  void _showTopChartsOnMainPage() {
    // Only load if not already loading and no search text
    if (!isLoadingCharts && !_isChartLoadRequested && linkCtr.text.isEmpty) {
      _loadTopCharts();
    }
  }

  // Helper method to ensure search UI is shown during loading
  void _ensureSearchUIVisibleDuringLoading() {
    if (selectedItem == null && (isLoading || isSearching || isLoadingCharts)) {
      setState(() {
        isShowingSearchResults = true;
      });
    }
  }

  // Unified handler for selecting an item from search results or top charts.
  void _handleItemSelection(dynamic item, {bool fromTopCharts = false}) {
    debugPrint("handleItemSelection invoked. fromTopCharts: $fromTopCharts");
    debugPrint("Raw item details: ${item.toString()}");

    // Use Apple Music as the source for all chart and search results
    final source = 'apple_music';

    final id = item['id']?.toString() ?? '';
    final title = item['title'] ?? 'Unknown';
    final artist = item['artist'] ?? '';
    final type = item['type']?.toString().toLowerCase() ?? '';

    // Handle URL extraction for different result types
    final String url = fromTopCharts
        ? item['external_url'] ??
            item['url'] ??
            _constructUrl(source, type, id, title)
        : item['url'] ?? _constructUrl(source, type, id, title);

    debugPrint(
        "Computed values - source: $source, id: $id, title: $title, artist: $artist, type: $type");

    setState(() {
      _itemSelected = true;
      isShowingSearchResults = false;
      isLoadingCharts = false;
      _isChartLoadRequested = false;
      searchResults = null;
      selectedItem = {
        'title': title,
        'artist': artist,
        'type': type,
        'source': source,
        'url': url,
        'coverArtUrl': item['coverArtUrl'] ??
            item['artwork']?['url']
                ?.toString()
                .replaceAll('{w}x{h}', '500x500'),
        'heroTag': 'selected_${DateTime.now().millisecondsSinceEpoch}',
      };
      debugPrint("Final selectedItem: ${selectedItem.toString()}");
    });
    linkCtr.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if search results should be shown - always show during searching or loading
    // But never show if an item is selected
    final bool shouldShowResults = selectedItem == null &&
        (isShowingSearchResults || isSearching || isLoadingCharts || isLoading);

    // Load top charts on the main page if needed.
    if (selectedItem == null &&
        !_itemSelected &&
        !shouldShowResults &&
        searchResults == null &&
        !isLoadingCharts &&
        !_isChartLoadRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTopChartsOnMainPage();
      });
    }

    // Debug print to check visibility conditions
    debugPrint('shouldShowResults: $shouldShowResults');
    debugPrint('selectedItem: $selectedItem');
    debugPrint('isShowingSearchResults: $isShowingSearchResults');
    debugPrint('isSearching: $isSearching');
    debugPrint('isLoadingCharts: $isLoadingCharts');
    debugPrint('isLoading: $isLoading');

    return AppScaffold(
      showGraphics: true,
      onBurgerPop: () {
        setState(() {
          isMenuVisible = !isMenuVisible;
        });
      },
      isMenuVisible: isMenuVisible,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              const SizedBox(height: 18),
              AppToolbar(burgerMenuFnc: () {
                setState(() {
                  isMenuVisible = !isMenuVisible;
                });
              }),
              const SizedBox(height: 18),
              profileTopView(),
              const SizedBox(height: 38),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                            "Search or paste your link below to convert a\nsong or playlist that goes in your profile",
                            textAlign: TextAlign.center,
                            style: AppStyles.addMusicSubTitleTs),
                        const SizedBox(height: 24),
                        // Search bar (always visible)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Music link or search",
                                textAlign: TextAlign.left,
                                style: AppStyles.authTextFieldLabelTextStyle),
                            const SizedBox(height: 10),
                            // Only show search bar if no item is selected
                            if (selectedItem == null)
                              MusicSearchBar(
                                hint: "Search or paste your music link here",
                                controller: linkCtr,
                                focusNode: _searchFocusNode,
                                isLoading: isLoading || isSearching,
                                onTap: _showSearchUI,
                                onPaste: (value) {
                                  // Handle paste events for music links
                                  final linkLower = value.toLowerCase();
                                  final isSupported = linkLower
                                          .contains('spotify.com') ||
                                      linkLower.contains('apple.com/music') ||
                                      linkLower.contains('music.apple.com') ||
                                      linkLower.contains('deezer.com');

                                  if (isSupported && !isLoading && mounted) {
                                    // Determine the source of the link
                                    String source = 'unknown';
                                    if (linkLower.contains('spotify.com')) {
                                      source = 'Spotify';
                                    } else if (linkLower
                                            .contains('apple.com/music') ||
                                        linkLower.contains('music.apple.com')) {
                                      source = 'Music';
                                    } else if (linkLower
                                        .contains('deezer.com')) {
                                      source = 'Deezer';
                                    }

                                    setState(() {
                                      isShowingSearchResults = false;
                                      searchResults = null;
                                      selectedItem = null;
                                      pastedLinkSource = source;
                                      errorMessage = '';
                                    });
                                  }
                                },
                                onSearch: (query) {
                                  // Never initiate a new search if one is already in progress
                                  if (!isLoading && !isSearching) {
                                    _handleSearch(query);
                                  }
                                },
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) {
                                  // When user hits enter/done, perform search if there's text
                                  if (linkCtr.text.isNotEmpty) {
                                    final linkLower =
                                        linkCtr.text.toLowerCase();
                                    final isSupported = linkLower
                                            .contains('spotify.com') ||
                                        linkLower.contains('apple.com/music') ||
                                        linkLower.contains('music.apple.com') ||
                                        linkLower.contains('deezer.com');

                                    if (isSupported) {
                                      // Just update the pasted link source
                                      String source = 'unknown';
                                      if (linkLower.contains('spotify.com')) {
                                        source = 'Spotify';
                                      } else if (linkLower
                                              .contains('apple.com/music') ||
                                          linkLower
                                              .contains('music.apple.com')) {
                                        source = 'Music';
                                      } else if (linkLower
                                          .contains('deezer.com')) {
                                        source = 'Deezer';
                                      }

                                      setState(() {
                                        selectedItem = null;
                                        pastedLinkSource = source;
                                        isShowingSearchResults = false;
                                        errorMessage = '';
                                      });
                                    } else {
                                      _handleSearch(linkCtr.text);
                                    }
                                  }
                                },
                              ),

                            // Display selected item or pasted link information
                            _buildSelectedItemInfo(),
                          ],
                        ),

                        // Only show description field and convert button when not showing search results
                        AnimatedOpacity(
                          opacity: shouldShowResults ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: shouldShowResults,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                Text("Description",
                                    textAlign: TextAlign.left,
                                    style:
                                        AppStyles.authTextFieldLabelTextStyle),
                                const SizedBox(height: 10),
                                TextFieldWidget(
                                    hint:
                                        "Let us know a little bit about this song or playlist!",
                                    maxLines: 6,
                                    minLines: 6,
                                    height: 160,
                                    height2: 156,
                                    controller: desCtr),
                                const SizedBox(height: 32),
                                AnimatedPrimaryButton(
                                  text: isLoading ? "Converting..." : "Convert",
                                  onTap: () {
                                    // Debug prints
                                    debugPrint('Convert button tapped');
                                    debugPrint('isLoading: $isLoading');
                                    debugPrint('selectedItem: $selectedItem');
                                    debugPrint('linkCtr.text: ${linkCtr.text}');

                                    // Skip the action if loading
                                    if (isLoading) return;

                                    Future.delayed(
                                      const Duration(milliseconds: 180),
                                      () {
                                        // Debug prints inside delayed callback
                                        debugPrint('Inside delayed callback');

                                        // Check if we have a selected item or a link in the text field
                                        if (selectedItem != null) {
                                          debugPrint(
                                              'Converting selected item: ${selectedItem!['title']}');
                                          _handleLinkConversion("");
                                        } else if (linkCtr.text.isNotEmpty) {
                                          debugPrint(
                                              'Converting link: ${linkCtr.text}');
                                          _handleLinkConversion(linkCtr.text);
                                        } else {
                                          debugPrint(
                                              'No item or link to convert');
                                          setState(() {
                                            errorMessage =
                                                'Please enter a music link or search for a song';
                                          });
                                        }
                                      },
                                    );
                                  },
                                  height: 40,
                                  width: MediaQuery.of(context).size.width - 46,
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
                                const SizedBox(height: 8),
                                if (errorMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      errorMessage,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 48),
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

          // Search overlay
          if (shouldShowResults)
            Positioned.fill(
              child: _buildSearchOverlay(),
            ),
        ],
      ),
    );
  }

  Widget profileTopView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage:
                NetworkImage(AppUtils.profileModel.profilePath ?? ''),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 22),
          Text("Add Music", style: AppStyles.addMusicTitleTs),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay() {
    // Don't show search overlay if an item is selected and we're not loading/searching
    if (selectedItem != null) {
      return const SizedBox.shrink();
    }

    // Create a background that covers the entire screen with the app's tan background color
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: AppColors.appBg, // Tan background color
        child: SafeArea(
          child: Column(
            children: [
              // Search bar at the top
              Container(
                color: AppColors.textPrimary, // Dark background for search bar
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isShowingSearchResults = false;
                            });
                            _searchFocusNode.unfocus();
                          },
                        ),
                        Text(
                          "Search Music",
                          style: AppStyles.addMusicTitleTs.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Use MusicSearchBar for search and paste functionality
                    MusicSearchBar(
                      hint: "Search or paste your music link here",
                      controller: linkCtr,
                      focusNode: _searchFocusNode,
                      isLoading: isLoading || isSearching,
                      onTap: _showSearchUI,
                      height: 50,
                      height2: 46,
                      onPaste: (value) {
                        // Handle paste events for music links
                        final linkLower = value.toLowerCase();
                        final isSupported = linkLower.contains('spotify.com') ||
                            linkLower.contains('apple.com/music') ||
                            linkLower.contains('music.apple.com') ||
                            linkLower.contains('deezer.com');

                        if (isSupported && !isLoading && mounted) {
                          // Determine the source of the link
                          String source = 'unknown';
                          if (linkLower.contains('spotify.com')) {
                            source = 'Spotify';
                          } else if (linkLower.contains('apple.com/music') ||
                              linkLower.contains('music.apple.com')) {
                            source = 'Music';
                          } else if (linkLower.contains('deezer.com')) {
                            source = 'Deezer';
                          }

                          setState(() {
                            isShowingSearchResults = false;
                            searchResults = null;
                            selectedItem = null;
                            pastedLinkSource = source;
                            errorMessage = '';
                          });
                        }
                      },
                      onSearch: (query) {
                        // Never initiate a new search if one is already in progress
                        if (!isLoading && !isSearching) {
                          _handleSearch(query);
                        }
                      },
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        // When user hits enter/done, perform search if there's text
                        if (linkCtr.text.isNotEmpty) {
                          final linkLower = linkCtr.text.toLowerCase();
                          final isSupported =
                              linkLower.contains('spotify.com') ||
                                  linkLower.contains('apple.com/music') ||
                                  linkLower.contains('music.apple.com') ||
                                  linkLower.contains('deezer.com');

                          if (isSupported) {
                            // Just update the pasted link source
                            String source = 'unknown';
                            if (linkLower.contains('spotify.com')) {
                              source = 'Spotify';
                            } else if (linkLower.contains('apple.com/music') ||
                                linkLower.contains('music.apple.com')) {
                              source = 'Music';
                            } else if (linkLower.contains('deezer.com')) {
                              source = 'Deezer';
                            }

                            setState(() {
                              selectedItem = null;
                              pastedLinkSource = source;
                              isShowingSearchResults = false;
                              errorMessage = '';
                            });
                          } else {
                            _handleSearch(linkCtr.text);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Search results content - takes up entire screen below search bar
              Expanded(
                child: _buildSearchResultsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsContent() {
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
                  AppColors.textPrimary, // Dark spinner on tan background
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isLoadingCharts
                    ? 'Loading top charts...'
                    : isSearching
                        ? 'Searching...'
                        : 'Loading...',
                style: AppStyles.itemDesTs.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary, // Dark text on tan background
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If searchResults is null, schedule loading top charts
    if (searchResults == null) {
      // Schedule the loading after the build phase
      if (!isLoadingCharts && !_isChartLoadRequested) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isLoadingCharts && searchResults == null) {
            _loadTopCharts();
          }
        });
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.textPrimary, // Dark spinner on tan background
            ),
          ),
        ),
      );
    }

    // Ensure we have a valid results list
    final results = searchResults!['results'] as List<dynamic>? ?? [];

    // Print the first result for debugging
    if (results.isNotEmpty) {
      debugPrint('First result: ${results.first}');
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                color: AppColors.textPrimary,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Header for results
    final headerText = linkCtr.text.isEmpty ? "Top Charts" : "Search Results";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with source info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Music icon
              const Icon(
                Icons.music_note,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            itemCount: results.length,
            physics: const AlwaysScrollableScrollPhysics(),
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            addSemanticIndexes: false,
            itemBuilder: (context, index) {
              final item = results[index];
              final type = item['type']?.toString().toLowerCase() ?? '';

              // Get appropriate icon based on content type
              IconData typeIcon;
              switch (type) {
                case 'track':
                  typeIcon = Icons.music_note;
                  break;
                case 'album':
                  typeIcon = Icons.album;
                  break;
                case 'artist':
                  typeIcon = Icons.person;
                  break;
                case 'playlist':
                  typeIcon = Icons.queue_music;
                  break;
                default:
                  typeIcon = Icons.music_note;
              }

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Log the tap event from main page top charts.
                    debugPrint(
                        "Item tapped from main page top charts for item: ${item.toString()}");
                    // Always treat these results as top charts.
                    _handleItemSelection(item, fromTopCharts: true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Cover art with nice shadow
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item['coverArtUrl'] != null
                                  ? Image.network(
                                      item['coverArtUrl'],
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Fallback if image fails to load
                                        return Container(
                                          width: 64,
                                          height: 64,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            typeIcon,
                                            color: AppColors.textPrimary,
                                            size: 30,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 64,
                                      height: 64,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        typeIcon,
                                        color: AppColors.textPrimary,
                                        size: 30,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['artist'] ?? '',
                                  style: TextStyle(
                                    color:
                                        AppColors.textPrimary.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                // Type badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        typeIcon,
                                        size: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        type.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget to display selected item or pasted link information
  Widget _buildSelectedItemInfo() {
    if (selectedItem != null) {
      // Display selected item info
      final title = selectedItem!['title'] ?? 'Unknown';
      final artist = selectedItem!['artist'] ?? '';
      final type = selectedItem!['type']?.toString() ?? '';
      final source = 'Spotify'; // Always show as Spotify
      final coverArtUrl = selectedItem!['coverArtUrl'];
      final heroTag = selectedItem!['heroTag'] ?? 'selected_item';

      // Get appropriate icon based on content type
      IconData typeIcon;
      switch (type.toLowerCase()) {
        case 'track':
          typeIcon = Icons.music_note;
          break;
        case 'album':
          typeIcon = Icons.album;
          break;
        case 'artist':
          typeIcon = Icons.person;
          break;
        case 'playlist':
          typeIcon = Icons.queue_music;
          break;
        default:
          typeIcon = Icons.music_note;
      }

      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textPrimary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover art
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: coverArtUrl != null
                    ? Image.network(
                        coverArtUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image fails to load
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              typeIcon,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          typeIcon,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (artist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        artist,
                        style: TextStyle(
                          color: AppColors.textPrimary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Type and source badges
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.animatedBtnColorConvertTop
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.animatedBtnColorConvertTop
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              typeIcon,
                              size: 10,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Clear button
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                setState(() {
                  selectedItem = null;
                  linkCtr.clear();
                  errorMessage = '';
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    } else if (pastedLinkSource != null && linkCtr.text.isNotEmpty) {
      // Display pasted link info
      final displaySource =
          pastedLinkSource == 'Music' ? 'Spotify' : pastedLinkSource;

      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textPrimary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Platform icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: displaySource == 'Spotify'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: displaySource == 'Spotify'
                      ? Colors.green.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.music_note,
                color: displaySource == 'Spotify' ? Colors.green : Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Link info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$displaySource link pasted",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    linkCtr.text,
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Clear button
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                setState(() {
                  pastedLinkSource = null;
                  linkCtr.clear();
                  errorMessage = '';
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    // Return empty container if no item is selected and no link is pasted
    return const SizedBox.shrink();
  }

  // Widget to display top charts on the main page
  Widget _buildMainPageTopCharts() {
    return SizedBox(
      height: 350, // Fixed total height
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: Text(
              "Top Charts",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildMainPageChartsList(maxItems: 5),
          ),
        ],
      ),
    );
  }

  // Widget to display top charts list on the main page
  Widget _buildMainPageChartsList({int? maxItems}) {
    // Show loading indicator while loading charts
    if (isLoadingCharts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textPrimary, // Dark spinner on tan background
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading top charts...',
                style: AppStyles.itemDesTs.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary, // Dark text on tan background
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If searchResults is null, schedule loading top charts
    if (searchResults == null) {
      // Schedule the loading after the build phase
      if (!isLoadingCharts && !_isChartLoadRequested) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isLoadingCharts && searchResults == null) {
            _loadTopCharts();
          }
        });
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.textPrimary, // Dark spinner on tan background
            ),
          ),
        ),
      );
    }

    // Ensure we have a valid results list
    final results = searchResults!['results'] as List<dynamic>? ?? [];

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                color: AppColors.textPrimary,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Limit the number of items if maxItems is specified
    final displayResults = maxItems != null && maxItems < results.length
        ? results.sublist(0, maxItems)
        : results;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      itemCount: displayResults.length,
      physics: const AlwaysScrollableScrollPhysics(),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      itemBuilder: (context, index) {
        final item = displayResults[index];
        final type = item['type']?.toString().toLowerCase() ?? '';

        // Get appropriate icon based on content type
        IconData typeIcon;
        switch (type) {
          case 'track':
            typeIcon = Icons.music_note;
            break;
          case 'album':
            typeIcon = Icons.album;
            break;
          case 'artist':
            typeIcon = Icons.person;
            break;
          case 'playlist':
            typeIcon = Icons.queue_music;
            break;
          default:
            typeIcon = Icons.music_note;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Log the tap event from main page top charts.
              debugPrint(
                  "Item tapped from main page top charts for item: ${item.toString()}");
              // Always treat these results as top charts.
              _handleItemSelection(item, fromTopCharts: true);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Cover art with nice shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item['coverArtUrl'] != null
                            ? Image.network(
                                item['coverArtUrl'],
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if image fails to load
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      typeIcon,
                                      color: AppColors.textPrimary,
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 64,
                                height: 64,
                                color: Colors.grey[200],
                                child: Icon(
                                  typeIcon,
                                  color: AppColors.textPrimary,
                                  size: 30,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? 'Unknown',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['artist'] ?? '',
                            style: TextStyle(
                              color: AppColors.textPrimary.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.animatedBtnColorConvertTop
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.animatedBtnColorConvertTop
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  typeIcon,
                                  size: 12,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  type.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _constructUrl(String source, String type, String id, String title) {
    if (source == 'apple_music') {
      if (type == 'artist') {
        final urlSafeName = title
            .toLowerCase()
            .replaceAll(' ', '-')
            .replaceAll(RegExp(r'[^\w-]'), '');
        return 'https://music.apple.com/us/artist/$urlSafeName/$id';
      }
      return 'https://music.apple.com/us/album/$id';
    }
    return 'https://music.apple.com/search?term=${Uri.encodeComponent(title)}';
  }
}
