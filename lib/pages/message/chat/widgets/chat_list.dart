import 'package:chatty/pages/message/chat/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatList extends GetView<ChatController> {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(()=> Container(
      child: CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.symmetric(
            vertical: 0.w,
            horizontal: 0.w
          ),
          sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => null)),
          )
        ],
      ),
    ));
  }
}