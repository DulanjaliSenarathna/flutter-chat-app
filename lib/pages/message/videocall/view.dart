import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatty/common/values/colors.dart';
import 'package:chatty/pages/message/videocall/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoCallPage extends GetView<VideoCallController> {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primary_bg,
        body: SafeArea(
          child: Obx(() => Container(
                child: controller.state.isReadyPreview.value ?  Stack(
                  children: [
                    controller.state.onRemortUID.value ==0?Container():
                    AgoraVideoView(controller: 
                    VideoViewController.remote(
                      rtcEngine: controller.engine, 
                      canvas: VideoCanvas(uid: controller.state.onRemortUID.value), 
                      connection: RtcConnection(channelId: controller.state.channelId.value)))
                    ],
                ):Container(),
              )),
        ));
  }
}
