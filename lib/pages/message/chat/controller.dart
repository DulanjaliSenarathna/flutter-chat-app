import 'dart:io';

import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/widgets/toast.dart';
import 'package:chatty/pages/message/chat/state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatController extends GetxController {
  ChatController();

  final state = ChatState();
  late String doc_id;
  final myInputController = TextEditingController();

  //get the user or sender's token
  final token = UserStore.to.profile.token;

  //firebase data instance
  final db = FirebaseFirestore.instance;
  var listener;
  var isLoadmore = true;
  File? _photo;
  final ImagePicker _picker = ImagePicker();
  ScrollController myScrollController = ScrollController();

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

  Future<bool> requestPermission(Permission permission) async {
    var permissionStatus = await permission.status;
    if (permissionStatus != PermissionStatus.granted) {
      var status = await permission.request();
      if (status != PermissionStatus.granted) {
        toastInfo(msg: "Please enable permission have video call");
        if(GetPlatform.isAndroid){
           await openAppSettings();
        }
        return false;
      }
    }

    return true;
  }

  Future<void> videoCall() async {
    state.more_status.value = false;
    bool micStatus = await requestPermission(Permission.microphone);
    bool camStatus = await requestPermission(Permission.camera);

    if(GetPlatform.isAndroid && micStatus && camStatus){
      Get.toNamed(AppRoutes.VideoCall, parameters: {
      "to_token": state.to_token.value,
      "to_name": state.to_name.value,
      "to_avatar": state.to_avatar.value,
      "call_role": "anchor",
      "doc_id": doc_id
    });
    
    }else{
      Get.toNamed(AppRoutes.VideoCall, parameters: {
      "to_token": state.to_token.value,
      "to_name": state.to_name.value,
      "to_avatar": state.to_avatar.value,
      "call_role": "anchor",
      "doc_id": doc_id
    });
    }
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

    // Clearing red dots
    clearMsgNum(doc_id);
  }

  Future<void> clearMsgNum(String doc_id) async {
    var messageResult = await db
        .collection('message')
        .doc(doc_id)
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .get();
    // to know if we have any unread messages or calls
    if (messageResult.data() != null) {
      var item = messageResult.data()!;
      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;

      //this is your phone
      if (item.from_token == token) {
        to_msg_num = 0;
      } else {
        from_msg_num = 0;
      }

      await db.collection("message").doc(doc_id).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
      });
    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    state.msgcontentList.clear();
    final messages = db
        .collection("message")
        .doc(doc_id)
        .collection("msglist")
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msg, options) => msg.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(15);

    listener = messages.snapshots().listen((event) {
      List<Msgcontent> tempMsgList = <Msgcontent>[];
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            if (change.doc.data() != null) {
              tempMsgList.add(change.doc.data()!);
              print("${change.doc.data()!}");
            }
            break;

          case DocumentChangeType.modified:
            // TODO: Handle this case.
            break;

          case DocumentChangeType.removed:
            // TODO: Handle this case.
            break;
        }
      }

      tempMsgList.reversed.forEach((element) {
        state.msgcontentList.value.insert(0, element);
      });

      state.msgcontentList.refresh();
      if (myScrollController.hasClients) {
        myScrollController.animateTo(
            //points to the very top of your list
            //lowest index
            myScrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });

    myScrollController.addListener(() {
      if (myScrollController.offset + 20 >
          myScrollController.position.maxScrollExtent) {
        if (isLoadmore) {
          state.isLoading.value = true;
          // to stop unnecessary request to firebase
          isLoadmore = false;
          asyncLoadMoreData();
        }
      }
    });
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      uploadFile();
    } else {
      print("No image selected");
    }
  }

  Future uploadFile() async {
    var result = await ChatAPI.upload_img(file: _photo);
    print(result.data);
    if (result.code == 0) {
      sendImageMessage(result.data!);
    } else {
      toastInfo(msg: "Sending Image Error");
    }
  }

  void sendImageMessage(String url) async {
    //Created an object to send to firebase
    final content = Msgcontent(
        token: token, content: url, type: "image", addtime: Timestamp.now());

    db
        .collection('message')
        .doc(doc_id)
        .collection('msglist')
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msg, options) => msg.toFirestore())
        .add(content)
        .then((DocumentReference doc) {
      print('..... base id is $doc_id, new img docid is ${doc.id}');
    });

    //collection().get().docs.data()
    var messageResult = await db
        .collection('message')
        .doc(doc_id)
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .get();
    // to know if we have any unread messages or calls
    if (messageResult.data() != null) {
      var item = messageResult.data()!;
      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;
      if (item.from_token == token) {
        from_msg_num = from_msg_num + 1;
      } else {
        to_msg_num = to_msg_num + 1;
      }

      await db.collection("message").doc(doc_id).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
        "last_msg": "[image]",
        "last_time": Timestamp.now()
      });
    }
  }

  void closeAllPop() async {
    Get.focusScope?.unfocus();
    state.more_status.value = false;
  }

  void asyncLoadMoreData() async {
    final messages = await db
        .collection("message")
        .doc(doc_id)
        .collection("msglist")
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msg, options) => msg.toFirestore())
        .orderBy("addtime", descending: true)
        .where("addtime", isLessThan: state.msgcontentList.value.last.addtime)
        .limit(10)
        .get();

    if (messages.docs.isNotEmpty) {
      messages.docs.forEach((element) {
        var data = element.data();
        state.msgcontentList.value.add(data);
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      isLoadmore = true;
    });
    state.isLoading.value = false;
  }

  void sendMessage() async {
    String sendContent = myInputController.text;
    print('................$sendContent');
    if (sendContent.isEmpty) {
      toastInfo(msg: 'Content is empty');
      return;
    }

    //Created an object to send to firebase
    final content = Msgcontent(
        token: token,
        content: sendContent,
        type: "text",
        addtime: Timestamp.now());

    db
        .collection('message')
        .doc(doc_id)
        .collection('msglist')
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msg, options) => msg.toFirestore())
        .add(content)
        .then((DocumentReference doc) {
      print('..... base id is $doc_id, new msg docid is ${doc.id}');
      myInputController.clear();
    });

    //collection().get().docs.data()
    var messageResult = await db
        .collection('message')
        .doc(doc_id)
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .get();
    // to know if we have any unread messages or calls
    if (messageResult.data() != null) {
      var item = messageResult.data()!;
      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;
      if (item.from_token == token) {
        from_msg_num = from_msg_num + 1;
      } else {
        to_msg_num = to_msg_num + 1;
      }

      await db.collection("message").doc(doc_id).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
        "last_msg": sendContent,
        "last_time": Timestamp.now()
      });
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    listener.cancel();
    myInputController.dispose();
    myScrollController.dispose();
    clearMsgNum(doc_id);
  }
}
