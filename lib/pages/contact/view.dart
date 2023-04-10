import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just/common/values/colors.dart';
import 'package:just/pages/contact/widget/contact_list.dart';

import 'index.dart';

class ContactPage extends GetView<ContactController> {
  const ContactPage({Key? key}) : super(key: key);

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Contact',
        style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryElement,
      appBar: _buildAppBar(),
      body: Container(
        margin: EdgeInsets.only(top: 350),
        width: 360.w,
        height: 780.h,
        child: ContactList(),
      ),
    );
  }
}
