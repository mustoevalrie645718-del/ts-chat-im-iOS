import 'package:get/get.dart';

import '../../repository/repository.dart';
import '../../repository/repository_adapter.dart';
import 'meeting_logic.dart';

class MeetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IMeetingRepository>(() => MeetingRepository());
    Get.lazyPut(() => MeetingLogic(repository: Get.find()));
  }
}
