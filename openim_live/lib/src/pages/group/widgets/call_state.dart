import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/src/pages/group/widgets/call_view.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../openim_live.dart';
import '../../../manager/call_manager.dart';
import '../../../widgets/small_window.dart';
import 'controls.dart';
import 'participant_info.dart';

abstract class GroupView extends StatefulWidget {
  const GroupView({
    super.key,
    required this.callType,
    this.roomID,
    required this.groupID,
    required this.inviterUserID,
    required this.inviteeUserIDList,
    this.onClose,
    required this.autoPickup,
    this.onError,
    this.onSyncGroupInfo,
    this.onSyncGroupMemberInfo,
    this.onEnabledSpeaker,
  });
  final CallType callType;
  final String? roomID;
  final String groupID;
  final String inviterUserID;
  final List<String> inviteeUserIDList;
  final Function()? onClose;
  final bool autoPickup;
  final Future<GroupInfo?> Function(String groupID)? onSyncGroupInfo;
  final Future<List<GroupMembersInfo>> Function(String groupID, List<String> userIDList)? onSyncGroupMemberInfo;
  final Function(dynamic error, dynamic stack)? onError;
  final void Function(bool enabledSpeaker)? onEnabledSpeaker;
}

abstract class GroupState<T extends GroupView> extends State<T> {
  CallState callState = CallState.call;
  StreamSubscription? callEventSub;
  bool minimize = false;
  int duration = 0;
  String _callingDurationText = '00:00';
  Timer? _callingTimer;
  bool enabledMicrophone = true;
  bool enabledSpeaker = false;
  bool _didAutoClose = false;
  GroupInfo? groupInfo;
  List<GroupMembersInfo> membersList = [];
  late List<String> inviteeUserIDList;

  List<String> get memberIDList => [widget.inviterUserID, ...inviteeUserIDList];
  List<ParticipantTrack> participantTracks = [];
  Room? room;

  bool get isVideoCall => widget.callType == CallType.video;

  @override
  void initState() {
    bindRoomStreams();

    inviteeUserIDList = [...widget.inviteeUserIDList];
    callEventSub = CallManager().callStateStream.listen((event) {
      if (event != null) {
        _onStateDidUpdate(event);
      }
    });

    widget.onSyncGroupInfo?.call(widget.groupID).then(_onUpdateGroupInfo);
    widget.onSyncGroupMemberInfo?.call(widget.groupID, memberIDList).then(_onUpdateGroupMemberInfo);

    autoPickup();
    onChangedSpeakerStatus(enabledSpeaker);

    super.initState();
  }

  @override
  void dispose() {
    _stopCallingTimer(reset: true);
    callEventSub?.cancel();
    super.dispose();
  }

  bool isHost() {
    return widget.inviterUserID == room?.localParticipant?.identity;
  }

  void _onUpdateGroupInfo(GroupInfo? info) {
    if (!mounted && null != info) return;
    setState(() {
      groupInfo = info;
    });
  }

  void _onUpdateGroupMemberInfo(List<GroupMembersInfo> list) {
    if (!mounted && list.isNotEmpty) return;
    setState(() {
      membersList = list;
    });
  }

  void _onStateDidUpdate(CallEvent event) {
    Logger.print(
      'GroupView _onStateDidUpdate: ${event.state}, user: ${event.data.userID}, inviteeList: $inviteeUserIDList',
      fileName: 'group_call_state.dart',
    );

    if (event.state == CallState.calling) {
      _startCallingTimer();
    } else if (event.state == CallState.beHangup ||
        event.state == CallState.beRejected ||
        event.state == CallState.beCanceled ||
        event.state == CallState.timeout ||
        event.state == CallState.otherReject ||
        event.state == CallState.otherAccepted) {
      if (event.state == CallState.otherReject || event.state == CallState.otherAccepted) {
        final isReject = event.state == CallState.otherReject;
        IMViews.showToast(sprintf(StrRes.otherCallHandle, [isReject ? StrRes.rejectCall : StrRes.accept]));
      }
      _stopCallingTimer(reset: true);

      if (event.data.userID == DataSp.userID) {
        widget.onClose?.call();
        return;
      }
    }

    if (event.state == CallState.beHangup ||
        event.state == CallState.beRejected ||
        event.state == CallState.beCanceled ||
        event.state == CallState.timeout && event.data.userID != null) {
      final userID = event.data.userID!;
      var userIDs = inviteeUserIDList;

      if (inviteeUserIDList.contains(userID)) {
        userIDs = inviteeUserIDList.where((id) => id != userID).toList();
        updateInviteeUserIDs(userIDs);
      }

      // If the inviter canceled/timeout/hangup and room has no participants, close immediately
      final inviterUserID = event.data.invitation?.inviterUserID;
      if (userID == inviterUserID &&
          (event.state == CallState.beCanceled ||
              event.state == CallState.timeout ||
              event.state == CallState.beHangup)) {
        final remoteCount = room?.remoteParticipants.length ?? 0;
        if (remoteCount == 0) {
          Logger.print('Inviter $userID canceled/timeout/hangup and room is empty, closing call',
              fileName: 'group_call_state.dart');
          widget.onClose?.call();
          return;
        }
      }

      if (event.state == CallState.beAccepted) {
        Logger.print(
            'User $userID accepted the call. Updating call state to ${event.state} but not closing. inviteeUserIDList count: ${userIDs.length}, remoteParticipants count: ${room?.remoteParticipants.length}, didAutoClose: $_didAutoClose',
            fileName: 'group_call_state.dart');
        if (callState != CallState.calling) {
          setState(() {
            callState = event.state;
          });
        }
        return;
      }

      Logger.print(
          'Updated inviteeUserIDList after event, user count: ${userIDs.length}, remoteParticipants count: ${room?.remoteParticipants.length}, didAutoClose: $_didAutoClose',
          fileName: 'group_call_state.dart');
      maybeAutoCloseOnEmptyRoom(source: 'callState:${event.state.name}');
    }
    if (callState == CallState.calling) {
      if (event.state == CallState.beHangup ||
          event.state == CallState.beRejected ||
          event.state == CallState.timeout) {
        //If a call is already in progress and a participant leaves,
        //do not refresh the UI; otherwise, the buttons will flicker.
        //Let LiveKit handle the refreshing of the participant list.
        return;
      }
    }

    setState(() {
      callState = event.state;
    });
  }

  void autoPickup() {
    if (widget.autoPickup) {
      onTapPickup();
    }
  }

  Future onTapPickup() async {
    Logger.print('GroupSignalState onTapPickup called.');

    try {
      await CallManager().acceptCall();

      Logger.print('GroupSignalState onTapPickup connected.');
    } catch (e, s) {
      Logger.print('GroupSignalState onTapPickup connect error: $e, $s');
      widget.onError?.call(e, s);
    }
  }

  Future<void> onTapHangup() async {
    Logger.print('GroupSignalState onTapHangup called.');

    try {
      await CallManager().hangupCall(duration: duration);
      Logger.print('GroupSignalState onTapHangup connected.');
    } catch (e, s) {
      Logger.print('GroupSignalState onTapHangup error: $e, $s');
      widget.onError?.call(e, s);
    }

    widget.onClose?.call();
  }

  Future<void> onTapCancel() async {
    Logger.print('GroupSignalState onTapCancel called.');

    try {
      await CallManager().cancelCall();
      Logger.print('GroupSignalState onTapCancel connected.');
    } catch (e, s) {
      Logger.print('GroupSignalState onTapCancel error: $e, $s');
      widget.onError?.call(e, s);
    }

    widget.onClose?.call();
  }

  Future<void> onTapReject() async {
    Logger.print('GroupSignalState onTapReject called.');

    try {
      await CallManager().rejectCall();
      Logger.print('GroupSignalState onTapReject connected.');
    } catch (e, s) {
      Logger.print('GroupSignalState onTapReject error: $e, $s');
      widget.onError?.call(e, s);
    }

    widget.onClose?.call();
  }

  void insertInterruptionMessage() {
    CallManager().insertCallMessage(state: CallState.interruption);
  }

  void onTapMinimize() {
    setState(() {
      minimize = true;
    });
  }

  void onTapMaximize() {
    FocusScope.of(context).unfocus();
    setState(() {
      minimize = false;
    });
  }

  void callingDuration(int duration) {
    this.duration = duration;
  }

  void _startCallingTimer() {
    if (_callingTimer != null) return;
    _callingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      duration++;
      if (mounted) {
        setState(() {
          _callingDurationText = IMUtils.seconds2HMS(duration);
        });
      }
    });
  }

  void _stopCallingTimer({bool reset = false}) {
    _callingTimer?.cancel();
    _callingTimer = null;
    if (reset) {
      duration = 0;
      _callingDurationText = '00:00';
    }
  }

  void onChangedMicStatus(bool enabled) {
    enabledMicrophone = enabled;
  }

  void onChangedSpeakerStatus(bool enabled) {
    enabledSpeaker = enabled;
    widget.onEnabledSpeaker?.call(enabled);
  }

  void updateInviteeUserIDs(List<String> userIDs) {
    if (!mounted) return;
    Logger.print('updateInviteeUserIDs: $userIDs', fileName: 'group_call_state.dart');
    setState(() {
      inviteeUserIDList = [...userIDs];
    });
    widget.onSyncGroupMemberInfo?.call(widget.groupID, memberIDList).then(_onUpdateGroupMemberInfo);
  }

  void maybeAutoCloseOnEmptyRoom({String? source}) {
    if (_didAutoClose) return;
    final remoteCount = room?.remoteParticipants.length ?? 0;
    final leftIsReciver =
        inviteeUserIDList.firstOrNull != null && inviteeUserIDList.first == room?.localParticipant?.identity;
    if ((inviteeUserIDList.isEmpty || leftIsReciver) && remoteCount == 0) {
      // When the last participant who answered the call leaves,
      // their user ID will still be present in the `inviteeUserIDList`, so a special check is needed;
      // when the initiator is the last one to leave, the `inviteeUserIDList` will be empty.
      Logger.print(
        'All invitees have left the call. source: $source, inviteeUserIDList count: ${inviteeUserIDList.length}, remoteParticipants count: $remoteCount',
        fileName: 'group_call_state.dart',
      );
      _didAutoClose = true;
      widget.onClose?.call();
    }
  }

  Future<void> bindRoomStreams();

  //Alignment(0.9, -0.9),
  double alignX = 0.9;
  double alignY = -0.9;

  Alignment get moveAlign => Alignment(alignX, alignY);

  void onMoveSmallWindow(DragUpdateDetails details) {
    final globalDy = details.globalPosition.dy;
    final globalDx = details.globalPosition.dx;
    setState(() {
      alignX = (globalDx - .5.sw) / .5.sw;
      alignY = (globalDy - .5.sh) / .5.sh;
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          AnimatedScale(
            scale: minimize ? 0 : 1,
            alignment: moveAlign,
            duration: const Duration(milliseconds: 200),
            onEnd: () {},
            child: Material(
              color: Colors.black,
              child: Stack(
                children: [
                  // ImageRes.liveBg.toImage
                  //   ..fit = BoxFit.cover
                  //   ..width = 1.sw
                  //   ..height = 1.sh,
                  ControlsView(
                    currentCallState: callState,
                    callingDurationText: _callingDurationText,
                    room: room,
                    callType: widget.callType,
                    onMinimize: onTapMinimize,
                    onCallingDuration: callingDuration,
                    onEnabledMicrophone: onChangedMicStatus,
                    onEnabledSpeaker: onChangedSpeakerStatus,
                    onHangUp: onTapHangup,
                    onPickUp: onTapPickup,
                    onReject: onTapReject,
                    onCancel: onTapCancel,
                    child: (state) => state == CallState.beCalled
                        ? BeCalledView(
                            callType: widget.callType,
                            inviterUserID: widget.inviterUserID,
                            inviteeUserIDList: inviteeUserIDList,
                            groupInfo: groupInfo,
                            memberInfoList: membersList,
                          )
                        : CallingView(
                            participantTracks: participantTracks,
                            membersList:
                                isHost() || (callState != CallState.calling && callState != CallState.connecting)
                                    ? membersList
                                    : [
                                        GroupMembersInfo(
                                          userID: OpenIM.iMManager.userID,
                                          nickname: OpenIM.iMManager.userInfo.nickname,
                                          faceURL: OpenIM.iMManager.userInfo.faceURL,
                                        )
                                      ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (minimize)
            Align(
              alignment: moveAlign,
              child: AnimatedOpacity(
                opacity: minimize ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: SmallWindowView(
                  opacity: minimize ? 1 : 0,
                  callState: callState,
                  groupInfo: groupInfo,
                  onTapMaximize: onTapMaximize,
                  onPanUpdate: onMoveSmallWindow,
                  child: (state) {
                    // if (participantTracks.isNotEmpty &&
                    //     state == CallState.calling &&
                    //     widget.callType == CallType.video) {
                    //   return SizedBox(
                    //     width: 120.w,
                    //     height: 180.h,
                    //     child: ParticipantWidget.widgetFor(
                    //         participantTracks.first),
                    //   );
                    // }
                    return null;
                  },
                ),
              ),
            ),
        ],
      );
}
