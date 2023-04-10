import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../common/apis/contact.dart';
import 'index.dart';

class ContactController extends GetxController {
  ContactController();
  final title = "just .";
  final state = ContactState();

  @override
  void onReady() {
    super.onReady();
    EasyLoading.show(
        indicator: CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    state.contactList.clear();
    ContactAPI.post_contact();
  }
}
