import 'package:get/get.dart';
import 'package:just/common/routes/routes.dart';
import 'package:just/pages/frame/welcome/state.dart';

class WelcomeController extends GetxController {
  WelcomeController();
  final title = "just .";
  final state = WelcomeState();

  @override
  void onReady() {
    super.onReady();
    Future.delayed(
        Duration(seconds: 3), () => Get.offAllNamed(AppRoutes.Message));
  }
}
