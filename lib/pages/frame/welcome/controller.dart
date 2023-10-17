import 'package:chatty/pages/frame/welcome/state.dart';
import 'package:get/get.dart';

class WelcomeCotroller extends GetxController {
  WelcomeCotroller();
  final title = 'Jengo .';
  final state = WelcomeState();

  @override
  void onReady() {
    super.onReady();
    print("Welcome Controller");
  }
}
