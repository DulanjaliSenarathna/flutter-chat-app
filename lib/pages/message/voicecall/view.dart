import 'package:chatty/common/values/colors.dart';
import 'package:chatty/pages/message/voicecall/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceCallPage extends GetView<VoiceCallController> {
  const VoiceCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primary_bg,
        body: SafeArea(
          child: Obx(() => Container(
                child: Stack(
                  children: [
                    Positioned(
                        top: 10.h,
                        left: 30.w,
                        right: 30.w,
                        child: Column(
                          children: [
                            Text(
                              controller.state.callTime.value,
                              style: TextStyle(
                                  color: AppColors.primaryElementText,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.normal),
                            ),
                            Container(
                              width: 70.h,
                              height: 70.h,
                              margin: EdgeInsets.only(top: 150.h),
                              child: Image.network(
                                  controller.state.to_avatar.value),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5.h),
                              child: Text(
                                controller.state.to_name.value,
                                style: TextStyle(
                                    color: AppColors.primaryElementText,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.normal),
                              ),
                            )
                          ],
                        )),
                    Positioned(
                        bottom: 80.h,
                        left: 30.h,
                        right: 30.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //microphone section
                            Column(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(15.w),
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.w)),
                                        color: controller
                                                .state.openMicrophone.value
                                            ? AppColors.primaryElementText
                                            : AppColors.primaryText),
                                    child: controller.state.openMicrophone.value
                                        ? Image.asset(
                                            "assets/icons/b_microphone.png")
                                        : Image.asset(
                                            "assets/icons/a_microphone.png"),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10.h),
                                  child: Text(
                                    "Microphone",
                                    style: TextStyle(
                                        color: AppColors.primaryElementText,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: controller.state.isJoined.value
                                      ? controller.leaveChannel
                                      : controller.joinChannel,
                                  child: Container(
                                    padding: EdgeInsets.all(15.w),
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.w)),
                                        color: controller.state.isJoined.value
                                            ? AppColors.primaryElementBg
                                            : AppColors.primaryElementStatus),
                                    child: controller.state.isJoined.value
                                        ? Image.asset(
                                            "assets/icons/a_phone.png")
                                        : Image.asset(
                                            "assets/icons/a_telephone.png"),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10.h),
                                  child: Text(
                                    controller.state.isJoined.value
                                        ? "Disconnect"
                                        : "Connect",
                                    style: TextStyle(
                                        color: AppColors.primaryElementText,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(15.w),
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.w)),
                                        color:
                                            controller.state.enableSpeaker.value
                                                ? AppColors.primaryElementText
                                                : AppColors.primaryText),
                                    child: controller.state.enableSpeaker.value
                                        ? Image.asset(
                                            "assets/icons/b_trumpet.png")
                                        : Image.asset(
                                            "assets/icons/a_trumpet.png"),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10.h),
                                  child: Text(
                                    "Speaker",
                                    style: TextStyle(
                                        color: AppColors.primaryElementText,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ))
                  ],
                ),
              )),
        ));
  }
}
