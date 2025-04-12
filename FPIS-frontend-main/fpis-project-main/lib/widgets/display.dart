import 'package:flutter/material.dart';

class Display extends StatelessWidget {
  const Display({
    super.key,
    required this.content,
  });

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 478,
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: ShapeDecoration(
        color: Color(0x00D9D9D9),
        shape: RoundedRectangleBorder(side: BorderSide(width: 5)),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: Color(0xFFA3B4AC),
          shape: RoundedRectangleBorder(side: BorderSide(width: 5)),
        ),
        child: content,
      ),
    );
  }
}
