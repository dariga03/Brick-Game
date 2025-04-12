import 'package:brick_game/controllers/display_controller.dart';
import 'package:brick_game/controllers/game_details_controller.dart';
import 'package:brick_game/pages/arkanoid/controller.dart';
import 'package:brick_game/pages/race/controller.dart';
import 'package:brick_game/pages/snake/controller.dart';
import 'package:brick_game/pages/tetris/controller.dart';
import 'package:brick_game/widgets/controls.dart';
import 'package:brick_game/widgets/display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Brick game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(
        () {
          Get.lazyPut(() => DisplayController(), fenix: true);
          Get.put(GameDetailsController(), permanent: true);
          Get.put(RaceController(), permanent: true);
          Get.put(TetrisController(), permanent: true);
          Get.put(SnakeController(), permanent: true);
          Get.put(ArkanoidController(), permanent: true);
        },
      ),
      getPages: [
        GetPage(
          name: "/main",
          page: () => MainScreen(),
        ),
      ],
      initialRoute: "/main",
    );
  }
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final DisplayController displayController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        height: Get.size.height,
        width: Get.size.width,
        child: SafeArea(
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 26,
                  child: Display(
                    content: displayController.getContent(),
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: Controls(displayController.controlls.value ?? Controlls()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
