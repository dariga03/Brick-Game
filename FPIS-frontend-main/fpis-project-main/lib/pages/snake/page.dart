import 'dart:math';

import 'package:brick_game/pages/game_details.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SnakePage extends StatelessWidget {
  SnakePage({super.key});

  final SnakeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.36,
          child: Obx(() {
            final bool u = controller.updater.value;

            List<List<BlockType>> grid = List.generate(
              SnakeController.gridHeight,
              (i) => List.generate(
                SnakeController.gridWidth,
                (j) => BlockType.empty,
              ),
            );

            for (int i = 0; i < controller.snakeCells.length; i++) {
              final Point<int> cell = controller.snakeCells[i];
              grid[cell.y][cell.x] = BlockType.filled;
            }

            grid[controller.apple.y][controller.apple.x] = BlockType.filled;

            return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: SnakeController.gridWidth,
                childAspectRatio: 1,
              ),
              itemCount: grid.length * grid[0].length,
              itemBuilder: (context, index) {
                return Block(
                  grid[index ~/ SnakeController.gridWidth][index % SnakeController.gridWidth],
                );
              },
            );
          }),
        ),
        GameDetails(),
      ],
    );
  }
}
