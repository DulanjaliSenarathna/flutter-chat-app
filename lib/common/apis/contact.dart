import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/utils/utils.dart';

class ContactAPI {
  /// Turn page
  /// refresh
  static Future<ContactResponseEntity> post_contact() async {
    var response = await HttpUtil().post(
      'api/contact',
    );
    return ContactResponseEntity.fromJson(response);
  }


}
