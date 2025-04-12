import 'package:brick_game/pages/arkanoid/controller.dart';
import 'package:brick_game/pages/game_details.dart';
import 'package:brick_game/pages/tetris/controller.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArkanoidPage extends StatelessWidget {
  ArkanoidPage({super.key});
  final ArkanoidController controller = Get.find();

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
                BlockType cell = BlockType.empty;

                // Draw bricks from playfield
                if (row < controller.playfield.length && col < controller.playfield[0].length) {
                  cell = controller.playfield[row][col];
                }

                // Draw paddle
                if (row == 25 - 2 && col >= controller.paddleX && col < controller.paddleX + 3) {
                  cell = BlockType.filled;
                }

                // Draw ball
                if (controller.gameState != GameState.gameOver) {
                  if (row == controller.ballY && col == controller.ballX) {
                    cell = BlockType.filled;
                  }
                }

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
