import 'package:get/get.dart';

import '../../repository/repository.dart';
import '../../repository/repository_adapter.dart';
import 'book_meeting_logic.dart';

class BookMeetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IMeetingRepository>(() => MeetingRepository());
    Get.lazyPut(() => BookMeetingLogic(repository: Get.find()));
  }
}
