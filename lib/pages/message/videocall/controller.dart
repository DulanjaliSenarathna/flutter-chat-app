//import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/chat.dart';
import 'package:chatty/common/entities/chatcall.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/values/server.dart';
import 'package:chatty/pages/message/videocall/state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallController extends GetxController {
  VideoCallController();

  final state = VideoCallState();
  final player = AudioPlayer();
  String appId = APPID;
  final db = FirebaseFirestore.instance;
  final profile_token = UserStore.to.profile.token;
  late RtcEngine engine;

  int call_s = 0;
  int call_m = 0;
  int call_h = 0;
  late final Timer callTimer;

  ChannelProfileType channelProfileType =
      ChannelProfileType.channelProfileCommunication;

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    state.to_name.value = data["to_name"] ?? "";
    state.to_avatar.value = data["to_avatar"] ?? "";
    state.call_role.value = data["call_role"] ?? "";
    state.doc_id.value = data["doc_id"] ?? "";
    state.to_token.value = data["to_token"] ?? "";
    initEngine();
  }

  Future<void> initEngine() async {
    player.setAsset("assets/Sound_Horizon.mp3");

    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: appId));

    engine.registerEventHandler(RtcEngineEventHandler(
        onError: (ErrorCodeType err, String msg) {
      print('[onError] err:$err, ,msg:$msg');
    }, onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
      print('onConnection ${connection.toJson()}');
      state.isJoined.value = true;
    }, onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
      state.onRemortUID.value = remoteUid;

      //since the other user joined, don't show the avatar anymore
      state.isShowAvatar.value = false;
      await player.pause();
      callTime();
    }, onLeaveChannel: (RtcConnection connection, RtcStats stats) {
      print("...... user left the room ......");
      state.isJoined.value = false;
      state.onRemortUID.value = 0;
      state.isShowAvatar.value = true;
    }, onRtcStats: (RtcConnection connection, RtcStats stats) {
      print("time ......");
      print(stats.duration);
    }));

    await engine.enableVideo();
    await engine.setVideoEncoderConfiguration(const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0));
    await engine.startPreview();
    state.isReadyPreview.value = true;
    await joinChannel();
    if (state.call_role == "anchor") {
      //send notification to the other user
      await sendNotification("video");
      await player.play();
    }
  }

  void callTime() {
    callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      call_s = call_s + 1;
      if (call_s >= 60) {
        call_s = 0;
        call_m = call_m + 1;
      }
      if (call_m >= 60) {
        call_m = 0;
        call_h = call_h + 1;
      }

      var h = call_h < 10 ? "0${call_h}" : "${call_h}";
      var m = call_m < 10 ? "0${call_m}" : "${call_m}";
      var s = call_s < 10 ? "0${call_s}" : "${call_s}";

      if (call_h == 0) {
        state.callTime.value = "$m:$s";
        state.callTimeNum.value = "$call_m m and $call_s";
      } else {
        state.callTime.value = "$h $m:$s";
        state.callTimeNum.value = "$call_h h $call_m m and $call_s";
      }
    });
  }

  Future<void> sendNotification(String call_type) async {
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.call_type = call_type;
    callRequestEntity.to_token = state.to_token.value;
    callRequestEntity.to_avatar = state.to_avatar.value;
    callRequestEntity.doc_id = state.doc_id.value;
    callRequestEntity.to_name = state.to_name.value;

    var res = await ChatAPI.call_notifications(params: callRequestEntity);
    if (res.code == 0) {
      print("notification success");
    } else {
      print("could not send notification");
    }
  }

  Future<String> getToken() async {
    if (state.call_role == "anchor") {
      state.channelId.value = md5
          .convert(utf8.encode("${profile_token}_${state.to_token}"))
          .toString();
    } else {
      state.channelId.value = md5
          .convert(utf8.encode("${state.to_token}_$profile_token"))
          .toString();
    }

    CallTokenRequestEntity callTokenRequestEntity = CallTokenRequestEntity();
    callTokenRequestEntity.channel_name = state.channelId.value;

    print("............channel Id is ${state.channelId.value}");
    print("...my access token is${UserStore.to.token}");

    var res = await ChatAPI.call_token(params: callTokenRequestEntity);
    if (res.code == 0) {
      return res.data!;
    }
    return "";
  }

  Future<void> joinChannel() async {
    await Permission.microphone.request();
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);

    String token = await getToken();
    if (token.isEmpty) {
      EasyLoading.dismiss();
      Get.back();
      return;
    }

    await engine.joinChannel(
        token: token,
        channelId: state.channelId.value,
        uid: 0,
        options: ChannelMediaOptions(
            channelProfile: channelProfileType,
            clientRoleType: ClientRoleType.clientRoleBroadcaster));

    EasyLoading.dismiss();
  }

  Future<void> leaveChannel() async {
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);

    await player.pause();
    await sendNotification("cancel");
    state.isJoined.value = false;
    state.switchCamera.value = true;
    EasyLoading.dismiss();
    Get.back();
  }

  Future<void> switchCamera() async {
    await engine.switchCamera();
    state.switchCamera.value = !state.switchCamera.value;
  }

  Future<void> addCallTime() async {
    var profile = UserStore.to.profile;
    var msgData = ChatCall(
        from_token: profile.token,
        to_token: state.to_token.value,
        from_name: profile.name,
        to_name: state.to_name.value,
        from_avatar: profile.avatar,
        to_avatar: state.to_avatar.value,
        call_time: state.callTime.value,
        type: "video",
        last_time: Timestamp.now());

    await db
        .collection("chatcall")
        .withConverter(
            fromFirestore: ChatCall.fromFirestore,
            toFirestore: (ChatCall msg, options) => msg.toFirestore())
        .add(msgData);
    String sendContent = "Call time ${state.callTimeNum.value} [video]";
    saveMessage(sendContent);
  }

  saveMessage(String sendContent) async {
    if (state.doc_id.value.isEmpty) {
      return;
    }
    final content = Msgcontent(
        token: profile_token,
        content: sendContent,
        type: "text",
        addtime: Timestamp.now());
    await db
        .collection("message")
        .doc(state.doc_id.value)
        .collection("msglist")
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msgContent, options) =>
                msgContent.toFirestore()).add(content);
  }

  Future<void> _dispose() async {
    if (state.call_role == "anchor") {
      addCallTime();
    }
    await player.pause();
    await engine.leaveChannel();
    await engine.release();
    await player.stop();
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }
}
