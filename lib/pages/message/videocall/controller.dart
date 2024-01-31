//import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/chat.dart';
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
      state.isShowAvatar.value = false;
      await player.pause();
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
     // await sendNotification("video");
      await player.play();
    }
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

    await player.stop();
    state.isJoined.value = false;
    EasyLoading.dismiss();
    Get.back();
  }

  Future<void> _dispose() async {
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

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}
