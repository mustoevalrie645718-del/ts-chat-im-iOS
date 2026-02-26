import 'package:flutter/services.dart';


var platform = const MethodChannel("com.bkb.bkb_pro");
Future<void> jumpToAndroidMethod(String url, String jsTag) async {
  Map<String, String> message = {'titleurl': url, 'jstag': jsTag};
  final String result =
      await platform.invokeMethod('jumpToAndroidPage', message);
}
Future<void> jumpToAndroidMethod2(String url, String jsTag) async {
  Map<String, String> message = {'titleurl': url, 'jstag': jsTag};
  final String result =
  await platform.invokeMethod('jumpToAndroidPagesys', message);
  print('result===$result');
}
