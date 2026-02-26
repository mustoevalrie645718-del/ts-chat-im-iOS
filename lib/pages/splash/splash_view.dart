import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../routes/app_navigator.dart';
import 'PrivacyPolicyDialog.dart';
import 'splash_logic.dart';

class SplashPage extends StatelessWidget {
  final logic = Get.find<SplashLogic>();
  final String _privacyText = '''
【隐私政策】
一、信息收集
1.1 我们会收集您的设备信息（如设备型号、操作系统版本），用于应用适配和性能优化。
1.2 当您使用应用功能时，我们可能收集您的操作行为数据，用于提升用户体验。

二、信息使用
2.1 收集的信息仅用于本应用的功能实现和服务优化，不会用于其他用途。
2.2 我们不会向第三方出售、出租您的个人信息。

三、信息保护
3.1 我们采用加密技术保护您的个人信息，防止信息泄露、丢失。
3.2 您可以随时在应用设置中查看、修改或删除您的个人信息。

四、用户权利
4.1 您有权选择是否同意本隐私政策，拒绝后将无法使用应用。
4.2 本政策可能会不定期更新，更新后我们会通过应用内通知告知您。

''';
  SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Styles.c_0089FF_opacity10, Styles.c_FFFFFF_opacity0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 130.h,
            child: ImageRes.loginLogo.toImage
              ..width = 55.61.w
              ..height = 78.91.h,
          ), Obx(() =>Visibility(
            visible: logic.isshow.value,
            child: PrivacyPolicyDialog(privacyContent: _privacyText, onAgree: () {
              AppNavigator.startLogin();
            }),
          )),
        ],
      ),
    );
  }
}
