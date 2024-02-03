import 'package:chatty/pages/profile/controller.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/common/values/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

AppBar buildAppBar() {
  return AppBar(
    title: Text(
      "Profile",
      style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16.sp,
          fontWeight: FontWeight.normal),
    ),
  );
}

Widget buildProfilePhoto(ProfileController controller) {
  return Stack(
    children: [
      Container(
        width: 120.w,
        height: 120.w,
        decoration: BoxDecoration(
            color: AppColors.primarySecondaryBackground,
            borderRadius: BorderRadius.all(Radius.circular(60.w)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1))
            ]),
        child: controller.state.profile_detail.value.avatar != null
            ? CachedNetworkImage(
                imageUrl: controller.state.profile_detail.value.avatar!,
                height: 120.w,
                width: 120.w,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(60.w)),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill)),
                ),
                errorWidget: (context, url, error) => const Image(
                  image: AssetImage("assets/images/account_header.png"),
                ),
              )
            : Image(
                width: 120.w,
                height: 120.h,
                fit: BoxFit.cover,
                image: const AssetImage("assets/images/account_header.png")),
      ),
      Positioned(
          bottom: 0.w,
          right: 0.w,
          height: 35.w,
          child: GestureDetector(
            child: Container(
              height: 35.w,
              width: 35.w,
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                  color: AppColors.primaryElement,
                  borderRadius: BorderRadius.all(Radius.circular(40.w))),
              child: Image.asset("assets/icons/edit.png"),
            ),
          ))
    ],
  );
}

Widget bulidName(ProfileController controller) {
  return Container(
      width: 295.w,
      height: 44.h,
      decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.all(Radius.circular(5.w)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1))
          ]),
      margin: EdgeInsets.only(bottom: 20.h, top: 60.h),
      child: _profileTextField(controller));
}

Widget _profileTextField(ProfileController controller) {
  return TextField(
    //controller: controller.myInputController,
    maxLines: null,
    keyboardType: TextInputType.multiline,
    decoration: InputDecoration(
        hintText: controller.state.profile_detail.value.name,
        contentPadding: EdgeInsets.only(left: 15.w, top: 0, bottom: 0),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        hintStyle:
            const TextStyle(color: AppColors.primaryText)),
        style: TextStyle(
          color: AppColors.primaryText,
          fontFamily: "Avenir",
          fontWeight: FontWeight.normal,
          fontSize: 14.sp
        ),
  );
}

Widget buildCompleteBtn() {
  return GestureDetector(
    child: Container(
      width: 295.w,
      height: 44.h,
      margin: EdgeInsets.only(top: 60.h, bottom: 30.h),
      decoration: BoxDecoration(
          color: AppColors.primaryElement,
          borderRadius: BorderRadius.all(Radius.circular(5.w)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Complete",
            style: TextStyle(
                color: AppColors.primaryElementText,
                fontSize: 14.sp,
                fontWeight: FontWeight.normal),
          )
        ],
      ),
    ),
  );
}

Widget buildLogOutBtn(ProfileController controller) {
  return GestureDetector(
    child: Container(
      width: 295.w,
      height: 44.h,
      margin: EdgeInsets.only(top: 0.h, bottom: 30.h),
      decoration: BoxDecoration(
          color: AppColors.primarySecondaryElementText,
          borderRadius: BorderRadius.all(Radius.circular(5.w)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Logout",
            style: TextStyle(
                color: AppColors.primaryElementText,
                fontSize: 14.sp,
                fontWeight: FontWeight.normal),
          )
        ],
      ),
    ),
    onTap: () {
      Get.defaultDialog(
          title: "Are you sure to logout?",
          backgroundColor: Colors.white,
          content: Container(),
          radius: 5.0,
          confirmTextColor: Colors.white,
          onConfirm: () {
            controller.goLogOut();
          },
          onCancel: () {},
          textConfirm: "Confirm",
          textCancel: "Cancel");
    },
  );
}
