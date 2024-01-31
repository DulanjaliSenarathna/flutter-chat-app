import 'package:get/get.dart';

class VideoCallState {
  RxBool isJoined = false.obs;
  RxBool openMicrophone = true.obs;
  RxBool enableSpeaker = true.obs;
  RxString callTime = "00.00".obs;
  RxString callStatus = "not connected".obs;

  var to_token = "".obs;
  var to_name = "".obs;
  var to_avatar = "".obs;
  var doc_id = "".obs;
  var channelId = "".obs;

  //reciever = audience
  //anchor = caller
  var call_role = "audience".obs;

  RxBool isReadyPreview = false.obs;

  //if user did not join show avatar, otherwise don't show
  RxBool isShowAvatar = true.obs;

  //change camera front and back
  RxBool switchCamera = true.obs;

  //remember the remord id of the user from agora
  RxInt onRemortUID = 0.obs;
}
