import 'package:chatty/common/routes/pages.dart';
import 'package:chatty/common/style/style.dart';
import 'package:chatty/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> main() async {
  await Global.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360,780),
      builder: (context,child) => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      builder:EasyLoading.init() ,
    )
    );
  }
}
