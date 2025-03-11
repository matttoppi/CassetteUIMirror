import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:vitality/vitality.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _imagesLoaded = false;
  bool _isLowPerformanceDevice = false;
  late final Future<List<ui.Image>> _imagesFuture;

  // Cache for loaded images to prevent reloading
  List<ui.Image>? _cachedImages;

  // Lifecycle observer reference
  late final _LifecycleObserver _lifecycleObserver;

  // List of background elements
  final List<String> bgElements = [
    icCircleBlue,
    icArrowsLeft,
    icZigZagRed1,
    icCircleRed,
    icArrowsRight,
    icZigZagRed3,
    icCircleLightRed,
    icZigZagRed2,
  ];

  @override
  void initState() {
    super.initState();

    // Create animation controller with optimized duration
    _fadeController = AnimationController(
      // Coordinate with HomePage animations - start slightly before logo appears
      duration: const Duration(milliseconds: 2200), // is the length that
      vsync: this,
      value: 0,
    );

    // Start loading images immediately in initState
    _imagesFuture = _loadAndCacheImages();

    // Detect if running on web or a likely low-performance device
    _isLowPerformanceDevice = kIsWeb ||
        !defaultTargetPlatform.toString().contains('ios') &&
            !defaultTargetPlatform.toString().contains('macos');

    // Add a listener to pause animations when app goes to background
    _lifecycleObserver = _LifecycleObserver(
      onPaused: () {
        if (mounted && _fadeController.isAnimating) {
          _fadeController.stop();
        }
      },
      onResumed: () {
        if (mounted && _imagesLoaded && !_fadeController.isCompleted) {
          _fadeController.forward();
        }
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  // Optimized image loading function with caching
  Future<List<ui.Image>> _loadAndCacheImages() async {
    // Return cached images if already loaded
    if (_cachedImages != null) return _cachedImages!;

    // Select fewer images for low performance devices
    final imagesToLoad = _isLowPerformanceDevice
        ? bgElements.sublist(
            0, 5) // Use 5 images on low-end devices (increased from 4)
        : bgElements;

    List<ui.Image> list = [];

    try {
      // Load images in parallel for better performance
      final futures = imagesToLoad.map((image) async {
        // Use smaller image size for low performance devices
        final targetWidth =
            _isLowPerformanceDevice ? 64 : null; // Increased from 48

        // Add a small delay to sequence image loading and reduce memory pressure
        if (_isLowPerformanceDevice) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        ByteData data = await rootBundle.load(image);
        List<int> bytes = data.buffer.asUint8List();
        ui.Codec codec = await ui.instantiateImageCodec(
          Uint8List.fromList(bytes),
          targetWidth: targetWidth,
        );
        ui.FrameInfo fi = await codec.getNextFrame();
        return fi.image;
      }).toList();

      // Wait for all images to load
      list = await Future.wait(futures);

      // Start animation after images are loaded
      if (mounted) {
        setState(() {
          _imagesLoaded = true;
          _cachedImages = list; // Cache the loaded images
        });

        // Delayed start to coordinate with other homepage animations
        // This ensures background fades in after homepage initial layout
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _fadeController.forward();
          }
        });
      }
    } catch (e) {
      // If image loading fails, still try to show animation with empty list
      if (mounted) {
        setState(() {
          _imagesLoaded = true;
        });
        _fadeController.forward();
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive adjustments
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    // Calculate optimal parameters based on device and screen size
    // Increased number of items across all device types
    final itemsCount = _isLowPerformanceDevice
        ? 10 // Increased from 6
        : isSmallScreen
            ? 20 // Increased from 8
            : 30; // Increased from 12

    // Increased sizes across all device types
    final maxSize = _isLowPerformanceDevice
        ? 65.0 // Increased from 40.0
        : isSmallScreen
            ? 75.0 // Increased from 50.0
            : 90.0; // Increased from 60.0

    final minSize = _isLowPerformanceDevice
        ? 40.0 // Increased from 20.0
        : isSmallScreen
            ? 50.0 // Increased from 25.0
            : 60.0; // Increased from 30.0

    // Slightly reduced speeds to make larger shapes move at a pleasant pace
    final maxSpeed = _isLowPerformanceDevice
        ? 0.12 // Reduced from 0.15
        : isSmallScreen
            ? 0.18 // Reduced from 0.20
            : 0.22; // Reduced from 0.25

    final minSpeed = _isLowPerformanceDevice
        ? 0.04 // Reduced from 0.05
        : isSmallScreen
            ? 0.07 // Reduced from 0.08
            : 0.09; // Reduced from 0.1

    // Use FutureBuilder to handle async image loading
    return FutureBuilder<List<ui.Image>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        // Show nothing while loading
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        // Create repeatable patterns from loaded images for better distribution
        final patterns = _createPatterns(snapshot.data ?? []);

        return RepaintBoundary(
          // Add RepaintBoundary for better performance
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeController.value,
                child: child,
              );
            },
            child: Vitality.randomly(
              whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
              randomItemsColors:
                  List.generate(itemsCount, (index) => Colors.white),
              background: Colors.transparent,
              itemsCount: itemsCount,
              maxSize: maxSize,
              minSize: minSize,
              maxSpeed: maxSpeed,
              minSpeed: minSpeed,
              enableYMovements: true,
              enableXMovements: true,
              randomItemsBehaviours: patterns,
            ),
          ),
        );
      },
    );
  }

  // Helper function to create better distributed patterns from loaded images
  List<ItemBehaviour> _createPatterns(List<ui.Image> images) {
    if (images.isEmpty) return [];

    // Increased the count to match the itemsCount in build
    final int maxPatternCount = _isLowPerformanceDevice ? 10 : 24;
    final patterns = <ItemBehaviour>[];

    // Create a balanced distribution of images
    for (int i = 0; i < maxPatternCount; i++) {
      final imageIndex = i % images.length;
      patterns.add(
        ItemBehaviour(
          shape: ShapeType.Image,
          image: images[imageIndex],
        ),
      );
    }

    return patterns;
  }

  @override
  void dispose() {
    _fadeController.dispose();

    // Clear cached images to free memory
    _cachedImages = null;

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);

    super.dispose();
  }
}

// Custom lifecycle observer to manage animations when app is in background
class _LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback? onPaused;
  final VoidCallback? onResumed;

  _LifecycleObserver({this.onPaused, this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPaused?.call();
        break;
      case AppLifecycleState.resumed:
        onResumed?.call();
        break;
      default:
        break;
    }
  }
}
