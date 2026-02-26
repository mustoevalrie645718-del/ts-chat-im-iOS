import 'package:get/get.dart';

import '../repository/meeting.pb.dart';
import 'm_pages.dart';

class MNavigator {
  static Future<T?>? startMeeting<T>() => Get.toNamed(MRoutes.meeting);

  static Future<T?>? startJoinMeeting<T>() => Get.toNamed(MRoutes.joinMeeting);

  static startBookMeeting({
    MeetingInfoSetting? meetingInfo,
    bool offAndToNamed = false,
  }) {
    final args = {'meetingInfo': meetingInfo};
    return offAndToNamed ? Get.offAndToNamed(MRoutes.bookMeeting, arguments: args) : Get.toNamed(MRoutes.bookMeeting, arguments: args);
  }

  static startMeetingDetail(
    MeetingInfoSetting meetingInfo,
    String meetingCreator, {
    bool offAndToNamed = false,
  }) {
    final args = {'meetingInfo': meetingInfo, 'meetingCreator': meetingCreator};
    return offAndToNamed ? Get.offAndToNamed(MRoutes.meetingDetail, arguments: args) : Get.toNamed(MRoutes.meetingDetail, arguments: args);
  }
}
