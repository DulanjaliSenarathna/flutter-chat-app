//import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/values/server.dart';
import 'package:chatty/pages/message/voicecall/state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceCallController extends GetxController {
  VoiceCallController();

  final state = VoiceCallState();
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
      await player.pause();
    }, onLeaveChannel: (RtcConnection connection, RtcStats stats) {
      print("...... user left the room ......");
      state.isJoined.value = false;
    }, onRtcStats: (RtcConnection connection, RtcStats stats) {
      print("time ......");
      print(stats.duration);
    }));

    await engine.enableAudio();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming);
   await joinChannel();
  }

  Future<void> joinChannel() async {
    await Permission.microphone.request();
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(
        indicator: CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);

    await engine.joinChannel(
        token:
            "007eJxTYJD8IKdY81niSMn9bpYLoV0XfT6kF9UVHlPcPcmq793EywUKDKlGZqYWBonm5omJxibJhqkWlqZGlmYWycmJhgaGlskmq5SDUxsCGRkCyiUYGKEQxGdlyErNS89nYAAAi80ffw==",
        channelId: "jengo",
        uid: 0,
        options: ChannelMediaOptions(
            channelProfile: channelProfileType,
            clientRoleType: ClientRoleType.clientRoleBroadcaster));

    EasyLoading.dismiss();
  }

  Future<void> leaveChannel() async {
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(
        indicator: CircularProgressIndicator(),
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
