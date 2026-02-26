import 'package:common_utils/common_utils.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/src/pages/meeting/meeting_logic.dart';

import '../../../openim_meeting.dart';
import '../../repository/meeting.pb.dart';
import '../../repository/pb_extension.dart';

class MeetingDetailLogic extends GetxController {
  late MeetingInfoSetting meetingInfo;
  late String meetingCreator;
  late int startTime;
  late int endTime;

  SelectContactsBridge? get bridge => PackageBridge.selectContactsBridge;

  MeetingBridge? get meetingBridge => PackageBridge.meetingBridge;

  RTCBridge? get rtcBridge => PackageBridge.rtcBridge;

  bool get rtcIsBusy => meetingBridge?.hasConnection == true || rtcBridge?.hasConnection == true;

  @override
  void onInit() {
    meetingInfo = Get.arguments['meetingInfo'];
    meetingCreator = Get.arguments['meetingCreator'];
    startTime = meetingInfo.scheduledTime;
    endTime = meetingInfo.endTime;
    super.onInit();
  }

  String get meetingStartTime => DateUtil.formatDateMs(startTime, format: 'HH:mm');

  String get meetingEndTime => DateUtil.formatDateMs(endTime, format: 'HH:mm');

  String get meetingStartDate => DateUtil.formatDateMs(startTime, format: IMUtils.getTimeFormat1());

  String get meetingEndDate => DateUtil.formatDateMs(endTime, format: IMUtils.getTimeFormat1());

  String get meetingNo => meetingInfo.meetingID;

  String get meetingDuration {
    final offset = meetingInfo.duration;
    return '${offset ~/ (60 * 1000)}${StrRes.minute}';
  }

  bool get isMine => meetingInfo.hostUserID == OpenIM.iMManager.userID;

  bool isStartedMeeting() {
    final start = DateUtil.getDateTimeByMs(meetingInfo.scheduledTime);
    final now = DateTime.now();
    return start.difference(now).isNegative;
  }

  void copy() {
    IMUtils.copy(text: meetingInfo.meetingID);
  }

  enterMeeting() {
    if (rtcIsBusy) {
      IMViews.showToast(StrRes.callingBusy);
    } else {
      MeetingClient().join(Get.context!, meetingID: meetingInfo.meetingID, onClose: () {
        if (Get.isRegistered<MeetingLogic>()) {
          Get.find<MeetingLogic>().queryUnfinishedMeeting();

          Get.back();
        }
      });
    }
  }

  shareMeeting() async {
    final meetingID = meetingInfo.meetingID;
    final meetingName = meetingInfo.meetingName;
    final startTime = meetingInfo.scheduledTime ~/ 1000;
    final duration = meetingInfo.duration ~/ 1000;
    Logger.print('metaData meetingID : $meetingID');
    Logger.print('metaData meetingName : $meetingName');
    Logger.print('metaData startTime : $startTime');
    Logger.print('metaData duration : $duration');
    final result = await bridge?.selectContacts(2);
    if (result is Map) {
      final list = IMUtils.convertCheckedListToShare(result.values);
      await LoadingView.singleton.wrap(
          asyncFunction: () => Future.forEach(
                list,
                (map) => MeetingClient().invite(
                  userID: map['userID'],
                  groupID: map['groupID'],
                  meetingID: meetingID,
                  meetingName: meetingName,
                  startTime: startTime,
                  duration: duration,
                ),
              ));
      IMViews.showToast('分享成功');
    }
  }

  editMeeting() {
    Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(label: StrRes.updateMeetingInfo, onTap: _modifyMeetingInfo),
          SheetItem(
            label: StrRes.cancelMeeting,
            textStyle: Styles.ts_FF381F_17sp,
            onTap: _cancelMeeting,
          ),
        ],
      ),
    );
  }

  _cancelMeeting() async {
    try {
      await MeetingRepository().endMeeting(meetingInfo.meetingID, DataSp.userID!, endType: MeetingEndType.CancelType);
      Get.back();
    } catch (e, s) {
      Logger.print('error: $e,  stack: $s');
      if (e.toString().contains('NotExist')) {
        IMViews.showToast("会议已经结束！");
      } else {
        IMViews.showToast("网络异常请稍后再试！");
      }
    }
  }

  _modifyMeetingInfo() => MNavigator.startBookMeeting(
        meetingInfo: meetingInfo,
        offAndToNamed: true,
      );
}
