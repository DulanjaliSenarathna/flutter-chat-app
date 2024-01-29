import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/base.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/pages/message/state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:get/get.dart';

class MessageController extends GetxController {
  MessageController();
  final state = MessageState();

  void goProfile() async {
    await Get.toNamed(AppRoutes.Profile);
  }

  @override
  void onReady() {
    super.onReady();
    firebaseMessageSetup();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getProfile();
  }

  void getProfile() async {
    var profile = await UserStore.to.profile;
    state.head_detail.value = profile;
    state.head_detail.refresh();
  }

  firebaseMessageSetup() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print("....my device token $fcmToken");
    if (fcmToken != null) {
      BindFcmTokenRequestEntity bindFcmTokenRequestEntity =
          BindFcmTokenRequestEntity();
      bindFcmTokenRequestEntity.fcmtoken = fcmToken;
      await ChatAPI.bind_fcmtoken(params: bindFcmTokenRequestEntity);
    }
  }
}
