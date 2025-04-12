import 'package:brick_game/pages/tetris/controller.dart';
import 'package:brick_game/pages/game_details.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TetrisPage extends StatelessWidget {
  TetrisPage({super.key});

  final TetrisController controller = Get.find();

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

                // Add current tetromino to visualization
                if (controller.gameState != GameState.gameOver) {
                  int tetrominoLocalRow = row - controller.tetromino.row;
                  int tetrominoLocalCol = col - controller.tetromino.col;

                  if (tetrominoLocalRow >= 0 &&
                      tetrominoLocalRow < controller.tetromino.matrix.length &&
                      tetrominoLocalCol >= 0 &&
                      tetrominoLocalCol < controller.tetromino.matrix[0].length &&
                      controller.tetromino.matrix[tetrominoLocalRow][tetrominoLocalCol] != 0) {
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
