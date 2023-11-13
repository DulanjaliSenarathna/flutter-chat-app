import 'package:chatty/common/routes/names.dart';
import 'package:chatty/pages/message/voicecall/state.dart';
import 'package:get/get.dart';

class VoiceCallController extends GetxController {
  VoiceCallController();

  final state = VoiceCallState();

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    state.to_name.value = data["to_name"] ?? "";
    state.to_avatar.value = data["to_avatar"] ?? "";
  }
}
