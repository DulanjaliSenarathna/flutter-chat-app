import 'package:chatty/common/values/colors.dart';
import 'package:chatty/pages/contact/controller.dart';
import 'package:chatty/pages/contact/widgets/contact_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactPage extends GetView<ContactController> {
  const ContactPage({super.key});

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Contact",
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
      appBar: _buildAppBar(),
      body: Container(width: 360.w, height: 780.h, child: ContactList()),
    );
  }
}
