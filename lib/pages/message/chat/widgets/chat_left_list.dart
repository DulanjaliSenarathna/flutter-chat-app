import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/common/entities/msgcontent.dart';
import 'package:chatty/common/values/colors.dart';
import 'package:chatty/common/values/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ChatLeftList(Msgcontent item) {
  var imagePath = null;
  if (item.type == "image") {
    imagePath = item.content?.replaceAll("http://localhost/", SERVER_API_URL);
  }
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 250.w, minHeight: 40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.primaryElement,
                    borderRadius: BorderRadius.all(Radius.circular(5.w))),
                padding: EdgeInsets.only(
                    top: 10.w, bottom: 10.w, right: 10.w, left: 10.w),
                child: item.type == "text"
                    ? Text(
                        "${item.content}",
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primaryElementText),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 90.w),
                        child: GestureDetector(
                          child: CachedNetworkImage(imageUrl: imagePath),
                          onTap: () {},
                        ),
                      ),
              )
            ],
          ),
        )
      ],
    ),
  );
}
