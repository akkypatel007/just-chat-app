import 'package:get/get.dart';
import 'package:just/pages/frame/welcome/controller.dart';

class WelcomeBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeController>(() => WelcomeController());
  }
}
