import 'package:get/get.dart';
import 'package:just/common/routes/routes.dart';
import 'package:just/pages/message/state.dart';

class MessageController extends GetxController {
  MessageController();
  final state = MessageState();

  void goProfile() async {
    await Get.toNamed(AppRoutes.Profile);
  }
}
