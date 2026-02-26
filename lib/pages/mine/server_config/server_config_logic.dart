import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';

class ServerConfigLogic extends GetxController {
  var checked = true.obs;
  var index = 0.obs;
  var ipCtrl = TextEditingController();
  var authCtrl = TextEditingController();
  var imApiCtrl = TextEditingController();
  var imWsCtrl = TextEditingController();
  var logLevelCtrl = TextEditingController(text: 3.toString());

  var isIP = true.obs;

  void switchServer(bool isIp) {
    isIP.value = isIp;
    ipCtrl.clear();
    final hintText = isIP.value ? 'ip' : 'web.rentsoft.cn';
    if (isIP.value) {
      authCtrl.text = 'http://$hintText:10008';
      imApiCtrl.text = 'http://$hintText:10002';
      imWsCtrl.text = 'ws://$hintText:10001';
    } else {
      ipCtrl.text = 'web.rentsoft.cn';
      authCtrl.text = 'https://$hintText/chat';
      imApiCtrl.text = 'https://$hintText/api';
      imWsCtrl.text = 'wss://$hintText/msg_gateway';
    }
  }

  @override
  void onInit() {
    ipCtrl.text = Config.serverIp;
    authCtrl.text = Config.appAuthUrl;
    imApiCtrl.text = Config.imApiUrl;
    imWsCtrl.text = Config.imWsUrl;
    logLevelCtrl.text = Config.logLevel.toString();

    isIP.value = RegexUtil.isIP(ipCtrl.text);

    ipCtrl.addListener(() {
      if (isIP.value) {
        authCtrl.text = 'http://${ipCtrl.text}:10008';
        imApiCtrl.text = 'http://${ipCtrl.text}:10002';
        imWsCtrl.text = 'ws://${ipCtrl.text}:10001';
      } else {
        authCtrl.text = 'https://${ipCtrl.text}/chat/';
        imApiCtrl.text = 'https://${ipCtrl.text}/api/';
        imWsCtrl.text = 'wss://${ipCtrl.text}/msg_gateway';
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    authCtrl.dispose();
    imApiCtrl.dispose();
    imWsCtrl.dispose();
    ipCtrl.dispose();
    logLevelCtrl.dispose();
    super.onClose();
  }

  void toggleRadio() {
    checked.value = !checked.value;
  }

  void confirm() async {
    if (ipCtrl.text.isEmpty) {
      IMViews.showToast('Enter Server Address!');
      return;
    }
    await DataSp.putServerConfig({
      'serverIP': ipCtrl.text,
      'authUrl': authCtrl.text,
      'apiUrl': imApiCtrl.text,
      'wsUrl': imWsCtrl.text,
      'logLevel': logLevelCtrl.text,
    });
    Logger().sdkIsInitialized = false;
    OpenIM.iMManager.unInitSDK();
    HttpUtil.updateBaseURL(imApiCtrl.text);
    ApiService().setBaseUrl(imApiCtrl.text);
    Get.find<IMController>().initOpenIM(resetStatus: true);
    DataSp.removeLoginCertificate();

    IMViews.showToast(StrRes.serverSettingTips);
  }

  void toggleTab(i) {
    index.value = i;
  }
}
