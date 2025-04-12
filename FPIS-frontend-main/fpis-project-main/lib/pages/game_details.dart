import 'package:brick_game/controllers/game_details_controller.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameDetails extends GetView<GameDetailsController> {
  const GameDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Text("SCORE"),
          Text("${controller.score}"),
          SizedBox(height: 10),
          Text("HI-SCORE"),
          Text("${controller.hiScore}"),
          SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width / 5,
            height: MediaQuery.of(context).size.width / 5,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
              ),
              itemCount: 4 * 4,
              itemBuilder: (context, index) => Obx(() {
                final u = controller.updater.value;
                int row = index ~/ 4;
                int col = index % 4;

                final diff = 4 - controller.matrix.length;
                final l = controller.matrix.length;
                if (diff > 0) {
                  for (int i = 0; i < l; i++) {
                    for (int j = 0; j < diff; j++) {
                      controller.matrix[i].add(false);
                    }
                  }
                  for (int i = 0; i < diff; i++) {
                    controller.matrix.add(List.filled(4, false).obs);
                  }
                }

                bool exists = controller.matrix[row][col];

                return Block(exists ? BlockType.filled : BlockType.empty);
              }),
            ),
          ),
          SizedBox(height: 10),
          Text("SPEED"),
          Text("${controller.speed}"),
          SizedBox(height: 10),
          Text("GOAL"),
          Text("${controller.currentGoal}/${controller.goal}"),
          SizedBox(height: 10),
          Text("LEVEL"),
          Text("${controller.level}"),
        ],
      ),
    );
  }
}
