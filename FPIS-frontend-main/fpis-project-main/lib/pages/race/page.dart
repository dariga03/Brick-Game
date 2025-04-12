import 'package:brick_game/pages/race/controller.dart';
import 'package:brick_game/pages/game_details.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RacePage extends StatelessWidget {
  RacePage({super.key});
  final RaceController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.36,
          child: Obx(() {
            final bool u = controller.updater.value;
            return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                childAspectRatio: 1,
              ),
              itemCount: 25 * 10,
              itemBuilder: (context, index) {
                int row = index ~/ 10;
                int col = index % 10;
                BlockType cell = controller.playfield[row][col];
                return Block(cell);
              },
            );
          }),
        ),
        GameDetails(),
      ],
    );
  }
}
