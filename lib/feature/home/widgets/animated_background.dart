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

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  double _opacity = 0.0;

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
    return list;
  }

  @override
  void initState() {
    super.initState();
    // Delay a bit then fade the background in over 1 second
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ui.Image>>(
      future: loadImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 1000),
            child: Vitality.randomly(
              whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
              randomItemsColors: const [Colors.yellow],
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
        }
        return const SizedBox();
      },
    );
  }
}
