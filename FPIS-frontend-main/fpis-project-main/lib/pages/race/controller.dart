import 'dart:async';
import 'dart:math';

import 'package:brick_game/controllers/game_details_controller.dart';
import 'package:brick_game/pages/tetris/controller.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RaceController extends GetxController {
  // settings
  static const int gridWidth = 10;
  static const int gridHeight = 25;
  int speed = 1;
  int frameSkipCount = 0;
  int obstacleGenerationCooldown = 9;

  // car shapes
  static const Map<String, List<List<int>>> carShapes = {
    'car1': [
      [0, 1, 0],
      [1, 1, 1],
      [0, 1, 0],
      [1, 0, 1],
    ],
    'car2': [
      [0, 1, 0],
      [1, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
    ],
    'truck': [
      [0, 1, 0],
      [1, 1, 1],
      [1, 1, 1],
      [0, 1, 0],
    ],
  };

  // storage keys
  static const String maxScoreKey = "race_score_max";
  static const String speedKey = "race_speed";
  static const String goalKey = "race_goal";

  // dependency injection
  static RaceController get find => Get.find();
  GameDetailsController gameDetailsController = Get.find();
  final box = GetStorage();

  // UI update trigger
  RxBool updater = false.obs;

  // game state variables
  GameState gameState = GameState.initial;
  int score = 0;
  int distance = 0;
  Car playerCar = Car(shape: [
    [0, 1, 0],
    [1, 1, 1],
    [0, 1, 0],
    [1, 0, 1],
  ], row: 20, col: 3);
  List<Car> obstacles = [];
  List<String> carSequence = [];
  List<List<BlockType>> playfield = List.generate(
    gridHeight,
    (_) => List.generate(gridWidth, (_) => BlockType.empty),
  );

  // road boundaries
  int leftBoundary = 1;
  int rightBoundary = 8;

  init() {
    box.writeIfNull(maxScoreKey, 0);
    box.writeIfNull(goalKey, 500);
    box.writeIfNull(speedKey, 15);

    gameDetailsController.hiScore.value = box.read(maxScoreKey);
    gameDetailsController.goal.value = box.read(goalKey);
    speed = box.read(speedKey);
    gameDetailsController.speed.value = speed;

    playfield = List.generate(
      gridHeight,
      (_) => List.generate(gridWidth, (_) => BlockType.empty),
    );

    // Initialize player car
    playerCar = Car(shape: [
      [0, 1, 0],
      [1, 1, 1],
      [0, 1, 0],
      [1, 0, 1],
    ], row: 20, col: 3);

    obstacles = [];
    carSequence = [];
    frameSkipCount = 0;
    score = 0;
    distance = 0;
    gameState = GameState.initial;

    // Setup initial road
    clearAndRedrawPlayfield();
  }

  void startGame() {
    gameState = GameState.playing;
    Timer.periodic(
      Duration(milliseconds: 100),
      (timer) {
        switch (gameState) {
          case GameState.initial:
            break;
          case GameState.playing:
            updateGame();
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

  void updateGame() {
    frameSkipCount++;
    if (frameSkipCount > 15 - speed) {
      frameSkipCount = 0;

      // Move obstacles down
      moveObstacles();

      if (obstacleGenerationCooldown > 0) {
        obstacleGenerationCooldown--;
      } else {
        // Generate new obstacles
        if (getRandomInt(0, 20) < 3 && obstacles.length < 3) {
          generateObstacle();
          obstacleGenerationCooldown = 8 + getRandomInt(0, 4);
        }
      }

      // Increase distance and score
      distance += speed;
      score = distance ~/ 10;

      // Update game details
      gameDetailsController.score.value = score;
      gameDetailsController.currentGoal.value = score;

      // Check if goal reached
      if (gameDetailsController.goal.value <= score) {
        gameDetailsController.goal.value *= 2;
        box.write(goalKey, gameDetailsController.goal.value);
        increaseSpeed();
      }

      // Check for collisions
      if (checkCollision()) {
        gameOver();
      }

      // Clear and redraw the playfield
      clearAndRedrawPlayfield();
    }

    updater.toggle();
  }

  void clearAndRedrawPlayfield() {
    // Clear the entire playfield first
    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        playfield[row][col] = BlockType.empty;
      }
    }

    // Set road boundaries (the first and last columns are walls)
    setupRoad();

    // Draw player car
    drawPlayerCar();

    // Draw obstacles
    drawObstacles();
  }

  void setupRoad() {
    // Set road boundaries (the first and last columns are walls)
    for (int row = 0; row < gridHeight; row++) {
      playfield[row][0] = BlockType.filled;
      playfield[row][gridWidth - 1] = BlockType.filled;
    }
  }

  void drawPlayerCar() {
    for (int row = 0; row < playerCar.shape.length; row++) {
      for (int col = 0; col < playerCar.shape[row].length; col++) {
        if (playerCar.shape[row][col] != 0) {
          int newRow = playerCar.row + row;
          int newCol = playerCar.col + col;

          if (newRow >= 0 && newRow < gridHeight && newCol >= 0 && newCol < gridWidth) {
            playfield[newRow][newCol] = BlockType.filled;
          }
        }
      }
    }
  }

  void drawObstacles() {
    for (Car obstacle in obstacles) {
      for (int row = 0; row < obstacle.shape.length; row++) {
        for (int col = 0; col < obstacle.shape[row].length; col++) {
          if (obstacle.shape[row][col] != 0) {
            int newRow = obstacle.row + row;
            int newCol = obstacle.col + col;

            if (newRow >= 0 && newRow < gridHeight && newCol >= 0 && newCol < gridWidth) {
              playfield[newRow][newCol] = BlockType.filled;
            }
          }
        }
      }
    }
  }

  void moveObstacles() {
    List<Car> updatedObstacles = [];

    for (Car obstacle in obstacles) {
      obstacle.row++;

      // Remove obstacles that have moved off the screen
      if (obstacle.row < gridHeight) {
        updatedObstacles.add(obstacle);
      }
    }

    obstacles = updatedObstacles;
  }

  void generateObstacle() {
    // Get a random car shape
    List<String> carTypes = carShapes.keys.toList();
    String carType = carTypes[getRandomInt(0, carTypes.length - 1)];
    List<List<int>> shape = carShapes[carType]!;

    // Place it at a random position at the top of the screen
    int col = Random().nextInt(2) == 1 ? 5 : 1;

    obstacles.add(Car(shape: shape, row: -shape.length, col: col));
  }

  bool checkCollision() {
    // Check collision between player car and obstacles
    for (Car obstacle in obstacles) {
      for (int row = 0; row < playerCar.shape.length; row++) {
        for (int col = 0; col < playerCar.shape[row].length; col++) {
          if (playerCar.shape[row][col] != 0) {
            int playerRow = playerCar.row + row;
            int playerCol = playerCar.col + col;

            for (int oRow = 0; oRow < obstacle.shape.length; oRow++) {
              for (int oCol = 0; oCol < obstacle.shape[oRow].length; oCol++) {
                if (obstacle.shape[oRow][oCol] != 0) {
                  int obstacleRow = obstacle.row + oRow;
                  int obstacleCol = obstacle.col + oCol;

                  if (playerRow == obstacleRow && playerCol == obstacleCol) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }

    // Check collision with road boundaries
    for (int row = 0; row < playerCar.shape.length; row++) {
      for (int col = 0; col < playerCar.shape[row].length; col++) {
        if (playerCar.shape[row][col] != 0) {
          int newRow = playerCar.row + row;
          int newCol = playerCar.col + col;

          if (newCol <= 0 || newCol >= gridWidth - 1) {
            return true;
          }
        }
      }
    }

    return false;
  }

  void movePlayerCar(int dx) {
    if (gameState == GameState.gameOver || gameState == GameState.paused || gameState == GameState.initial) return;

    int newCol = playerCar.col + dx;

    // Check if the move is valid
    bool validMove = true;
    for (int row = 0; row < playerCar.shape.length; row++) {
      for (int col = 0; col < playerCar.shape[row].length; col++) {
        if (playerCar.shape[row][col] != 0) {
          int checkCol = newCol + col;

          // Check if move would cause collision with boundaries
          if (checkCol <= 0 || checkCol >= gridWidth - 1) {
            validMove = false;
            break;
          }
        }
      }
      if (!validMove) break;
    }

    if (validMove) {
      playerCar.col = newCol;
      clearAndRedrawPlayfield();
      updater.toggle();
    }
  }

  void increaseSpeed() {
    if (speed < 10) {
      speed++;
      gameDetailsController.speed.value = speed;
      box.write(speedKey, speed);
    }
  }

  void gameOver() {
    final max = box.read(maxScoreKey);
    if (max == null || score > max) {
      box.write(maxScoreKey, score);
      gameDetailsController.hiScore.value = score;
    }

    Get.snackbar("Game over", "Score: $score", snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);
    gameState = GameState.gameOver;
    updater.toggle();
  }

  int getRandomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }
}

class Car {
  List<List<int>> shape;
  int row;
  int col;

  Car({
    required this.shape,
    required this.row,
    required this.col,
  });
}
