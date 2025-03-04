import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:vitality/vitality.dart';
import 'dart:ui' as ui;
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

  List<String> bgElements = [
    icCircleBlue,
    icArrowsLeft,
    icZigZagRed1,
    icCircleRed,
    icArrowsRight,
    icZigZagRed3,
    icCircleLightRed,
    icZigZagRed2,
  ];

  Future<List<ui.Image>> loadImage() async {
    List<ui.Image> list = [];
    for (var image in bgElements) {
      ByteData data = await rootBundle.load(image);
      List<int> bytes = data.buffer.asUint8List();
      ui.Codec codec =
          await ui.instantiateImageCodec(Uint8List.fromList(bytes));
      ui.FrameInfo fi = await codec.getNextFrame();
      list.add(fi.image);
    }

    // Only start animation after images are loaded
    if (!_imagesLoaded && mounted) {
      setState(() {
        _imagesLoaded = true;
      });
      _fadeController.forward();
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
      value: 0, // Ensure we start at 0
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ui.Image>>(
      future: loadImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // Return empty widget while loading
        }

        return AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeController.value,
              child: Vitality.randomly(
                whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
                randomItemsColors: List.generate(12, (index) => Colors.white),
                background: Colors.transparent,
                itemsCount: 12,
                maxSize: 60,
                minSize: 30,
                maxSpeed: 0.25,
                minSpeed: 0.1,
                enableYMovements: true,
                enableXMovements: true,
                randomItemsBehaviours: snapshot.data
                        ?.map((image) => ItemBehaviour(
                              shape: ShapeType.Image,
                              image: image,
                            ))
                        .toList() ??
                    [],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
