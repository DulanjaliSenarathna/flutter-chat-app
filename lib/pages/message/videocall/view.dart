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
                child: controller.state.isReadyPreview.value
                    ? Stack(
                        children: [
                          controller.state.onRemortUID.value == 0
                              ? Container()
                              : AgoraVideoView(
                                  controller: VideoViewController.remote(
                                      rtcEngine: controller.engine,
                                      canvas: VideoCanvas(
                                          uid: controller
                                              .state.onRemortUID.value),
                                      connection: RtcConnection(
                                          channelId: controller
                                              .state.channelId.value))),
                        controller.state.isShowAvatar.value ? Container():
                        Positioned(
                          top: 10.h,
                          left: 30.w,
                          right: 30.w,
                          child: Column(
                            children: [
                              Container(
                                child: Text(controller.state.callTime.value,
                                style: TextStyle(
                                  color: AppColors.primaryElementText,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.normal
                                ),),
                              )
                            ],
                        )),
                          Positioned(
                              bottom: 80.h,
                              left: 30.w,
                              right: 30.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          controller.state.isJoined.value
                                              ? controller.leaveChannel()
                                              : controller.joinChannel();
                                        },
                                        child: Container(
                                          width: 60.w,
                                          height: 60.h,
                                          padding: EdgeInsets.all(15.w),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30.w),
                                            color: controller.state.isJoined.value?AppColors.primaryElementBg:AppColors.primaryElementStatus
                                          ),
                                          child: controller.state.isJoined.value?Image.asset("assets/icons/a_phone.png"):Image.asset("assets/icons/a_telephone.png"),
                                        ),
                                      )
                                    ,
                                    Container(
                                      margin: EdgeInsets.only(top: 10.h),
                                      child: Text(
                                        controller.state.isJoined.value?"Disconnect":"Connecting",
                                        style: TextStyle(
                                          color: AppColors.primaryElementText,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.normal
                                        ),
                                      ),
                                    )
                                    ],
                                  )
                                ],
                              )
                              ),
                              //if the user did not join, show his avatar
                              controller.state.isShowAvatar.value? Positioned(
                                top: 10.h,
                                left: 30.h,
                                right: 30.h,
                                child: Column(
                                children: [

                                  //show other user's avatar
                                  Container(
                                    width: 70.w,
                                    height: 70.w,
                                    margin: EdgeInsets.only(top: 150.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.w),
                                      color: AppColors.primaryElementText
                                    ),
                                    child: Image.network(controller.state.to_avatar.value,
                                    fit: BoxFit.fill,)
                                    ,
                                    
                                  ),
                                  //show other user's avatar
                                  Container(
                                    margin: EdgeInsets.only(top: 6.h),
                                    child: Text(
                                      controller.state.to_name.value,
                                      style: TextStyle(
                                        color: AppColors.primaryElementText,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.normal
                                      ),
                                    ),
                                  )
                                ],
                              )
                              ):Container()
                        ],
                      )
                    : Container(),
              )),
        ));
  }
}
