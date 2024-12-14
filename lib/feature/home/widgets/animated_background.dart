import 'package:cassettefrontend/core/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:vitality/vitality.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class AnimatedBackground extends StatelessWidget {
  AnimatedBackground({super.key});

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
  Widget build(BuildContext context) {
    return FutureBuilder<List<ui.Image>>(
        future: loadImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Vitality.randomly(
              whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
              randomItemsColors: const [Colors.yellow],
              background: Colors.transparent,
              itemsCount: 16,
              maxSize: 60,
              minSize: 60,
              maxSpeed: 0.5,
              minSpeed: 0.5,
              enableYMovements: true,
              enableXMovements: true,
              randomItemsBehaviours: snapshot.data
                      ?.map((image) => ItemBehaviour(
                            shape: ShapeType.Image,
                            image: image,
                          ))
                      .toList() ??
                  [],
            );
          }
          return const SizedBox();
        });
  }
}
