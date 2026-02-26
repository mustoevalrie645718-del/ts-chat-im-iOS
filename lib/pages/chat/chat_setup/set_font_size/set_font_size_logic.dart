import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../../core/controller/im_controller.dart';
import '../../chat_logic.dart';

class SetFontSizeLogic extends GetxController {
  // final chatLogic = Get.find<ChatLogic>();
  final chatLogic = Get.find<ChatLogic>(tag: GetTags.chat);
  final factor = 1.0.obs;
  final userInfo = Get.find<IMController>().userInfo.value;
  @override
  void onInit() {
    factor.value = DataSp.getChatFontSizeFactor();
    super.onInit();
  }

  void changed(dynamic fac) {
    factor.value = fac;
  }

  Future saveFactor() async {
    await chatLogic.changeFontSize(factor.value);
  }

  void reset() async {
    await chatLogic.changeFontSize(factor.value = Config.textScaleFactor);
  }
}
