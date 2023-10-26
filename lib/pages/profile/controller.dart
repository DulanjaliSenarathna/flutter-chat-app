import 'package:chatty/common/routes/names.dart';
import 'package:chatty/pages/profile/state.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  ProfileController();
  final title = 'Jengo .';
  final state = ProfileState();

  @override
  void onReady() {
    super.onReady();
    Future.delayed(
        const Duration(seconds: 3), () => Get.offAllNamed(AppRoutes.Message));
  }
}
