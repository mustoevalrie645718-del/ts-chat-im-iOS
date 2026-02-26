import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void showMyToast(String msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.CENTER);
  }
}
