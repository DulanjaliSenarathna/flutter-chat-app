import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/widgets/toast.dart';
import 'package:chatty/pages/message/chat/state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  ChatController();

  final state = ChatState();
  late String doc_id;
  final myInputController = TextEditingController();

  //get the user or sender's token
  final token = UserStore.to.profile.token;

  //firebase data instance
  final db = FirebaseFirestore.instance;

  void goMore() {
    state.more_status.value = state.more_status.value ? false : true;
  }

  void audioCall() {
    state.more_status.value = false;
    Get.toNamed(AppRoutes.VoiceCall, parameters: {
      "to_token": state.to_token.value,
      "to_name": state.to_name.value,
      "to_avatar": state.to_avatar.value,
      "call_role": "anchor",
      "doc_id": doc_id
    });
  }

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    print(data);
    doc_id = data['doc_id']!;
    state.to_token.value = data['to_token'] ?? "";
    state.to_name.value = data['to_name'] ?? "";
    state.to_avatar.value = data['to_avatar'] ?? "";
    state.to_online.value = data['to_online'] ?? "1";
  }

  void sendMessage() async {
    String sendContent = myInputController.text;
    print('................$sendContent');
    if (sendContent.isEmpty) {
      toastInfo(msg: 'Content is empty');
      return;
    }

    //Created an object to send to firebase
   final content =  Msgcontent(
        token: token,
        content: sendContent,
        type: "text",
        addtime: Timestamp.now());

    db.collection('message').doc(doc_id).collection('msglist')
    .withConverter(
      fromFirestore: Msgcontent.fromFirestore,
      toFirestore: (Msgcontent msg,options)=>msg.toFirestore()).add(content).then((DocumentReference doc) =>{
        print('.....new msg docid is ${doc.id}')
      } );
  }
}
