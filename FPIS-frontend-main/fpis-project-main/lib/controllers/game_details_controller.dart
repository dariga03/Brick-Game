import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GameDetailsController extends GetxController {
  static GameDetailsController get find => Get.find();

  RxBool updater = false.obs;

  RxInt score = 0.obs;
  RxInt hiScore = 0.obs;
  RxInt goal = 0.obs;
  RxInt currentGoal = 0.obs;
  RxInt level = 1.obs;
  RxInt speed = 1.obs;
  RxInt lives = 3.obs;
  RxList<RxList<bool>> matrix = List.generate(4, (index) => List.generate(4, (index) => false).obs).obs;
}
