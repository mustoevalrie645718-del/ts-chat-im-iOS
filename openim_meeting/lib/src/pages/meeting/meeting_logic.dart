import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/openim_meeting.dart';
import 'package:sprintf/sprintf.dart';

import '../../repository/meeting.pb.dart';
import '../../repository/repository_adapter.dart';
import '../../widgets/meeting_alert_dialog.dart';
import '../../repository/pb_extension.dart';

class MeetingLogic extends GetxController {
  final IMeetingRepository repository;
  final meetingClient = MeetingClient();

  MeetingLogic({required this.repository});

  final meetingInfoList = <MeetingInfoSetting>[].obs;
  final nicknameMapping = <String, String>{}.obs;
  final globalKey = Key('Meeting-View-key');

  /// Timer for refreshing meeting status periodically
  Timer? _refreshTimer;

  MeetingBridge? get meetingBridge => PackageBridge.meetingBridge;

  RTCBridge? get rtcBridge => PackageBridge.rtcBridge;

  bool get rtcIsBusy => meetingBridge?.hasConnection == true || rtcBridge?.hasConnection == true;

  String get userID => DataSp.userID!;

  @override
  void onInit() {
    super.onInit();
    Logger.print('MeetingLogic onInit');
    _startRefreshTimer();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.onClose();
  }

  /// Start a periodic timer to refresh meeting status every minute
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      // Trigger UI rebuild to update meeting status (started/not started)
      meetingInfoList.refresh();
    });
  }

  @override
  void onReady() {
    // queryUnfinishedMeeting();
    super.onReady();
  }

  Future<List<MeetingInfoSetting>> _queryUnfinishedMeeting() => repository.getUnfinished(userID);

  void queryUnfinishedMeeting() async {
    final list = await _queryUnfinishedMeeting();
    list.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    meetingInfoList.assignAll(list);
  }

  void removeLocalFinishedMeeting(String meetingID) {
    meetingInfoList.removeWhere((element) => element.meetingID == meetingID);
  }

  void queryUnfinishedMeetingByTerminal() async {
    final meetingID = DataSp.getMeetingInProgress();
    if (meetingID?.isNotEmpty == true) {
      final result = await repository.getMeetingInfo(meetingID!, userID);
      if (result != null && result.status == MeetingStatus.inProgress) {
        MeetingAlertDialog.showInProgressByTerminal(Get.context!, onConfirm: () {
          quickEnterMeeting(meetingID);
          DataSp.removeMeetingInProgress();
        });
      }
    }
  }

  String getMeetingCreateDate(MeetingInfoSetting meetingInfo) {
    return DateUtil.formatDateMs(
      meetingInfo.scheduledTime,
      format: Get.locale?.languageCode == 'zh' ? 'MM月dd日' : 'MM/dd',
    );
  }

  String getMeetingDuration(MeetingInfoSetting meetingInfo) {
    final startTime = DateUtil.formatDateMs(
      meetingInfo.scheduledTime,
      format: 'HH:mm',
    );
    final endTime = DateUtil.formatDateMs(
      meetingInfo.endTime,
      format: 'HH:mm',
    );
    return "$startTime - $endTime";
  }

  bool isStartedMeeting(MeetingInfoSetting meetingInfo) {
    final start = DateUtil.getDateTimeByMs(meetingInfo.scheduledTime);
    final now = DateTime.now();
    return start.difference(now).isNegative;
  }

  String getMeetingSubject(MeetingInfoSetting meetingInfo) {
    return meetingInfo.meetingName;
  }

  String getTitle(MeetingInfoSetting meetingInfo) {
    return meetingInfo.meetingName;
  }

  String getMeetingOrganizer(MeetingInfoSetting meetingInfo) {
    return sprintf(StrRes.meetingOrganizerIs, [meetingInfo.creatorNickname]);
  }

  void joinMeeting() {
    if (rtcIsBusy) {
      IMViews.showToast(StrRes.callingBusy);
    } else {
      MNavigator.startJoinMeeting();
    }
  }

  void bookMeeting() => MNavigator.startBookMeeting();

  void meetingDetail(MeetingInfoSetting meetingInfo) => MNavigator.startMeetingDetail(
        meetingInfo,
        meetingInfo.creatorNickname,
      );

  void quickMeeting() {
    if (rtcIsBusy) {
      IMViews.showToast(StrRes.callingBusy);
    } else {
      meetingClient.create(Get.context!,
          meetingName: _meetingName,
          startTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          duration: 1 * 60 * 60, onClose: () {
        queryUnfinishedMeeting();
      }).then((_) => queryUnfinishedMeeting());
    }
  }

  void quickEnterMeeting(String meetingID, {String? password}) async {
    if (meetingClient.isBusy) {
      IMViews.showToast(StrRes.callingBusy);
      return;
    }

    meetingClient.join(
      Get.context!,
      meetingID: meetingID,
    );
  }

  String get _meetingName => sprintf(StrRes.meetingInitiatorIs, [OpenIM.iMManager.userInfo.nickname]);
// void quickMeeting() => MeetingHelper.createMeeting(
//       meetingName: sprintf(
//           StrRes.meetingInitiatorIs, [OpenIM.iMManager.uInfo.nickname]),
//       startTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       duration: 1 * 60 * 60,
//     );
}
