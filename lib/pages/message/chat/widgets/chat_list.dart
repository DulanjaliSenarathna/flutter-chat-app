import 'package:chatty/pages/message/chat/controller.dart';
import 'package:chatty/pages/message/chat/widgets/chat_left_list.dart';
import 'package:chatty/pages/message/chat/widgets/chat_right_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatList extends GetView<ChatController> {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.only(bottom: 70.w),
          child: CustomScrollView(
            controller: controller.myScrollController,
            reverse: true,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 0.w, horizontal: 0.w),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  var item = controller.state.msgcontentList[index];
                  if (controller.token == item.token) {
                    //user token with msglist token
                    return ChatRightList(item);
                  } else {
                    return ChatLeftList(item);
                  }
                }, childCount: controller.state.msgcontentList.length)),
              )
            ],
          ),
        ));
  }
}
