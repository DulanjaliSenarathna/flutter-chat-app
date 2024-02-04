import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/base.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/pages/message/state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:get/get.dart';

class MessageController extends GetxController {
  MessageController();
  final state = MessageState();
  final db = FirebaseFirestore.instance;
  final token = UserStore.to.profile.token;

  void goProfile() async {
    await Get.toNamed(AppRoutes.Profile, arguments: state.head_detail.value);
    getProfile();
  }

  @override
  void onReady() {
    super.onReady();
    firebaseMessageSetup();
  }

  goTabStatus() {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    state.tabStatus.value = !state.tabStatus.value;

    if (state.tabStatus.value) {
      Future.delayed(const Duration(seconds: 2), () {
        asyncLoadMsgData();
      });
    } else {}

    EasyLoading.dismiss();
  }

  void asyncLoadMsgData() async {
    //var token = UserStore.to.profile.token;
    var from_messages = await db
        .collection("message")
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where("from_token", isEqualTo: token)
        .get();

    print(from_messages.docs.length);

    var to_messages = await db
        .collection("message")
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where("to_token", isEqualTo: token)
        .get();
    print(to_messages.docs.length);

    state.msgLlist.clear();

    if (from_messages.docs.isNotEmpty) {
      await addMessage(from_messages.docs);
    }

    if (to_messages.docs.isNotEmpty) {
      await addMessage(to_messages.docs);
    }
  }

  addMessage(List<QueryDocumentSnapshot<Msg>> data) {
    data.forEach((element) {
      var item = element.data();
      Message message = Message();

      //Saves the current properties
      message.doc_id = element.id;
      print('================================= ${message.doc_id}');
      message.last_time = item.last_time;
      //message.msg_num = item.msg_num;
      message.last_msg = item.last_msg;
      if (item.from_token == token) {
        message.name = item.to_name;
        message.avatar = item.to_avatar;
        message.token = item.to_token;
        message.online = item.to_online;
        message.msg_num = item.to_msg_num ?? 0;
      } else {
        message.name = item.from_name;
        message.avatar = item.from_avatar;
        message.token = item.from_token;
        message.online = item.from_online;
        message.msg_num = item.from_msg_num ?? 0;
      }
      state.msgLlist.add(message);
    });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getProfile();
    _snapShots();
  }

  _snapShots() {
    var token = UserStore.to.profile.token;
    final toMessageRef = db
        .collection("message")
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where("to_token", isEqualTo: token);

    final fromMessageRef = db
        .collection("message")
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where("from_token", isEqualTo: token);

    toMessageRef.snapshots().listen((event) {
      asyncLoadMsgData();
    });

    fromMessageRef.snapshots().listen((event) {
      asyncLoadMsgData();
    });
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
      try {
        await ChatAPI.bind_fcmtoken(params: bindFcmTokenRequestEntity);
      } catch (e) {
        print(e.toString() + "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      }
    }
  }
}
