import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/src/widgets/live_button.dart';
import 'package:synchronized/synchronized.dart';

import '../../../live_client.dart';
import 'package:openim_live/src/utils/live_utils.dart';

class ControlsView extends StatefulWidget {
  const ControlsView({
    super.key,
    this.child,
    this.currentCallState = CallState.call,
    this.callType = CallType.video,
    this.room,
    this.onMinimize,
    this.onCallingDuration,
    this.callingDurationText = '00:00',
    this.onEnabledMicrophone,
    this.onEnabledSpeaker,
    this.onCancel,
    this.onHangUp,
    this.onPickUp,
    this.onReject,
  });
  final Widget? Function(CallState state)? child;
  final Room? room;
  final CallState currentCallState;
  final CallType callType;
  final Function()? onMinimize;
  final Function(int duration)? onCallingDuration;
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

  bool _enabledSpeaker = true;

  final _lockAudio = Lock();
  final _lockSpeaker = Lock();

  bool _pickuping = false;

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
    Logger.print('Group ControlsView initState: ${widget.currentCallState}');

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
          'Group ControlsView didUpdateWidget, current call state: ${widget.currentCallState}, was be interruption $_wasBeInterruption');

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

  @override
  void deactivate() {
    super.deactivate();
  }

  void _roomDidUpdate(Room room) {
    _room ??= room;
    if (room.localParticipant != null && _participant == null) {
      _participant = room.localParticipant;
      _participant?.addListener(_onChange);
    }
  }

  void _onChange() {
    // trigger refresh
    setState(() {});
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _setAudioOutputDevice();
  }

  Future _setAudioOutputDevice() async {
    final outs = await Hardware.instance.audioOutputs();

    // If there is a Bluetooth headset, when the speaker is turned on, the Bluetooth headset is not recognized.
    if (lkPlatformIs(PlatformType.android)) {
      if (_enabledSpeaker) {
        await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
      } else {
        await rtc.Helper.setSpeakerphoneOn(false);
      }
    }

    final dev = Hardware.instance.selectedAudioOutput;
    Logger.print('outs: $outs - selected: $dev');
  }

  Future _toggleAudio() async {
    await _lockAudio.synchronized(() async {
      _enabledMicrophone = !_enabledMicrophone;
      widget.onEnabledMicrophone?.call(_enabledMicrophone);
      try {
        if (_enabledMicrophone) {
          await _enableAudio();
        } else {
          await _disableAudio();
        }
      } catch (e) {
        Logger.print('toggle audio error: ${e.toString()}', fileName: 'controls.dart');
      }
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
    await _participant?.setCameraEnabled(true);
  }

  bool _isSwitchingCamera = false;

  void _toggleCamera() async {
    final track = _participant?.videoTrackPublications.firstOrNull?.track;
    if (track == null || _isSwitchingCamera) return;

    _isSwitchingCamera = true;

    // Toggle position tracking
    final oldPosition = position;
    final newPosition = oldPosition == CameraPosition.front ? CameraPosition.back : CameraPosition.front;

    position = newPosition;
    Logger.print('[toggleCamera] Switching to: $newPosition');

    // NOTE: Do NOT update CameraPositionTracker here.
    // Wait until switchCamera completes to avoid mirroring the OLD video feed with the NEW mirror mode.

    try {
      await rtc.Helper.switchCamera(track.mediaStreamTrack);

      // Update tracker AFTER switch confirms
      CameraPositionTracker.currentPosition.value = newPosition;

      // Force rebuild to update mirror mode
      setState(() {});
    } catch (e) {
      Logger.print('[toggleCamera] failed: $e');
      // Revert on failure
      position = oldPosition;
      // No need to revert Tracker as we haven't updated it yet
    } finally {
      _isSwitchingCamera = false;
    }
  }

  // Setup audio interruption handling for cellular calls
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

      // Listen to audio interruptions (e.g., incoming cellular calls)
      _audioInterruptionSub = session.interruptionEventStream.listen((event) {
        if (_participant == null) {
          return;
        }

        if (Platform.isIOS || event.type == AudioInterruptionType.unknown) {
          return;
        }

        if (event.begin) {
          // Interruption began (cellular call incoming)
          Logger.print('Audio interrupted by cellular call - muting LiveKit audio');

          // Save current audio states
          _wasPlayingBeforeInterruption = _participant!.isMicrophoneEnabled();

          // Mute microphone input
          if (_wasPlayingBeforeInterruption) {
            _toggleAudio(); // Mute microphone without playing sound
          }

          // Pause audio output from all participants
          _pauseAllParticipantsAudio();
        } else {
          // Interruption ended (cellular call ended)
          Logger.print('Audio interruption ended - restoring LiveKit audio');
          if (!_wasBeInterruption) return;

          // Restore microphone if it was enabled before
          if (_wasPlayingBeforeInterruption && !_participant!.isMicrophoneEnabled()) {
            _toggleAudio(); // Unmute microphone without playing sound
          }

          // Resume audio output from all participants
          _resumeAllParticipantsAudio();

          // Reset state
          _wasBeInterruption = false;
          _wasPlayingBeforeInterruption = false;
        }
      });
      await session.setActive(true, androidWillPauseWhenDucked: true);
    } catch (e) {
      Logger.print('Failed to setup audio interruption handling: $e');
    }
  }

  // Pause audio output from all remote participants during cellular call
  void _pauseAllParticipantsAudio() async {
    try {
      Logger.print('Pausing audio from all remote participants');

      // Pause audio from all remote participants
      for (final participant in _room!.remoteParticipants.values) {
        final audioTrackPublication = participant.audioTrackPublications.firstOrNull;
        if (audioTrackPublication == null) {
          Logger.print('No audio track for participant: ${participant.identity}, metadata: ${participant.metadata}');
          continue;
        }

        Logger.print('Pausing audio from participant: ${participant.identity}');
        audioTrackPublication.disable();
      }

      // Also pause local audio playback if needed
      final localAudioTrack = _participant?.audioTrackPublications.firstOrNull?.track;
      if (localAudioTrack != null) {
        await localAudioTrack.disable();
      }
    } catch (e) {
      Logger.print('Error pausing participants audio: $e');
    }
  }

  // Resume audio output from all remote participants after cellular call
  void _resumeAllParticipantsAudio() async {
    try {
      Logger.print('Resuming audio from all remote participants');

      // Resume audio from all remote participants
      for (final participant in _room!.remoteParticipants.values) {
        final audioTrackPublication = participant.audioTrackPublications.firstOrNull;
        if (audioTrackPublication == null) {
          continue;
        }

        Logger.print('Resuming audio from participant: ${participant.identity}');
        audioTrackPublication.enable();
      }

      // Resume local audio playback if needed
      final localAudioTrack = _participant?.audioTrackPublications.firstOrNull?.track;
      if (localAudioTrack != null) {
        await localAudioTrack.enable();
      }
    } catch (e) {
      Logger.print('Error resuming participants audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 45.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ImageRes.liveClose.toImage
                    ..width = 30.w
                    ..height = 30.h
                    ..onTap = widget.onMinimize,
                ),
                Align(
                  alignment: Alignment.center,
                  child: _videoCallingDurationView,
                ),
                if (null != _participant)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Visibility(
                      visible: isVideo,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          (_participant!.isCameraEnabled() ? ImageRes.liveCameraOn : ImageRes.liveCameraOff).toImage
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
              ],
            ),
          ),
          Expanded(child: widget.child?.call(widget.currentCallState) ?? const SizedBox()),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              height: 120.h,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
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
          32.verticalSpace,
        ],
      ),
    );
  }

  Key _keyForButtonType(String type) => ValueKey('group_button_$type');

  List<Widget> _buildButtonRowChildren() {
    List<Widget> buttons = [];

    if (widget.currentCallState == CallState.call) {
      buttons = [
        LiveButton.microphone(
          key: _keyForButtonType('microphone'),
          on: _enabledMicrophone,
          onTap: _toggleAudio,
        ),
        LiveButton.cancel(
          key: _keyForButtonType('cancel'),
          onTap: widget.onCancel,
        ),
        LiveButton.speaker(
          key: _keyForButtonType('speaker'),
          on: _enabledSpeaker,
          onTap: Hardware.instance.canSwitchSpeakerphone ? _toggleSpeaker : null,
        ),
      ];
    } else if (widget.currentCallState == CallState.beCalled) {
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
    } else {
      buttons = [
        LiveButton.microphone(
          key: _keyForButtonType('microphone'),
          on: _enabledMicrophone,
          onTap: _toggleAudio,
        ),
        LiveButton.hungUp(
          key: _keyForButtonType('hungup'),
          onTap: widget.onHangUp,
        ),
        LiveButton.speaker(
          key: _keyForButtonType('speaker'),
          on: _enabledSpeaker,
          onTap: _toggleSpeaker,
        ),
      ];
    }

    return buttons.map((button) {
      return _AnimatedButtonAppearance(key: button.key, child: button);
    }).toList();
  }

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
        child: isCalling
            ? (widget.callingDurationText.toText..style = Styles.ts_FFFFFF_opacity70_17sp)
            : const SizedBox.shrink(),
      );
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
