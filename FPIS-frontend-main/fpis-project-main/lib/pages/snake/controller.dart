import 'dart:async';
import 'dart:math';

import 'package:brick_game/controllers/game_details_controller.dart';
import 'package:brick_game/pages/tetris/controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

int speed = 4;

class SnakeController extends GetxController {
  // settings
  static const int gridWidth = 10; // Width: 10 cells as requested
  static const int gridHeight = 25; // Height: 25 cells as requested
  int frameSkipCount = 0;
  int speed = 10;

  // storage keys
  static const String maxScoreKey = "snake_score_max";
  static const String speedKey = "snake_speed";
  static const String goalKey = "snake_goal";

  // something like di
  static SnakeController get find => Get.find();
  GameDetailsController gameDetailsController = Get.find();
  final box = GetStorage();

  // for proper ui update
  RxBool updater = false.obs;

  // game state variables
  GameState gameState = GameState.initial;
  int score = 0;
  int snakeLength = 4;
  int snakeX = 4;
  int snakeY = 12;
  int snakeDx = 1;
  int snakeDy = 0;
  List<Point<int>> snakeCells = [];

  Point<int> apple = Point(1, 1);

  init() {
    box.writeIfNull(maxScoreKey, 0);
    box.writeIfNull(goalKey, 2);
    box.writeIfNull(speedKey, 10);

    gameDetailsController.hiScore.value = box.read(maxScoreKey);
    gameDetailsController.goal.value = box.read(goalKey);
    speed = box.read(speedKey);
    gameDetailsController.speed.value = speed;

    frameSkipCount = 0;
    score = 0;
    gameState = GameState.initial;
  }

  void startGame() {
    gameState = GameState.playing;

    snakeCells.add(Point(snakeX, snakeY));
    apple = Point(getRandomInt(0, gridWidth), getRandomInt(0, gridHeight));

    Timer.periodic(
      Duration(milliseconds: 100),
      (timer) {
        switch (gameState) {
          case GameState.initial:
            break;
          case GameState.playing:
            gameLoop();
            break;
          case GameState.paused:
            break;
          case GameState.gameOver:
            timer.cancel();
            break;
        }
      },
    );
  }

  void gameLoop() {
    frameSkipCount++;
    if (frameSkipCount < speed) {
      return;
    }
    frameSkipCount = 0;

    // Move snake by its velocity
    snakeX += snakeDx;
    snakeY += snakeDy;

    // Wrap snake position horizontally on edge of screen
    if (snakeX < 0) {
      snakeX = gridWidth - 1;
    } else if (snakeX >= gridWidth) {
      snakeX = 0;
    }

    // Wrap snake position vertically on edge of screen
    if (snakeY < 0) {
      snakeY = gridHeight - 1;
    } else if (snakeY >= gridHeight) {
      snakeY = 0;
    }

    // Keep track of where snake has been. Front of the array is always the head
    snakeCells.insert(0, Point(snakeX, snakeY));

    // Remove cells as we move away from them
    if (snakeCells.length > snakeLength) {
      snakeCells.removeLast();
    }

    // Check if snake ate apple
    if (snakeX == apple.x && snakeY == apple.y) {
      snakeLength++;
      gameDetailsController.score.value = snakeLength - 4;

      apple = Point(getRandomInt(0, gridWidth), getRandomInt(0, gridHeight));
    }

    // Check collision with self
    for (int i = 1; i < snakeCells.length; i++) {
      if (snakeX == snakeCells[i].x && snakeY == snakeCells[i].y) {
        // Reset game
        snakeX = 4;
        snakeY = 12;
        snakeCells.clear();
        snakeCells.add(Point(snakeX, snakeY));
        snakeLength = 4;
        snakeDx = 1;
        snakeDy = 0;
        apple = Point(getRandomInt(0, gridWidth), getRandomInt(0, gridHeight));

        if (gameDetailsController.score.value > gameDetailsController.hiScore.value) {
          gameDetailsController.hiScore.value = gameDetailsController.score.value;
          box.write(maxScoreKey, gameDetailsController.score.value);
        }
        gameState = GameState.gameOver;
        updater.toggle();
        break;
      }
    }
    updater.toggle();
  }

  void onLeft() {
    if (snakeDx == 0) {
      snakeDx = -1;
      snakeDy = 0;
      updater.toggle();
    }
  }

  void onRight() {
    if (snakeDx == 0) {
      snakeDx = 1;
      snakeDy = 0;
      updater.toggle();
    }
  }

  void onUp() {
    if (snakeDy == 0) {
      snakeDy = -1;
      snakeDx = 0;
      updater.toggle();
    }
  }

  void onDown() {
    if (snakeDy == 0) {
      snakeDy = 1;
      snakeDx = 0;
      updater.toggle();
    }
  }

  void onRotate() {}

  int getRandomInt(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
