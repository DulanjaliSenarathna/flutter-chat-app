import 'package:chatty/common/routes/names.dart';
import 'package:chatty/pages/message/voicecall/state.dart';
import 'package:get/get.dart';

class VoiceCallController extends GetxController {
  VoiceCallController();
  final title = 'Jengo';
  final state = VoiceCallState();

  @override
  void onReady() {
    super.onReady();
    Future.delayed(
        const Duration(seconds: 3), () => Get.offAllNamed(AppRoutes.Message));
  }
}
