import 'package:chatty/common/entities/entities.dart';
import 'package:get/get.dart';

class MessageState {
  var head_detail = UserItem().obs;
  RxBool tabStatus = true.obs;
  RxList<Message> msgLlist = <Message>[].obs;
  RxList<CallMessage> callLlist = <CallMessage>[].obs;
}
