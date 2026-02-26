import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../openim_live.dart';
import '../../../manager/call_manager.dart';
import '../../../widgets/small_window.dart';
import 'controls.dart';
import 'participant.dart';

abstract class SignalView extends StatefulWidget {
  const SignalView({
    super.key,
    required this.callType,
    required this.userID,
    this.onSyncUserInfo,
    this.onClose,
    required this.autoPickup,
    this.onError,
    this.onEnabledSpeaker,
  });
  final CallType callType;
  final String userID;
  final Function()? onClose;
  final bool autoPickup;
  final Function(dynamic error, dynamic stack)? onError;
  final Future<UserInfo?> Function(String userID)? onSyncUserInfo;
  final void Function(bool enabledSpeaker)? onEnabledSpeaker;
}

abstract class SignalState<T extends SignalView> extends State<T> {
  CallState callState = CallState.call;
  UserInfo? userInfo;
  StreamSubscription? callEventSub;
  bool minimize = false;
  int duration = 0;
  String _callingDurationText = '00:00';
  Timer? _callingTimer;
  bool enabledMicrophone = true;
  bool enabledSpeaker = false;
  Timer? _remoteJoinTimer;
  static const _remoteJoinTimeout = Duration(seconds: 15);

  ParticipantTrack? remoteParticipantTrack;
  ParticipantTrack? localParticipantTrack;
  Room? room;

  @override
  void initState() {
    bindRoomStreams();

    callEventSub = CallManager().callStateStream.listen((event) {
      if (event != null) {
        _onStateDidUpdate(event);
      }
    });
    widget.onSyncUserInfo?.call(widget.userID).then(_onUpdateUserInfo);
    autoPickup();
    onChangedSpeakerStatus(enabledSpeaker);
    super.initState();
  }

  @override
  void dispose() {
    _cancelRemoteJoinTimer();
    _stopCallingTimer(reset: true);
    callEventSub?.cancel();
    super.dispose();
  }

  void _onUpdateUserInfo(UserInfo? info) {
    Logger.print('SignalState _onUpdateUserInfo: $info');
    if (!mounted && null != info) return;
    setState(() {
      userInfo = info;
    });
  }

  void _onStateDidUpdate(CallEvent event) {
    Logger.print('SignalView _onStateDidUpdate: ${event.state}');
    if ((event.state == CallState.beHangup ||
            event.state == CallState.beRejected ||
            event.state == CallState.beCanceled ||
            event.state == CallState.timeout ||
            event.state == CallState.otherReject ||
            event.state == CallState.otherAccepted) &&
        event.data.userID != null) {
      if (event.state == CallState.otherReject || event.state == CallState.otherAccepted) {
        final isReject = event.state == CallState.otherReject;
        IMViews.showToast(sprintf(StrRes.otherCallHandle, [isReject ? StrRes.rejectCall : StrRes.accept]));
      }
      _cancelRemoteJoinTimer();
      widget.onClose?.call();
    }
    if (event.state == CallState.calling && !existParticipants()) {
      _startRemoteJoinTimer();
    }
    if (event.state == CallState.calling) {
      _startCallingTimer();
      if (callState != CallState.calling) {
        setState(() {
          callState = event.state;
        });
      }
    } else if (event.state == CallState.beHangup ||
        event.state == CallState.beRejected ||
        event.state == CallState.beCanceled ||
        event.state == CallState.timeout) {
      _stopCallingTimer(reset: true);
    } else {
      setState(() {
        callState = event.state;
      });
    }
  }

  void autoPickup() {
    if (widget.autoPickup) {
      onTapPickup();
    }
  }

  Future onTapPickup() async {
    Logger.print('SignalState onTapPickup called.');

    try {
      await CallManager().acceptCall();
      Logger.print('SignalState onTapPickup connected.');
    } catch (e, s) {
      Logger.print('SignalState onTapPickup connect error: $e, $s');
      widget.onError?.call(e, s);
    }
  }

  Future<void> onTapHangup({bool skipHangup = false}) async {
    Logger.print('SignalState onTapHangup called.');
    _cancelRemoteJoinTimer();

    try {
      await CallManager().hangupCall(duration: duration);
      Logger.print('SignalState onTapHangup connected.');
    } catch (e, s) {
      Logger.print('SignalState onTapHangup error: $e, $s');
      widget.onError?.call(e, s);
    }

    widget.onClose?.call();
  }

  Future<void> onTapCancel() async {
    Logger.print('SignalState onTapCancel called.');
    _cancelRemoteJoinTimer();

    try {
      await CallManager().cancelCall();
      Logger.print('SignalState onTapCancel connected.');
    } catch (e, s) {
      Logger.print('SignalState onTapCancel error: $e, $s');
      widget.onError?.call(e, s);
    }

    widget.onClose?.call();
  }

  Future<void> onTapReject() async {
    Logger.print('SignalState onTapReject called.');
    _cancelRemoteJoinTimer();

    try {
      await CallManager().rejectCall();
      Logger.print('SignalState onTapReject connected.');
    } catch (e, s) {
      Logger.print('SignalState onTapReject error: $e, $s');
      widget.onError?.call(e, s);
    }

    widget.onClose?.call();
  }

  void insertInterruptionMessage() {
    CallManager().insertCallMessage(state: CallState.interruption);
  }

  void insertHangupMessageWhenInBackground() {
    onTapHangup(skipHangup: true);
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

  void _startRemoteJoinTimer() {
    _cancelRemoteJoinTimer();
    _remoteJoinTimer = Timer(_remoteJoinTimeout, () {
      if (!mounted || callState != CallState.calling || existParticipants()) return;
      widget.onError?.call('Remote participant did not join within ${_remoteJoinTimeout.inSeconds}s.', null);
    });
  }

  void _cancelRemoteJoinTimer() {
    _remoteJoinTimer?.cancel();
    _remoteJoinTimer = null;
  }

  void onRemoteParticipantsUpdated() {
    if (existParticipants()) {
      _cancelRemoteJoinTimer();
    } else if (callState == CallState.calling) {
      _startRemoteJoinTimer();
    }
  }

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

  Future<void> bindRoomStreams();

  bool existParticipants();

  bool smallScreenIsRemote = true;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          AnimatedScale(
            scale: minimize ? 0 : 1,
            alignment: moveAlign,
            duration: const Duration(milliseconds: 200),
            onEnd: () {},
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  if (null != remoteParticipantTrack)
                    ParticipantWidget.widgetFor(smallScreenIsRemote ? remoteParticipantTrack! : localParticipantTrack!),
                  ControlsView(
                    key: const ValueKey('single_controls_view'),
                    callType: widget.callType,
                    currentCallState: callState,
                    callingDurationText: _callingDurationText,
                    room: room,
                    userInfo: userInfo,
                    onMinimize: onTapMinimize,
                    onEnabledMicrophone: onChangedMicStatus,
                    onEnabledSpeaker: onChangedSpeakerStatus,
                    onHangUp: onTapHangup,
                    onPickUp: onTapPickup,
                    onReject: onTapReject,
                    onCancel: onTapCancel,
                  ),
                  if (null != localParticipantTrack)
                    Positioned(
                      top: 97.h,
                      right: 12.w,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 120.w,
                          height: 180.h,
                          child: IgnorePointer(
                            child: ParticipantWidget.widgetFor(
                                smallScreenIsRemote ? localParticipantTrack! : remoteParticipantTrack!),
                          ),
                        ),
                        onTap: () {
                          if (remoteParticipantTrack != null) {
                            setState(() {
                              smallScreenIsRemote = !smallScreenIsRemote;
                            });
                          }
                        },
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
                  userInfo: userInfo,
                  callState: callState,
                  onTapMaximize: onTapMaximize,
                  onPanUpdate: onMoveSmallWindow,
                  child: (state) {
                    // if (null != remoteParticipantTrack &&
                    //     state == CallState.calling &&
                    //     widget.callType == CallType.video) {
                    //   return SizedBox(
                    //     width: 120.w,
                    //     height: 180.h,
                    //     child: ParticipantWidget.widgetFor(
                    //         remoteParticipantTrack!),
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
