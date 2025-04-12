import 'package:brick_game/controllers/display_controller.dart';
import 'package:flutter/material.dart';

class Controls extends StatelessWidget {
  const Controls(this.controlls, {super.key});

  final Controlls controlls;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 30,
          left: 75,
          child: Control(text: "up/level", onTap: controlls.onUp),
        ),
        Positioned(
          top: 100,
          left: 0,
          child: Control(text: "left\nprev game", onTap: controlls.onLeft),
        ),
        Positioned(
          top: 100,
          left: 150,
          child: Control(text: "right\nnext game", onTap: controlls.onRight),
        ),
        Positioned(
          top: 180,
          left: 75,
          child: Control(text: "down/pause", onTap: controlls.onDown),
        ),
        Positioned(
          top: 100,
          left: 250,
          child: Control(
            text: "rotate",
            size: 60,
            onTap: controlls.onRotate,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              Control(
                text: "start\npause",
                onTap: controlls.onStart,
                size: 10,
                isSettings: true,
              ),
              Control(
                text: "sound",
                onTap: controlls.onSound,
                size: 10,
                isSettings: true,
              ),
              Control(
                text: "setting",
                onTap: controlls.onSettings,
                size: 10,
                isSettings: true,
              ),
              Control(
                text: "exit",
                onTap: controlls.onExit,
                size: 10,
                isSettings: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Control extends StatelessWidget {
  const Control({
    super.key,
    required this.text,
    this.onTap,
    this.size = 30,
    this.isSettings = false,
  });
  final String text;
  final double size;
  final Function()? onTap;
  final bool isSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size * 2 + 20,
      width: size * 2 + 20,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              maxRadius: size + 1,
              minRadius: size + 1,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                maxRadius: size,
                minRadius: size,
                backgroundColor: isSettings ? Colors.green : Colors.yellow,
              ),
            ),
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSettings ? 8 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
