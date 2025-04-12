import 'dart:async';
import 'dart:math';

import 'package:brick_game/controllers/game_details_controller.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TetrisController extends GetxController {
  // settings
  static const int gridWidth = 10;
  static const int gridHeigth = 25;
  int speed = 1;
  int frameSkipCount = 0;

  static const Map<String, List<List<int>>> tetrominos = {
    'I': [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    'J': [
      [1, 0, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
    'L': [
      [0, 0, 1],
      [1, 1, 1],
      [0, 0, 0],
    ],
    'O': [
      [1, 1],
      [1, 1],
    ],
    'S': [
      [0, 1, 1],
      [1, 1, 0],
      [0, 0, 0],
    ],
    'Z': [
      [1, 1, 0],
      [0, 1, 1],
      [0, 0, 0],
    ],
    'T': [
      [0, 1, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
  };

  // storage keys
  static const String maxScoreKey = "tetris_score_max";
  static const String speedKey = "tetris_speed";
  static const String goalKey = "tetris_goal";

  // something like di
  static TetrisController get find => Get.find();
  GameDetailsController gameDetailsController = Get.find();
  final box = GetStorage();

  // to update ui properly
  RxBool updater = false.obs;

  // game state variables
  GameState gameState = GameState.initial;
  int score = 0;
  Tetromino tetromino = Tetromino(name: 'I', matrix: tetrominos['I']!, row: -2, col: 3);
  List<String> tetrominoSequence = [];
  List<List<BlockType>> playfield = List.generate(
    gridHeigth + 2,
    (_) => List.generate(gridWidth, (_) => BlockType.empty),
  );

  init() {
    box.writeIfNull(maxScoreKey, 0);
    box.writeIfNull(goalKey, 2);
    box.writeIfNull(speedKey, 1);

    gameDetailsController.hiScore.value = box.read(maxScoreKey);
    gameDetailsController.goal.value = box.read(goalKey);
    speed = box.read(speedKey);
    gameDetailsController.speed.value = speed;

    playfield = List.generate(
      gridHeigth + 2,
      (_) => List.generate(gridWidth, (_) => BlockType.empty),
    );
    tetromino = Tetromino(name: 'I', matrix: tetrominos['I']!, row: -2, col: 3);
    tetrominoSequence = [];
    frameSkipCount = 0;
    score = 0;
    gameState = GameState.initial;
    tetromino = getNextTetromino();
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
    if (frameSkipCount > 20 - speed) {
      frameSkipCount = 0;
      tetromino.row++;
      shadowOfTetromino();

      if (!isValidMove(tetromino.matrix, tetromino.row, tetromino.col)) {
        tetromino.row--;
        placeTetromino();
      }
    }
    updater.toggle();
  }

  Tetromino getNextTetromino() {
    if (tetrominoSequence.length < 2) {
      generateSequence();
    }

    String name = tetrominoSequence.removeLast();
    gameDetailsController.matrix = tetrominos[tetrominoSequence.last]!.map((e) => e.map((ee) => ee == 1).toList().obs).toList().obs;
    gameDetailsController.updater.toggle();

    List<List<int>> matrix = tetrominos[name]!;

    int col = (gridWidth / 2 - (matrix[0].length / 2)).floor();
    int row = name == 'I' ? -1 : -2;

    return Tetromino(
      name: name,
      matrix: matrix,
      row: row,
      col: col,
    );
  }

  void generateSequence() {
    // tetrominoSequence.clear();
    List<String> sequence = ['I', 'J', 'L', 'O', 'S', 'T', 'Z'];

    while (sequence.isNotEmpty) {
      int rand = getRandomInt(0, sequence.length - 1);
      String name = sequence.removeAt(rand);
      tetrominoSequence.add(name);
    }
  }

  void placeTetromino() {
    for (int row = 0; row < tetromino.matrix.length; row++) {
      for (int col = 0; col < tetromino.matrix[row].length; col++) {
        if (tetromino.matrix[row][col] != 0) {
          if (tetromino.row + row < 0) {
            final max = box.read(maxScoreKey);
            if (max == null || score > max) {
              box.write(maxScoreKey, score);
            }

            Get.snackbar("Game over", "Score: $score", snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);
            gameState = GameState.gameOver;
            updater.toggle();
            return;
          }

          if (tetromino.row + row >= 0) {
            playfield[tetromino.row + row][tetromino.col + col] = BlockType.filled;
          }
        }
      }
    }

    // Clear lines
    for (int row = gridHeigth - 1; row >= 0;) {
      if (playfield[row].every((cell) => cell == BlockType.filled)) {
        score++;
        if (score > 5 * speed) {
          speed++;
          if (speed >= 10) {
            speed = 10;
          }
          gameDetailsController.speed.value = speed;
          box.write(speedKey, speed);
        }
        gameDetailsController.score.value = score;
        gameDetailsController.currentGoal.value = score;
        if (gameDetailsController.goal.value == score) {
          gameDetailsController.goal.value *= 2;
          box.write(goalKey, gameDetailsController.goal.value);
        }

        updater.toggle();
        playfield.removeAt(row);
        playfield.insert(0, List.generate(gridWidth, (_) => BlockType.empty));
      } else {
        row--;
      }
    }

    tetromino = getNextTetromino();
    updater.toggle();
  }

  void moveTetromino(int dx, int dy) {
    if (gameState == GameState.gameOver || gameState == GameState.paused || gameState == GameState.initial) return;

    if (dx != 0) {
      int newCol = tetromino.col + dx;
      if (isValidMove(tetromino.matrix, tetromino.row, newCol)) {
        tetromino.col = newCol;
      }
    }

    if (dy > 0) {
      int newRow = tetromino.row + dy;
      if (!isValidMove(tetromino.matrix, newRow, tetromino.col)) {
        tetromino.row = newRow - 1;
        placeTetromino();
        return;
      }
      tetromino.row = newRow;
    }
    shadowOfTetromino();
    updater.toggle();
  }

  bool isValidMove(List<List<int>> matrix, int cellRow, int cellCol) {
    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col] != 0) {
          int newRow = cellRow + row;
          int newCol = cellCol + col;

          if (newCol < 0 || newCol >= gridWidth || newRow >= gridHeigth || (newRow >= 0 && playfield[newRow][newCol] == BlockType.filled)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void onUp() {
    do {
      tetromino.row++;
    } while (isValidMove(tetromino.matrix, tetromino.row, tetromino.col));
    tetromino.row--;
    placeTetromino();
    updater.toggle();
  }

  void shadowOfTetromino() {
    Tetromino tetr = Tetromino(name: tetromino.name, matrix: tetromino.matrix, row: tetromino.row, col: tetromino.col);
    do {
      tetr.row++;
    } while (isValidMove(tetr.matrix, tetr.row, tetr.col));
    tetr.row--;
    placeShadow(tetr);
    updater.toggle();
  }

  void placeShadow(Tetromino tetr) {
    // remove previous shadow
    for (int i = 0; i < playfield.length; i++) {
      for (int j = 0; j < playfield[i].length; j++) {
        if (playfield[i][j] == BlockType.predicted) playfield[i][j] = BlockType.empty;
      }
    }

    for (int row = 0; row < tetr.matrix.length; row++) {
      for (int col = 0; col < tetr.matrix[row].length; col++) {
        if (tetr.matrix[row][col] != 0) {
          if (tetr.row + row < 0) {
            final max = box.read(maxScoreKey);
            if (max == null || score > max) {
              box.write(maxScoreKey, score);
            }

            Get.snackbar("Game over", "Score: $score", snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);
            gameState = GameState.gameOver;
            updater.toggle();
            return;
          }

          if (tetr.row + row >= 0) {
            playfield[tetr.row + row][tetr.col + col] = BlockType.predicted;
          }
        }
      }
    }
  }

  void rotateTetromino() {
    if (gameState == GameState.gameOver || gameState == GameState.paused || gameState == GameState.initial) return;

    List<List<int>> rotatedMatrix = rotate(tetromino.matrix);
    if (isValidMove(rotatedMatrix, tetromino.row, tetromino.col)) {
      tetromino.matrix = rotatedMatrix;
      shadowOfTetromino();
      updater.toggle();
    }
  }

  List<List<int>> rotate(List<List<int>> matrix) {
    int N = matrix.length - 1;
    return List.generate(matrix.length, (i) => List.generate(matrix.length, (j) => matrix[N - j][i]));
  }

  int getRandomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }
}

enum GameState { initial, playing, paused, gameOver }

class Tetromino {
  String name;
  List<List<int>> matrix;
  int row;
  int col;

  Tetromino({
    required this.name,
    required this.matrix,
    required this.row,
    required this.col,
  });
}
