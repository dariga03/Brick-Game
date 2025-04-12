// import 'dart:async';
// import 'dart:math';

// import 'package:brick_game/controllers/game_details_controller.dart';
// import 'package:brick_game/widgets/block.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class ArkanoidController extends GetxController {
//   // settings
//   static const int gridWidth = 10;
//   static const int gridHeight = 25;
//   int speed = 1;

//   // game dimensions
//   double paddleWidth = 3;
//   late double initialPaddleX = (gridWidth - paddleWidth) / 2;
//   static const double ballRadius = 0.5;
//   static const double initialBallSpeed = 0.5;

//   // storage keys
//   static const String maxScoreKey = "arkanoid_score_max";
//   static const String speedKey = "arkanoid_speed";
//   static const String levelKey = "arkanoid_level";

//   // something like di
//   static ArkanoidController get find => Get.find();
//   GameDetailsController gameDetailsController = Get.find();
//   final box = GetStorage();

//   // to update UI properly
//   RxBool updater = false.obs;

//   // game state variables
//   GameState gameState = GameState.initial;
//   int score = 0;
//   int lives = 3;
//   int level = 1;

//   // paddle position
//   late double paddleX = initialPaddleX;

//   // ball properties
//   double ballX = gridWidth / 2;
//   double ballY = gridHeight - 4;
//   double ballSpeedX = initialBallSpeed;
//   double ballSpeedY = -initialBallSpeed;
//   bool ballReleased = false;

//   // level bricks configuration
//   List<List<BlockType>> bricks = [];

//   // power-ups
//   List<PowerUp> activePowerUps = [];

//   init() {
//     box.writeIfNull(maxScoreKey, 0);
//     box.writeIfNull(levelKey, 1);
//     box.writeIfNull(speedKey, 1);

//     gameDetailsController.hiScore.value = box.read(maxScoreKey);
//     gameDetailsController.goal.value = box.read(levelKey);
//     speed = box.read(speedKey);
//     gameDetailsController.speed.value = speed;

//     // reset game variables
//     score = 0;
//     lives = 3;
//     level = 1;
//     paddleX = initialPaddleX;
//     resetBall(false);

//     // initialize bricks for level 1
//     generateLevel(level);

//     gameState = GameState.initial;
//   }

//   void startGame() {
//     gameState = GameState.playing;
//     Timer.periodic(
//       Duration(milliseconds: 16), // roughly 60 FPS
//       (timer) {
//         switch (gameState) {
//           case GameState.initial:
//             break;
//           case GameState.playing:
//             updateGame();
//             break;
//           case GameState.paused:
//             break;
//           case GameState.gameOver:
//             timer.cancel();
//             break;
//         }
//       },
//     );
//   }

//   void updateGame() {
//     // Move active power-ups
//     _updatePowerUps();

//     // Ball movement if released
//     if (ballReleased) {
//       _updateBall();
//     } else {
//       // Ball follows paddle if not released
//       ballX = paddleX + paddleWidth / 2;
//     }

//     // Check if level is completed
//     bool levelCompleted = true;
//     for (int row = 0; row < bricks.length; row++) {
//       for (int col = 0; col < bricks[row].length; col++) {
//         if (bricks[row][col] == BlockType.filled) {
//           levelCompleted = false;
//           break;
//         }
//       }
//       if (!levelCompleted) break;
//     }

//     if (levelCompleted) {
//       _levelUp();
//     }

//     updater.toggle();
//   }

//   void _updateBall() {
//     // Update ball position
//     ballX += ballSpeedX * speed;
//     ballY += ballSpeedY * speed;

//     // Collision with side walls
//     if (ballX <= ballRadius || ballX >= gridWidth - ballRadius) {
//       ballSpeedX = -ballSpeedX;

//       // Fix ball position to avoid getting stuck
//       if (ballX < ballRadius) ballX = ballRadius;
//       if (ballX > gridWidth - ballRadius) ballX = gridWidth - ballRadius;
//     }

//     // Collision with top wall
//     if (ballY <= ballRadius) {
//       ballSpeedY = -ballSpeedY;
//       ballY = ballRadius;
//     }

//     // Collision with paddle
//     if (ballY >= gridHeight - 1 - ballRadius && ballY <= gridHeight - ballRadius && ballX >= paddleX && ballX <= paddleX + paddleWidth) {
//       // Calculate bounce angle based on where ball hit the paddle
//       double relativeIntersectX = (paddleX + (paddleWidth / 2)) - ballX;
//       double normalizedIntersect = relativeIntersectX / (paddleWidth / 2);

//       // Angle calculation (maximum 75 degrees)
//       double bounceAngle = normalizedIntersect * (pi / 4);

//       // Set new ball direction
//       double velocity = sqrt(ballSpeedX * ballSpeedX + ballSpeedY * ballSpeedY);
//       ballSpeedY = -(velocity * cos(bounceAngle)).abs();
//       ballSpeedX = velocity * sin(bounceAngle);

//       // Give a minimum horizontal speed to avoid vertical-only bouncing
//       if ((ballSpeedX).abs() < 0.1) {
//         ballSpeedX = ballSpeedX < 0 ? -0.1 : 0.1;
//       }
//     }

//     // Ball falls below paddle
//     if (ballY > gridHeight) {
//       lives--;
//       gameDetailsController.lives.value = lives;

//       if (lives <= 0) {
//         gameOver();
//       } else {
//         resetBall(true);
//       }
//     }

//     // Collision with bricks
//     _checkBrickCollision();
//   }

//   void _checkBrickCollision() {
//     int brickWidth = gridWidth ~/ bricks[0].length;
//     int brickHeight = 1;

//     for (int row = 0; row < bricks.length; row++) {
//       for (int col = 0; col < bricks[row].length; col++) {
//         if (bricks[row][col] == BlockType.filled) {
//           int brickX = col * brickWidth;
//           int brickY = row * brickHeight;

//           // Check if ball collides with this brick
//           if (ballX >= brickX && ballX <= brickX + brickWidth && ballY >= brickY && ballY <= brickY + brickHeight) {
//             // Determine if horizontal or vertical collision
//             double overlapLeft = ballX + ballRadius - brickX;
//             double overlapRight = brickX + brickWidth - (ballX - ballRadius);
//             double overlapTop = ballY + ballRadius - brickY;
//             double overlapBottom = brickY + brickHeight - (ballY - ballRadius);

//             // Find smallest overlap
//             double minOverlapX = min(overlapLeft, overlapRight);
//             double minOverlapY = min(overlapTop, overlapBottom);

//             if (minOverlapX < minOverlapY) {
//               ballSpeedX = -ballSpeedX;
//             } else {
//               ballSpeedY = -ballSpeedY;
//             }

//             // Update brick state
//             bricks[row][col] = BlockType.empty;

//             // Update score
//             score += 10;
//             gameDetailsController.score.value = score;
//             gameDetailsController.currentGoal.value = level;

//             // Possibly spawn a power-up
//             if (Random().nextInt(10) < 3) {
//               // 30% chance
//               _spawnPowerUp(brickX + brickWidth / 2, brickY + brickHeight / 2);
//             }

//             // Only handle one collision per frame
//             return;
//           }
//         }
//       }
//     }
//   }

//   void _spawnPowerUp(double x, double y) {
//     // Randomly select a power-up type
//     PowerUpType type = PowerUpType.values[Random().nextInt(PowerUpType.values.length)];

//     // Create and add the power-up
//     activePowerUps.add(PowerUp(
//       x: x,
//       y: y,
//       type: type,
//     ));
//   }

//   void _updatePowerUps() {
//     List<PowerUp> toRemove = [];

//     for (var powerUp in activePowerUps) {
//       // Move power-up downward
//       powerUp.y += 0.2 * speed;

//       // Check if power-up is caught by paddle
//       if (powerUp.y >= gridHeight - 1 && powerUp.x >= paddleX && powerUp.x <= paddleX + paddleWidth) {
//         _applyPowerUp(powerUp.type);
//         toRemove.add(powerUp);
//       }

//       // Remove if off screen
//       if (powerUp.y > gridHeight) {
//         toRemove.add(powerUp);
//       }
//     }

//     // Remove used or off-screen power-ups
//     activePowerUps.removeWhere((powerUp) => toRemove.contains(powerUp));
//   }

//   void _applyPowerUp(PowerUpType type) {
//     switch (type) {
//       case PowerUpType.extraLife:
//         lives++;
//         gameDetailsController.lives.value = lives;
//         break;

//       case PowerUpType.expandPaddle:
//         paddleWidth = min(5.0, paddleWidth + 1.0);
//         // Schedule paddle return to normal size after 10 seconds
//         Future.delayed(Duration(seconds: 10), () {
//           paddleWidth = 3.0;
//           updater.toggle();
//         });
//         break;

//       case PowerUpType.slowBall:
//         double currentSpeed = sqrt(ballSpeedX * ballSpeedX + ballSpeedY * ballSpeedY);
//         ballSpeedX = ballSpeedX / currentSpeed * (initialBallSpeed * 0.7);
//         ballSpeedY = ballSpeedY / currentSpeed * (initialBallSpeed * 0.7);

//         // Return to normal speed after 8 seconds
//         Future.delayed(Duration(seconds: 8), () {
//           double currentSpeed = sqrt(ballSpeedX * ballSpeedX + ballSpeedY * ballSpeedY);
//           ballSpeedX = ballSpeedX / currentSpeed * initialBallSpeed;
//           ballSpeedY = ballSpeedY / currentSpeed * initialBallSpeed;
//           updater.toggle();
//         });
//         break;
//     }
//   }

//   void _levelUp() {
//     level++;
//     gameDetailsController.goal.value = level;
//     box.write(levelKey, level);

//     // Increase speed every 3 levels
//     if (level % 3 == 0) {
//       speed = min(10, speed + 1);
//       gameDetailsController.speed.value = speed;
//       box.write(speedKey, speed);
//     }

//     resetBall(true);
//     generateLevel(level);

//     Get.snackbar("Level Complete!", "Starting level $level", snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);
//   }

//   void resetBall(bool withDelay) {
//     ballReleased = false;
//     ballX = paddleX + paddleWidth / 2;
//     ballY = gridHeight - 2;

//     // Randomize ball direction slightly for variety
//     double angle = (Random().nextDouble() - 0.5) * (pi / 3); // Between -30 and 30 degrees
//     ballSpeedX = initialBallSpeed * sin(angle) * (Random().nextBool() ? 1 : -1);
//     ballSpeedY = -initialBallSpeed * cos(angle);

//     if (withDelay) {
//       // Add a small delay before the ball auto-releases
//       Future.delayed(Duration(seconds: 2), () {
//         if (gameState == GameState.playing) {
//           ballReleased = true;
//         }
//       });
//     }
//   }

//   void generateLevel(int level) {
//     // Clear existing bricks
//     bricks = [];

//     // Define number of rows based on level (more rows for higher levels)
//     int rows = min(8, 3 + (level ~/ 2));
//     int cols = 10;

//     for (int i = 0; i < rows; i++) {
//       List<BlockType> row = List.generate(cols, (index) => BlockType.filled);

//       // Add pattern variations based on level
//       if (level > 1) {
//         // Add some empty spaces in higher levels for more interesting patterns
//         for (int j = 0; j < cols; j++) {
//           // Create patterns based on level number
//           if (level % 2 == 0 && (i + j) % 3 == 0) {
//             row[j] = BlockType.empty;
//           } else if (level % 3 == 0 && i % 2 == 0 && j % 2 == 0) {
//             row[j] = BlockType.empty;
//           } else if (level % 5 == 0 && (i * j) % 4 == 0) {
//             row[j] = BlockType.empty;
//           }
//         }
//       }

//       bricks.add(row);
//     }
//   }

//   void movePaddle(double dx) {
//     if (gameState == GameState.gameOver || gameState == GameState.paused || gameState == GameState.initial) return;

//     paddleX = max(0, min(gridWidth - paddleWidth, paddleX + dx));

//     // If ball is not released, it should follow the paddle
//     if (!ballReleased) {
//       ballX = paddleX + paddleWidth / 2;
//     }

//     updater.toggle();
//   }

//   void releaseBall() {
//     if (gameState == GameState.playing && !ballReleased) {
//       ballReleased = true;
//     }
//   }

//   void pauseGame() {
//     if (gameState == GameState.playing) {
//       gameState = GameState.paused;
//     } else if (gameState == GameState.paused) {
//       gameState = GameState.playing;
//     }
//     updater.toggle();
//   }

//   void gameOver() {
//     final maxScore = box.read(maxScoreKey) ?? 0;
//     if (score > maxScore) {
//       box.write(maxScoreKey, score);
//       gameDetailsController.hiScore.value = score;
//     }

//     Get.snackbar("Game Over", "Score: $score", snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);

//     gameState = GameState.gameOver;
//     updater.toggle();
//   }
// }

// enum GameState { initial, playing, paused, gameOver }

// enum PowerUpType { extraLife, expandPaddle, slowBall }

// class PowerUp {
//   double x;
//   double y;
//   PowerUpType type;

//   PowerUp({
//     required this.x,
//     required this.y,
//     required this.type,
//   });
// }

import 'dart:async';
import 'dart:math';

import 'package:brick_game/controllers/game_details_controller.dart';
import 'package:brick_game/pages/tetris/controller.dart';
import 'package:brick_game/widgets/block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ArkanoidController extends GetxController {
  // settings
  int speed = 1;
  int frameSkipCount = 0;

  // game dimensions
  static const double initialPaddleX = (10 - 3) / 2;

  // storage keys
  static const String maxScoreKey = "arkanoid_score_max";
  static const String speedKey = "arkanoid_speed";
  static const String levelKey = "arkanoid_level";

  // something like di
  static ArkanoidController get find => Get.find();
  GameDetailsController gameDetailsController = Get.find();
  final box = GetStorage();

  // to update UI properly
  RxBool updater = false.obs;

  // game state variables
  GameState gameState = GameState.initial;
  int score = 0;
  int lives = 3;
  int level = 1;

  // playfield
  List<List<BlockType>> playfield = List.generate(
    25,
    (_) => List.generate(10, (_) => BlockType.empty),
  );

  // paddle position (represented in the grid)
  int paddleX = initialPaddleX.toInt();

  // ball properties
  int ballX = (10 / 2).floor();
  int ballY = 25 - 3;
  double ballDirectionX = 0;
  double ballDirectionY = -1;
  bool ballReleased = false;

  // brick area (top portion of the screen)
  int brickRows = 10;

  init() {
    box.writeIfNull(maxScoreKey, 0);
    box.writeIfNull(levelKey, 1);
    box.writeIfNull(speedKey, 15);

    gameDetailsController.hiScore.value = box.read(maxScoreKey);
    gameDetailsController.goal.value = box.read(levelKey);
    speed = box.read(speedKey);
    gameDetailsController.speed.value = speed;

    // reset game variables
    score = 0;
    lives = 3;
    level = 1;
    paddleX = initialPaddleX.toInt();
    frameSkipCount = 0;

    // Clear playfield
    playfield = List.generate(
      25,
      (_) => List.generate(10, (_) => BlockType.empty),
    );

    resetBall();
    generateLevel(level);

    gameState = GameState.initial;
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
            releaseBall();
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

      if (ballReleased) {
        moveBall();
      }
    }
    updater.toggle();
  }

  void generateLevel(int level) {
    // Clear existing bricks
    for (int row = 0; row < brickRows; row++) {
      for (int col = 0; col < 10; col++) {
        playfield[row][col] = BlockType.empty;
      }
    }

    // Define number of rows based on level (more rows for higher levels)
    int rows = min(8, 3 + (level ~/ 2));

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < 10; col++) {
        // Create patterns based on level number
        bool createBrick = true;

        if (level > 1) {
          if (level % 2 == 0 && (row + col) % 3 == 0) {
            createBrick = false;
          } else if (level % 3 == 0 && row % 2 == 0 && col % 2 == 0) {
            createBrick = false;
          } else if (level % 5 == 0 && (row * col) % 4 == 0) {
            createBrick = false;
          }
        }

        if (createBrick) {
          playfield[row][col] = BlockType.filled;
        }
      }
    }
  }

  void resetBall() {
    ballReleased = false;
    ballX = paddleX + (3 ~/ 2);
    ballY = 25 - 3;

    // Set initial ball direction (slightly randomized)
    double angle = (Random().nextDouble() - 0.5) * (pi / 3); // Between -30 and 30 degrees
    ballDirectionX = sin(angle);
    ballDirectionY = -cos(angle);
  }

  void moveBall() {
    // Calculate new position
    double newBallX = ballX + ballDirectionX;
    double newBallY = ballY + ballDirectionY;

    // Check collisions with walls
    if (newBallX < 0 || newBallX >= 10) {
      ballDirectionX = -ballDirectionX;
      newBallX = ballX + ballDirectionX;
    }

    // Check collision with top wall
    if (newBallY < 0) {
      ballDirectionY = -ballDirectionY;
      newBallY = ballY + ballDirectionY;
    }

    // Check collision with paddle
    if (newBallY.round() >= 25 - 2 && newBallX.round() >= paddleX && newBallX.round() < paddleX + 3) {
      // Calculate bounce angle based on where ball hit the paddle
      double relativeIntersectX = (paddleX + (3 / 2)) - newBallX;
      double normalizedIntersect = relativeIntersectX / (3 / 2);

      // Angle calculation
      double bounceAngle = normalizedIntersect * (pi / 3); // Max 60 degrees

      // Set new ball direction
      ballDirectionX = -sin(bounceAngle);
      ballDirectionY = -cos(bounceAngle);
    }

    // Check collision with bricks
    bool brickHit = false;
    int hitBrickRow = -1;
    int hitBrickCol = -1;

    // Check if the ball is in the brick area
    if (newBallY.round() < brickRows) {
      int checkRow = newBallY.round();
      int checkCol = newBallX.round();

      if (checkRow >= 0 && checkCol >= 0 && checkRow < 25 && checkCol < 10 && playfield[checkRow][checkCol] == BlockType.filled) {
        brickHit = true;
        hitBrickRow = checkRow;
        hitBrickCol = checkCol;

        // Determine bounce direction (simplistic approach)
        // Check if we're hitting from the side or top/bottom
        if (ballY.round() != checkRow) {
          ballDirectionY = -ballDirectionY;
        } else {
          ballDirectionX = -ballDirectionX;
        }
      }
    }

    // Update ball position
    ballX = (newBallX.clamp(0, 10 - 1)).round();
    ballY = newBallY.round();

    // Ball falls below paddle
    if (ballY >= 25) {
      lives--;
      gameDetailsController.lives.value = lives;

      if (lives <= 0) {
        gameOver();
      } else {
        resetBall();
      }
    }

    // Handle brick hit
    if (brickHit) {
      // Remove the brick
      playfield[hitBrickRow][hitBrickCol] = BlockType.empty;

      // Update score
      score += 10;
      gameDetailsController.score.value = score;
      gameDetailsController.currentGoal.value = level;

      // Check if level is completed
      bool levelCompleted = true;
      for (int row = 0; row < brickRows; row++) {
        for (int col = 0; col < 10; col++) {
          if (playfield[row][col] == BlockType.filled) {
            levelCompleted = false;
            break;
          }
        }
        if (!levelCompleted) break;
      }

      if (levelCompleted) {
        levelUp();
      }
    }
  }

  void movePaddle(int dx) {
    if (gameState == GameState.gameOver || gameState == GameState.paused || gameState == GameState.initial) return;

    int newPaddleX = paddleX + dx;
    if (newPaddleX >= 0 && newPaddleX + 3 <= 10) {
      paddleX = newPaddleX;

      // If ball is not released, it should follow the paddle
      if (!ballReleased) {
        ballX = paddleX + (3 ~/ 2);
      }
    }

    updater.toggle();
  }

  void releaseBall() {
    if (gameState == GameState.playing && !ballReleased) {
      ballReleased = true;
    }
  }

  void levelUp() {
    level++;
    gameDetailsController.goal.value = level;
    box.write(levelKey, level);

    // Increase speed every 3 levels
    if (level % 3 == 0) {
      speed = min(10, speed + 1);
      gameDetailsController.speed.value = speed;
      box.write(speedKey, speed);
    }

    resetBall();
    generateLevel(level);

    Get.snackbar("Level Complete!", "Starting level $level", snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);
  }

  void pauseGame() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
    } else if (gameState == GameState.paused) {
      gameState = GameState.playing;
    }
    updater.toggle();
  }

  void gameOver() {
    final max = box.read(maxScoreKey);
    if (max == null || score > max) {
      box.write(maxScoreKey, score);
      gameDetailsController.hiScore.value = score;
    }

    Get.snackbar("Game Over", "Score: $score", snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);

    gameState = GameState.gameOver;
    updater.toggle();
  }
}
