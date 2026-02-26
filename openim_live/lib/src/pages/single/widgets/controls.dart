import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/src/widgets/live_button.dart';
import 'package:synchronized/synchronized.dart';

import '../../../live_client.dart';
import '../../../widgets/loading_view.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import 'package:openim_live/src/utils/live_utils.dart';

class ControlsView extends StatefulWidget {
  const ControlsView({
    super.key,
    this.currentCallState = CallState.call,
    this.callType = CallType.video,
    this.room,
    this.userInfo,
    this.onMinimize,
    this.callingDurationText = '00:00',
    this.onEnabledMicrophone,
    this.onEnabledSpeaker,
    this.onCancel,
    this.onHangUp,
    this.onPickUp,
    this.onReject,
  });

  final Room? room;
  final CallState currentCallState;
  final CallType callType;
  final UserInfo? userInfo;
  final Function()? onMinimize;
  final String callingDurationText;
  final Function(bool enabled)? onEnabledMicrophone;
  final Function(bool enabled)? onEnabledSpeaker;
  final Future Function()? onPickUp;
  final Function()? onCancel;
  final Function()? onReject;
  final Function()? onHangUp;

  @override
  State<ControlsView> createState() => _ControlsViewState();
}

class _ControlsViewState extends State<ControlsView> {
  CameraPosition position = CameraPosition.front;

  StreamSubscription? _deviceChangeSub;

  Room? _room;
  LocalParticipant? _participant;

  bool _enabledMicrophone = true;
  bool _enabledSpeaker = false;

  final _lockAudio = Lock();
  final _lockSpeaker = Lock();

  bool _pickuping = false; // receiver pickup

  StreamSubscription? _audioInterruptionSub;

  bool _wasPlayingBeforeInterruption = false;
  bool _wasBeInterruption = false;

  @override
  void dispose() {
    _audioInterruptionSub?.cancel();
    _deviceChangeSub?.cancel();
    _participant?.removeListener(_onChange);
    super.dispose();
  }

  @override
  void initState() {
    Logger.print('ControlsView initState: ${widget.currentCallState}');

    // Only configure WebRTC audio if we're already in a call or connecting
    // This prevents overriding the ringtone's AudioSession configuration
    if (widget.currentCallState == CallState.calling || widget.currentCallState == CallState.connecting) {
      _setupAudioInterruptionHandling();
    }

    if (widget.room != null) {
      _roomDidUpdate(widget.room!);
    }
    _deviceChangeSub = Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    Hardware.instance.enumerateDevices().then(_loadDevices);
    CameraPositionTracker.currentPosition.value = CameraPosition.front;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ControlsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentCallState != oldWidget.currentCallState) {
      Logger.print(
          'ControlsView didUpdateWidget, wasInterruption： $_wasBeInterruption, widget.currentCallState: ${widget.currentCallState}, oldWidget.currentCallState: ${oldWidget.currentCallState}');

      // Configure WebRTC audio when transitioning to connecting or calling state
      if ((widget.currentCallState == CallState.connecting || widget.currentCallState == CallState.calling) &&
          (oldWidget.currentCallState != CallState.connecting && oldWidget.currentCallState != CallState.calling)) {
        _setupAudioInterruptionHandling();
      }
    }
    if (widget.room != oldWidget.room && widget.room != null) {
      _roomDidUpdate(widget.room!);
    }

    if (_wasBeInterruption) {
      Logger.print('Pause audio after widget update');
      _pauseAllParticipantsAudio();
    }
  }

  void _roomDidUpdate(Room room) {
    _room ??= room;
    if (room.localParticipant != null && _participant == null) {
      setState(() {
        _participant = room.localParticipant;
      });
      _participant?.addListener(_onChange);
    }
  }

  void _onChange() {
    setState(() {});
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _setAudioOutputDevice();
  }

  Future _setAudioOutputDevice() async {
    final outs = await Hardware.instance.audioOutputs();

    if (lkPlatformIs(PlatformType.android)) {
      if (_enabledSpeaker) {
        await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
      } else {
        await rtc.Helper.setSpeakerphoneOn(false);
      }
    }

    final dev = Hardware.instance.selectedAudioOutput;
    Logger.print('outs: $outs - selected: $dev');

    final ins = await Hardware.instance.audioInputs();
    final bluetooth = ins.firstWhereOrNull((e) => e.deviceId.toLowerCase().contains('bluetooth'));

    if (bluetooth != null) {
      await Hardware.instance.selectAudioInput(bluetooth);
    } else {
      await Hardware.instance.selectAudioInput(ins.first);
    }

    Logger.print('ints: $ins - selected: ${bluetooth ?? ins.first}');
  }

  Future _toggleAudio() async {
    await _lockAudio.synchronized(() async {
      _enabledMicrophone = !_enabledMicrophone;
      widget.onEnabledMicrophone?.call(_enabledMicrophone);
      if (_enabledMicrophone) {
        await _enableAudio();
      } else {
        await _disableAudio();
      }
      setState(() {});
    });
  }

  Future<void> _enableSpeakerphone(bool enabled) async {
    Logger.print('enableSpeakerphone: $enabled');
    await _room?.setSpeakerOn(enabled, forceSpeakerOutput: false);
  }

  void _toggleSpeaker() async {
    await _lockSpeaker.synchronized(() async {
      _enabledSpeaker = !_enabledSpeaker;
      widget.onEnabledSpeaker?.call(_enabledSpeaker);
      _enableSpeakerphone(_enabledSpeaker);
      setState(() {});
    });
  }

  Future<void> _disableAudio() async {
    await _participant?.setMicrophoneEnabled(false);
  }

  Future<void> _enableAudio() async {
    await _participant?.setMicrophoneEnabled(true);
  }

  Future<void> _disableVideo() async {
    await _participant?.setCameraEnabled(false);
  }

  Future<void> _enableVideo() async {
    await _participant?.setCameraEnabled(true, cameraCaptureOptions: CameraCaptureOptions(cameraPosition: position));
  }

  bool _isSwitchingCamera = false;

  void _toggleCamera() async {
    final track = _participant?.videoTrackPublications.firstOrNull?.track;
    if (track == null || _isSwitchingCamera) return;

    _isSwitchingCamera = true;

    final oldPosition = position;
    final newPosition = oldPosition == CameraPosition.front ? CameraPosition.back : CameraPosition.front;

    position = newPosition;
    Logger.print('[toggleCamera] Switching to: $newPosition');

    try {
      await rtc.Helper.switchCamera(track.mediaStreamTrack);
      CameraPositionTracker.currentPosition.value = newPosition;
      setState(() {});
    } catch (e) {
      Logger.print('[toggleCamera] failed: $e');
      position = oldPosition;
    } finally {
      _isSwitchingCamera = false;
    }
  }

  void _setupAudioInterruptionHandling() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ));

      _audioInterruptionSub = session.interruptionEventStream.listen((event) {
        if (_participant == null) {
          return;
        }

        if (Platform.isIOS || event.type == AudioInterruptionType.unknown) {
          return;
        }

        if (event.begin) {
          Logger.print('Audio interrupted by cellular call - muting LiveKit audio: ${event.type}');

          _wasPlayingBeforeInterruption = _participant!.isMicrophoneEnabled();

          if (_wasPlayingBeforeInterruption) {
            _toggleAudio();
          }

          _pauseAllParticipantsAudio();
        } else {
          Logger.print('Audio interruption ended - restoring LiveKit audio: ${event.type}');
          if (!_wasBeInterruption) return;

          if (_wasPlayingBeforeInterruption && !_participant!.isMicrophoneEnabled()) {
            _toggleAudio();
          }

          _resumeAllParticipantsAudio();

          _wasBeInterruption = false;
          _wasPlayingBeforeInterruption = false;
        }
      });
      await session.setActive(true, androidWillPauseWhenDucked: true);
    } catch (e) {
      Logger.print('Failed to setup audio interruption handling: $e');
    }
  }

  void _pauseAllParticipantsAudio() async {
    try {
      Logger.print('Pausing audio from all remote participants');

      for (final participant in _room!.remoteParticipants.values) {
        final audioTrackPublication = participant.audioTrackPublications.firstOrNull;
        if (audioTrackPublication == null) {
          Logger.print('No audio track for participant: ${participant.identity}, metadata: ${participant.metadata}');
          continue;
        }

        Logger.print('Pausing audio from participant: ${participant.identity}');
        audioTrackPublication.disable();
      }

      final localAudioTrack = _participant?.audioTrackPublications.firstOrNull?.track;
      if (localAudioTrack != null) {
        await localAudioTrack.disable();
      }
    } catch (e) {
      Logger.print('Error pausing participants audio: $e');
    }
  }

  void _resumeAllParticipantsAudio() async {
    try {
      Logger.print('Resuming audio from all remote participants');

      for (final participant in _room!.remoteParticipants.values) {
        final audioTrackPublication = participant.audioTrackPublications.firstOrNull;
        if (audioTrackPublication == null) {
          continue;
        }

        Logger.print('Resuming audio from participant: ${participant.identity}');
        audioTrackPublication.enable();
      }

      final localAudioTrack = _participant?.audioTrackPublications.firstOrNull?.track;
      if (localAudioTrack != null) {
        await localAudioTrack.enable();
      }
    } catch (e) {
      Logger.print('Error resuming participants audio: $e');
    }
  }

  Key _keyForButtonType(String type) => ValueKey('button_$type');

  List<Widget> _buildButtonRowChildren() {
    List<Widget> buttons = [];

    if (widget.currentCallState == CallState.beCalled ||
        (widget.currentCallState == CallState.connecting && _pickuping)) {
      buttons = [
        LiveButton.reject(
          key: _keyForButtonType('reject'),
          onTap: widget.onReject,
        ),
        LiveButton.pickUp(
          key: _keyForButtonType('pickup'),
          loading: _pickuping,
          onTap: () {
            setState(() => _pickuping = true);
            widget.onPickUp?.call();
          },
        ),
      ];
    } else if (widget.currentCallState == CallState.call || widget.currentCallState == CallState.connecting) {
      buttons = [
        LiveButton.microphone(
          key: _keyForButtonType('microphone'),
          on: _enabledMicrophone,
          onTap: () {
            Logger.print('controls onTapMicrophone');
            _toggleAudio();
          },
        ),
        LiveButton.cancel(
          key: _keyForButtonType('cancel'),
          onTap: () {
            Logger.print('controls onTapCancel');
            widget.onCancel?.call();
          },
        ),
        if (Hardware.instance.canSwitchSpeakerphone)
          LiveButton.speaker(
            key: _keyForButtonType('speaker'),
            on: _enabledSpeaker,
            onTap: () {
              Logger.print('controls onTapSpeaker');
              _toggleSpeaker();
            },
          ),
      ];
    } else if (widget.currentCallState == CallState.calling) {
      buttons = [
        LiveButton.microphone(
          key: _keyForButtonType('microphone'),
          on: _enabledMicrophone,
          onTap: () {
            Logger.print('controls onTapMicrophone');
            _toggleAudio();
          },
        ),
        LiveButton.hungUp(
          key: _keyForButtonType('hungup'),
          onTap: () {
            Logger.print('controls onTapHungUp');
            widget.onHangUp?.call();
          },
        ),
        LiveButton.speaker(
          key: _keyForButtonType('speaker'),
          on: _enabledSpeaker,
          onTap: () {
            Logger.print('controls onTapSpeaker');
            _toggleSpeaker();
          },
        ),
      ];
    }

    return buttons.map((button) {
      return _AnimatedButtonAppearance(key: button.key, child: button);
    }).toList();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 16.w,
              top: 7.h,
              child: ImageRes.liveClose.toImage
                ..width = 30.w
                ..height = 30.h
                ..onTap = widget.onMinimize,
            ),
            if (null != _participant)
              Positioned(
                right: 16.w,
                top: 7.h,
                child: Visibility(
                  visible: isVideo,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (_participant!.isCameraEnabled() ? ImageRes.liveCameraOff : ImageRes.liveCameraOn).toImage
                        ..width = 30.w
                        ..height = 30.h
                        ..onTap = (_participant!.isCameraEnabled() ? _disableVideo : _enableVideo),
                      16.horizontalSpace,
                      ImageRes.liveSwitchCamera.toImage
                        ..width = 30.w
                        ..height = 30.h
                        ..onTap = _toggleCamera,
                    ],
                  ),
                ),
              ),
            if (null != widget.userInfo)
              Positioned(
                top: 166.h,
                width: 1.sw,
                child: _userInfoView,
              ),
            Positioned(
              bottom: 32.h,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: Builder(
                    key: ValueKey<int>(_buildButtonRowChildren().length),
                    builder: (context) {
                      final children = _buildButtonRowChildren();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: children,
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 156.h,
              width: 1.sw,
              child: Center(child: _videoCallingDurationView),
            ),
          ],
        ),
      );

  bool get isVideo => widget.callType == CallType.video;

  bool get isCalling => widget.currentCallState == CallState.calling;

  Widget get _videoCallingDurationView => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: (isVideo && isCalling)
            ? (widget.callingDurationText.toText..style = Styles.ts_FFFFFF_opacity70_17sp)
            : const SizedBox.shrink(),
      );

  Widget get _userInfoView {
    String text;
    if (widget.currentCallState == CallState.call) {
      text = isVideo ? StrRes.waitingVideoCallHint : StrRes.waitingVoiceCallHint;
    } else if (widget.currentCallState == CallState.beCalled) {
      text = isVideo ? StrRes.invitedVideoCallHint : StrRes.invitedVoiceCallHint;
    } else if (widget.currentCallState == CallState.connecting) {
      text = StrRes.connecting;
    } else if (widget.currentCallState == CallState.beRejected) {
      text = StrRes.rejectCall;
    } else if (widget.currentCallState == CallState.beCanceled) {
      text = StrRes.cancel;
    } else if (widget.currentCallState == CallState.beHangup || widget.currentCallState == CallState.hangup) {
      text = StrRes.hangUp;
    } else if (widget.currentCallState == CallState.timeout) {
      text = StrRes.callTimeout;
    } else {
      text = isVideo ? '' : widget.callingDurationText;
    }

    String? nickname = IMUtils.emptyStrToNull(widget.userInfo!.remark) ?? widget.userInfo!.nickname;
    String? faceURL = widget.userInfo!.faceURL;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: (isVideo && isCalling)
          ? const SizedBox.shrink()
          : Column(
              key: const ValueKey('userInfoColumn'),
              children: [
                AvatarView(width: 70.w, height: 70.h, text: nickname, url: faceURL),
                10.verticalSpace,
                (nickname ?? '').toText
                  ..style = TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                10.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: (text.toText
                    ..style = TextStyle(color: Colors.white, fontSize: 17.sp)
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis),
                ),
                if (widget.currentCallState == CallState.call) const LiveLoadingView(),
              ],
            ),
    );
  }
}

class _AnimatedButtonAppearance extends StatelessWidget {
  final Widget child;
  const _AnimatedButtonAppearance({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Transform.scale(
          scale: (0.8 + 0.2 * value).clamp(0.8, 1.0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}
