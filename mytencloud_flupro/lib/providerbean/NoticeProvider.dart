import 'package:flutter/foundation.dart';

class NoticeProvider with ChangeNotifier {
  int _counter = 1;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();  // 通知所有监听者更新状态
  }
}
