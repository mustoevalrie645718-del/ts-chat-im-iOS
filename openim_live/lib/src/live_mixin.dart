import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_openim_live_alert/flutter_openim_live_alert.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:rxdart/rxdart.dart';

import '../openim_live.dart';
import 'manager/call_manager.dart';
import 'services/signaling_service.dart';
import 'services/livekit_service.dart';

mixin OpenIMLive {
  final _callManager = CallManager();
  final _signalingService = SignalingService();
  final _liveKitService = LiveKitService();

  bool callingIsBusy = false;

  StreamSubscription<CallEvent?>? _callStateSubscription;
  StreamSubscription<Room?>? _roomSubscription;

  final signalingSubject = PublishSubject<CallEvent>();
  Function(SignalingMessageEvent)? onSignalingMessage;

  void onInitLive() {
    _callStateSubscription = _callManager.callStateStream.listen((event) {
      if (event != null) {
        signalingSubject.add(event);
        callingIsBusy = true;

        if (event.state == CallState.beCalled || event.state == CallState.join) {
          _handleIncomingCall(event);
        } else if (event.state == CallState.call) {
          _handleOutgoingCall(event);
        }
      } else {
        // Call ended - auto-close
        callingIsBusy = false;
        _closeLiveAlert();
      }
    });

    _roomSubscription = _liveKitService.roomStream.listen((room) {
      Logger.print('LiveController: room name ${room?.name} updated, room is ${room != null ? "connected" : "null"}',
          fileName: 'live_controller.dart');
    });

    _callManager.onSignalingMessage = (value) {
      onSignalingMessage?.call(value);
    };

    FlutterOpenimLiveAlert.buttonEvent(
      onAccept: () {
        _callManager.acceptCall();
      },
      onReject: () {
        _callManager.rejectCall();
      },
    );
  }

  void onCloseLive() {
    _callManager.hangupCall();
    FlutterOpenimLiveAlert.closeLiveAlert();

    _callStateSubscription?.cancel();
    _roomSubscription?.cancel();
  }

  // --- IMController Bridge Methods ---
  // These are called by IMController's listener. We forward them to SignalingService.

  void invitationCancelled(SignalingInfo info) {
    _signalingService.onInvitationCancelled(info);
  }

  void invitationTimeout(SignalingInfo info) {
    _signalingService.onInvitationTimeout(info);
  }

  void inviteeAccepted(SignalingInfo info) {
    _signalingService.onInviteeAccepted(info);
  }

  void inviteeRejected(SignalingInfo info) {
    _signalingService.onInviteeRejected(info);
  }

  void receiveNewInvitation(SignalingInfo info) {
    _signalingService.onReceiveNewInvitation(info);
  }

  void inviteeAcceptedByOtherDevice(SignalingInfo info) {
    _signalingService.onInviteeAcceptedByOtherDevice(info);
  }

  void inviteeRejectedByOtherDevice(SignalingInfo info) {
    _signalingService.onInviteeRejectedByOtherDevice(info);
  }

  void beHangup(SignalingInfo info) {
    _signalingService.onHangup(info);
  }

  // --- UI Triggers (Legacy Logic Adapted) ---

  void _handleIncomingCall(CallEvent event) async {
    if (Platform.isAndroid &&
        await Permissions.checkSystemAlertWindow() &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
      // Show background alert
      FlutterOpenimLiveAlert.showLiveAlert(
        title: 'Incoming Call',
        rejectText: StrRes.rejectCall,
        acceptText: StrRes.acceptCall,
      );
    }

    _startLiveClient(event.data, CallState.beCalled);
  }

  void _handleOutgoingCall(CallEvent event) {
    _startLiveClient(event.data, CallState.call);
  }

  void _startLiveClient(SignalingInfo info, CallState initState) {
    final callType = info.invitation!.mediaType == 'video' ? CallType.video : CallType.audio;
    final callObj = info.invitation!.sessionType == 1 ? CallObj.single : CallObj.group;

    OpenIMLiveClient().start(
      Get.overlayContext!,
      callType: callType,
      callObj: callObj,
      inviterUserID: info.invitation!.inviterUserID!,
      inviteeUserIDList: info.invitation!.inviteeUserIDList!,
      groupID: info.invitation!.groupID,
      roomID: info.invitation!.roomID,
      initState: initState,
      onSyncUserInfo: (userID) => OpenIM.iMManager.userManager
          .getUsersInfo(userIDList: [userID]).then((list) => UserInfo.fromJson(list.first.toJson())),
      onSyncGroupInfo: (groupID) =>
          OpenIM.iMManager.groupManager.getGroupsInfo(groupIDList: [groupID]).then((list) => list.firstOrNull),
      onSyncGroupMemberInfo: (groupID, memberIDList) =>
          OpenIM.iMManager.groupManager.getGroupMembersInfo(groupID: groupID, userIDList: memberIDList),
      onError: (error, stack) {
        final e = error is String ? error : error.toString();
        Logger.print('LiveClient error: $e', fileName: 'live_controller.dart');

        if (!e.contains('NotFound')) {
          IMViews.showToast(e);
        }

        _callManager.cleanup();
        _closeLiveAlert();
      },
      onClose: () {
        _callManager.cleanup();
        _closeLiveAlert();
      },
    );
  }

  void _closeLiveAlert() {
    if (Platform.isAndroid) {
      FlutterOpenimLiveAlert.closeLiveAlert();
    }
  }

  // Public method called by app to start a call
  void call({
    required CallObj callObj,
    required CallType callType,
    List<String>? inviteeUserIDList,
    String? groupID,
  }) async {
    if (inviteeUserIDList == null || inviteeUserIDList.isEmpty) return;

    // CallManager will trigger _handleOutgoingCall via stream
    try {
      await _callManager.startCall(
        inviteeUserIDs: inviteeUserIDList,
        callType: callType,
        groupID: groupID,
      );
    } catch (e) {
      Logger.print('Call failed: $e', fileName: 'live_controller.dart');
      _closeLiveAlert();

      var tips = StrRes.networkError;

      if (e is PlatformException) {
        if (int.parse(e.code) == SDKErrorCode.hasBeenBlocked) {
          tips = StrRes.callFail;
        } else if (int.parse(e.code) == SDKErrorCode.callingInviterIsBusy) {
          tips = StrRes.userBusyVideoCallHint;
        }

        OpenIMLiveClient().dismiss();
      } else if (e is LiveKitException) {
        tips = kDebugMode ? e.message : '';
      } else if (e is MediaConnectException) {
        tips = kDebugMode ? e.message : '';
      } else {
        OpenIMLiveClient().dismiss();
      }

      if (tips.isNotEmpty) {
        IMViews.showToast(tips);
      }
    }
  }

  void join({
    required SignalingCertificate certificate,
    required InvitationInfo invitation,
    String? groupID,
  }) async {
    try {
      await _callManager.joinCall(
        certificate: certificate,
        invitation: invitation,
        groupID: groupID,
      );
    } catch (e) {
      Logger.print('Join call failed: $e', fileName: 'live_controller.dart');
      IMViews.showToast('Join call failed: $e');
      await _callManager.hangupCall();
      _closeLiveAlert();
    }
  }

  // Legacy stubs
  void callingTerminal() {}
  void enterbackground() {}
  void enterforeground() {
    _closeLiveAlert();
  }
}
