import 'package:chatty/pages/message/videocall/controller.dart';
import 'package:get/get.dart';

class VideoCallBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoCallController>(() => VideoCallController());
  }
}
