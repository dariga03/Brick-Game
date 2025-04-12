import 'package:flutter/material.dart';

class Block extends StatelessWidget {
  const Block(this.type, {super.key});

  final BlockType type;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case BlockType.filled:
        color = Colors.black;
        break;
      case BlockType.empty:
        color = Colors.black.withValues(alpha: 0.3);
        break;
      case BlockType.predicted:
        color = Colors.black.withValues(alpha: 0.5);
        break;
    }

    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.white60,
          width: 1,
        ),
      ),
      child: Text(" "),
    );
  }
}

enum BlockType {
  filled,
  empty,
  predicted,
}
