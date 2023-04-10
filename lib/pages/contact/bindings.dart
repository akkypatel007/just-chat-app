import 'package:get/get.dart';

import 'index.dart';

class ContactBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactController>(() => ContactController());
  }
}
