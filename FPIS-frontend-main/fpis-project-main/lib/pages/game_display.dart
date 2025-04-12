import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';

class GameDisplay extends StatelessWidget {
  GameDisplay({
    super.key,
    required this.blocks,
  });

  final List<Block> blocks;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      // child: Column(
      //   children: blockCoordinats.map(
      //     (first) {
      //       return Row(
      //           children: first.map((e) {
      //         return Block(0, 0, type: e);
      //       }).toList());
      //     },
      //   ).toList(),
      // ),
    );
  }
}
